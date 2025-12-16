# Quick Start Guide

Version: v1.2025.12
Last updated: 2025-12-16

This quick start guide provides a condensed version of the lab for experienced users who want to quickly complete the exercises.

> [!NOTE]
> This guide includes both **core modules** and **optional advanced modules** (preview features).
> Skip optional modules if time is limited.

## Prerequisites Checklist

- ☐ Azure subscription with Owner permissions
- ☐ Windows Server 2022+ with SQL Server 2017+ installed and licensed
- ☐ PowerShell 7.0+
- ☐ Azure PowerShell modules installed
- ☐ Network connectivity to Azure (HTTPS/443)

---

## Core Modules (Required)

## Quick Setup (15 minutes)

### 1. Deploy Infrastructure

```powershell
# Clone repository
git clone https://github.com/microsoft/azure-arc-enabled-sql-server.git
cd azure-arc-enabled-sql-server/arc-sql-hands-on-lab

# Connect to Azure and deploy
Connect-AzAccount
Set-AzContext -SubscriptionId "<your-subscription-id>"

# Deploy Bicep template
cd bicep
.\deploy.ps1 -BaseName "arcsql-lab" -Environment "dev"
```

### 2. Validate Network Connectivity

```powershell
cd ../scripts
.\Test-ArcConnectivity.ps1 -Region "swedencentral" -Verbose
```

### 3. Onboard to Azure Arc

1. Generate script in Azure portal: **Azure Arc > Servers > Add > Generate script**
2. Configure: `arcsql-lab-arc-rg`, `Sweden Central`, `Windows`
3. Run on-premises server:
   ```powershell
   .\OnboardingScript.ps1
   ```

### 4. Verify SQL Extension & Discovery

- Check: **Azure Arc > Infrastructure > Servers > [YourServer] > Extensions**
- Verify: **Azure Arc > Data services > SQL Server instances**

### 5. Configure License Type

```powershell
# Set to PAYG first
Update-AzSqlInstanceArc -ResourceGroupName "arcsql-lab-arc-rg" `
    -Name "<sql-instance-name>" -LicenseType "PAYG"

# Then change to Paid (Software Assurance)
Update-AzSqlInstanceArc -ResourceGroupName "arcsql-lab-arc-rg" `
    -Name "<sql-instance-name>" -LicenseType "Paid"
```

### 6. Enable Best Practices Assessment

Portal: **SQL Server instance > Best practices assessment > Configure**
- Select Log Analytics workspace: `arcsql-lab-law-*`
- Schedule: Weekly, Sunday 12:00 AM
- Click **Enable**
- Click **Run assessment now**

### 7. Deploy Azure Policy for BPA at Scale

1. Navigate to: **Azure Policy > Definitions**
2. Search: "Configure Arc-enabled Servers with SQL Server extension"
3. Click **Assign**
4. Configure:
   - Scope: Your subscription
   - Parameters: Enable = true, Select Log Analytics workspace
   - Remediation: Create task, System-assigned MI
5. Click **Create**

### 8. Cleanup

```powershell
cd scripts
.\Cleanup-Lab.ps1 -SubscriptionId "<your-subscription-id>" -BaseName "arcsql-lab"
```

---

## Optional Advanced Modules (Preview Features)

> [!WARNING]
> **Preview features**: These modules use preview features subject to
> [Azure Preview Terms](https://azure.microsoft.com/support/legal/preview-supplemental-terms/).
> Skip if time is limited.

---

### 9. Configure Automatic Updates (Optional - 10 min)

**Via Portal:**
1. Navigate to: **Arc Server > Operations > SQL Server Configuration**
2. Under **Update** section:
   - Enable automatic updates
   - Set maintenance schedule (e.g., Sunday, 02:00)
3. Click **Save**

**Via Azure CLI:**

```powershell
# Install Az.Maintenance module
Install-Module -Name Az.Maintenance -AllowClobber -Force

# Create maintenance configuration
$resourceGroup = "arcsql-lab-arc-rg"
$serverName = "<your-arc-server-name>"

$maintenanceConfig = New-AzMaintenanceConfiguration `
    -ResourceGroupName $resourceGroup `
    -Name "SQL-Sunday-Updates" `
    -Location "swedencentral" `
    -MaintenanceScope "InGuestPatch" `
    -StartDateTime "2024-11-17 02:00" `
    -Duration "03:00" `
    -RecurEvery "Week Sunday"

# Assign to Arc server
New-AzConfigurationAssignment `
    -ResourceGroupName $resourceGroup `
    -Location "swedencentral" `
    -ResourceName $serverName `
    -ResourceType "Microsoft.HybridCompute/machines" `
    -ProviderName "Microsoft.Maintenance" `
    -ConfigurationAssignmentName "SQL-Updates-Assignment" `
    -MaintenanceConfigurationId $maintenanceConfig.Id
```

---

### 10. Advanced SQL Monitoring (Optional - 20 min)

**Via Portal:**
1. Navigate to: **SQL Server Arc > Performance Dashboard (preview)**
2. Click **Configure**
3. Toggle monitoring to **On**
4. Click **Apply settings**
5. Explore dashboards: CPU, Memory, Storage I/O, Active Sessions

**Via Azure CLI:**

```powershell
$subscriptionId = "<your-subscription-id>"
$resourceGroup = "arcsql-lab-arc-rg"
$sqlServerArcName = "<your-sql-server-arc-name>"

# Enable monitoring
az resource update `
    --ids "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.AzureArcData/SqlServerInstances/$sqlServerArcName" `
    --set 'properties.monitoring.enabled=true' `
    --api-version 2023-09-01-preview
```

---

### 11. Automated Backups & Point-in-Time Restore (Optional - 40 min)

#### Part A: Configure Instance-Level Backups

**Via Portal:**
1. Navigate to: **SQL Server Arc > Backups**
2. Click **Configure policies**
3. Set:
   - Retention days: 14
   - Full backup: Every 7 days
   - Differential: Every 24 hours
   - Transaction log: Every 5 minutes
4. Click **Apply**

**Via Azure CLI:**

```powershell
$resourceGroup = "arcsql-lab-arc-rg"
$sqlServerArcName = "<your-sql-server-arc-name>"

# Configure backup policy
az sql server-arc backups-policy create `
    --name $sqlServerArcName `
    --resource-group $resourceGroup `
    --retention-days 14 `
    --full-backup-days 7 `
    --diff-backup-hours 24 `
    --tlog-backup-mins 5

# View policy
az sql server-arc backups-policy show `
    --name $sqlServerArcName `
    --resource-group $resourceGroup
```

#### Part B: Configure Database-Level Backups (Optional)

**Via Portal:**
1. Select database under SQL Server instance
2. Go to: **Data management > Backup (preview)**
3. Click **Configure database backup policies**
4. Set custom retention and schedules
5. Click **Apply**

**Via Azure CLI:**

```powershell
$databaseName = "<database-name>"

# Configure database-level policy
az sql db-arc backups-policy create `
    --name $databaseName `
    --server $sqlServerArcName `
    --resource-group $resourceGroup `
    --retention-days 21 `
    --full-backup-days 1 `
    --diff-backup-hours 12 `
    --tlog-backup-mins 10
```

#### Part C: Verify Backups

```powershell
# Check backup files on SQL Server host
$backupPath = "C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup"
Get-ChildItem -Path $backupPath -Recurse | 
    Where-Object {$_.Extension -in '.bak','.trn','.dif'} |
    Select-Object Name, Length, LastWriteTime |
    Sort-Object LastWriteTime -Descending
```

```sql
-- Query backup history in SQL Server
SELECT TOP 20
    bs.database_name,
    bs.backup_start_date,
    CASE bs.type
        WHEN 'D' THEN 'Full'
        WHEN 'I' THEN 'Differential'
        WHEN 'L' THEN 'Transaction Log'
    END AS BackupType,
    bs.backup_size / 1024 / 1024 AS BackupSizeMB
FROM msdb.dbo.backupset bs
ORDER BY bs.backup_start_date DESC;
```

#### Part D: Point-in-Time Restore

**Via Portal:**
1. Navigate to: **SQL Server Arc > Backups**
2. Find database in list, click **Restore**
3. Select point-in-time within retention window
4. Enter new database name (e.g., `MyDB_PITR_20241110`)
5. Click **Create**

**Via Azure CLI:**

```powershell
$sourceDatabaseName = "<source-database>"
$targetDatabaseName = "${sourceDatabaseName}_PITR_$(Get-Date -Format 'yyyyMMddHHmm')"
$restorePointInTime = "2024-11-10T14:30:00Z"

# Initiate restore
az sql db-arc restore `
    --name $targetDatabaseName `
    --server $sqlServerArcName `
    --resource-group $resourceGroup `
    --source-database $sourceDatabaseName `
    --restore-point-in-time $restorePointInTime
```

---

### 12. Final Cleanup

```powershell
cd scripts
.\Cleanup-Lab.ps1 -SubscriptionId "<your-subscription-id>" -BaseName "arcsql-lab"
```

---

## Key Commands Reference

```powershell
# Check Arc agent status
azcmagent show

# List Arc SQL Server instances
Get-AzSqlInstanceArc -ResourceGroupName "arcsql-lab-arc-rg"

# Update license type
Update-AzSqlInstanceArc -ResourceGroupName "arcsql-lab-arc-rg" `
    -Name "<name>" -LicenseType "Paid"

# Check extension status
Get-AzConnectedMachineExtension -ResourceGroupName "arcsql-lab-arc-rg" `
    -MachineName "<server-name>"
```

## Troubleshooting Quick Tips

| Issue | Solution |
|-------|----------|
| Agent install fails | Check `Test-ArcConnectivity.ps1` output |
| SQL extension not deploying | Wait 30 mins or manually deploy |
| BPA can't enable | Verify license type is Paid/PAYG |
| Policy not working | Check MI permissions on Log Analytics |

## Time Estimates

**Core Modules:**
- Infrastructure deployment: 5 min
- Arc onboarding: 5 min
- SQL discovery: 5 min
- License configuration: 5 min
- BPA setup & run: 15 min
- Azure Policy deployment: 10 min
- Cleanup: 5 min

**Core Total: ~50 minutes** (excluding assessment run time)

**Optional Advanced Modules:**
- Automatic updates configuration: 10 min
- Advanced SQL monitoring: 20 min
- Automated backups & PITR: 40 min

**Optional Total: +70 minutes**

**Complete Lab: ~2 hours** (with all optional modules)

## Next Steps

For detailed instructions and explanations, see the [full lab guide](README.md).
