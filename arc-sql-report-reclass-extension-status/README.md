# Azure Arc SQL reclass report
Version: v1.2026.09
Last updated: 2026-09-30

`Get-SQLAzureArcReclassReport.ps1` exports two CSV files that help you audit SQL Server resources
enabled by Azure Arc and the `WindowsAgent.SqlServer` extension.

## Prerequisites

- Install the `Az.ResourceGraph`, `Az.ConnectedMachine`, and `Az.Accounts` modules.
- You need at least the Reader role in each subscription that you want to query.
- Sign in to Azure before you run the script. If you use multiple tenants, sign in to the
  correct Microsoft Entra tenant first.

## Output files

### ArcSQLServerinstanceswithReclass.csv

| Property | Description |
| --- | --- |
| `createdAt` | Time when the SQL Server resource was created |
| `subscriptionId` | Subscription ID |
| `resourceGroup` | Resource group name |
| `AzureArcServerName` | Azure Arc server that hosts the SQL Server instance |
| `Status` | SQL Server resource status |
| `SQLInstanceName` | SQL Server instance name |
| `version` | SQL Server version |
| `edition` | SQL Server edition |
| `vcores` | Number of vCores |
| `licenseTypeinGraph` | License type reported by Azure Resource Graph |
| `licenseTypeInExt` | License type reported by the extension query |
| `ExVersion` | `WindowsAgent.SqlServer` extension version |
| `provisioningState` | Extension provisioning state |

### SQLExtensionStatus.csv

| Property | Description |
| --- | --- |
| `subscriptionId` | Subscription ID |
| `resourceGroup` | Resource group name |
| `name` | Azure Arc server where the extension is installed |
| `Status` | Extension status |
| `ExVersion` | `WindowsAgent.SqlServer` extension version |
| `provisioningState` | Extension provisioning state |

## Run the script

```powershell
.\Get-SQLAzureArcReclassReport.ps1
```

The script writes both CSV files to the current folder.

## Interpret the results

- Compare `licenseTypeinGraph` and `licenseTypeInExt` to find mismatches.
- Review `ExVersion` and `provisioningState` to identify failed or outdated extensions.
- Compare `ExVersion` with the
  [release notes](https://learn.microsoft.com/sql/sql-server/azure-arc/release-notes?view=sql-server-ver17).
  Only extension versions released within the last year are supported.
