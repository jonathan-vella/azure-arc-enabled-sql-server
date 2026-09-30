# Use cases for SQL Server enabled by Azure Arc
Version: v1.2026.09
Last updated: 2026-09-30

Use these examples to decide where Arc SQL helps first. They stay close to supported features and avoid product
marketing.

> [!IMPORTANT]
> PAYG licensing and migration targets can change Azure charges. Validate billing choices before you enable them.

## Use case 1: estate inventory and policy

Start here when the team does not trust its SQL inventory. Arc SQL discovers instances on Arc-enabled servers and
surfaces them as Azure resources that you can query and tag.

Use it when you need to:

- find supported and unsupported SQL versions
- group servers by owner, region, or business unit
- apply Azure RBAC and policy to the SQL resource

Example query:

```kusto
resources
| where type == "microsoft.azurearcdata/sqlserverinstances"
| project name, resourceGroup, location, properties.version, properties.edition
```

## Use case 2: security hardening without a new local toolset

Arc SQL helps when the security team wants Azure controls without moving the server first.

- Least privilege is the default for the Azure extension for SQL Server.
- Managed identity is GA.
- Disabling SQL authentication is GA for SQL Server 2025 on Windows.
- Monitoring is still preview, so treat it as an optional add-on, not a baseline requirement.

Read [security benefits](security-benefits.md) for the current boundaries and the preview list.

## Use case 3: licensing and support lifecycle

Arc SQL is useful when licensing choices change by workload.

| Situation | Why Arc SQL helps |
| --- | --- |
| Short-lived or variable workloads | PAYG can fit better than fixed capacity planning |
| Stable workloads with existing licensing | Paid and LicenseOnly keep the SQL resource in Azure without forcing PAYG |
| Mixed estate with old and new deployments | One resource model is easier to review than separate local records |

Keep billing choices separate from the first technical rollout. Onboard servers first, then change license settings
after review.

## Use case 4: migration planning and portal migration

Arc SQL helps when you need a current view of migration readiness before choosing a target.

- Migration assessment is GA and runs on a schedule for supported instances.
- Portal migration to SQL Managed Instance is GA.
- Portal migration to SQL Server on Azure VMs is GA.
- Azure SQL Database remains a preview target.

For a guided walkthrough, start with [Module 12](../arc-sql-hands-on-lab/modules/12-migration.md).

## Use case 5: guided adoption in a lab

Use the lab when a team needs a safe path instead of a slide deck.

- [Module 0](../arc-sql-hands-on-lab/modules/00-infrastructure.md) sets up the Azure side.
- [Module 3](../arc-sql-hands-on-lab/modules/03-sql-extension.md) deploys the extension.
- [Module 11](../arc-sql-hands-on-lab/modules/11-disable-sql-auth.md) covers SQL authentication disablement.
- [Module 12](../arc-sql-hands-on-lab/modules/12-migration.md) covers migration assessment and portal migration.

## Learn more

- [Overview][overview]
- [Best practices assessment][assess]
- [Migration assessment][migration-assessment]
- [Manage licensing and billing][license]

[overview]: https://learn.microsoft.com/sql/sql-server/azure-arc/overview?view=sql-server-ver17
[assess]: https://learn.microsoft.com/sql/sql-server/azure-arc/assess?view=sql-server-ver17
[migration-assessment]: https://learn.microsoft.com/sql/sql-server/azure-arc/migration-assessment?view=sql-server-ver17
[license]: https://learn.microsoft.com/sql/sql-server/azure-arc/manage-license-billing?view=sql-server-ver17
