# Module 0: Infrastructure setup

Version: v1.2026.09
Last updated: 2026-09-30

Deploy the lab resource groups and Log Analytics workspace in `swedencentral`. When you finish, the Azure
resources and provider registrations are ready for Arc onboarding.

## Prerequisites
- Review [Prerequisites](../PREREQUISITES.md).
- Use a management workstation with Azure PowerShell and Azure CLI installed.

## Steps
### 1. Clone the lab repository
Clone the repository if you do not already have a local copy.

```powershell
git clone https://github.com/jonathan-vella/azure-arc-enabled-sql-server.git
Set-Location .\azure-arc-enabled-sql-server\arc-sql-hands-on-lab
```

### 2. Review the deployment files
Review [main.bicep](../bicep/main.bicep), [log-analytics.bicep](../bicep/modules/log-analytics.bicep), and
[deploy.ps1](../bicep/deploy.ps1). The template deploys the `arcsql-lab-arc-rg` and
`arcsql-lab-monitoring-rg` resource groups and a Log Analytics workspace.

### 3. Deploy the lab infrastructure
Run the deployment script from the `arc-sql-hands-on-lab` folder.

```powershell
Connect-AzAccount
Set-AzContext -Subscription "<your-subscription-id>"

pwsh .\bicep\deploy.ps1 `
  -SubscriptionId "<your-subscription-id>" `
  -BaseName "arcsql-lab" `
  -Environment "dev" `
  -Location "swedencentral"
```

### 4. Register the remaining Arc resource providers
The deployment script registers `Microsoft.HybridCompute`, `Microsoft.AzureArcData`, and
`Microsoft.OperationalInsights`. Azure Arc server onboarding also needs `Microsoft.GuestConfiguration` and
`Microsoft.HybridConnectivity`.

```powershell
$providers = @(
  'Microsoft.HybridCompute'
  'Microsoft.AzureArcData'
  'Microsoft.OperationalInsights'
  'Microsoft.GuestConfiguration'
  'Microsoft.HybridConnectivity'
)

$providers | ForEach-Object {
  Register-AzResourceProvider -ProviderNamespace $_ | Out-Null
}

Get-AzResourceProvider -ProviderNamespace $providers |
  Select-Object ProviderNamespace, RegistrationState
```

## Validate
- In the Azure portal, confirm that `arcsql-lab-arc-rg` and `arcsql-lab-monitoring-rg` exist in
  `swedencentral`.
- Confirm that the Log Analytics workspace was created in `arcsql-lab-monitoring-rg`.
- Confirm that `bicep\deployment-outputs.json` exists after the deployment finishes.
- Confirm that all five resource providers show `Registered`.

## Troubleshooting
- If `pwsh .\bicep\deploy.ps1` fails before the deployment starts, run `az --version` and
  `az bicep version` on the workstation.
- If the script stops on an authorization error, verify the selected subscription with `Get-AzContext` and run
  `Set-AzContext` again.
- If either lab resource group name is already in use, remove the existing groups or rerun the script with a
  different `-BaseName`.

Back to the [module index](../README.md#modules).
