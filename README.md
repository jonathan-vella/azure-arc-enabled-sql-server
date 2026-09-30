# SQL Server enabled by Azure Arc
Version: v1.2026.09
Last updated: 2026-09-30

![SQL Server enabled by Azure Arc](media/azure-arc-sql-banner.gif)

Use this repository to onboard SQL Server to Azure Arc, manage licensing, review assessments,
and run the hands-on lab.

## Start here

| Task | Link |
| --- | --- |
| Prepare the lab environment | [Lab prerequisites](arc-sql-hands-on-lab/PREREQUISITES.md) |
| Run the full lab | [Hands-on lab module index](arc-sql-hands-on-lab/README.md#modules) |
| Deploy lab infrastructure | [Module 0: Infrastructure setup](arc-sql-hands-on-lab/modules/00-infrastructure.md) |
| Connect a server to Azure Arc | [Module 2: Arc onboarding](arc-sql-hands-on-lab/modules/02-arc-onboarding.md) |
| Install the Azure extension for SQL Server | [Module 3: SQL Server extension](arc-sql-hands-on-lab/modules/03-sql-extension.md) |
| Change license type or ESU settings | [License management](arc-sql-modify-license-type/README.md) |
| Generate an extension status report | [Extension status report](arc-sql-report-reclass-extension-status/README.md) |
| Troubleshoot connectivity | [Connectivity guide](arc-sql-connectivity/README.md) |

The lab now uses one file per module. Start with the
[hands-on lab module index](arc-sql-hands-on-lab/README.md#modules), which includes Module 11:
Disable SQL authentication and Module 12: Migration assessment and portal migration.

## Current feature status

For the current support matrix, use the
[release notes][learn-release-notes]. Key points as of 2026-09-30:

- Least privilege is enabled by default starting with extension `1.1.3518.465`.
- Managed identity and backup to URL are generally available.
- Migration to Azure SQL Managed Instance and to SQL Server on Azure VMs from the Azure portal
  are generally available.
- Disabling SQL authentication is generally available for SQL Server 2025 on Windows.
- Monitoring, automated backups, point-in-time restore, and the Linux extension remain preview.
- Only Azure extension for SQL Server versions released within the last year are supported.

## Repository contents

| Folder | Description |
| --- | --- |
| [arc-sql-best-practice-assessment](arc-sql-best-practice-assessment/) | Configure and review SQL best practices assessments |
| [arc-sql-connectivity](arc-sql-connectivity/) | Validate required endpoints and outbound connectivity |
| [arc-sql-data-collection](arc-sql-data-collection/) | Review data collection categories and privacy information |
| [arc-sql-faq](arc-sql-faq/) | Read operational and support FAQs |
| [arc-sql-hands-on-lab](arc-sql-hands-on-lab/) | Run the end-to-end lab with one file per module |
| [arc-sql-modify-license-type](arc-sql-modify-license-type/) | Change license type, P-Core, and ESU settings |
| [arc-sql-monitoring](arc-sql-monitoring/) | Configure monitoring and preview monitoring features |
| [arc-sql-presentation-files](arc-sql-presentation-files/) | Access slide decks and presentation files |
| [arc-sql-report-reclass-extension-status](arc-sql-report-reclass-extension-status/) | Export extension status and license reports |
| [arc-sql-value-proposition](arc-sql-value-proposition/) | Review business and security positioning |
| [arc-sql-videos](arc-sql-videos/) | Watch recorded walkthroughs |

## Microsoft Learn documentation

### Getting started

- [Overview][learn-overview]
- [Prerequisites][learn-prereqs]
- [Deployment options][learn-deploy]
- [Connect your SQL Server to Azure Arc][learn-connect]

### Key features

- [Best practices assessment][learn-bpa]
- [Migration assessment][learn-migration]
- [Disable SQL authentication][learn-disable-sql-auth]
- [Monitoring][learn-monitoring]
- [Extended Security Updates][learn-esu]

### Management and troubleshooting

- [Manage licensing and billing][learn-license]
- [Configure least privilege][learn-lpp]
- [View inventory][learn-inventory]
- [Troubleshoot deployment][learn-troubleshoot]
- [Known issues][learn-known-issues]
- [Release notes][learn-release-notes]

## Support and security

- Review the official [prerequisites][learn-prereqs] and
  [unsupported configurations][learn-unsupported] before onboarding production systems.
- Prefer Microsoft Entra ID and least-privilege access where the feature supports it.
- Do not commit credentials or secrets. See [TEMPLATE-FILES.md](TEMPLATE-FILES.md).

## Contributing

Use the standard GitHub pull request process for documentation and script changes.

<!-- Reference links -->
[learn-overview]: https://learn.microsoft.com/sql/sql-server/azure-arc/overview?view=sql-server-ver17
[learn-prereqs]: https://learn.microsoft.com/sql/sql-server/azure-arc/prerequisites?view=sql-server-ver17
[learn-deploy]: https://learn.microsoft.com/sql/sql-server/azure-arc/deployment-options?view=sql-server-ver17
[learn-connect]: https://learn.microsoft.com/sql/sql-server/azure-arc/connect?view=sql-server-ver17
[learn-bpa]: https://learn.microsoft.com/sql/sql-server/azure-arc/assess?view=sql-server-ver17
[learn-migration]: https://learn.microsoft.com/sql/sql-server/azure-arc/migration-assessment?view=sql-server-ver17
[learn-disable-sql-auth]: https://learn.microsoft.com/sql/sql-server/azure-arc/disable-sql-authentication?view=sql-server-ver17
[learn-monitoring]: https://learn.microsoft.com/sql/sql-server/azure-arc/sql-monitoring?view=sql-server-ver17
[learn-esu]: https://learn.microsoft.com/sql/sql-server/azure-arc/extended-security-updates?view=sql-server-ver17
[learn-license]: https://learn.microsoft.com/sql/sql-server/azure-arc/manage-license-billing?view=sql-server-ver17
[learn-lpp]: https://learn.microsoft.com/sql/sql-server/azure-arc/configure-least-privilege?view=sql-server-ver17
[learn-inventory]: https://learn.microsoft.com/sql/sql-server/azure-arc/view-inventory?view=sql-server-ver17
[learn-troubleshoot]: https://learn.microsoft.com/sql/sql-server/azure-arc/troubleshoot-deployment?view=sql-server-ver17
[learn-known-issues]: https://learn.microsoft.com/sql/sql-server/azure-arc/known-issues?view=sql-server-ver17
[learn-release-notes]: https://learn.microsoft.com/sql/sql-server/azure-arc/release-notes?view=sql-server-ver17
[learn-unsupported]: https://learn.microsoft.com/sql/sql-server/azure-arc/overview?view=sql-server-ver17#unsupported-configurations
