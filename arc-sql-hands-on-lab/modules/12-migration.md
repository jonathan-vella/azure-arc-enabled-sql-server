# Module 12: Migration assessment and portal migration

Version: v1.2026.09
Last updated: 2026-09-30

Review the migration assessment that SQL Server enabled by Azure Arc generates for your instance, then walk through the
portal migration flow to a SQL Server on Azure VM without creating billable resources unless you choose to.

## Prerequisites

- Completed [Module 3](03-sql-extension.md).
- The `Microsoft.AzureArcData/sqlServerInstances/getTelemetry/` permission to view assessment reports. The
  built-in Azure Hybrid Database Administrator - Read Only Service role includes it.
- Outbound access to `telemetry.swedencentral.arcdataservices.com`. [Module 1](01-network-validation.md) tests it.

## Part A: Review the assessment

The assessment is free, on by default, and refreshes every Sunday at 23:00 local server time. This part creates no
Azure resources.

1. In the Azure portal, open your **SQL Server - Azure Arc** resource.
1. Under **Migration**, select **Assessments**, then select **Run assessment** to refresh the report.
1. Note the **Recommended Target** banner and the readiness (**Ready**, **Not ready**, **Unknown**) for each target.
1. Select a readiness link, then open the **Compatibility** tab and read one finding and its remediation guidance.
1. Open the **SKU Recommendation** tab and note the monthly cost estimate.
1. Select **Assessment settings**. Compare the **Modernize to PaaS** and **Minimize cost** strategies.

> [!NOTE]
> Assessments support SQL Server 2014 or later on Windows. Failover cluster instances and Linux are not supported.

## Part B: Explore the migration flow (no resources created)

1. Under **Migration**, select **Database migration**.
1. Review the four tiles: **Assess source instance**, **Select target**, **Migrate data**, and **Monitor and cutover**.
1. Select **Select target**, then choose **No, I want to create a new target**. Read the settings on the
   **Create SQL Server VM** pane and close the pane without creating anything.

## Part C: Migrate a database (optional, billable)

> [!WARNING]
> This part creates resources that bill until you delete them: a SQL Server on Azure VM, a storage account for backups,
> and their disks and network resources. Continue only if you accept those charges.

Before you start, confirm:

- You accept the cost shown in the assessment's **SKU Recommendation** tab.
- You use a new resource group named `arcsql-lab-migration-rg` so cleanup is one command.

Follow the current
[Migration to SQL Server on Azure VMs](https://learn.microsoft.com/sql/sql-server/azure-arc/migrate-to-sql-server-on-azure-vms?view=sql-server-ver17)
steps, which have four stages:

1. **Prepare the source.** Take a full backup of a test database and upload it to a blob container in a new storage
   account, as the preparation article describes.
1. **Select target.** Create a small SQL Server VM in `arcsql-lab-migration-rg`.
1. **Migrate data.** Choose **Migrate using backup and restore**, select the database, and point to the blob container.
1. **Monitor and cutover.** Wait for **Ready for cutover**, then select **Cutover**.

Verify that the database exists on the target VM, then remove everything you created:

```powershell
Remove-AzResourceGroup -Name "arcsql-lab-migration-rg" -Force
```

`Cleanup-Lab.ps1` does not remove this resource group.

## Validate

- The assessment shows a recommended target and a readiness state for each target.
- You can name one compatibility finding and its remediation.
- If you ran Part C, the migrated database is online on the target VM and `arcsql-lab-migration-rg` is deleted.

## Related resources

- [SQL Server migration in Azure Arc overview](https://learn.microsoft.com/sql/sql-server/azure-arc/migration-overview?view=sql-server-ver17)
- [Assess migration readiness](https://learn.microsoft.com/sql/sql-server/azure-arc/migration-assessment?view=sql-server-ver17)
- [Troubleshooting](../TROUBLESHOOTING.md)

Back to the [module index](../README.md#modules).
