# Frequently Asked Questions - SQL Server enabled by Azure Arc

This document provides answers to commonly asked questions about SQL Server enabled by Azure Arc.

Last updated: 2025-10-31

## Table of Contents

- [General FAQ](#general-faq)
- [Pay-as-you-go Billing](#pay-as-you-go-billing)
- [Security](#security)
- [Associated Services](#associated-services)
- [Extended Security Updates (ESU)](#extended-security-updates-esu)
- [Deployment and Configuration](#deployment-and-configuration)
- [Features and Capabilities](#features-and-capabilities)
- [Troubleshooting](#troubleshooting)

---

## General FAQ

### Can I exclude any SQL Server instances when I onboard with Azure Policy?

Yes, you can use the `excludedInstances` setting in the Azure Policy to indicate the SQL Server instances that you don't want to include in the onboarding process.

For example, if you have any standby instances, you might not want to view them in the portal. When you use Azure Policy to onboard, you can exclude such instances using pattern matching of the instance names.

**Steps:**
1. Create a copy of the definition provided in Azure to create a custom definition
2. Set the value for excluded instances in the custom definition
3. Target the subscription and resource group

### Is the data from my instance of SQL Server sent to Azure?

No. Microsoft only captures metadata and information about your SQL Server to help troubleshoot and inventory. The data sent doesn't include user data or information about your utilization of SQL Server.

The following types of data are collected:
- **Inventory data**: SQL Server version, edition, host OS, instance names, databases
- **Configuration data**: Settings and properties
- **Usage metrics**: For licensing and billing purposes only
- **Performance data**: Only when monitoring features are explicitly enabled
- **Assessment data**: For best practices and migration readiness assessments

### What Azure regions support SQL Server enabled by Azure Arc?

SQL Server enabled by Azure Arc is available in 25+ regions including:
- **Americas**: East US, East US 2, West US, West US 2, West US 3, Central US, North Central US, South Central US, West Central US, Canada Central, Canada East, Brazil South
- **Europe**: West Europe, North Europe, UK South, UK West, France Central, Switzerland North, Norway East, Sweden Central
- **Asia Pacific**: Southeast Asia, Japan East, Korea Central, Australia East, Central India
- **Government**: US Government Virginia (limited features)

**Important**: For successful onboarding, assign the same region to both Arc-enabled Server and Arc-enabled SQL Server.

### Can I use SQL Server enabled by Azure Arc with Azure VMware Solution (AVS)?

Yes, you can deploy SQL Server enabled by Azure Arc in VMware VMs running in Azure VMware Solution. However, you must follow the specific deployment steps outlined in [Deploy Arc-enabled Azure VMware Solution](https://learn.microsoft.com/en-us/azure/azure-vmware/deploy-arc-for-azure-vmware-solution) to enable a fully integrated experience with Arc capabilities within the AVS private cloud.

---

## Pay-as-you-go Billing

### Does pay-as-you-go billing stop charging when connectivity between the SQL Server resource and Azure is temporarily interrupted?

No, intermittent internet connectivity doesn't stop the pay-as-you-go billing. The usage is reported and accounted for by the billing logic when the connectivity is restored.

### Do I get charged if my virtual machine is stopped?

No. When the VM is stopped, the usage data isn't collected. Therefore, you won't be charged for the time the VM was stopped.

### Do I get charged if my SQL Server instance is stopped?

No. The usage data collection requires an active SQL Server instance. Therefore, you won't be charged for the time the SQL Server instance was stopped.

### Do I get charged if my SQL Server instance was running for less than an hour?

The billing granularity is one hour. If your instance was active for less than an hour, you are billed for the full hour.

### Is there a minimum number of cores with pay-as-you-go billing?

Pay-as-you-go billing doesn't change the licensing terms of SQL Server. Therefore, it's subject to the four-core minimum as defined in the [SQL Server licensing terms](https://www.microsoft.com/licensing/terms/productoffering/SQLServer/EAEAS).

### If the affinity mask is specified for my SQL Server to use a subset of virtual cores, will it reduce the pay-as-you-go charges?

No. When you run your SQL Server instance on a virtual or physical machine, you're required to license the full set of cores that the machine can access. Therefore, your pay-as-you-go charges are based on the full core count even if you use the affinity mask to limit your SQL Server's usage of these cores. See [SQL Server licensing guide](https://www.microsoft.com/licensing/docs/view/SQL-Server) for details.

### Can I switch from pay-as-you-go to license and vice versa?

Yes, you can change your selection. To change, run SQL Server Setup again, and choose the **Maintenance** tab, then select **Edition Upgrade**. The mode is now changed to Enterprise license. To revert back to pay-as-you-go, you can use the same steps and change the setting.

### I have an enterprise or a small business account with Microsoft, do I need to enable the recurring pay-as-you-go billing?

No. At this point, recurring billing is only enabled in the cloud solution provider (CSP) managed Azure subscriptions.

### How do I ensure that my VM and SQL Server are not billed when disconnected or turned off intentionally?

If the machine is offline for less than 30 days and then reconnects, the uploaded SQL Server usage will reflect the offline period, and the monthly invoice will account for it. If you keep the machine offline for longer than 30 days, the pay-as-you-go billing will resume when the machine is back online and reconnects to Azure Arc.

### If I have a server that is regularly disconnected for more than 30 days, what should I do?

**Option 1**: If you take your VM offline intentionally for a period longer than 30 days and stop using SQL Server, the pay-as-you-go billing will resume when the machine is back online and reconnects to Azure Arc.

**Option 2**: If your SQL Server instance is continuously running during the disconnected time period, you must restore the connectivity to stay compliant. Review [Troubleshoot extension](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/troubleshoot-extension?view=sql-server-ver17).

**Recommended approach for extended offline periods**: If you plan to keep the machine offline for longer than 30 days, disconnect the Arc-enabled SQL Server and then reconnect using one of the supported deployment options when you're ready to use it again.

### How can I be notified when a given machine does not send usage data or when recurring billing has happened?

You can:
- See the billing mode of each machine in the Arc-enabled SQL Server Billing dashboard in the Azure portal
- Write your own Azure Resource Graph (ARG) query to get the billing mode and last billed data points
- Subscribe to Activity Log events for when usage records are not received when expected or when recurring billing starts. Review [Use activity logs with SQL Server enabled by Azure Arc](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/activity-logs?view=sql-server-ver17)

---

## Security

### What are the best practices for security?

Review and implement [SQL Server enabled by Azure Arc best practices](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/security-overview?view=sql-server-ver17#best-practices). Key recommendations include:

- **Use least privilege mode**: Minimize permissions granted to the Azure extension for SQL Server
- **Implement network security**: Control access through firewalls and network security groups
- **Enable Microsoft Defender for Cloud**: Discover and mitigate database vulnerabilities
- **Use Microsoft Entra authentication**: Leverage modern authentication with MFA and SSO (requires SQL Server 2022+)
- **Keep agents updated**: Regularly update Azure Arc agents to the latest versions
- **Review security recommendations**: Regularly check Microsoft Defender for Cloud recommendations
- **Implement TDE**: Use Transparent Data Encryption for data at rest
- **Use Managed Identity**: Authenticate to Azure resources without storing credentials

### Is TDE with Azure Key Vault supported?

No. TDE with Azure Key Vault is not currently supported for SQL Server enabled by Azure Arc. You can manually set up TDE for your own instances using traditional methods.

### Is there Azure Key Vault support?

Yes, there is Key Vault support for SQL Server enabled by Azure Arc for storing the Microsoft Entra ID certificate used for authentication.

### Does SQL Server enabled by Azure Arc support Private Link?

Yes. SQL Server enabled by Azure Arc supports Private Link for most endpoints, but some endpoints don't require Private Link and some endpoints aren't supported. For specific information, see [Connected Machine agent network requirements](https://learn.microsoft.com/en-us/azure/azure-arc/servers/network-requirements?tabs=azure-cloud#urls).

**Note**: Private Link connections to the Azure Arc data processing service at the `<region>.arcdataservices.com` endpoint (used for inventory and usage upload) are not currently supported.

### What configuration changes are made?

You can find details on the roles created by the Azure extension for SQL Server at [Roles created by Azure extension for SQL Server installation](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/permissions-granted-agent-extension?view=sql-server-ver17).

### What is the URL list of endpoints that need to be opened up?

You need to open up the endpoint at `*.<region>.arcdataservices.com`. For specific information, review [Prerequisites - Connect to Azure Arc data processing service](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/prerequisites?view=sql-server-ver17#connect-to-azure-arc-data-processing-service).

### Does TLS inspection work with Azure Extension for SQL Server?

If your organization uses TLS inspection, the Azure Extension for SQL Server does not use certificate pinning and will continue to work, as long as your machine trusts the certificate presented by the TLS inspection service. For information on TLS inspection with Azure Arc-enabled server extension, see [Network Security](https://learn.microsoft.com/en-us/azure/azure-arc/servers/security-networking#general-networking).

### What are the details on the permissions assigned?

Review [Configure Windows service accounts and permissions for Azure extension for SQL Server](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/configure-windows-accounts-agent?view=sql-server-ver17).

### What user is the Microsoft SQL Server extension service running as?

- **When least privilege mode is enabled**: The service runs as the `NT Service\SQLServerExtension` account
- **When least privilege mode is disabled**: The service runs as Local System

To enable least privilege mode, review [Least privilege mode](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/configure-least-privilege?view=sql-server-ver17).

### Is least privilege mode supported for SQL Server enabled by Azure Arc?

Yes, least privilege mode is supported and recommended for SQL Server enabled by Azure Arc. 

**Important**: Existing servers with extension version `1.1.2859.223` or greater (released November 2024) will eventually have the least privileged configuration applied automatically. To prevent the automatic application of least privilege, block extension upgrades after `1.1.2859.223`.

Learn more about the permissions assigned at [Configure Windows service accounts and permissions for Azure extension for SQL Server](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/configure-windows-accounts-agent?view=sql-server-ver17).

### How do I set the minimum permissions to deploy SQL Server enabled by Azure Arc?

Least privilege mode uses minimum permissions to deploy SQL Server enabled by Azure Arc. To enable least privilege mode, review [Operate SQL Server enabled by Azure Arc with least privilege](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/configure-least-privilege?view=sql-server-ver17).

---

## Associated Services

### How does SQL Server enabled by Azure Arc license management work with associated services?

The associated services (such as SSRS, SSIS, SSAS, and Power BI Report Server) are represented as SQL Server instances in Azure Resource Manager (ARM) with a `service_type` property reflecting if it is an engine or an associated service installation.

Key points:
- Associated services can be connected to Azure Arc
- Pay-as-you-go billing is available for all service types
- ESU subscriptions are available for all service types
- SQL Server inventory includes all service types
- Most advanced features (Best Practices Assessment, Migration Assessment, etc.) are available only for SQL Server Database Engine

Review [Manage licensing and billing](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/manage-license-billing?view=sql-server-ver17) and [Extended Security Updates](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/extended-security-updates?view=sql-server-ver17) for details.

---

## Extended Security Updates (ESU)

### What are Extended Security Updates?

Extended Security Updates (ESUs) provide security updates for SQL Server instances that have reached the end of their support lifecycle. ESUs can extend support for up to three years after the end-of-support date.

### How do I subscribe to ESUs?

There are two ways to get ESUs:

1. **ESU Subscription through Azure Arc** (Recommended):
   - Continuous coverage until canceled
   - Billed hourly through Azure
   - Can be canceled at any time
   - Automatic cancellation when migrated to Azure or upgraded
   - Supports automatic and manual patch installation
   - Requires SQL Server to be connected to Azure Arc

2. **ESU Plan through Volume Licensing**:
   - Each year of coverage must be purchased separately
   - Must be paid in full
   - Differently priced by year
   - Requires registration on Azure portal
   - Supports manual installation of patches only

### What are the billing rules for ESUs?

**For virtual machines**:
- Billed for the total number of virtual cores of the machine (minimum 4 cores)
- VMs eligible for failover rights are not billable

**For physical servers**:
- Billed for all physical cores of the machine (minimum 4 cores)
- Physical servers eligible for failover rights are not billable

**Bill-back charges**:
- If you enroll after the end-of-support date, you'll receive a one-time bill-back charge for the months missed since the start of the current ESU year

### Can I use ESUs with high-availability and disaster recovery configurations?

Yes. SQL Server licenses with Software Assurance or pay-as-you-go (PAYG) can benefit from free passive instances of SQL Server for high availability and disaster recovery (HADR) configurations.

Azure Extension for SQL Server automatically detects passive instances for availability groups (AGs) or failover clustered instances (FCIs) and reflects the use by emitting special $0 meters for disaster recovery, as long as you configured the LicenseType property to `Paid` or `PAYG`.

### What happens to my ESU subscription when I upgrade or migrate?

- **Upgrade to newer SQL Server version**: ESU subscription is automatically canceled
- **Migrate to Azure SQL**: ESU charges automatically stop, but you continue to have access to the ESUs

---

## Deployment and Configuration

### How is Azure Arc-enabled SQL Server deployed?

Azure Arc automatically installs the Azure extension for SQL Server when a server connected to Azure Arc has SQL Server installed. All SQL Server instance resources are automatically created in Azure.

**Deployment methods**:
1. **Automatic connection**: Connect server to Azure Arc, SQL Server instances are automatically discovered
2. **Manual connection**: Use Azure portal, PowerShell, or CLI to explicitly connect instances
3. **At-scale deployment**: Use Azure Policy, Configuration Manager, or PowerShell scripts
4. **During SQL Server installation**: SQL Server 2022 can be connected to Azure Arc during installation (Windows only)

### How do I prevent automatic SQL extension deployment?

Add a tag to the Windows or Linux server with:
- **Name**: `ArcSQLServerExtensionDeployment`
- **Value**: `Disabled`

This tag must be added before connecting the server to Azure Arc.

### What happens during the automatic connection process?

When a server with SQL Server is connected to Azure Arc:
1. Azure Connected Machine agent is installed on the server
2. SQL Server instances are automatically discovered
3. Azure extension for SQL Server is deployed
4. SQL Server instance resources are created in Azure
5. New roles are applied to SQL Server and databases
6. Instance and database inventory begins

### Can I onboard SQL Server instances selectively?

Yes, you can use the `excludedInstances` setting in Azure Policy or extension configuration to exclude specific SQL Server instances based on pattern matching of instance names.

### What SQL Server versions and editions are supported?

**Versions**: SQL Server 2012 (11.x) and later (64-bit only)

**Editions**: Enterprise, Standard, Web, Express, Developer, Evaluation
- Note: Business Intelligence edition is not supported
- Express LocalDB is not supported

### What operating systems are supported?

**Windows**:
- Windows 10 and 11
- Windows Server 2012 R2 and later (Windows Server 2012 has limited support)

**Linux**:
- Ubuntu 20.04 (x64)
- Red Hat Enterprise Linux (RHEL) 8 (x64)
- SUSE Linux Enterprise Server (SLES) 15 (x64)

**Note**: Most features are available on Windows. Linux support is available but with a limited feature set.

### Can I use SQL Server enabled by Azure Arc with SQL Server in Azure VMs?

No. SQL Server instances running in Azure Virtual Machines are not supported with Azure Arc-enabled SQL Server. Azure VMs already have native Azure management capabilities.

### Can I run SQL Server enabled by Azure Arc in containers?

No. SQL Server running in containers is not currently supported.

---

## Features and Capabilities

### What features are available with different license types?

| Feature | License Only | License with SA or Subscription | Pay-as-you-go |
|---------|-------------|--------------------------------|---------------|
| Connect to Azure Arc | Yes | Yes | Yes |
| SQL Server inventory | Yes | Yes | Yes |
| Migration readiness | Yes | Yes | Yes |
| Database migration (preview) | Yes | Yes | Yes |
| Microsoft Entra authentication | Yes | Yes | Yes |
| Microsoft Defender for Cloud | Yes | Yes | Yes |
| Microsoft Purview | Yes | Yes | Yes |
| Best practices assessment | No | Yes | Yes |
| ESU subscription | No | Yes | Yes |
| Automated backups (preview) | No | Yes | Yes |
| Point-in-time restore | No | Yes | Yes |
| Automatic updates | No | Yes | Yes |
| Monitoring (preview) | No | Yes | Yes |
| Client connection summary | No | Yes | Yes |

### What is the difference between monitoring and best practices assessment?

**Monitoring (preview)**:
- Real-time performance monitoring from Azure portal
- Built-in performance dashboards
- Tracks active connections, database I/O, CPU, and memory usage
- Available for Enterprise and Standard editions on Windows
- Requires SQL Server 2016 SP1 or later

**Best Practices Assessment**:
- Evaluates configuration against Microsoft best practices
- Provides recommendations for performance and security improvements
- Runs on-demand or on a schedule
- Available for all editions on Windows
- Focuses on configuration, not real-time performance

### What is migration assessment?

Migration assessment is an automatic feature that:
- Provides cloud readiness analysis for migration to Azure
- Identifies risks and mitigation strategies
- Recommends the best Azure SQL target (SQL MI, Azure SQL DB, or SQL on Azure VM)
- Provides right-sized SKU recommendations based on performance data
- Estimates costs for recommended configurations
- Runs automatically once per week
- Is free and available for all SQL Server editions

### Can I disable automatic features?

Yes, most automatic features can be disabled:
- Migration assessment: Can be disabled per instance
- Best practices assessment: Disabled by default, must be explicitly enabled
- Performance monitoring: Enabled by default but can be disabled
- Automatic updates: Disabled by default

### What is Microsoft Entra authentication?

Microsoft Entra authentication (formerly Azure Active Directory) provides modern, centralized identity and access management for SQL Server 2022 and later. 

**Benefits**:
- Removes the need for password-based authentication
- Supports multi-factor authentication (MFA)
- Enables single sign-on (SSO)
- Uses managed identity for passwordless authentication to Azure resources
- Centralized identity management

**Requirements**:
- SQL Server 2022 (16.x) or SQL Server 2025 (17.x) Preview
- SQL Server enabled by Azure Arc
- Latest Azure extension for SQL Server

---

## Troubleshooting

### Why aren't my SQL Server instances showing up in Azure?

**Common causes**:
1. **Arc agent not installed**: Ensure the Azure Connected Machine agent is installed and running
2. **Extension not deployed**: Check if the Azure extension for SQL Server is installed
3. **Tag blocking deployment**: Check if the `ArcSQLServerExtensionDeployment = Disabled` tag is present
4. **Resource provider not registered**: Ensure `Microsoft.AzureArcData` is registered
5. **Network connectivity issues**: Verify access to `*.<region>.arcdataservices.com`
6. **Region not supported**: Verify the region is supported for Arc-enabled SQL Server

### How do I check the Azure extension version?

In Azure portal:
1. Navigate to your Arc-enabled server resource
2. Go to **Extensions** under Settings
3. Look for **WindowsAgent.SqlServer** (Windows) or **LinuxAgent.SqlServer** (Linux)
4. Check the version number

Alternatively, check the extension log file at:
`C:\ProgramData\GuestConfig\extension_logs\Microsoft.AzureData.WindowsAgent.SqlServer\`

### Best practices assessment is failing with connection errors

**Issue**: Assessment fails to connect to SQL Server

**Resolution**:
1. Verify SQL Server is online and accessible
2. Ensure `NT AUTHORITY\SYSTEM` is a member of the sysadmin server role (or configure least privilege mode)
3. Check that databases are online and updateable
4. Review connectivity using [Troubleshoot connectivity issues in SQL Server](https://learn.microsoft.com/en-us/troubleshoot/sql/database-engine/connect/resolve-connectivity-errors-overview)

### Azure Monitor Agent (AMA) upload failed for assessments

**Issue**: Assessment data isn't uploading to Log Analytics workspace

**Resolution**:
1. Verify the linked Log Analytics workspace has a table named `SqlAssessment_CL`
2. Ensure Azure Monitor Agent (version >= 1.10.0) is successfully provisioned
3. Check the Extensions tab under the Arc resource to verify AMA status

### How do I disconnect SQL Server from Azure Arc?

To disconnect:
1. Navigate to the SQL Server - Azure Arc resource in Azure portal
2. Select **Delete** to remove the Azure resource
3. The extension will remain on the server but stop reporting
4. To fully remove the extension, go to the Server - Azure Arc resource
5. Select **Extensions** and remove the Azure extension for SQL Server

For complete removal including the Arc agent, see [Disconnect SQL Server instances from Azure Arc](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/delete-from-azure-arc?view=sql-server-ver17).

### Extension is stuck in Creating or Deleting state

If the extension is stuck in an odd state for a long time:
1. Try to [disconnect your SQL Server instances from Azure Arc](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/delete-from-azure-arc?view=sql-server-ver17)
2. Reconnect using one of the supported deployment methods
3. If the issue persists, contact Microsoft Support

### Where can I find extension logs?

**Windows**:
- Extension logs: `C:\ProgramData\GuestConfig\extension_logs\Microsoft.AzureData.WindowsAgent.SqlServer\`
- Latest version log file: `unifiedagent.log`
- Older versions log file: `ExtensionLog_0.log`

**Linux**:
- Extension logs: `/var/lib/GuestConfig/extension_logs/Microsoft.AzureData.LinuxAgent.SqlServer/`

### How do I get support?

For support:
1. Review the [troubleshooting documentation](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/troubleshoot-deployment?view=sql-server-ver17)
2. Check [known issues](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/known-issues?view=sql-server-ver17)
3. Search the [Microsoft Q&A forum](https://learn.microsoft.com/answers/)
4. [Create an Azure support request](https://learn.microsoft.com/en-us/azure/azure-portal/supportability/how-to-create-azure-support-request)

---

## Additional Resources

- [SQL Server enabled by Azure Arc - Overview](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/overview?view=sql-server-ver17)
- [Prerequisites](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/prerequisites?view=sql-server-ver17)
- [Deployment options](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/deployment-options?view=sql-server-ver17)
- [Release notes](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/release-notes?view=sql-server-ver17)
- [Known issues](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/known-issues?view=sql-server-ver17)
- [Troubleshooting guides](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/troubleshoot-deployment?view=sql-server-ver17)
- [Azure Arc documentation](https://learn.microsoft.com/en-us/azure/azure-arc/)

---

**Note**: This FAQ is based on the latest Microsoft Learn documentation as of October 2025. Features and capabilities are subject to change. For the most up-to-date information, always refer to the official [Microsoft Learn documentation](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/).
