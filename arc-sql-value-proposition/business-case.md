# Business case for SQL Server enabled by Azure Arc
Version: v1.2026.09
Last updated: 2026-09-30

This page is a decision aid. It avoids ROI claims and focuses on where Arc SQL usually reduces friction, where it can
change spend, and when it is reasonable to wait.

## Where Arc SQL saves time

| Problem | How Arc SQL helps |
| --- | --- |
| SQL inventory is spread across scripts, tickets, and local notes | Arc SQL creates one Azure resource model for supported instances |
| Access reviews depend on local server access | Azure RBAC moves SQL resource access review into Azure |
| Migration planning starts from stale data | Migration assessment gives a current readiness view in the portal |
| Security guidance differs by server | A shared Azure control plane makes review and rollout more consistent |

Read [use cases](use-cases.md) for examples and [security benefits](security-benefits.md) for the current security
baseline.

## Where spend can change

> [!IMPORTANT]
> PAYG licensing, migration targets, and any preview feature that stores data in Azure can change monthly spend.
> Review billing impact before enablement.

| Choice | Cost effect to review |
| --- | --- |
| PAYG licensing | SQL billing can move from fixed licensing to usage-based charges |
| Migration to SQL Managed Instance | Azure compute, storage, and networking charges apply |
| Migration to SQL Server on Azure VMs | VM, storage, backup, and networking charges apply |
| Monitoring or backup previews | Preview scope can change before GA |

Backup to URL with managed identity is GA. Automated backups and PITR are still preview, so budget planning should
treat them separately.

## When Arc SQL is a good fit

Arc SQL is usually worth the effort when you need one or more of these outcomes:

- a current inventory for a hybrid SQL estate
- Azure RBAC and Microsoft Entra ID aligned with SQL resource management
- migration assessment before choosing a target
- a controlled path to PAYG for selected workloads

## When to defer

Defer a wider rollout when:

- the estate is very small and already well documented
- outbound connectivity to Azure is not available
- the team is relying on preview-only features for the first business case

In those cases, start with one lab or pilot instead of a large rollout.

## Evaluation checklist

1. Review the [overview page](README.md) for the current GA and preview split.
2. Run the [hands-on lab](../arc-sql-hands-on-lab/README.md) if the team needs a shared baseline.
3. Use [Module 11](../arc-sql-hands-on-lab/modules/11-disable-sql-auth.md) for SQL authentication disablement.
4. Use [Module 12](../arc-sql-hands-on-lab/modules/12-migration.md) for assessment and portal migration.
5. Keep [Module 13](../arc-sql-hands-on-lab/modules/13-cleanup.md) in scope when you estimate lab cost.

## References

- [Manage licensing and billing][license]
- [Migration overview][migration-overview]
- [Migration assessment][migration-assessment]

[license]: https://learn.microsoft.com/sql/sql-server/azure-arc/manage-license-billing?view=sql-server-ver17
[migration-overview]: https://learn.microsoft.com/sql/sql-server/azure-arc/migration-overview?view=sql-server-ver17
[migration-assessment]: https://learn.microsoft.com/sql/sql-server/azure-arc/migration-assessment?view=sql-server-ver17
