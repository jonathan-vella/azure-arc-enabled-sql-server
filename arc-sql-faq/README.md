# Frequently asked questions for SQL Server enabled by Azure Arc

Version: v1.2026.09
Last updated: 2026-09-30

Use this FAQ for the questions that come up most often when you connect SQL Server to Azure Arc.

## Table of contents

- [General questions](#general-questions)
- [Pay-as-you-go billing and licensing](#pay-as-you-go-billing-and-licensing)
- [Security](#security)
- [Associated services](#associated-services)
- [Extended Security Updates](#extended-security-updates)
- [Deployment and supported configurations](#deployment-and-supported-configurations)
- [Features](#features)
- [Troubleshooting](#troubleshooting)
- [Additional resources](#additional-resources)

## General questions

### Can I exclude SQL Server instances during onboarding?

Yes. Use the `excludedInstances` setting in Azure Policy or in the extension configuration to skip named
instances that you do not want to onboard.

### Is user data from my SQL Server instance sent to Azure?

No. SQL Server enabled by Azure Arc collects metadata, configuration details, inventory, and billing data.
It does not collect user data. Monitoring and assessment data are collected only when you enable those
features.

### Which Azure regions are supported?

Use a region that is supported for both Azure Arc-enabled servers and SQL Server enabled by Azure Arc.
Review the current supported region list in the prerequisites article before you deploy.

### Can I use it with Azure VMware Solution?

Yes. You can onboard SQL Server instances that run in Azure VMware Solution virtual machines. Follow the
Azure VMware Solution guidance for Arc onboarding.

## Pay-as-you-go billing and licensing

> [!IMPORTANT]
> Pay-as-you-go billing, license changes, and Extended Security Updates can affect charges. Review the
> current licensing article before you change `LicenseType`, enable PAYG, or subscribe to ESUs.

### Does pay-as-you-go billing stop if connectivity is interrupted?

No. Short interruptions do not stop billing. If the machine reconnects within 30 days, the extension uploads
usage data after connectivity returns. If the machine stays disconnected for more than 30 days, the PAYG
subscription expires.

### Am I billed when the virtual machine or SQL Server instance is stopped?

No. If the virtual machine is stopped, or if the SQL Server instance is not running, usage is not collected
for that time.

### Am I billed for a partial hour?

Yes. PAYG billing is hourly. Running for part of an hour still bills the full hour.

### What core count is billed with pay-as-you-go?

PAYG bills all cores that the machine or virtual machine can access, with a four-core minimum. Limiting SQL
Server with an affinity mask does not reduce charges.

### Can I switch between PAYG and license-only billing?

Yes. SQL Server enabled by Azure Arc supports the documented license modes, including `PAYG`, `Paid`, and
`LicenseOnly`. Review [Manage licensing and billing][manage-license-billing] before you change the mode.

### Do I need recurring billing consent in every Azure subscription?

No. The recurring PAYG consent flow applies to cloud solution provider managed subscriptions. Other Azure
subscription types do not use that consent flow.

### What should I do for planned offline periods longer than 30 days?

If you plan to keep the machine offline for more than 30 days, disconnect the SQL Server resource before the
extended outage and reconnect it when the workload is back in service.

### How can I track billing state and usage gaps?

Use the billing dashboard in the Azure portal, Azure Resource Graph queries, and activity logs for SQL
Server enabled by Azure Arc.

## Security

### What are the main security recommendations?

Use least privilege, keep the extension current, review Microsoft Defender for Cloud recommendations, and use
Microsoft Entra ID where it fits your environment.

### Is least privilege supported?

Yes. Least privilege is supported for SQL Server enabled by Azure Arc on Windows.

The current auto-upgrade target is extension version `1.1.3518.465`. In that version, least privilege is
enabled by default. The extension creates the `NT SERVICE\SqlServerExtension` login and grants only the
permissions required for enabled features.

Microsoft Learn also notes that version `1.1.3453.436` enabled least privilege by default, while versions
`1.1.3464.439`, `1.1.3494.451`, and `1.1.3500.453` do not enable it by default.

### Which account does the extension use?

When least privilege is enabled, the extension service runs as `NT SERVICE\SqlServerExtension`. When least
privilege is not enabled, it runs as Local System.

### How do I configure the minimum permissions for deployment?

Use the least privilege guidance for supported Windows deployments. Review the documented prerequisites before
you enable it. Least privilege is not currently supported on Linux.

### Does TLS inspection work with the Azure extension for SQL Server?

Yes, as long as the machine trusts the certificate presented by the TLS inspection device.

### Does SQL Server enabled by Azure Arc support private networking?

Use the documented private path and Azure Arc network requirement guidance. The data processing endpoint at
`*.<region>.arcdataservices.com` still has specific connectivity requirements, and a Private Link connection
for that service is not supported.

### Where can I review the permissions granted by the extension?

Review the permissions and service-account articles for Azure extension for SQL Server:

- [Configure Windows service accounts and permissions][windows-accounts]
- [Operate with least privilege][least-privilege]

## Associated services

### Which associated services can Azure Arc manage for licensing?

SQL Server enabled by Azure Arc can manage licensing for these associated services:

- SQL Server Analysis Services
- SQL Server Integration Services
- SQL Server Reporting Services
- Power BI Report Server

### How does licensing work for associated services?

A standalone associated service needs its own license or subscription. If the associated service is installed
with the SQL Server Database Engine on the same machine, it does not need a separate SQL Server license.
Review the associated services section in [Manage licensing and billing][manage-license-billing].

## Extended Security Updates

> [!IMPORTANT]
> ESU subscriptions affect billing. Review the ESU article and the product lifecycle dates before you enable
> ESUs on production servers.

### Which SQL Server versions are covered by ESU subscriptions enabled by Azure Arc?

The current ESU subscription article for SQL Server enabled by Azure Arc applies to SQL Server 2014 (12.x)
and SQL Server 2016 (13.x).

As of 2026-09-30:

- SQL Server 2014 is in its ESU period.
- SQL Server 2016 Year 1 ESU coverage started on 2026-07-14.
- SQL Server 2012 is no longer covered by the current Azure Arc ESU subscription article.

### How do I subscribe to ESUs?

You can get ESUs in two ways:

1. An Azure Arc ESU subscription that bills hourly and can be canceled.
2. A Volume Licensing ESU purchase, if that purchasing path fits your organization.

Azure Arc gives you subscription-based management in Azure and supports the current ESU workflow for SQL
Server 2014 and SQL Server 2016.

### How is ESU billing calculated?

ESU billing is based on all virtual cores for a virtual machine or all physical cores for a physical server,
with a four-core minimum.

If you subscribe after the current ESU year has already started, Azure bills back to the start of that ESU
year on the next invoice.

### Do passive high-availability or disaster-recovery replicas incur ESU charges?

Passive replicas can use failover rights when the underlying SQL Server licenses qualify for them. Review the
high-availability and disaster-recovery section in the ESU article for the exact requirements.

### What happens to ESUs after I upgrade or migrate?

When you move off the out-of-support version, you no longer need ESUs for that instance. Review the ESU
article before you upgrade or migrate so that billing and entitlement are handled correctly.

## Deployment and supported configurations

### How is SQL Server enabled by Azure Arc deployed?

For a server that is already connected to Azure Arc, the Azure extension for SQL Server discovers supported
instances and creates the Azure resources for them. You can deploy at scale with Azure Policy, PowerShell,
or other automation.

### How do I prevent automatic extension deployment?

Apply the tag `ArcSQLServerExtensionDeployment=Disabled` to the server before you connect it to Azure Arc.

### What happens during automatic connection?

On a supported server, Azure Arc deploys the SQL extension, discovers SQL Server instances, creates Azure
resources, and starts inventory and licensing workflows.

### Can I onboard only selected instances?

Yes. Use `excludedInstances` to skip specific instances during policy-based or scripted deployment.

### Which SQL Server versions and operating systems are supported?

Current Microsoft Learn prerequisites list these supported configurations:

- SQL Server 2014 (12.x) and later
- 64-bit SQL Server only
- Windows 10 and Windows 11
- Windows Server 2016 and later
- Ubuntu 20.04 (x64)
- Red Hat Enterprise Linux 8 (x64)
- SUSE Linux Enterprise Server 15 (x64)

### Which configurations are not supported?

Current unsupported configurations include:

- Windows Server versions earlier than Windows Server 2016
- SQL Server running in containers
- SQL Server Business Intelligence edition

### Can I migrate from the portal?

Yes. Migration to Azure SQL Managed Instance and migration to SQL Server on Azure VMs from the Azure portal
are both generally available.

## Features

### Which recently released features are generally available?

Recent generally available features include:

- Managed identity for SQL Server 2025 on Windows
- Backup to URL with managed identity for SQL Server 2025
- Migration to Azure SQL Managed Instance from the portal
- Migration to SQL Server on Azure VMs from the portal
- Disable SQL authentication for SQL Server 2025 on Windows
- Client connection summary

### Which features are still in preview?

> [!NOTE]
> ⚠️ Monitoring, automated backups, restore to a point in time, the Linux extension, and migration to Azure
> SQL Database are preview features. They are governed by the [supplemental terms of use][preview-terms].

### What is Microsoft Entra authentication in this context?

Microsoft Entra authentication lets SQL Server use Microsoft Entra ID instead of SQL logins for supported
scenarios.

For SQL Server 2025 on Windows, managed identity support is generally available. SQL Server 2025 on Windows
also supports disabling SQL authentication through Azure Arc. For SQL Server 2022, Microsoft Entra
integration continues to use the documented setup options for that version.

## Troubleshooting

### Why are my SQL Server instances not showing up in Azure?

Check these first:

- The Azure Connected Machine agent is installed and healthy.
- The SQL extension is installed.
- The server does not have `ArcSQLServerExtensionDeployment=Disabled`.
- The `Microsoft.AzureArcData` resource provider is registered.
- The server can reach the required Azure Arc and data-processing endpoints.
- The selected Azure region is supported.

### How do I check the extension version?

In the Azure portal, open the Arc-enabled server resource, select **Extensions**, and inspect
`WindowsAgent.SqlServer` or `LinuxAgent.SqlServer`.

Only Azure extension for SQL Server versions released within the last year are supported. Review the current
support policy in the [release notes][release-notes].

### Where are the extension logs?

Use these default paths:

- Windows: `C:\ProgramData\GuestConfig\extension_logs\Microsoft.AzureData.WindowsAgent.SqlServer\`
- Linux: `/var/lib/GuestConfig/extension_logs/Microsoft.AzureData.LinuxAgent.SqlServer/`

### How do I disconnect SQL Server from Azure Arc?

Delete the SQL Server enabled by Azure Arc resource in Azure. If you also want to remove the extension,
remove it from the Arc-enabled server resource.

### Where can I get help?

Start with the official troubleshooting and known issues articles. If you still need help, open an Azure
support request.

## Additional resources

- [Overview][overview]
- [Prerequisites][prerequisites]
- [Deployment options][deployment-options]
- [Release notes][release-notes]
- [Manage licensing and billing][manage-license-billing]
- [Extended Security Updates][esu]
- [Troubleshooting deployment][troubleshoot-deployment]
- [Known issues][known-issues]
- [Azure Arc documentation][azure-arc-docs]

[azure-arc-docs]: https://learn.microsoft.com/azure/azure-arc/
[deployment-options]: https://learn.microsoft.com/sql/sql-server/azure-arc/deployment-options?view=sql-server-ver17
[esu]: https://learn.microsoft.com/sql/sql-server/azure-arc/extended-security-updates?view=sql-server-ver17
[known-issues]: https://learn.microsoft.com/sql/sql-server/azure-arc/known-issues?view=sql-server-ver17
[least-privilege]: https://learn.microsoft.com/sql/sql-server/azure-arc/configure-least-privilege?view=sql-server-ver17
[manage-license-billing]: https://learn.microsoft.com/sql/sql-server/azure-arc/manage-license-billing?view=sql-server-ver17
[overview]: https://learn.microsoft.com/sql/sql-server/azure-arc/overview?view=sql-server-ver17
[preview-terms]: https://azure.microsoft.com/support/legal/preview-supplemental-terms/
[prerequisites]: https://learn.microsoft.com/sql/sql-server/azure-arc/prerequisites?view=sql-server-ver17
[release-notes]: https://learn.microsoft.com/sql/sql-server/azure-arc/release-notes?view=sql-server-ver17
[troubleshoot-deployment]: https://learn.microsoft.com/sql/sql-server/azure-arc/troubleshoot-deployment?view=sql-server-ver17
[windows-accounts]: https://learn.microsoft.com/sql/sql-server/azure-arc/configure-windows-accounts-agent?view=sql-server-ver17
