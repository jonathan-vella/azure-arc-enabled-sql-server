# Azure Arc-Enabled SQL Server

This repository contains scripts and utilities for managing SQL Server instances enabled by Azure Arc.

## Overview

**SQL Server enabled by Azure Arc** extends Azure management and governance capabilities to SQL Server instances hosted outside of Azure—including on-premises, edge, or other cloud environments. With Azure Arc, you can:

- Manage your SQL Server instances at scale from a single point of control in Azure
- Monitor performance and inventory across all connected SQL Server instances
- Assess migration readiness and receive recommendations for Azure SQL targets
- Enable advanced features such as Microsoft Defender for Cloud and Microsoft Purview integration
- Access Extended Security Updates (ESUs) for end-of-support SQL Server versions

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

### Onboarding Automation
- [`arc-server-onboarding-automation`](arc-server-onboarding-automation): Scripts and documentation for automating the onboarding of servers to Azure Arc.

### Learning Resources
- [`arc-sql-videos`](arc-sql-videos): Collection of instructional videos about Azure Arc-enabled SQL Server, including overview, monitoring features, and migration assessment demonstrations.
- [`arc-sql-presentation-files`](arc-sql-presentation-files): Presentation materials related to Azure Arc-enabled SQL Server, suitable for technical briefings, customer presentations, and education.

## Prerequisites

- Azure subscription
- Windows or Linux machine with SQL Server installed
- PowerShell 7.0 or higher
- Azure PowerShell module installed
- Appropriate Azure RBAC permissions
- Network connectivity to Azure (outbound HTTPS on TCP port 443)

## Important Notes

- For successful onboarding and functioning, assign the same region to both Arc-enabled Server and Arc-enabled SQL Server resources
- SQL Server enabled by Azure Arc is available in multiple Azure regions (see [documentation](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/overview?view=sql-server-ver16) for complete list)
- Review the [architecture](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/overview?view=sql-server-ver16#architecture) and [prerequisites](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/connect-sql-server-azure-arc?view=sql-server-ver16) before deployment

## Getting Started

1. Clone this repository:
   ```
   git clone https://github.com/microsoft/azure-arc-enabled-sql-server.git
   cd azure-arc-enabled-sql-server
   ```

2. Navigate to the script directory for your desired task.
3. Follow the instructions in the script or README for that specific task.

## Learn More

- [SQL Server enabled by Azure Arc - Overview](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/overview?view=sql-server-ver16)
- [Connect your SQL Server to Azure Arc](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/connect-sql-server-azure-arc?view=sql-server-ver16)
- [Configure SQL best practices assessment - SQL Server enabled by Azure Arc](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/sql-best-practices-assessment-azure-arc?view=sql-server-ver16)
- [Monitor SQL Server enabled by Azure Arc (preview)](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/monitor-sql-server-azure-arc?view=sql-server-ver16)
- [Azure Arc documentation](https://learn.microsoft.com/en-us/azure/azure-arc/)

## Security Best Practices

- Always follow the principle of least privilege when assigning permissions
- Use Managed Identity for authentication when possible
- Keep Azure Arc agents updated to the latest versions 
- Regularly review security recommendations in Microsoft Defender for Cloud
- Implement network security controls to protect SQL Server instances

## Contributing

This project welcomes contributions and suggestions. Please follow the standard GitHub pull request process.

---

© Microsoft Corporation. Licensed under the Apache License, Version 2.0.