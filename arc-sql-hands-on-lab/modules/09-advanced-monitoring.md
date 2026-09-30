# Module 9: Configure advanced monitoring

Version: v1.2026.09
Last updated: 2026-09-30

⚠️ This feature is in preview and is subject to the
[supplemental terms of use](https://azure.microsoft.com/support/legal/preview-supplemental-terms/).
Enable the performance dashboard for the SQL Server enabled by Azure Arc resource and review the
DMV datasets that Azure collects. Use the dashboard to inspect CPU, memory, storage I/O, sessions,
and waits.

## Prerequisites

- Review the [lab prerequisites](../PREREQUISITES.md).
- Use the lab server in `arcsql-lab-arc-rg`. The lab baseline is Windows Server 2022 with SQL
  Server 2022. Microsoft Learn documents support for Windows Server 2016 or later and SQL Server
  2016 SP1 or later for this preview.
- Use SQL Server Standard or Enterprise edition.
- Use Azure Extension for SQL Server version `1.1.2504.99` or later.
- Allow outbound HTTPS to `*.swedencentral.arcdataservices.com`. For other regions, allow
  `*.<region>.arcdataservices.com`.
- To view the dashboard, use an Azure role that includes
  `Microsoft.AzureArcData/sqlServerInstances/getTelemetry/`. Microsoft Learn documents Azure Hybrid
  Database Administrator - Read Only Service Role for this permission.

> [!IMPORTANT]
> Monitoring requires **Pay-as-you-go** or **License with Software Assurance**. If you change the
> license type to enable monitoring, review the billing impact before you save the change.

## Steps

### 1. Check the extension version

Confirm that the Azure Extension for SQL Server is installed and at a supported version:

```powershell
Get-AzConnectedMachineExtension `
  -ResourceGroupName "arcsql-lab-arc-rg" `
  -MachineName "<arc-server-name>" `
  -Name "WindowsAgent.SqlServer" |
  Select-Object Name, ProvisioningState, TypeHandlerVersion
```

### 2. Open the performance dashboard

1. Open your **SQL Server - Azure Arc** resource in the Azure portal.
2. Select **Monitoring** > **Performance Dashboard**.
3. If data collection is off, select **Configure**.
4. In **Configure monitoring settings**, turn collection on.
5. Select **Apply settings**.

Monitoring starts automatically when the instance meets the product prerequisites. Initial data can
take several minutes to appear in the portal.

### 3. Enable or disable collection from PowerShell

Use the current Microsoft Learn command if you want to change collection from the command line:

```powershell
$subscriptionId = "<your-subscription-id>"
$resourceGroup = "arcsql-lab-arc-rg"
$sqlServerArcName = "<sql-server-arc-resource-name>"
$resourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/" +
  "Microsoft.AzureArcData/SqlServerInstances/$sqlServerArcName"

az resource update `
  --ids $resourceId `
  --set 'properties.monitoring.enabled=true' `
  --api-version 2023-09-01-preview
```

Check the current monitoring setting:

```powershell
az resource show `
  --ids $resourceId `
  --api-version 2023-09-01-preview `
  --query properties.monitoring
```

### 4. Review the collected datasets

The preview collects these datasets from SQL Server dynamic management views:

- Active sessions every 30 seconds
- CPU utilization every 10 seconds
- Memory utilization every 10 seconds
- Storage I/O every 10 seconds
- Database properties every 5 minutes
- Database storage utilization every minute
- Common performance counters every minute
- Detailed performance counters every minute
- Wait statistics every 10 seconds

Wait statistics collection is enabled in the preview, but Microsoft Learn notes that the dashboard
does not visualize wait statistics yet.

## Validate

- **Monitoring** > **Performance Dashboard** opens for the SQL Server enabled by Azure Arc resource.
- CPU, Memory, Storage I/O, and Active Sessions start to show data after collection begins.
- `az resource show ... --query properties.monitoring` returns the monitoring configuration.
- You can switch between dashboard tabs without errors.

## Troubleshooting

- If the dashboard does not open, confirm that your Azure role includes
  `Microsoft.AzureArcData/sqlServerInstances/getTelemetry/`.
- If no data appears after about 15 minutes, confirm outbound access to
  `*.swedencentral.arcdataservices.com` and verify that the instance uses
  Pay-as-you-go or License with Software Assurance.
- If the toggle is unavailable, confirm that the instance runs on Windows and uses a supported
  SQL Server version and edition.
- Failover cluster instances are not supported in this preview.

Back to the [module index](../README.md#modules).
