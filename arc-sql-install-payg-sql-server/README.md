# Install Pay-As-You-Go SQL Server with Azure Arc

## Overview

This script installs a pay-as-you-go (PAYG) SQL Server instance on your machine and automatically connects it to Azure Arc. The PAYG licensing model allows you to purchase SQL Server using an hourly billing model through Azure instead of purchasing traditional licenses.

**Benefits of PAYG licensing:**
- Variable demand: Great for SQL Server instances with variable compute capacity needs over time
- Short-term usage: Ideal for servers needed for a limited time period
- Cost optimization: Only pay for active usage; no charges when VM or SQL Server instance is stopped
- Flexible scaling: Can scale down cores during less busy times
- All SQL Server benefits: Includes Software Assurance benefits like free new version upgrades, HADR benefits, unlimited virtualization with Enterprise edition, and 180-day dual-use benefit
- Available for all versions: SQL Server 2012 through SQL Server 2022

**Important**: PAYG billing follows SQL Server licensing terms, including the four-core minimum. Billing granularity is one hour.

# Prerequisites

- You have met the [onboarding prerequisites](https://learn.microsoft.com/sql/sql-server/azure-arc/prerequisites).
- You have downloaded a SQL Server image file from the workspace provided by Microsoft technical support. To obtain it, open a support request using the "Get SQL Installation Media" subcategory and specify the desired version and edition. 
- You are logged in to the machine with an administrator account. 
- If you are installing SQL Server on Windows Server 2016, you have a secure TLS configuration as described below.


# Mitigating the TLS version issue on Windows Server 2016

When running the script on Windows Server 2016, the OS may be configured with a TLS version that does not meet the Azure security requirements. You need to enable strong TLS versions (TLS 1.2 and 1.3) when they are available, while still supporting older TLS versions (1.0 and 1.1) when TLS 1.2 and 1.3 are unavailable. You need to also disable versions SSL2 and SSL3, which are insecure.

To see if you need to make the change, run the command below from an elevated PowerShell prompt.
```PowerShell
[Net.ServicePointManager]::SecurityProtocol
```

If the result is `SSL3, Tls`, you need to fix the TLS version by running the following commands.

```PowerShell
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord 
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord 
```

After running these commands, reboot the machine (in case currently-running applications were referencing previous values). To verify that the changes were applied correctly, run this command again: 

```PowerShell
[Net.ServicePointManager]::SecurityProtocol
```
The result should be `Tls, Tls11, Tls12, Tls13`

# Downloading the script

To download the script to your current folder run:

```console
curl https://raw.githubusercontent.com/microsoft/sql-server-samples/master/samples/manage/azure-arc-enabled-sql-server/install-payg-sql-server/install-payg-sql-server.ps1 -o install-payg-sql-server.ps1
```

# Launching the script

The script must be run in an elevated PowerShell session. It accepts the following command line parameters:

| **Parameter** | **Value** | **Description** |
|:--|:--|:--|
|`-AzureSubscriptionId`|subscription_id|**Required**: Azure subscription ID that will contain the Arc-enabled machine and Arc-enabled SQL Server resources. This subscription will be billed for SQL Server software using PAYG. |
|`-AzureResourceGroup`|resource_group_name|**Required**: Resource group that will contain the Arc-enabled machine and Arc-enabled SQL Server resource.|
|`-AzureRegion`|region name|**Required**: The Azure region to store the machine and SQL Server metadata. Must be a [supported region](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/overview?view=sql-server-ver17#supported-azure-regions). |
|`-SqlServerInstanceName`|instance name|**Optional**: Name of the SQL Server instance. If not specified, the machine name will be used.|
|`-SqlServerAdminAccounts`|SQL Server admin accounts|**Optional**: SQL Server administrator accounts. Default: `BUILTIN\ADMINISTRATORS`.|
|`-SqlServerSvcAccount`|service account|**Optional**: SQL Server service account. Default: `NT AUTHORITY\NETWORK SERVICE`.|
|`-SqlServerSvcPassword`|password|**Required if** a custom service account is specified.|
|`-AgtServerSvcAccount`|service account|**Optional**: SQL Agent service account. Default: `NT AUTHORITY\NETWORK SERVICE`.|
|`-AgtServerSvcPassword`|password|**Required if** a custom service account is specified.|
|`-IsoFolder`|folder path|**Required**: The folder containing the SQL Server installation media files downloaded from Microsoft.|
|`-ConsentToRecurringPAYG`|"Yes" or "No"|**Required for CSP subscriptions**: Consent to recurring PAYG billing in CSP-managed subscriptions.|
|`-ExcludedSqlInstances`|array of instance names|**Optional**: Array of SQL Server instance names to exclude from Azure Arc connection.|
|`-Proxy`|HTTP proxy URL|**Optional**: HTTP proxy server URL if your network requires proxy configuration.|

# Examples

## Example 1: Basic PAYG Installation

The following command installs a SQL Server instance from the Downloads folder, connects it to Azure Arc with PAYG licensing. It uses default admin and service accounts, and uses a direct connection to Azure.

```PowerShell
.\install-payg-sql-server.ps1 `
  -AzureSubscriptionId <subscription_id> `
  -AzureResourceGroup <resource_group> `
  -AzureRegion westus `
  -IsoFolder C:\Downloads
```

## Example 2: PAYG with CSP Subscription

For CSP-managed subscriptions, you must provide consent for recurring billing:

```PowerShell
.\install-payg-sql-server.ps1 `
  -AzureSubscriptionId <subscription_id> `
  -AzureResourceGroup <resource_group> `
  -AzureRegion eastus `
  -IsoFolder C:\SQLMedia `
  -ConsentToRecurringPAYG Yes
```

## Example 3: Custom Instance with Exclusions

Install with a custom instance name and exclude specific instances from Azure Arc:

```PowerShell
.\install-payg-sql-server.ps1 `
  -AzureSubscriptionId <subscription_id> `
  -AzureResourceGroup <resource_group> `
  -AzureRegion westeurope `
  -SqlServerInstanceName PROD01 `
  -IsoFolder C:\SQLMedia `
  -ExcludedSqlInstances @('MSSQLSERVER\TEST', 'MSSQLSERVER\DEV')
```

## Example 4: With Proxy Configuration

For environments requiring proxy configuration:

```PowerShell
.\install-payg-sql-server.ps1 `
  -AzureSubscriptionId <subscription_id> `
  -AzureResourceGroup <resource_group> `
  -AzureRegion westus2 `
  -IsoFolder C:\SQLMedia `
  -Proxy "http://proxy.contoso.com:8080"
```

# Post-Installation

After successful installation:
1. Verify the SQL Server instance is running
2. Check Azure portal to confirm the Arc-enabled SQL Server resource is created
3. Review the license type is set to PAYG
4. Monitor billing in Azure Cost Management
5. Consider enabling additional features:
   - Best Practices Assessment (requires Paid or PAYG license)
   - Migration Assessment (enabled by default)
   - Performance Monitoring (preview, enabled by default)
   - Microsoft Defender for Cloud
   - Automated backups (preview)

# Billing Information

**When are you charged?**
- Charges begin when the SQL Server instance is running and connected to Azure Arc
- Billing granularity: 1 hour (charges apply for any usage within an hour)
- No charges when VM or SQL Server instance is stopped

**Billing rules:**
- Minimum 4 cores per instance (SQL Server licensing terms)
- Full core count of the machine is billed (affinity mask doesn't reduce charges)
- Intermittent connectivity doesn't stop billing; usage is reported when connectivity is restored
- Offline for >30 days: billing resumes when machine reconnects

**Cost optimization tips:**
- Stop SQL Server instances and VMs when not in use
- Use scheduled start/stop for predictable workloads
- Monitor usage in Arc-enabled SQL Server Billing dashboard
- Subscribe to Activity Log events for billing notifications

# Additional Resources

- [SQL Server enabled by Azure Arc - Overview](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/overview?view=sql-server-ver17)
- [Manage licensing and billing](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/manage-license-billing?view=sql-server-ver17)
- [PAYG Billing FAQ](../arc-sql-faq#pay-as-you-go-billing)
- [SQL Server Licensing Guide](https://www.microsoft.com/licensing/docs/view/SQL-Server)
