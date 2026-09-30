# Module 8: Configure automatic updates

Version: v1.2026.09
Last updated: 2026-09-30

Automatic updates for SQL Server enabled by Azure Arc is generally available. In this module, you
enable scheduled Windows and SQL Server patching for the Arc-enabled server and verify the
maintenance window.

## Prerequisites

- Review the [lab prerequisites](../PREREQUISITES.md).
- Complete the earlier onboarding, SQL extension, and licensing modules for the lab server in
  `arcsql-lab-arc-rg`.
- Use a Windows Server host. Automatic updates for SQL Server enabled by Azure Arc currently apply
  only to Windows machines.
- Use an Azure role that can manage the Arc-enabled server. Azure Update Manager documents Azure
  Connected Machine Resource Administrator for Azure Arc-enabled servers.

> [!IMPORTANT]
> Automatic updates is available only when the SQL Server license type is **Pay-as-you-go** or
> **License with Software Assurance**. Changing the license type can affect billing. If you switch
> away from those license types, disable automatic updates and any Extended Security Updates first,
> save the change, wait about five minutes, and then change the license type.

## Steps

### 1. Confirm that the server is eligible

Automatic updates work at the host operating system level. They apply to every SQL Server instance
installed on the machine. Azure installs updates only during the maintenance window and only for
Windows and SQL Server updates classified as Important or Critical.

Check that the Azure Extension for SQL Server is installed and healthy:

```powershell
Get-AzConnectedMachineExtension `
  -ResourceGroupName "arcsql-lab-arc-rg" `
  -MachineName "<arc-server-name>" `
  -Name "WindowsAgent.SqlServer" |
  Select-Object Name, ProvisioningState, TypeHandlerVersion
```

### 2. Enable automatic updates in the Azure portal

1. Open **Server - Azure Arc** for your lab server.
2. Under **Operations**, select **SQL Server Configuration**.
3. In **Update**, set **Automatic updates** to **Enable**.
4. Set **Maintenance schedule** and **Maintenance start hour**. For example, use Sunday at 02:00.
5. Select **Save**.

Azure configures the Azure Extension for SQL Server in the background after you save the change.

### 3. Create the maintenance window with PowerShell

Use the documented Azure Update Manager cmdlets if you want to create and assign the maintenance
configuration from PowerShell instead of the portal:

```powershell
Install-Module -Name Az.Maintenance -Scope CurrentUser

$subscriptionId = "<your-subscription-id>"
$resourceGroup = "arcsql-lab-arc-rg"
$location = "swedencentral"
$serverName = "<arc-server-name>"
$assignmentName = "sql-weekly-window"
$startDateTime = (Get-Date).Date.AddDays(7).AddHours(2).ToString("yyyy-MM-dd HH:mm")

Set-AzContext -SubscriptionId $subscriptionId

$maintenanceConfig = New-AzMaintenanceConfiguration `
  -ResourceGroupName $resourceGroup `
  -Name $assignmentName `
  -Location $location `
  -MaintenanceScope "InGuestPatch" `
  -Timezone "UTC" `
  -StartDateTime $startDateTime `
  -Duration "03:00" `
  -RecurEvery "Week Sunday" `
  -WindowParameterClassificationToInclude @("Critical", "Security") `
  -InstallPatchRebootSetting "IfRequired" `
  -ExtensionProperty @{ InGuestPatchMode = "User" }

$arcServerId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/" +
  "Microsoft.HybridCompute/machines/$serverName"

New-AzConfigurationAssignment `
  -ResourceId $arcServerId `
  -Location $location `
  -ConfigurationAssignmentName $assignmentName `
  -MaintenanceConfigurationId $maintenanceConfig.Id
```

If you use this path, your role also needs the Azure Update Manager maintenance configuration and
assignment permissions on the resource group or subscription.

### 4. Review the resulting schedule

Check the maintenance configuration that you created:

```powershell
Get-AzMaintenanceConfiguration `
  -ResourceGroupName "arcsql-lab-arc-rg" `
  -Name "sql-weekly-window" |
  Select-Object Name, MaintenanceScope, RecurEvery, StartDateTime, Duration
```

In the portal, you can also open **Updates** on the Arc-enabled server to review compliance and the
next scheduled maintenance window.

## Validate

- **SQL Server Configuration** on the Arc-enabled server shows **Automatic updates** as enabled.
- **Updates** on the Arc-enabled server shows a maintenance window and update compliance data.
- The server remains on Pay-as-you-go or License with Software Assurance.
- If you created `sql-weekly-window`, `Get-AzMaintenanceConfiguration` returns the schedule.

## Troubleshooting

- If the automatic updates controls are unavailable, confirm that the host is Windows and that the
  SQL Server license type is not LicenseOnly.
- If a license type change is blocked, disable automatic updates and any Extended Security Updates,
  save the change, wait about five minutes, and try the license change again.
- If updates do not install, review the maintenance window, confirm Azure Update Manager access on
  the server, and check outbound access to Windows Update and Microsoft Update.

Back to the [module index](../README.md#modules).
