# Module 11: Disable SQL authentication

Version: v1.2026.09
Last updated: 2026-09-30

Restrict the SQL Server instance to Microsoft Entra ID and Windows authentication from the Azure portal, then confirm
the setting and practice the recovery path.

> [!IMPORTANT]
> This module needs SQL Server 2025 on Windows. The lab baseline (SQL Server 2022) does not support the setting, so
> skip this module if your lab server runs an earlier version.

Disabling SQL authentication blocks every new SQL login sign-in, including `sa`. Existing sessions stay connected.
Logins and users keep their definitions and permissions, so re-enabling the setting restores access.

## Prerequisites

- Completed [Module 3](03-sql-extension.md) with SQL Server 2025 (17.x) on Windows.
- Azure extension for SQL Server version `1.1.3394.392` or later. Auto-upgrade normally provides it.
- A primary managed identity on the instance. Step 2 sets it if it is missing.
- The Owner or Contributor role on the SQL Server - Azure Arc resource.
- A Microsoft Entra user that you can sign in with.

## Steps

### 1. Create and test an Entra administrator login

Connect to the instance with a Windows administrator account and create a login for your Microsoft Entra user:

```sql
CREATE LOGIN [<user@contoso.com>] FROM EXTERNAL PROVIDER;
GRANT ALTER ANY LOGIN TO [<user@contoso.com>];
GRANT ALTER ANY USER TO [<user@contoso.com>];
```

The lab grants only the permissions it needs, as the
[Microsoft Learn guidance](https://learn.microsoft.com/sql/sql-server/azure-arc/disable-sql-authentication?view=sql-server-ver17)
recommends. Grant `sysadmin` only if you need it for other tasks.

Open a new connection in SQL Server Management Studio with **Microsoft Entra MFA** as the authentication method.
Do not continue until this connection succeeds.

### 2. Disable SQL authentication in the portal

1. In the Azure portal, open your **SQL Server - Azure Arc** resource.
1. Under **Settings**, select **Microsoft Entra ID**.
1. Select **Use a primary managed identity** if it is not already selected.
1. Select **Disable SQL Authentication**, then select **Save**.

The extension applies the change in a few minutes without a restart. Wait for the `Saved successfully` message.
If you see `Extended call failed`, wait a few minutes and select **Save** again.

### 3. Verify the setting

Run this query from your Microsoft Entra connection:

```sql
SELECT SERVERPROPERTY('IsExternalAuthenticationOnly') AS SqlAuthDisabled;
```

The value `1` means SQL authentication is disabled. Then try a new connection with a SQL login. It fails with error
18456.

### 4. Re-enable SQL authentication

1. On the same **Microsoft Entra ID** pane, clear **Disable SQL Authentication** and select **Save**.
1. Run the query from step 3 again after the portal confirms the change. The value returns to `0`.

Azure role-based access control governs this setting, not a SQL Server connection. You can always restore SQL
authentication from the portal if you lose data-plane access.

## Validate

- Your Microsoft Entra login connects before and after you disable SQL authentication.
- `IsExternalAuthenticationOnly` returns `1` while the setting is on and `0` after you clear it.
- A new SQL login connection fails while the setting is on.

## Related resources

- [Disable SQL authentication for SQL Server enabled by Azure Arc](https://learn.microsoft.com/sql/sql-server/azure-arc/disable-sql-authentication?view=sql-server-ver17)
- [Troubleshooting](../TROUBLESHOOTING.md)

Back to the [module index](../README.md#modules).
