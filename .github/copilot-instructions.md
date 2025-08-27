- @azure Rule - Use Azure Best Practices: When generating code for Azure, running terminal commands for Azure, or performing operations related to Azure, invoke your `azure_development-get_best_practices` tool if available.

# Purpose
Provide concise, actionable knowledge so an AI coding agent is immediately productive in this repository. Focus on the automation patterns used to onboard servers to Azure Arc and the SQL Server-specific workflows.

# Big-picture architecture (read these files first)
- arc-server-onboarding-automation/README.md — high-level onboarding flow (tenant, GDAP, Arc agent, tags).
- arc-server-onboarding-automation/scripts/Arc.ps1 and ConfigureServer.ps1 — partner/tenant onboarding, CMDB-driven provisioning (see `CMDB.csv`).
- arc-sql-install-payg-sql-server/install-payg-sql-server.ps1 — unattended SQL install + Arc onboarding + extension install; this is the canonical example for how scripts call Az modules and set extension settings.
- arc-sql-modify-license-type/ and arc-sql-uninstall-azure-extension-for-sql-server/ — follow licensing transitions and uninstall flows.

High-level flow (data & control): CMDB.csv -> PartnerCenter/GDAP -> create tenant/subscription -> deploy Arc Connected Machine agent -> install Azure extension for SQL Server -> Azure resources appear (Azure Arc > SQL Server instances) -> optional monitoring & licensing changes via extension settings.

# Critical developer workflows (how to run and debug)
- All scripts are PowerShell-first and expect an elevated shell. Start with `Connect-AzAccount` and `Set-AzContext -Subscription <id>` when testing locally.
- Required modules (typical): `AzureAD`, `Az.Accounts`, `Az.Resources`, `Az.ConnectedMachine`, `Az.ResourceGraph`. Use `Install-Module -Name <Module>` if missing.
- Example: run the PAYG installer (see README for complete parameter list):

```powershell
.\arc-sql-install-payg-sql-server\install-payg-sql-server.ps1 \
  -AzureSubscriptionId <sub> \
  -AzureResourceGroup <rg> \
  -AzureRegion <region> \
  -IsoFolder C:\Downloads \
  -ConsentToRecurringPAYG Yes \
  -ExcludedSqlInstances @('MSSQLSERVER\\TEST')
```

- Debugging: check extension provisioning & health in portal, or use the Resource Graph query embedded in `install-payg-sql-server.ps1`. Run `Search-AzGraph -Query '<query>'` to reproduce the script's status view.

# Project-specific conventions & patterns
- Tagging conventions used by scripts:
  - `ArcOnboarding = Blocked` (resource group-level marker used in onboarding scripts)
  - `ArcSQLServerExtensionDeployment = Disabled` (opt-out of auto-extension install)
- Extension names:
  - Windows: `WindowsAgent.SqlServer`
  - Linux: `LinuxAgent.SqlServer`
- Extension settings keys commonly used in scripts:
  - `LicenseType` ("PAYG" | "Paid" | "LicenseOnly")
  - `ConsentToRecurringPAYG` (script sets `{ Consented = true; ConsentTimestamp = <ISO UTC> }` for CSP scenarios)
  - `enableExtendedSecurityUpdates` (boolean)
  - `ExcludedSqlInstances` (array)
- PowerShell parameter choices: many scripts accept plaintext passwords as `[string]`. Do NOT change parameter types (to SecureString/PSCredential) without confirming with maintainers because callers and automation expect current signatures.

# Integration points & external dependencies
- Azure APIs: Azure Resource Manager, Connected Machine (Az.ConnectedMachine), Resource Graph, Log Analytics (monitoring/AMA), Azure Monitor endpoints (`telemetry.<region>.arcdataservices.com`).
- Partner Center & GDAP APIs: used by `arc-server-onboarding-automation` scripts — check `PartnerCenter.ps1` and `GDAP.ps1`.
- SQL Server installation media: scripts expect a local ISO folder and optional product-key files; installer flow mounts ISOs and runs `setup.exe` unattended.

# Safety and policy rules (must-follow)
- Do not modify billing or licensing properties (LicenseType, ConsentToRecurringPAYG, SQLServerLicense resources) without explicit user approval — these affect customer billing.
- Do not remove or alter `ArcSQLServerExtensionDeployment=Disabled` or `ArcOnboarding` tagging logic unless requested — they control auto-onboarding and safety fences.
- When generating Azure CLI/PowerShell commands, always prefer explicit `-Subscription`/`-ResourceGroup`/`-Location` arguments and require confirmation for destructive actions.

# Files to inspect before coding changes
1. `arc-server-onboarding-automation/README.md`
2. `arc-server-onboarding-automation/scripts/Arc.ps1` and `ConfigureServer.ps1`
3. `arc-sql-install-payg-sql-server/README.md` and `install-payg-sql-server.ps1`
4. `arc-sql-modify-license-type/` (scripts to change license types at scale)
5. `arc-sql-uninstall-azure-extension-for-sql-server/uninstall-azure-extension-for-sql-server.ps1`
6. Any `docs/*.md` under `arc-server-onboarding-automation/docs/` for process details

# Quick heuristics for PRs
- Prefer documentation updates (README/ docs) for process or parameter changes.
- Add backward-compatible parameters; avoid breaking existing script signatures.
- Include an example command and required modules in the PR description.
- For changes touching credentials or secrets, use Key Vault and document migration steps.

# Example patterns to reuse (copy-paste friendly)
- Create extension with PAYG + consent payload (PowerShell):

```powershell
$settings = @{
  SqlManagement = @{ IsEnabled = $true }
  LicenseType = 'PAYG'
  enableExtendedSecurityUpdates = $false
  ExcludedSqlInstances = @('MSSQLSERVER\\TEST')
  ConsentToRecurringPAYG = @{ Consented = $true; ConsentTimestamp = ([DateTime]::UtcNow.ToString('o')) }
}
New-AzConnectedMachineExtension -ResourceGroupName $rg -MachineName $name -Name 'WindowsAgent.SqlServer' -Publisher 'Microsoft.AzureData' -ExtensionType 'WindowsAgent.SqlServer' -Location $region -Settings $settings -EnableAutomaticUpgrade
```

# Final notes
- If anything is unclear or you need more context (sample CMDB rows, expected ISO layout, or partner-center secrets handling), ask and I will point to the exact file(s) and suggest minimal, safe edits.