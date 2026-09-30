# Security benefits of SQL Server enabled by Azure Arc
Version: v1.2026.09
Last updated: 2026-09-30

This page covers the security features that matter most in current Arc SQL deployments. It focuses on what is GA
today and labels the preview areas clearly.

## Security baseline after onboarding

After you connect a supported server and deploy the Azure extension for SQL Server, you can use Azure RBAC, Microsoft
Entra ID integration, and Microsoft Defender for SQL from the Azure resource.

That baseline does not require you to enable every optional feature on day one. Start with inventory and access
control, then add the features that match your policy.

## Least privilege is now the default

Least privilege is the default for the Azure extension for SQL Server as of extension `1.1.3518.465`.
The extension uses the local login `NT SERVICE\SqlServerExtension`.

That change matters because older guidance often assumed broader local rights. If you are validating a rollout, check
the installed extension version before you compare the current behavior to older screenshots or scripts.

## Microsoft Entra ID and SQL authentication

Managed identity is GA. It is also a prerequisite for newer security features such as disabling SQL authentication.

> [!IMPORTANT]
> Disabling SQL authentication is GA only for SQL Server 2025 on Windows. Before you enable it, confirm that at
> least one Microsoft Entra or Windows admin login works.

Use this query to verify the final state:

```sql
SELECT SERVERPROPERTY('IsExternalAuthenticationOnly');
```

A value of `1` means SQL authentication is disabled. Existing sessions are not dropped, but new SQL logins, including
`sa`, are blocked until you re-enable SQL authentication from Azure.

## What stays in preview

| Feature | Status | Notes |
| --- | --- | --- |
| ⚠️ Monitoring | Preview | Do not make it a baseline requirement for first rollout |
| ⚠️ Automated backups and PITR | Preview | Backup automation is still preview even though backup to URL is GA |
| ⚠️ Linux extension | Preview | Linux Arc SQL extension remains preview |

⚠️ Preview features are subject to the [supplemental terms of use][preview-terms].

## References

- [Configure least privilege][least-privilege]
- [Disable SQL authentication][disable-sql-auth]
- [SQL Server enabled by Azure Arc overview][overview]
- [Defender for SQL in Defender for Cloud][defender]

[preview-terms]: https://azure.microsoft.com/support/legal/preview-supplemental-terms/
[least-privilege]: https://learn.microsoft.com/sql/sql-server/azure-arc/configure-least-privilege?view=sql-server-ver17
[disable-sql-auth]: https://learn.microsoft.com/sql/sql-server/azure-arc/disable-sql-authentication?view=sql-server-ver17
[overview]: https://learn.microsoft.com/sql/sql-server/azure-arc/overview?view=sql-server-ver17
[defender]: https://learn.microsoft.com/azure/defender-for-cloud/defender-for-sql-usage
