- @azure Rule - Use Azure Best Practices: When generating code for Azure, running terminal commands for Azure,
  or performing operations related to Azure, invoke your `azure_development-get_best_practices` tool if available.

# Purpose

This repository holds documentation, a hands-on lab, and PowerShell scripts for SQL Server enabled by Azure Arc.
Prose rules are in `.github/instructions/markdown.instructions.md` and `.github/skills/unslop/SKILL.md`.

# Repository layout

| Folder | Contents |
| --- | --- |
| `arc-sql-hands-on-lab/` | Lab README (module index), `modules/`, PREREQUISITES, QUICKSTART, `bicep/`, `scripts/` |
| `arc-sql-modify-license-type/` | Upstream script that changes license type at scale (keep unchanged) |
| `arc-sql-report-reclass-extension-status/` | Upstream report and reclass extension status script |
| `arc-sql-best-practice-assessment/`, `arc-sql-monitoring/`, `arc-sql-connectivity/`, `arc-sql-data-collection/` | Feature docs |
| `arc-sql-faq/`, `arc-sql-value-proposition/`, `arc-sql-videos/`, `arc-sql-presentation-files/` | Reference and sales material |

# Workflows

- Scripts are PowerShell 7 first. Start with `Connect-AzAccount` and `Set-AzContext -Subscription <id>`.
- Typical modules: `Az.Accounts`, `Az.Resources`, `Az.ConnectedMachine`, `Az.ResourceGraph`.
- Validate docs with `pwsh .github/scripts/check-docs.ps1` before committing.
- Lint scripts with `Invoke-ScriptAnalyzer -Path . -Recurse -Settings ./PSScriptAnalyzerSettings.psd1`.
- Preview infrastructure changes with `az deployment sub what-if`. Do not run `deploy.ps1` to test.

# Project conventions

- Tags: `ArcOnboarding = Blocked` and `ArcSQLServerExtensionDeployment = Disabled` block automatic onboarding.
- Extension names: `WindowsAgent.SqlServer` (Windows) and `LinuxAgent.SqlServer` (Linux).
- Extension settings used in scripts: `LicenseType` (`PAYG`, `Paid`, `LicenseOnly`), `ConsentToRecurringPAYG`,
  `enableExtendedSecurityUpdates`, and `ExcludedSqlInstances`.
- Some scripts accept passwords as `[string]`. Do not change parameter types or signatures without maintainer approval.

# Safety rules

- Do not change billing or licensing properties (`LicenseType`, `ConsentToRecurringPAYG`, SQLServerLicense resources)
  without explicit user approval.
- Do not remove or alter the `ArcSQLServerExtensionDeployment` or `ArcOnboarding` tag logic unless asked.
- Pass explicit `-Subscription`, `-ResourceGroup`, and `-Location` arguments, and confirm before destructive actions.

# Pull requests

- Prefer backward-compatible parameters.
- Include an example command and the required modules in the description.
- Store credentials in Key Vault and document any migration.

# Example: PAYG extension with consent payload

```powershell
$settings = @{
  SqlManagement = @{ IsEnabled = $true }
  LicenseType = 'PAYG'
  enableExtendedSecurityUpdates = $false
  ExcludedSqlInstances = @('MSSQLSERVER\TEST')
  ConsentToRecurringPAYG = @{ Consented = $true; ConsentTimestamp = ([DateTime]::UtcNow.ToString('o')) }
}
New-AzConnectedMachineExtension -ResourceGroupName $rg -MachineName $name -Name 'WindowsAgent.SqlServer' `
  -Publisher 'Microsoft.AzureData' -ExtensionType 'WindowsAgent.SqlServer' -Location $region `
  -Settings $settings -EnableAutomaticUpgrade
```
