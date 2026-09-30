# Module 5: Basic monitoring

Version: v1.2026.09
Last updated: 2026-09-30

⚠️ Monitoring is a preview feature that is covered by the [Azure preview supplemental terms](https://azure.microsoft.com/support/legal/preview-supplemental-terms/).
In this module you confirm the current prerequisites and use the portal performance dashboard to view SQL Server
metrics.

## Prerequisites
- Complete [Module 4](04-license-management.md) with **Pay-as-you-go** or **License with
  Software Assurance**.
- The lab host uses Windows Server 2022 or later with SQL Server 2022 or later. This lab baseline exceeds the product
  minimum for monitoring.
- The Azure extension for SQL Server is `WindowsAgent.SqlServer` version `1.1.2504.99` or later.

## Steps
### 1. Confirm the monitoring prerequisites
1. In the Azure portal, open **Azure Arc** > **SQL Server instances** and select your lab instance.
2. Confirm that the host license type is **Pay-as-you-go** or **License with Software Assurance**.
3. Confirm that the SQL Server edition is Standard or Enterprise.
4. Confirm that the SQL Server version is 2016 SP1 or later. The lab baseline already meets this requirement.
5. Run the following query for a quick read-only check:

```powershell
Search-AzGraph -Query @'
resources
| where type =~ "microsoft.azurearcdata/sqlserverinstances"
| where resourceGroup =~ "arcsql-lab-arc-rg"
| project sqlInstance = name,
          edition = tostring(properties.edition),
          version = tostring(properties.version),
          hostLicenseType = tostring(properties.licenseType)
'@
```

### 2. Open the performance dashboard
1. On the SQL Server resource, select **Monitoring** > **Performance Dashboard**.
2. Wait for the dashboard to load.
3. If the dashboard already shows charts, collection is active and you can continue to the next step.

### 3. Enable collection if it is turned off
1. If the dashboard shows that collection is off, select **Configure**.
2. On **Configure monitoring settings**, turn monitoring on.
3. Select **Apply settings**.
4. Return to **Performance Dashboard** and wait for charts to populate.

> [!NOTE]
> This preview feature sends metrics to the Azure telemetry pipeline. It does not use the Log Analytics workspace that
> you created for best practices assessment.

### 4. Review the dashboard data
1. On **Performance Dashboard**, review CPU, memory, storage I/O, waits, and active session charts.
2. Change the time range and confirm that the charts refresh.
3. If you are testing with a live workload, watch the charts react to that activity.

## Validate
- **Performance Dashboard** opens for the SQL Server enabled by Azure Arc resource.
- The dashboard shows live charts after monitoring is enabled.
- The query confirms the SQL Server instance is in `arcsql-lab-arc-rg` and uses an eligible host license type.
- No error banner appears on the monitoring pane after collection is enabled.

## Troubleshooting
- If the monitoring pane does not open, confirm that the host license type is Pay-as-you-go or License with Software
  Assurance.
- If the dashboard stays empty, verify that the extension version is `1.1.2504.99` or later and that the server can
  reach `*.<region>.arcdataservices.com`.
- If you can open the pane but cannot view metrics, verify that your Azure role includes the
  `Microsoft.AzureArcData/sqlServerInstances/getTelemetry/` action.

Back to the [module index](../README.md#modules).
