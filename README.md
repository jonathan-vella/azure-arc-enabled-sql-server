# Azure Arc-Enabled SQL Server

![Azure Arc-Enabled SQL Server](media/azure-arc-sql-banner.gif)

Version: v1.2025.12  
Last updated: 2025-12-16

Extend Azure management to SQL Server instances running anywhere—on-premises, edge, or other clouds.

![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?logo=powershell&logoColor=white)
![Bicep](https://img.shields.io/badge/Bicep-0078D4?logo=microsoft-azure&logoColor=white)
![Last updated](https://img.shields.io/badge/updated-2025--12-blue)

---

## 🚀 Most common tasks

| Task | Link |
|------|------|
| Onboard a server to Azure Arc | [Hands-on lab Module 2][lab-module2] |
| Change license type (PAYG ↔ Paid) | [License management](arc-sql-modify-license-type/README.md) |
| Enable Best Practices Assessment | [BPA setup](arc-sql-best-practice-assessment/README.md) |
| Troubleshoot connectivity | [Connectivity guide](arc-sql-connectivity/README.md) |

---

## 📖 Start here

Use the links below to find the right documentation for your task.

### 1. Get started / prerequisites

[Prerequisites](arc-sql-hands-on-lab/PREREQUISITES.md) – What you need before onboarding

### 2. Onboard Azure Arc servers

[Module 2: Arc onboarding][lab-module2] – Connect on-premises servers to Azure Arc

### 3. Install / configure SQL extension

[Module 3: SQL extension][lab-module3] – Deploy the Azure extension for SQL Server

### 4. Licensing (PAYG / Paid / ESU)

[License management](arc-sql-modify-license-type/README.md) – Manage license types and billing

### 5. Best Practices Assessment

[BPA guide](arc-sql-best-practice-assessment/README.md) – Run and review SQL best practices

### 6. Monitoring / feature flags

[Monitoring](arc-sql-monitoring/README.md) – Enable advanced monitoring and feature flags

### 7. Reporting / audits

[Extension status report](arc-sql-report-reclass-extension-status/README.md) – Generate reports

### 8. Hands-on lab

[Full lab](arc-sql-hands-on-lab/README.md) – End-to-end guided lab (~2 hours)

### 9. Troubleshooting / connectivity

[Connectivity](arc-sql-connectivity/README.md) – Diagnose and fix connectivity issues

### 10. Reference

- [FAQ](arc-sql-faq/README.md)
- [Videos](arc-sql-videos/README.md)
- [Presentations](arc-sql-presentation-files/README.md)

---

## Why Azure Arc for SQL Server?

Azure Arc extends Azure management capabilities to SQL Server instances running anywhere.
**[Explore the value proposition →](arc-sql-value-proposition/README.md)**

**Key benefits:**

- **Unified management** – Single control plane for your entire SQL Server estate
- **Flexible licensing** – Pay-as-you-go billing and license mobility options
- **Enhanced security** – Microsoft Defender, Microsoft Entra ID authentication, unified governance
- **Modernization path** – Migration assessment and ESU coverage for end-of-support versions

---

## Prerequisites

Before you begin, ensure you have:

- **Azure subscription** – [Create a free account][azure-free]
- **SQL Server 2012 or later** – 64-bit only
- **Supported OS** – Windows Server 2012+ or Windows 10/11; Linux (Ubuntu 20.04, RHEL 8, SLES 15)
- **.NET Framework 4.7.2+** – Windows only (extension 1.1.2504.99+)
- **PowerShell 7.0+** – For automation scripts
- **Network** – Outbound HTTPS (TCP 443) to `*.<region>.arcdataservices.com`
- **Azure RBAC** – Azure Connected Machine Onboarding role (minimum)

For full details, see [Prerequisites on Microsoft Learn][learn-prereqs].

---

## Unsupported configurations

The following are **not supported**:

- SQL Server running in containers
- SQL Server 2008 / 2008 R2 or older
- SQL Server in Azure VMs (use native Azure management)
- Instance names containing `#`
- Multiple instances with the same name on the same host

For the complete list, see [Unsupported configurations][learn-unsupported].

---

## Repository contents

| Folder | Description |
|--------|-------------|
| [arc-sql-best-practice-assessment](arc-sql-best-practice-assessment/) | SQL Best Practices Assessment |
| [arc-sql-connectivity](arc-sql-connectivity/) | Network connectivity validation tools |
| [arc-sql-data-collection](arc-sql-data-collection/) | Data collection categories and privacy info |
| [arc-sql-faq](arc-sql-faq/) | Frequently asked questions |
| [arc-sql-hands-on-lab](arc-sql-hands-on-lab/) | End-to-end hands-on lab with Bicep templates |
| [arc-sql-modify-license-type](arc-sql-modify-license-type/) | Modify license type, P-Core, and ESU settings |
| [arc-sql-monitoring](arc-sql-monitoring/) | Configure monitoring and feature flags |
| [arc-sql-presentation-files](arc-sql-presentation-files/) | Slide decks and presentation materials |
| [arc-sql-report-reclass-extension-status](arc-sql-report-reclass-extension-status/) | Extension status reports |
| [arc-sql-value-proposition](arc-sql-value-proposition/) | Business case and security benefits |
| [arc-sql-videos](arc-sql-videos/) | Instructional videos |

---

## Microsoft Learn documentation

### Getting started

- [Overview][learn-overview]
- [Prerequisites][learn-prereqs]
- [Deployment options][learn-deploy]
- [Connect your SQL Server to Azure Arc][learn-connect]

### Key features

- [Best practices assessment][learn-bpa]
- [Migration assessment][learn-migration]
- [Monitoring (preview)][learn-monitoring]
- [Microsoft Entra authentication][learn-entra]
- [Extended Security Updates][learn-esu]

### Management

- [Manage licensing and billing][learn-license]
- [Configure least privilege mode][learn-lpp]
- [View inventory][learn-inventory]

### Troubleshooting

- [Troubleshooting guide][learn-troubleshoot]
- [Known issues][learn-known-issues]
- [Release notes][learn-release-notes]

---

## Security best practices

- Follow the principle of least privilege when assigning permissions
- Use Managed Identity for authentication when possible
- Keep Azure Arc agents updated to the latest versions
- Review security recommendations in Microsoft Defender for Cloud
- **Never commit credentials or secrets** – See [TEMPLATE-FILES.md](TEMPLATE-FILES.md)

---

## Contributing

This project welcomes contributions and suggestions. Please follow the standard GitHub pull request
process.

---

© Microsoft Corporation. Licensed under the Apache License, Version 2.0.

<!-- Reference links -->
[azure-free]: https://azure.microsoft.com/pricing/purchase-options/azure-account?icid=azurefreeaccount
[lab-module2]: arc-sql-hands-on-lab/README.md#module-2-arc-server-onboarding-15-minutes
[lab-module3]: arc-sql-hands-on-lab/README.md#module-3-sql-server-extension-deployment--auto-discovery-15-minutes
[learn-overview]: https://learn.microsoft.com/sql/sql-server/azure-arc/overview?view=sql-server-ver17
[learn-prereqs]: https://learn.microsoft.com/sql/sql-server/azure-arc/prerequisites?view=sql-server-ver17
[learn-deploy]: https://learn.microsoft.com/sql/sql-server/azure-arc/deployment-options?view=sql-server-ver17
[learn-connect]: https://learn.microsoft.com/sql/sql-server/azure-arc/connect?view=sql-server-ver17
[learn-bpa]: https://learn.microsoft.com/sql/sql-server/azure-arc/assess?view=sql-server-ver17
[learn-migration]: https://learn.microsoft.com/sql/sql-server/azure-arc/migration-assessment?view=sql-server-ver17
[learn-monitoring]: https://learn.microsoft.com/sql/sql-server/azure-arc/sql-monitoring?view=sql-server-ver17
[learn-entra]: https://learn.microsoft.com/sql/relational-databases/security/authentication-access/azure-ad-authentication-sql-server-overview?view=sql-server-ver17
[learn-esu]: https://learn.microsoft.com/sql/sql-server/azure-arc/extended-security-updates?view=sql-server-ver17
[learn-license]: https://learn.microsoft.com/sql/sql-server/azure-arc/manage-license-billing?view=sql-server-ver17
[learn-lpp]: https://learn.microsoft.com/sql/sql-server/azure-arc/configure-least-privilege?view=sql-server-ver17
[learn-inventory]: https://learn.microsoft.com/sql/sql-server/azure-arc/view-inventory?view=sql-server-ver17
[learn-troubleshoot]: https://learn.microsoft.com/sql/sql-server/azure-arc/troubleshoot-deployment?view=sql-server-ver17
[learn-known-issues]: https://learn.microsoft.com/sql/sql-server/azure-arc/known-issues?view=sql-server-ver17
[learn-release-notes]: https://learn.microsoft.com/sql/sql-server/azure-arc/release-notes?view=sql-server-ver17
[learn-unsupported]: https://learn.microsoft.com/sql/sql-server/azure-arc/overview?view=sql-server-ver17#unsupported-configurations