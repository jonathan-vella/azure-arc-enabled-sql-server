# Why use SQL Server enabled by Azure Arc?
Version: v1.2026.09
Last updated: 2026-09-30

SQL Server enabled by Azure Arc lets you manage supported SQL Server instances in Azure without moving them first.
It adds Azure inventory, policy, RBAC, migration assessment, and licensing controls to servers that stay
on-premises, at the edge, or in another cloud.

## What Azure Arc changes

- It discovers SQL Server instances and databases on Arc-enabled servers.
- It gives you Azure Resource Graph queries and Azure RBAC for the SQL resource.
- It adds migration assessment and portal migration workflows.
- It supports license management, including PAYG, Paid, and LicenseOnly.
- It lets you adopt features one at a time instead of moving the whole estate.

## Feature status as of 2026-09-30

| Capability | Status | Notes |
| --- | --- | --- |
| Inventory, resource model, and license management | GA | Core Arc SQL control plane |
| Least privilege for the SQL extension | GA | Default since extension `1.1.3518.465`; uses `NT SERVICE\\SqlServerExtension` |
| Managed identity | GA | Required for some newer security features |
| Backup to URL with managed identity | GA | Separate from automated backups |
| Migration assessment | GA | Weekly assessment for supported instances |
| Portal migration to SQL Managed Instance | GA | Azure portal workflow |
| Portal migration to SQL Server on Azure VMs | GA | Azure portal workflow |
| Disable SQL authentication | GA | SQL Server 2025 on Windows |
| ⚠️ Monitoring | Preview | Portal monitoring remains preview |
| ⚠️ Automated backups and PITR | Preview | Backup automation and restore workflow remain preview |
| ⚠️ Linux extension | Preview | Linux Arc SQL extension remains preview |

⚠️ Preview features are subject to the [supplemental terms of use][preview-terms].

## Start with the right document

- Read [use cases](use-cases.md) for scenario-based examples.
- Read [security benefits](security-benefits.md) for least privilege, Microsoft Entra ID, and preview boundaries.
- Read [business case](business-case.md) if you need an adoption checklist instead of a product pitch.
- Read [architecture diagrams](diagrams.md) for slide-ready visuals.
- Try the [hands-on lab](../arc-sql-hands-on-lab/README.md) for a guided walkthrough.

## Key Microsoft Learn references

- [Overview][overview]
- [Best practices assessment][assess]
- [Manage licensing and billing][license]
- [Migration overview][migration-overview]
- [Disable SQL authentication][disable-sql-auth]

[preview-terms]: https://azure.microsoft.com/support/legal/preview-supplemental-terms/
[overview]: https://learn.microsoft.com/sql/sql-server/azure-arc/overview?view=sql-server-ver17
[assess]: https://learn.microsoft.com/sql/sql-server/azure-arc/assess?view=sql-server-ver17
[license]: https://learn.microsoft.com/sql/sql-server/azure-arc/manage-license-billing?view=sql-server-ver17
[migration-overview]: https://learn.microsoft.com/sql/sql-server/azure-arc/migration-overview?view=sql-server-ver17
[disable-sql-auth]: https://learn.microsoft.com/sql/sql-server/azure-arc/disable-sql-authentication?view=sql-server-ver17
