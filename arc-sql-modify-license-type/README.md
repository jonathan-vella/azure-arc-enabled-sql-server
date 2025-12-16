# Modify License Type for Azure Arc-enabled SQL Server

Version: v1.2025.12
Last updated: 2025-12-16

## Overview

This script provides a scalable solution to set or change the license type and/or enable or disable the ESU (Extended Security Updates) policy on all Azure Arc-connected SQL Servers in a specified scope.

**Use cases:**
- Transition from License Only to PAYG or Paid (with Software Assurance)
- Enable or disable Extended Security Updates subscriptions
- Configure unlimited virtualization with physical core licenses
- Audit and update license compliance across your SQL Server estate
- Bulk operations across subscriptions, resource groups, or individual machines

**Scope flexibility:**
- Single subscription
- Multiple subscriptions from a CSV file
- All subscriptions your role has access to (default)
- Specific resource group
- Individual machine

**License types:**
- **License Only**: You have a perpetual license but no Software Assurance or subscription
- **Paid**: You have a license with active Software Assurance or SQL Server subscription
- **PAYG** (Pay-As-You-Go): Hourly billing through Azure; no separate license purchase required

# Prerequisites

- You must have at least *Azure Connected Machine Resource Administrator* role and subscription *Reader* role.
- The Azure extension for SQL Server is updated to version 1.1.2230.58 or newer.
- You must be connected to Azure AD and logged in to your Azure account. If your account have access to multiple tenants, make sure to log in with a specific tenant ID.

# Launching the script

The script accepts the following command line parameters:

| **Parameter** | **Value** | **Description** |
|:--|:--|:--|
|`-SubId`|subscription_id *or* file_name|**Optional**: Azure subscription ID or a .csv file with a list of subscriptions<sup>1</sup>. If not specified, all subscriptions your role has access to will be scanned.|
|`-ResourceGroup`|resource_group_name|**Optional**: Limits the scope to a specific resource group within the subscription(s).|
|`-MachineName`|machine_name|**Optional**: Limits the scope to a specific Arc-enabled machine.|
|`-LicenseType`|"Paid", "PAYG", or "LicenseOnly"|**Optional**: Sets the license type to the specified value. Without `-Force`, only sets if currently undefined.|
|`-UsePcoreLicense`|"Yes" or "No"|**Optional**: Enables (`Yes`) or disables (`No`) unlimited virtualization license using physical cores. Requires license type to be "Paid" or "PAYG".|
|`-EnableESU`|"Yes" or "No"|**Optional**: Enables (`Yes`) or disables (`No`) the Extended Security Updates subscription. Requires license type to be "Paid" or "PAYG". Only applicable to SQL Server 2012 and 2014.|
|`-Force`|Switch|**Optional**: Forces the change of license type to the specified value on all extensions, even if already set. If not specified, `-LicenseType` is only set when undefined. Ignored if `-LicenseType` is not specified.|

<sup>1</sup>You can create a .csv file using the following command and then edit to remove the subscriptions you don't  want to scan.
```PowerShell
Get-AzSubscription | Export-Csv .\mysubscriptions.csv -NoTypeInformation
```
## Example 1

The following command will scan all the subscriptions to which the user has access to, and set the license type to "PAYG" on all servers where license type is undefined.

```PowerShell
.\modify-license-type.ps1 -LicenseType PAYG
```

## Example 2

The following command will scan all all the subscriptions to which the user has access to, and set the license type to "PAYG" on all servers .

```PowerShell
.\modify-license-type.ps1 -SubId <sub_id> -LicenseType PAYG -Force
```

## Example 3

The following command will scan resource group `<resource_group_name>` in the subscription `<sub_id>`, set the license type value to "PAYG" and enable unlimited virtualization license on all servers in the specified resource group.

```PowerShell
.\modify-license-type.ps1 -SubId <sub_id> -ResourceGroup <resource_group_name> -LicenseType PAYG -UsePcoreLicense Yes -Force
```

## Example 4

The following command will set License Type to 'Paid" and enables ESU on all servers in the subscriptions `<sub_id>` and the resource group `<resource_group_name>`.

```console
.\modify-license-type.ps1 -SubId <sub_id> -ResourceGroup <resource_group_name> -LicenseType Paid -EnableESU Yes -Force
```

## Example 5

The following command will disable ESU on all servers in the subscriptions `<sub_id>`.
    
```console
.\modify-license-type.ps1 -SubId <sub_id> -EnableESU No 
```

# Running the script using Cloud Shell

This option is recommended because Cloud shell has the Azure PowerShell modules pre-installed and you are automatically authenticated.  Use the following steps to run the script in Cloud Shell.

1. Launch the [Cloud Shell](https://shell.azure.com/). For details, [read more about PowerShell in Cloud Shell](https://aka.ms/pscloudshell/docs).

1. Connect to Azure AD. You must specify `<tenant_id>` if you have access to more than one AAD tenants.

    ```console
   Connect-AzureAD -TenantID <tenant_id>
    ```

1. Upload the script to your cloud shell using the following command:

    ```console
    curl https://raw.githubusercontent.com/microsoft/sql-server-samples/master/samples/manage/azure-arc-enabled-sql-server/modify-license-type/modify-license-type.ps1 -o modify-license-type.ps1
    ```

1. Run the script.

> [!NOTE]
> - To paste the commands into the shell, use `Ctrl-Shift-V` on Windows or `Cmd-v` on MacOS.
> - The script will be uploaded directly to the home folder associated with your Cloud Shell session.

# Running the script from a PC


Use the following steps to run the script in a PowerShell session on your PC.

1. Copy the script to your current folder:

    ```console
    curl https://raw.githubusercontent.com/microsoft/sql-server-samples/master/samples/manage/azure-arc-enabled-sql-server/modify-license-type/modify-license-type.ps1 -o modify-license-type.ps1
    ```

1. Make sure the NuGet package provider is installed:

    ```console
    Set-ExecutionPolicy  -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Install-packageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force
    ```

1. Make sure the the Az module is installed. For more information, see [Install the Azure Az PowerShell module](https://learn.microsoft.com/powershell/azure/install-az-ps):

    ```console
    Install-Module Az -Scope CurrentUser -Repository PSGallery -Force
    ```

1. Connect to Azure AD and log in to your Azure account. You must specify `<tenant_id>` if you have access to more than one AAD tenants.

    ```console
    Connect-AzureAD -TenantID <tenant_id>
    Connect-AzAccount -TenantID (Get-AzureADTenantDetail).ObjectId
    ```

1. Run the script. 
