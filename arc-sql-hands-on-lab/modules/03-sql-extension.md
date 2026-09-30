# Module 3: SQL Server extension

Version: v1.2026.09
Last updated: 2026-09-30

Confirm that Azure Arc deployed the SQL Server extension and discovered the local SQL Server instance. When you
finish, the SQL Server resource appears in Azure and the extension runs with least privilege by default.

## Prerequisites
- Review [Prerequisites](../PREREQUISITES.md).
- Complete [Module 2](02-arc-onboarding.md).
- Confirm that SQL Server is installed and running on the connected Windows Server.

## Steps
### 1. Confirm the expected extension behavior
When a Windows Server connected to Azure Arc has SQL Server installed, Azure Arc deploys the
`WindowsAgent.SqlServer` extension from `Microsoft.AzureData` automatically.

> [!NOTE]
> The current auto-upgrade target for the Azure extension for SQL Server is `1.1.3518.465`. On supported
> current builds, least privilege is the default behavior. The extension creates the
> `NT SERVICE\SqlServerExtension` login and grants only the permissions required by enabled features.

### 2. Check the Arc machine extension
Open the Arc machine in the Azure portal and review **Extensions**. You can also query the extension from
PowerShell.

```powershell
Get-AzConnectedMachineExtension `
  -ResourceGroupName "arcsql-lab-arc-rg" `
  -MachineName "<your-server-name>" |
  Where-Object Name -eq "WindowsAgent.SqlServer" |
  Format-List Name, ProvisioningState, Publisher, ExtensionType, EnableAutomaticUpgrade
```

### 3. Check the local extension service account
Run the following command on the Windows Server to confirm that the extension service is running with least
privilege.

```powershell
Get-CimInstance Win32_Service |
  Where-Object DisplayName -eq "Microsoft SQL Server Extension Service" |
  Select-Object Name, StartName, State
```

### 4. Validate the SQL Server resource
In the Azure portal, go to **Azure Arc** > **SQL Server** and confirm that the SQL Server instance appears. Open
the resource and review the instance version, edition, and host mapping.

## Validate
- Confirm that the Arc machine shows the `WindowsAgent.SqlServer` extension in the **Succeeded** state.
- Confirm that the SQL Server instance appears under **Azure Arc** > **SQL Server**.
- Confirm that the local service account is `NT SERVICE\SqlServerExtension`.
- Confirm that you did not need to grant the extension login `sysadmin` manually.

## Troubleshooting
- If the extension does not appear, wait a few minutes and refresh the Arc machine. Automatic deployment is not
  always immediate after server onboarding.
- If the extension still does not deploy, confirm that SQL Server is running and that the Arc machine does not
  have the `ArcSQLServerExtensionDeployment = Disabled` tag.

> [!IMPORTANT]
> If you rerun SQL Server registration from the portal, the flow asks you to choose a license option. `Paid`,
> `PAYG`, and recurring PAYG consent affect billing. Use only the option approved for this lab.

- If the SQL Server resource is still missing, use the **Azure Arc** > **SQL Server** onboarding flow to
  generate a fresh registration script and rerun registration on the server.

Back to the [module index](../README.md#modules).
