# Modify License Type for Azure Arc-enabled SQL Server

Version: v3.0.5
Last updated: 2025-12-16

## Overview

This script provides a scalable solution to set or change the license type and/or enable or disable the ESU (Extended Security Updates) policy on all Azure Arc-connected SQL Servers in a specified scope.

> [!IMPORTANT]
> **Script renamed**: The script has been renamed from `modify-license-type.ps1` to `modify-arc-sql-license-type.ps1`. This version includes significant new features including CSP consent support, report-only mode, and managed identity authentication for runbooks.

**Use cases:**

- Transition from License Only to PAYG or Paid (with Software Assurance)
- Enable or disable Extended Security Updates subscriptions
- Configure unlimited virtualization with physical core licenses
- Audit and update license compliance across your SQL Server estate
- Bulk operations across subscriptions, resource groups, or individual machines
- Preview changes with report-only mode before applying
- Run as Azure Automation runbook with managed identity

**Scope flexibility:**

- Single subscription
- Multiple subscriptions from a CSV file
- All subscriptions your role has access to (default)
- Specific resource group
- Individual machine or list of machines from a CSV file

**License types:**

- **License Only**: You have a perpetual license but no Software Assurance or subscription
- **Paid**: You have a license with active Software Assurance or SQL Server subscription
- **PAYG** (Pay-As-You-Go): Hourly billing through Azure; no separate license purchase required

**Physical core licensing (unlimited virtualization):**
When using `-UsePcoreLicense Yes`, you're enabling unlimited virtualization with a physical core license. Key considerations:

- Creates a `SQLServerLicense` resource in Azure representing your physical host(s)
- Minimum license size: 16 physical cores
- Scope can be: Azure tenant, subscription, or resource group
- **Enterprise edition only** for unlimited virtualization benefit
- Not available for VMs running on [Listed Providers](https://aka.ms/listedproviders) (e.g., AWS, GCP)
- Each VM in scope must have `UsePhysicalCoreLicense = True` and matching `LicenseType`

For detailed information, see [License SQL Server by physical cores with unlimited virtualization](https://learn.microsoft.com/sql/sql-server/azure-arc/manage-license-billing#license-sql-server-instances-by-physical-cores-with-unlimited-virtualization).

## Prerequisites

- You must have at least *Azure Connected Machine Resource Administrator* role and subscription *Reader* role.
- The Azure extension for SQL Server is updated to version 1.1.2230.58 or newer.
- You must be connected to Microsoft Entra ID and logged in to your Azure account. If your account has access to multiple tenants, make sure to log in with a specific tenant ID using the `-TenantId` parameter.

## Parameters

| **Parameter** | **Value** | **Description** |
|:--|:--|:--|
|`-SubId`|subscription_id *or* file_name|**Optional**: Azure subscription ID or a .csv file with a list of subscriptions<sup>1</sup>. If not specified, all subscriptions your role has access to will be scanned.|
|`-ResourceGroup`|resource_group_name|**Optional**: Limits the scope to a specific resource group within the subscription(s).|
|`-MachineName`|machine_name *or* file_name|**Optional**: A single machine name or a .csv file containing a list of machine names<sup>2</sup>.|
|`-LicenseType`|"Paid", "PAYG", or "LicenseOnly"|**Optional**: Sets the license type to the specified value. Without `-Force`, only sets if currently undefined.|
|`-ConsentToRecurringPAYG`|"Yes" or "No"|**Optional**: Consents to enabling recurring PAYG billing. Requires `-LicenseType PAYG`. **Applies to CSP subscriptions only.**|
|`-UsePcoreLicense`|"Yes" or "No"|**Optional**: Enables (`Yes`) or disables (`No`) unlimited virtualization license using physical cores. Requires license type to be "Paid" or "PAYG".|
|`-EnableESU`|"Yes" or "No"|**Optional**: Enables (`Yes`) or disables (`No`) the Extended Security Updates subscription. Requires license type to be "Paid" or "PAYG". Only applicable to SQL Server 2012 and 2014.|
|`-Force`|Switch|**Optional**: Forces the change of license type to the specified value on all extensions, even if already set. If not specified, `-LicenseType` is only set when undefined. Ignored if `-LicenseType` is not specified.|
|`-ExclusionTags`|JSON object|**Optional**: Excludes resources that have specific tags assigned. Format: `'{"tag":"value"}'`|
|`-TenantId`|tenant_id|**Optional**: Specifies the Microsoft Entra tenant ID to log in. Otherwise, the current login context is used.|
|`-ReportOnly`|Switch|**Optional**: Generates a CSV file listing resources that would be modified, without making any actual changes. Useful for previewing impact before applying.|
|`-UseManagedIdentity`|Switch|**Optional**: Logs in using managed identity. **Required** to run the script as an Azure Automation runbook.|

<sup>1</sup> You can create a subscriptions .csv file using the following command:

```PowerShell
Get-AzSubscription | Export-Csv .\mysubscriptions.csv -NoTypeInformation
```

<sup>2</sup> The machines .csv file should contain a column named `MachineName` with the list of Arc-enabled machine names.

## Examples

### Example 1: Set PAYG license type on all undefined licenses

The following command scans all the subscriptions the user has access to and sets the license type to "PAYG" on all servers where license type is undefined.

```PowerShell
.\modify-arc-sql-license-type.ps1 -LicenseType PAYG
```

### Example 2: Force PAYG license type on all servers in a subscription

The following command scans the specified subscription and forces the license type to "PAYG" on all servers.

```PowerShell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -LicenseType PAYG -Force
```

### Example 3: Enable unlimited virtualization with PAYG

The following command scans the specified resource group, sets the license type to "PAYG", and enables unlimited virtualization on all servers.

```PowerShell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -ResourceGroup <resource_group_name> -LicenseType PAYG -UsePcoreLicense Yes -Force
```

### Example 4: Enable Extended Security Updates

The following command sets License Type to "Paid" and enables ESU on all servers in the specified resource group.

```PowerShell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -ResourceGroup <resource_group_name> -LicenseType Paid -EnableESU Yes -Force
```

### Example 5: Disable Extended Security Updates

The following command disables ESU on all servers in the specified subscription.

```PowerShell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -EnableESU No
```

### Example 6: Preview changes with report-only mode

The following command generates a CSV report of changes that would be made, without actually applying them.

```PowerShell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -LicenseType PAYG -ReportOnly
```

### Example 7: Enable PAYG with CSP consent

The following command sets PAYG license type and provides consent for recurring PAYG billing (required for CSP subscriptions).

```PowerShell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -LicenseType PAYG -ConsentToRecurringPAYG Yes -Force
```

### Example 8: Exclude resources by tag

The following command updates all servers except those tagged with `Environment=Production`.

```PowerShell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -LicenseType PAYG -ExclusionTags '{"Environment":"Production"}' -Force
```

### Example 9: Run as Azure Automation runbook

The following command is designed to run as an Azure Automation runbook using managed identity.

```PowerShell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -LicenseType PAYG -UseManagedIdentity -Force
```

### Example 10: Process specific machines from a CSV file

The following command processes only the machines listed in the CSV file.

```PowerShell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -MachineName machines.csv -LicenseType PAYG -Force
```

## Running the script using Cloud Shell

This option is recommended because Cloud Shell has the Azure PowerShell modules pre-installed and you are automatically authenticated. Use the following steps to run the script in Cloud Shell.

1. Launch the [Cloud Shell](https://shell.azure.com/). For details, [read more about PowerShell in Cloud Shell](https://aka.ms/pscloudshell/docs).

1. Connect to Microsoft Entra ID. You must specify `<tenant_id>` if you have access to more than one tenant.

   ```console
   Connect-AzAccount -TenantId <tenant_id>
   ```

1. Upload the script to your cloud shell using the following command:

   ```console
   curl https://raw.githubusercontent.com/microsoft/sql-server-samples/master/samples/manage/azure-arc-enabled-sql-server/modify-license-type/modify-arc-sql-license-type.ps1 -o modify-arc-sql-license-type.ps1
   ```

1. Run the script with your desired parameters.

> [!NOTE]
> - To paste the commands into the shell, use `Ctrl-Shift-V` on Windows or `Cmd-v` on MacOS.
> - The script will be uploaded directly to the home folder associated with your Cloud Shell session.

## Running the script from a PC

Use the following steps to run the script in a PowerShell session on your PC.

1. Copy the script to your current folder:

   ```console
   curl https://raw.githubusercontent.com/microsoft/sql-server-samples/master/samples/manage/azure-arc-enabled-sql-server/modify-license-type/modify-arc-sql-license-type.ps1 -o modify-arc-sql-license-type.ps1
   ```

1. Make sure the NuGet package provider is installed:

   ```console
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force
   ```

1. Make sure the Az module is installed. For more information, see [Install the Azure Az PowerShell module](https://learn.microsoft.com/powershell/azure/install-az-ps):

   ```console
   Install-Module Az -Scope CurrentUser -Repository PSGallery -Force
   ```

1. Connect to Microsoft Entra ID and log in to your Azure account. You must specify `<tenant_id>` if you have access to more than one tenant.

   ```console
   Connect-AzAccount -TenantId <tenant_id>
   ```

1. Run the script with your desired parameters.

## Running as an Azure Automation runbook

To run this script as an Azure Automation runbook:

1. Create an Azure Automation account with a system-assigned managed identity.
1. Grant the managed identity the required permissions (Azure Connected Machine Resource Administrator and Reader on target subscriptions).
1. Import the script as a PowerShell runbook.
1. Use the `-UseManagedIdentity` parameter when configuring the runbook.

For detailed guidance on creating and managing Azure Automation runbooks, see [Create a standalone Azure Automation account](https://learn.microsoft.com/en-us/azure/automation/automation-create-standalone-account?tabs=azureportal).

### Scheduled P-Core License Activation

To schedule automatic activation of P-Core (unlimited virtualization) licenses at a specific date:

1. **Create a runbook** in your Automation Account using this simplified script:

   ```powershell
   param (
       [Parameter (Mandatory= $true)]
       [string] $LicenseId
   )

   # Suppress warnings
   Update-AzConfig -DisplayBreakingChangeWarning $false

   # Log in using managed identity
   Connect-AzAccount -Identity

   # Activate the license
   $currentLicense = Get-AzResource -ResourceId $LicenseId 
   $currentLicense.properties.activationState = "Activated"
   $currentLicense | Set-AzResource -Force
   ```

2. **Required permissions**: The managed identity needs `Microsoft.HybridCompute/licenses/write` permission on the target license resources.

3. **Schedule the runbook** to run on your desired activation date using Azure Automation schedules.

For P-Core licensing concepts, see [License SQL Server with unlimited virtualization](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/manage-license-billing?view=sql-server-ver17#license-sql-server-with-unlimited-virtualization).

## Output

The script creates a log file named `modify-arc-sql-license-type.log` in the current directory with detailed execution information.

When using `-ReportOnly`, a CSV file is generated listing all resources that would be modified, allowing you to review changes before applying them.
