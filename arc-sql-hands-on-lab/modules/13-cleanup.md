# Module 13: Lab cleanup

Version: v1.2026.09
Last updated: 2026-09-30

Remove the lab resource groups and disconnect the Azure Connected Machine agent from the lab
server. This module only removes the `arcsql-lab-*` resource groups that the core lab creates.

## Prerequisites

- Azure PowerShell access to the subscription that hosts `arcsql-lab-arc-rg` and
  `arcsql-lab-monitoring-rg`
- Local administrator access on the lab server if you need to disconnect or uninstall the Azure
  Connected Machine agent manually

> [!IMPORTANT]
> If you created extra resources in Module 11 or Module 12, remove them by following those module
> instructions before you run this cleanup. This module only targets the `arcsql-lab-*` resource
> groups and the local Arc agent.

## Steps

### 1. Review what the cleanup script removes

The cleanup script is `scripts\Cleanup-Lab.ps1`. It:

- Optionally disconnects and uninstalls the Azure Connected Machine agent from the local machine
- Deletes `arcsql-lab-arc-rg`
- Deletes `arcsql-lab-monitoring-rg`

The script doesn't remove unrelated resource groups or migration targets that you created outside
the base lab deployment.

### 2. Run the cleanup script

From the `arc-sql-hands-on-lab` folder, run:

```powershell
.\scripts\Cleanup-Lab.ps1 `
    -SubscriptionId "<subscription-id>" `
    -BaseName "arcsql-lab"
```

Review the resource list that the script prints. Type `YES` when the script asks for confirmation.

### 3. Disconnect the Arc agent manually if needed

If the script can't disconnect the server, run the same commands on the lab machine in an elevated
PowerShell session.

```powershell
& "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" disconnect --force-local-only
& "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" uninstall
```

### 4. Remove the lab resource groups manually if needed

If the script can't delete the resource groups, remove only the two lab groups.

```powershell
Remove-AzResourceGroup -Name "arcsql-lab-arc-rg" -Force
Remove-AzResourceGroup -Name "arcsql-lab-monitoring-rg" -Force
```

### 5. Verify that cleanup completed

Check that the Arc services are gone from the lab server.

```powershell
Get-Service -Name "himds", "GCArcService", "ExtensionService" -ErrorAction SilentlyContinue
```

Check that the two lab resource groups no longer exist.

```powershell
Get-AzResourceGroup -Name "arcsql-lab-arc-rg" -ErrorAction SilentlyContinue
Get-AzResourceGroup -Name "arcsql-lab-monitoring-rg" -ErrorAction SilentlyContinue
```

## Validate

- `arcsql-lab-arc-rg` no longer exists.
- `arcsql-lab-monitoring-rg` no longer exists.
- The local machine no longer has the Azure Connected Machine agent installed.
- `Get-Service` doesn't return `himds`, `GCArcService`, or `ExtensionService`.

## Troubleshooting

For general lab issues, see [Troubleshooting](../TROUBLESHOOTING.md).

Back to the [module index](../README.md#modules).
