# Azure Arc-Enabled SQL Server

Version: v1.2025.12
Last updated: 2025-12-16

This repository contains scripts and utilities for managing SQL Server instances enabled by Azure Arc.

## Why Azure Arc for SQL Server?

Azure Arc extends Azure management capabilities to SQL Server instances running anywhere—on-premises, edge locations, or other clouds. **[Explore the value proposition →](arc-sql-value-proposition/)**

**Key benefits**:
- **Unified management**: Single control plane for your entire SQL Server estate
- **Flexible licensing**: Pay-as-you-go billing and license mobility options
- **Enhanced security**: Microsoft Defender, Entra ID authentication, and unified governance
- **Modernization path**: Migration assessment and ESU coverage for end-of-support versions

| Document | Description |
|----------|-------------|
| [Value Proposition Overview](arc-sql-value-proposition/) | Executive summary and benefits by role |
| [Business Case](arc-sql-value-proposition/business-case.md) | Operational and cost flexibility analysis |
| [Use Cases](arc-sql-value-proposition/use-cases.md) | Real-world implementation scenarios |
| [Security Benefits](arc-sql-value-proposition/security-benefits.md) | Security and compliance capabilities |

## Overview

**SQL Server enabled by Azure Arc** extends Azure services to SQL Server instances hosted outside of Azure: in your data center, in edge site locations like retail stores, or any public cloud or hosting provider. Managing SQL Server through Azure Arc can also be configured for SQL Server VMs in Azure VMware Solution.

With Azure Arc, you can:

- **Manage at scale**: Manage all SQL Server instances from a single point of control in Azure, with detailed inventory of instances and databases
- **Auto-connect**: Automatically connect SQL Server instances discovered on Arc-enabled servers in supported regions
- **Best practices assessment**: Optimize configuration for performance and security with automated assessments
- **Migration assessment**: Automatically assess migration readiness with cloud readiness analysis, risk identification, and Azure SQL configuration recommendations
- **Performance monitoring (preview)**: Monitor SQL Server performance from Azure portal with built-in dashboards
- **Microsoft Entra authentication**: Utilize modern centralized identity and access management (requires SQL Server 2022 or later)
- **Microsoft Defender for Cloud**: Discover and mitigate database vulnerabilities with threat protection
- **Microsoft Purview integration**: Unified data governance with access policies and easier connection to Purview
- **Pay-as-you-go licensing**: Purchase SQL Server using a pay-as-you-go model instead of traditional licenses (available for SQL Server 2012-2022)
- **Extended Security Updates (ESUs)**: Access security updates for up to three years after end-of-support
- **Automated backups (preview)**: Automatically perform backups to local storage or network shares
- **Point-in-time restore (preview)**: Restore databases to a specific point in time
- **Least privilege mode**: Operate with minimum required permissions for enhanced security

### Architecture

![SQL Server - Azure Arc Architecture](media/sql%20server%20-%20azure%20arc%20-%20architecture%20diagram.png)

## Repository Contents

This repository contains scripts for various Azure Arc-enabled SQL Server management tasks:

### Arc SQL Server Resource Management
- [`arc-sql-namespace-migration/migrate-to-azure-arc-data.ps1`](arc-sql-namespace-migration/migrate-to-azure-arc-data.ps1): Migrate SQL Server - Azure Arc resources from legacy `Microsoft.AzureData` namespace to current `Microsoft.AzureArcData` namespace.

### Licensing Management
- [`arc-sql-activate-pcore-license`](arc-sql-activate-pcore-license): Scripts and guidance for activating P-Core licensing for SQL Server in Azure Arc.
- [`arc-sql-install-payg-sql-server`](arc-sql-install-payg-sql-server): Install SQL Server with Pay-As-You-Go licensing via Azure Arc.
- [`arc-sql-modify-license-type`](arc-sql-modify-license-type): Modify license type for existing SQL Server instances in Azure Arc.

### Monitoring and Management
- [`arc-sql-monitoring`](arc-sql-monitoring): Configure monitoring features for Azure Arc-enabled SQL Server.
- [`arc-sql-data-collection`](arc-sql-data-collection): Documentation on the data collection process and categories for SQL Server enabled by Azure Arc, including usage metrics, monitoring data, and privacy considerations.
- [`arc-sql-report-reclass-extension-status`](arc-sql-report-reclass-extension-status): Report on SQL Azure Arc reclassification status.
- [`arc-sql-uninstall-azure-extension-for-sql-server`](arc-sql-uninstall-azure-extension-for-sql-server): Uninstall Azure extension for SQL Server.
- [`arc-sql-connectivity`](arc-sql-connectivity): Documentation and tools for checking network connectivity for Azure Connected Machine Agent, essential for Azure Arc-enabled SQL Server functionality.
- [`arc-sql-best-practice-assessment`](arc-sql-best-practice-assessment): Enable and manage SQL Best Practices Assessment; includes an at-scale Azure Policy guide.

### Onboarding Automation
- [`arc-server-onboarding-automation`](arc-server-onboarding-automation): Scripts and documentation for automating the onboarding of servers to Azure Arc.

### Hands-On Lab 🆕
- [`arc-sql-hands-on-lab`](arc-sql-hands-on-lab): **Comprehensive 2-hour hands-on lab** covering end-to-end Azure Arc-enabled SQL Server deployment and management. Includes Bicep infrastructure templates, step-by-step guides for onboarding, license management, monitoring, Best Practices Assessment, and Azure Policy governance at scale. Perfect for IT Pros, System Administrators, and Cloud Architects.

### Learning Resources
- [`arc-sql-faq`](arc-sql-faq): Comprehensive FAQ covering common questions about deployment, licensing, security, features, and troubleshooting.
- [`arc-sql-videos`](arc-sql-videos): Collection of instructional videos about Azure Arc-enabled SQL Server, including overview, monitoring features, and migration assessment demonstrations.
- [`arc-sql-presentation-files`](arc-sql-presentation-files): Presentation materials related to Azure Arc-enabled SQL Server, suitable for technical briefings, customer presentations, and education.

## Prerequisites

- **Azure subscription**: Active subscription required ([create free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?icid=azurefreeaccount))
- **Supported SQL Server versions**: SQL Server 2012 (11.x) and later (64-bit only)
- **Operating systems**:
  - Windows: Windows 10/11, Windows Server 2012 and later
  - Linux: Ubuntu 20.04 (x64), RHEL 8 (x64), SLES 15 (x64)
- **.NET Framework**: .NET Framework 4.7.2 or later on Windows (for extension version 1.1.2504.99+)
- **PowerShell**: PowerShell 7.0 or higher for automation scripts
- **Azure PowerShell module**: Required for script-based management
- **Azure RBAC permissions**: 
  - Azure Connected Machine Onboarding role
  - Contributor or Owner role for full management
- **Network connectivity**: 
  - Outbound HTTPS on TCP port 443
  - Access to `*.<region>.arcdataservices.com`
- **Resource providers**: `Microsoft.AzureArcData` and `Microsoft.HybridCompute` must be registered
- **Arc Connected Machine agent**: Must be installed and running in full mode

## Important Notes

### Auto-Connect and Extension Deployment
- **Auto-connect**: Azure Arc automatically installs the Azure extension for SQL Server when a server connected to Azure Arc has SQL Server installed. All SQL Server instance resources are automatically created in Azure.
- The Arc-enabled SQL Server resource uses the same region and resource group as the Arc-enabled server resource.
- A tag `ArcSQLServerExtensionDeployment = Disabled` on the Arc-enabled server resource prevents automatic SQL extension deployment.

### Feature Availability
- **Best Practices Assessment**: Supports license types Paid or PAYG (not LicenseOnly) and currently runs on Windows hosts only.
- **Monitoring (preview)**: Available for Enterprise and Standard editions on Windows (requires SQL Server 2016 SP1 or later for SQL 2016).
- **Microsoft Entra authentication**: Requires SQL Server 2022 (16.x) or later.
- **Most features**: Available on Windows; limited feature set on Linux (see documentation for details).

### Supported Regions
Arc-enabled SQL Server is available in 25+ Azure regions including East US, West US, West Europe, UK South, Australia East, and more. For successful onboarding, assign the same region to both Arc-enabled Server and Arc-enabled SQL Server.

### Unsupported Configurations
- Windows Server 2012 or older (TLS requirements)
- SQL Server in containers
- SQL Server 2008 and older versions
- SQL Server in Azure Virtual Machines
- Multiple instances with same name on same host
- Instance names containing `#` symbol

## Getting Started

1. Clone this repository:
   ```
   git clone https://github.com/microsoft/azure-arc-enabled-sql-server.git
   cd azure-arc-enabled-sql-server
   ```

2. Navigate to the script directory for your desired task.
3. Follow the instructions in the script or README for that specific task.

## Learn More

### Getting Started
- [SQL Server enabled by Azure Arc - Overview](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/overview?view=sql-server-ver17)
- [Prerequisites](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/prerequisites?view=sql-server-ver17)
- [Deployment options](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/deployment-options?view=sql-server-ver17)
- [Connect your SQL Server to Azure Arc](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/connect?view=sql-server-ver17)
- [Manage automatic connection (auto-connect)](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/manage-autodeploy?view=sql-server-ver17)

### Key Features
- [Best practices assessment](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/assess?view=sql-server-ver17)
- [Migration assessment](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/migration-assessment?view=sql-server-ver17)
- [Monitoring (preview)](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/sql-monitoring?view=sql-server-ver17)
- [Microsoft Entra authentication](https://learn.microsoft.com/en-us/sql/relational-databases/security/authentication-access/azure-ad-authentication-sql-server-overview?view=sql-server-ver17)
- [Extended Security Updates](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/extended-security-updates?view=sql-server-ver17)

### Management
- [Manage licensing and billing](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/manage-license-billing?view=sql-server-ver17)
- [Configure least privilege mode](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/configure-least-privilege?view=sql-server-ver17)
- [View inventory](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/view-inventory?view=sql-server-ver17)

### Additional Resources
- [Frequently Asked Questions](arc-sql-faq)
- [Release notes](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/release-notes?view=sql-server-ver17)
- [Known issues](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/known-issues?view=sql-server-ver17)
- [Troubleshooting](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/troubleshoot-deployment?view=sql-server-ver17)
- [Azure Arc documentation](https://learn.microsoft.com/en-us/azure/azure-arc/)

## Security Best Practices

- Always follow the principle of least privilege when assigning permissions
- Use Managed Identity for authentication when possible
- Keep Azure Arc agents updated to the latest versions 
- Regularly review security recommendations in Microsoft Defender for Cloud
- Implement network security controls to protect SQL Server instances
- **Never commit credentials or secrets to source control** - See [TEMPLATE-FILES.md](TEMPLATE-FILES.md) for details on our template file system

## Contributing

This project welcomes contributions and suggestions. Please follow the standard GitHub pull request process.

---

© Microsoft Corporation. Licensed under the Apache License, Version 2.0.