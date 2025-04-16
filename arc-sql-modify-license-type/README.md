---
services: Azure Arc-enabled SQL Server
platforms: Azure
author: anosov1960
ms.author: sashan
ms.date: 12/01/2024
---


# Overview

This script provides a scaleable solution to set or change the license type and/or enable or disable the ESU policy on all Azure-connected SQL Servers in a specified scope.

You can specify a single subscription to scan, or provide a list of subscriptions as a .CSV file.
If not specified, all subscriptions your role has access to are scanned.

# Prerequisites

- You must have at least *Azure Connected Machine Resource Administrator* role and subscription *Reader* role.
- The Azure extension for SQL Server is updated to version 1.1.2230.58 or newer.
- You must be connected to Azure AD and logged in to your Azure account. If your account have access to multiple tenants, make sure to log in with a specific tenant ID.

# Launching the script

The script accepts the following command line parameters:

| **Parameter** &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;  | **Value** &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; | **Description** |
|:--|:--|:--|
|-SubId|subscription_id *or* a file_name|Optional: Subscription id or a .csv file with the list of subscriptions<sup>1</sup>. If not specified all subscriptions will be scanned|
|-ResourceGroup |resource_group_name|Optional: Limits the scope  to a specific resource group|
|-MachineName |machine_name|Optional: Limits the scope to a specific machine|
|-LicenseType | "Paid", "PAYG" or "LicenseOnly"| Optional: Sets the license type to the specified value |
|-UsePcoreLicense | "Yes", "No" | Optional. Enables unlimited virtualization license if the value is "Yes" or disables it if the value is "No". To enable, the license type must be "Paid" or "PAYG"|
|-EnableESU | "Yes", "No" | Optional. Enables the ESU policy the value is "Yes" or disables it if the value is "No". To enable, the license type must be "Paid" or "PAYG"|
|-Force| |Optional. Forces the change of the license type to the specified value on all installed extensions. If -Force is not specified, the -LicenseType value is set only if undefined. Ignored if -LicenseType  is not specified|

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
