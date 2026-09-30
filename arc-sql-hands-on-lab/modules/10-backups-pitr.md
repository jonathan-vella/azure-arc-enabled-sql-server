# Module 10: Automated backups and point-in-time restore

Version: v1.2026.09
Last updated: 2026-09-30

⚠️ This feature is in preview and is subject to the [supplemental terms of
use](https://azure.microsoft.com/support/legal/preview-supplemental-terms/). In this module, you
configure automated backups for a lab SQL Server enabled by Azure Arc instance and restore a
database to a new copy at a selected point in time.

## Prerequisites

- A lab SQL Server enabled by Azure Arc instance in `arcsql-lab-arc-rg`
- SQL Server 2022 or later for the lab steps. The backup and restore feature supports SQL Server
  2014 and later.
- A license with Software Assurance, a SQL Server subscription, or PAYG. The feature isn't
  available with `LicenseOnly`.
- At least one user database in the `FULL` recovery model
- A writable SQL Server default backup location
- Azure extension for SQL Server version `1.1.2504.99` or later for automatic permission grants.
  The current auto-upgrade target is `1.1.3518.465`.

> [!IMPORTANT]
> Automated backups and point-in-time restore are available only for licenses with Software
> Assurance, a SQL Server subscription, or PAYG.

## Steps

### 1. Review feature limits and prepare the instance

Automated backups are disabled by default. This preview has a few limits:

- Backup to URL isn't available.
- Databases must use the `FULL` recovery model.
- Automated backups aren't supported on failover cluster instances.
- Automated backups aren't supported on an instance that hosts an availability group replica.
- Dropping a database deletes its automated backups immediately.

Check the recovery model and the default backup path before you continue.

```sql
SELECT
    name,
    recovery_model_desc
FROM sys.databases
WHERE database_id > 4;

SELECT SERVERPROPERTY('InstanceDefaultBackupPath') AS DefaultBackupPath;
```

If a database isn't in the `FULL` recovery model, change it now.

```sql
ALTER DATABASE [YourDatabaseName] SET RECOVERY FULL;
```

Current extension builds grant backup permissions automatically. If your extension version is older
than `1.1.2504.99`, grant the required SQL permissions before you configure the policy.

```sql
USE master;
GO
CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS WITH DEFAULT_DATABASE = [master];
GO
ALTER SERVER ROLE [dbcreator] ADD MEMBER [NT AUTHORITY\SYSTEM];
GO
```

Run the next block in `master`, `model`, `msdb`, and each user database except `tempdb`.

```sql
CREATE USER [NT AUTHORITY\SYSTEM] FOR LOGIN [NT AUTHORITY\SYSTEM];
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [NT AUTHORITY\SYSTEM];
GO
```

### 2. Install the Azure CLI extension and set lab variables

The backup and restore commands are provided by the `arcdata` Azure CLI extension.

```powershell
az extension add --name arcdata

$resourceGroup = "arcsql-lab-arc-rg"
$sqlServerArcName = "<arc-enabled-sql-server-name>"
$databaseName = "<database-name>"
```

For a named SQL Server instance, use the Arc SQL resource name in the
`ServerName_InstanceName` format.

### 3. Configure the instance-level backup policy

In the Azure portal:

1. Open **Azure Arc** > **SQL Server instances** and select your instance.
2. Select **Backups**.
3. Select **Configure policies**.
4. Set **Retention days** to `14`.
5. Set **Full backup** to every `7` days.
6. Set **Differential backup** to every `24` hours.
7. Set **Transaction log backup** to every `5` minutes.
8. Select **Apply**.

To apply the same policy from the CLI, run:

```powershell
az sql server-arc backups-policy set `
    --name $sqlServerArcName `
    --resource-group $resourceGroup `
    --retention-days 14 `
    --full-backup-days 7 `
    --diff-backup-hours 24 `
    --tlog-backup-mins 5
```

If you want the built-in default schedule instead, use `--default-policy`.

```powershell
az sql server-arc backups-policy set `
    --name $sqlServerArcName `
    --resource-group $resourceGroup `
    --default-policy
```

### 4. Configure a database-level override

Use a database-level policy when one database needs a different retention period or backup
frequency.

In the Azure portal:

1. Open the same SQL Server instance.
2. Select the database that needs its own schedule.
3. Under **Data management**, select **Backup (preview)**.
4. Select **Configure policies**.
5. Set **Retention days** to `21`.
6. Set **Full backup** to every `1` day.
7. Set **Differential backup** to every `12` hours.
8. Set **Transaction log backup** to every `10` minutes.
9. Select **Apply**.

To configure the same override from the CLI, run:

```powershell
az sql db-arc backups-policy set `
    --name $databaseName `
    --server $sqlServerArcName `
    --resource-group $resourceGroup `
    --retention-days 21 `
    --full-backup-days 1 `
    --diff-backup-hours 12 `
    --tlog-backup-mins 10
```

### 5. Validate that backups are running

Review the configured policies first.

```powershell
az sql server-arc backups-policy show `
    --name $sqlServerArcName `
    --resource-group $resourceGroup

az sql db-arc backups-policy show `
    --name $databaseName `
    --server $sqlServerArcName `
    --resource-group $resourceGroup
```

Check the SQL Server backup folder on the lab server.

```powershell
$backupPath = "C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup"

Get-ChildItem -Path $backupPath -Recurse |
    Where-Object { $_.Extension -in '.bak', '.trn', '.dif' } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 20 Name, Length, LastWriteTime
```

Confirm that SQL Server recorded the native backups in `msdb`.

```sql
SELECT TOP (20)
    bs.database_name,
    bs.backup_start_date,
    bs.backup_finish_date,
    CASE bs.type
        WHEN 'D' THEN 'Full'
        WHEN 'I' THEN 'Differential'
        WHEN 'L' THEN 'Transaction Log'
    END AS backup_type,
    bs.backup_size / 1024 / 1024 AS backup_size_mb,
    bmf.physical_device_name
FROM msdb.dbo.backupset AS bs
INNER JOIN msdb.dbo.backupmediafamily AS bmf
    ON bs.media_set_id = bmf.media_set_id
ORDER BY bs.backup_start_date DESC;
```

The built-in process also backs up `master`, `model`, and `msdb`. System databases receive full
backups only.

### 6. Restore a database to a point in time

Wait until at least one full backup exists for the source database. The restore creates a new
database on the same instance. It doesn't overwrite the source database.

In the Azure portal:

1. Open **Azure Arc** > **SQL Server instances** and select the instance.
2. Select **Backups**.
3. Find the source database and select **Restore**.
4. Choose the restore time inside the available retention window.
5. Enter a new database name.
6. Review the deployment and select **Create**.

To run the same restore from the CLI, use the current command syntax:

```powershell
$sourceDatabaseName = "<source-database-name>"
$targetDatabaseName = "${sourceDatabaseName}_PITR_$(Get-Date -Format 'yyyyMMddHHmm')"
$restorePointInTime = "2026-09-30T10:30:00Z"

az sql db-arc restore `
    --dest-name $targetDatabaseName `
    --resource-group $resourceGroup `
    --name $sourceDatabaseName `
    --server $sqlServerArcName `
    --time $restorePointInTime
```

Validate the restored database in SQL Server.

```sql
SELECT
    name,
    create_date,
    state_desc
FROM sys.databases
WHERE name LIKE '%PITR%';
```

### 7. Disable or remove backup policies

Set `--retention-days 0` to stop automated backups but keep the policy definition.

```powershell
az sql server-arc backups-policy set `
    --name $sqlServerArcName `
    --resource-group $resourceGroup `
    --retention-days 0
```

Delete the instance-level policy only when you want to remove the schedule entirely.

```powershell
az sql server-arc backups-policy delete `
    --name $sqlServerArcName `
    --resource-group $resourceGroup
```

Delete the database-level policy to return that database to the instance-level schedule.

```powershell
az sql db-arc backups-policy delete `
    --name $databaseName `
    --server $sqlServerArcName `
    --resource-group $resourceGroup
```

## Validate

- The instance shows a configured backup policy in the Azure portal or in `az sql server-arc
  backups-policy show`.
- Any database override appears in `az sql db-arc backups-policy show`.
- Backup files are written to the SQL Server default backup path.
- `msdb.dbo.backupset` shows full, differential, or transaction log backups for the database.
- The restore operation creates a new database and leaves the source database unchanged.

## Troubleshooting

- If backups don't start, verify that `--retention-days` is greater than `0`, the database uses the
  `FULL` recovery model, and the backup account can write to the default backup path.
- If a database is skipped, confirm that the instance isn't an FCI and doesn't host an
  availability group replica.
- If point-in-time restore fails, confirm that the database has a complete backup chain inside the
  current retention window.
- For general lab issues, see [Troubleshooting](../TROUBLESHOOTING.md).

Back to the [module index](../README.md#modules).
