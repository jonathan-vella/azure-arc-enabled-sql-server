# Modify license type for Azure Arc-enabled SQL Server
Version: v1.2026.09
Last updated: 2026-09-30

This README covers script version `v3.0.5`.

The script is a verbatim copy of the [upstream script][upstream-script] at commit
`2d2d81773c0491f120d6728dd63cf86ce5cddc86`.

[upstream-script]: https://github.com/microsoft/sql-server-samples/blob/master/samples/manage/azure-arc-enabled-sql-server/modify-license-type/modify-arc-sql-license-type.ps1

This script sets or changes the license type and can enable or disable Extended Security Updates
for SQL Server resources enabled by Azure Arc within the scope you choose.

> [!IMPORTANT]
> The script was renamed from `modify-license-type.ps1` to
> `modify-arc-sql-license-type.ps1`.
>
> `-LicenseType`, `-EnableESU`, `-UsePcoreLicense`, and `-ConsentToRecurringPAYG`
> can affect billing.

## Use cases

- Transition from License Only to PAYG or Paid
- Enable or disable Extended Security Updates subscriptions
- Configure unlimited virtualization with physical core licenses
- Audit and update license compliance across subscriptions, resource groups, or machines
- Preview changes with report-only mode before applying them
- Run the script as an Azure Automation runbook with managed identity

## Scope options

You can run the script against:

- One subscription
- Multiple subscriptions from a CSV file
- All subscriptions your role can access
- One resource group
- One machine or a list of machines from a CSV file

## License types

- **License Only**: You have a perpetual license without Software Assurance or subscription.
- **Paid**: You have a license with active Software Assurance or a SQL Server subscription.
- **PAYG**: You pay for licensing through Azure billing.

## Physical core licensing

When you use `-UsePcoreLicense Yes`, the script enables unlimited virtualization with physical
core licensing.

Key points:

- It creates a `SQLServerLicense` resource in Azure for the physical host.
- The minimum license size is 16 physical cores.
- The scope can be the Azure tenant, subscription, or resource group.
- Unlimited virtualization applies only to Enterprise edition.
- It isn't available for VMs that run on
  [Listed Providers](https://aka.ms/listedproviders).
- Each VM in scope must have `UsePhysicalCoreLicense = True` and the matching `LicenseType`.

For details, see
[License SQL Server by physical cores with unlimited virtualization](https://learn.microsoft.com/sql/sql-server/azure-arc/manage-license-billing?view=sql-server-ver17#license-sql-server-instances-by-physical-cores-with-unlimited-virtualization).

## Prerequisites

- You need at least the Azure Connected Machine Resource Administrator role and Reader on the
  target subscriptions.
- Use a supported Azure extension for SQL Server version. Only versions released within the last
  year are supported. See the
  [release notes](https://learn.microsoft.com/sql/sql-server/azure-arc/release-notes?view=sql-server-ver17).
- Sign in to Azure before you run the script. If you use multiple tenants, sign in to the
  correct Microsoft Entra tenant, or pass `-TenantId`.

## Parameters

| Parameter | Value | Description |
| --- | --- | --- |
| `-SubId` | subscription_id or file_name | Optional. Azure subscription ID, or a `.csv` file with a list of subscriptions.<sup>1</sup> If omitted, the script scans all subscriptions your role can access. |
| `-ResourceGroup` | resource_group_name | Optional. Limits the scope to one resource group within the selected subscription or subscriptions. |
| `-MachineName` | machine_name or file_name | Optional. One machine name, or a `.csv` file that contains machine names.<sup>2</sup> |
| `-LicenseType` | `"Paid"`, `"PAYG"`, or `"LicenseOnly"` | Optional. Sets the license type. Without `-Force`, the script sets the value only when the current value is undefined. |
| `-ConsentToRecurringPAYG` | `"Yes"` or `"No"` | Optional. Consents to recurring PAYG billing. Requires `-LicenseType PAYG`. Applies only to CSP subscriptions. |
| `-UsePcoreLicense` | `"Yes"` or `"No"` | Optional. Enables or disables unlimited virtualization with physical core licensing. Requires `Paid` or `PAYG`. |
| `-EnableESU` | `"Yes"` or `"No"` | Optional. Enables or disables Extended Security Updates. Requires `Paid` or `PAYG`. Applies only to SQL Server 2012 and 2014. |
| `-Force` | Switch | Optional. Forces the change on all matching resources, even when the current value is already set. Ignored if `-LicenseType` is not provided. |
| `-ExclusionTags` | JSON object | Optional. Excludes resources that have specific tags. Format: `'{"tag":"value"}'` |
| `-TenantId` | tenant_id | Optional. Uses the specified Microsoft Entra tenant ID for sign-in. |
| `-ReportOnly` | Switch | Optional. Generates a CSV file that lists the resources that would change, without making changes. |
| `-UseManagedIdentity` | Switch | Optional. Signs in with managed identity. Required for Azure Automation runbooks. |
| `-WaitForCompletion` | Switch | Optional. Waits for each submitted extension update to reach a terminal provisioning state and reports the confirmed outcome. Without it, the report records `RequestSubmitted`, which means only that Azure accepted the request. The run is slower because the script polls each machine. |
| `-WaitTimeoutSeconds` | Integer | Optional. Maximum wait per resource when you use `-WaitForCompletion`. Default is `300`. Reaching the timeout isn't a failure. The script records `TimedOut` because the agent may still apply the update. |
| `-NoSummary` | Switch | Optional. Skips the execution outcome summary that the script prints at the end of the run, including the root causes of failed and skipped resources. |

<sup>1</sup> Create a subscriptions CSV file with:

```powershell
Get-AzSubscription | Export-Csv .\mysubscriptions.csv -NoTypeInformation
```

<sup>2</sup> The machines CSV file must contain a `MachineName` column.

## Examples

### Example 1: Set PAYG on undefined licenses

```powershell
.\modify-arc-sql-license-type.ps1 -LicenseType PAYG
```

### Example 2: Force PAYG in one subscription

```powershell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -LicenseType PAYG -Force
```

### Example 3: Enable unlimited virtualization with PAYG

```powershell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -ResourceGroup <resource_group_name> -LicenseType PAYG -UsePcoreLicense Yes -Force
```

### Example 4: Enable extended security updates

```powershell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -ResourceGroup <resource_group_name> -LicenseType Paid -EnableESU Yes -Force
```

### Example 5: Disable extended security updates

```powershell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -EnableESU No
```

### Example 6: Preview changes with report-only mode

```powershell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -LicenseType PAYG -ReportOnly
```

### Example 7: Enable PAYG with CSP consent

```powershell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -LicenseType PAYG -ConsentToRecurringPAYG Yes -Force
```

### Example 8: Exclude resources by tag

```powershell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -LicenseType PAYG -ExclusionTags '{"Environment":"Production"}' -Force
```

### Example 9: Run as an Azure Automation runbook

```powershell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -LicenseType PAYG -UseManagedIdentity -Force
```

### Example 10: Process specific machines from a CSV file

```powershell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -MachineName machines.csv -LicenseType PAYG -Force
```

### Example 11: Wait for confirmed results

```powershell
.\modify-arc-sql-license-type.ps1 -SubId <subscription_id> -LicenseType PAYG -Force -WaitForCompletion -WaitTimeoutSeconds 600
```

## Run the script in Cloud Shell

1. Launch [Cloud Shell](https://shell.azure.com/). For details, see
   [PowerShell in Cloud Shell](https://aka.ms/pscloudshell/docs).
2. Connect to Azure. If you have access to more than one tenant, specify `<tenant_id>`.

   ```powershell
   Connect-AzAccount -TenantId <tenant_id>
   ```

3. Upload the script to Cloud Shell.

   ```powershell
   curl https://raw.githubusercontent.com/microsoft/sql-server-samples/master/samples/manage/azure-arc-enabled-sql-server/modify-license-type/modify-arc-sql-license-type.ps1 -o modify-arc-sql-license-type.ps1
   ```

4. Run the script with your chosen parameters.

> [!NOTE]
> Use `Ctrl-Shift-V` on Windows or `Cmd-V` on macOS to paste into Cloud Shell.

## Run the script on a PC

1. Copy the script to your current folder.

   ```powershell
   curl https://raw.githubusercontent.com/microsoft/sql-server-samples/master/samples/manage/azure-arc-enabled-sql-server/modify-license-type/modify-arc-sql-license-type.ps1 -o modify-arc-sql-license-type.ps1
   ```

2. Install the NuGet package provider if needed.

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force
   ```

3. Install the Az module if needed. For details, see
   [Install the Azure Az PowerShell module](https://learn.microsoft.com/powershell/azure/install-az-ps).

   ```powershell
   Install-Module Az -Scope CurrentUser -Repository PSGallery -Force
   ```

4. Connect to Azure. If you have access to more than one tenant, specify `<tenant_id>`.

   ```powershell
   Connect-AzAccount -TenantId <tenant_id>
   ```

5. Run the script with your chosen parameters.

## Run as an Azure Automation runbook

1. Create an Azure Automation account with a system-assigned managed identity.
2. Grant the managed identity the required permissions on the target subscriptions.
3. Import the script as a PowerShell runbook.
4. Use the `-UseManagedIdentity` parameter when you configure the runbook.

For details, see
[Create a standalone Azure Automation account](https://learn.microsoft.com/azure/automation/automation-create-standalone-account?tabs=azureportal).

### Scheduled P-Core license activation

Use a separate runbook if you need to activate P-Core licensing on a specific date.

```powershell
param (
    [Parameter(Mandatory = $true)]
    [string] $LicenseId
)

Update-AzConfig -DisplayBreakingChangeWarning $false
Connect-AzAccount -Identity

$currentLicense = Get-AzResource -ResourceId $LicenseId
$currentLicense.properties.activationState = "Activated"
$currentLicense | Set-AzResource -Force
```

The managed identity needs `Microsoft.HybridCompute/licenses/write` on the target license
resources.

For P-Core licensing concepts, see
[License SQL Server with unlimited virtualization](https://learn.microsoft.com/sql/sql-server/azure-arc/manage-license-billing?view=sql-server-ver17#license-sql-server-with-unlimited-virtualization).

## Output

The script writes `modify-arc-sql-license-type.log` to the current directory.

When you use `-ReportOnly`, the script also creates a CSV file that lists the resources that
would change.
