# Module 2: Arc onboarding

Version: v1.2026.09
Last updated: 2026-09-30

Create a least-privilege service principal, install the Azure Connected Machine agent, and connect the Windows
Server to Azure Arc. When you finish, the server appears in Azure as a connected Arc machine.

## Prerequisites
- Review [Prerequisites](../PREREQUISITES.md).
- Complete [Module 0](00-infrastructure.md).
- Complete [Module 1](01-network-validation.md).
- Use a local administrator account on the target Windows Server.

## Steps
### 1. Create the onboarding service principal
Run [Create-ArcServicePrincipal.ps1](../scripts/Create-ArcServicePrincipal.ps1) on the management workstation.

```powershell
Set-Location .\scripts
pwsh .\scripts\Create-ArcServicePrincipal.ps1 `
  -SubscriptionId "<your-subscription-id>" `
  -ServicePrincipalName "Arc-SQL-Lab-Onboarding-SP" `
  -Scope "Subscription"
```

> [!IMPORTANT]
> Save the values from `service-principal-credentials.json` as soon as the script completes. The client secret
> is shown once.

### 2. Capture the values that `azcmagent` needs
Record the `ApplicationId`, `Secret`, `TenantId`, and `SubscriptionId` values from the script output. The
service principal is used only during onboarding.

### 3. Install the connected machine agent
Run the installation on the target Windows Server from an elevated PowerShell session.

```powershell
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri "https://aka.ms/AzureConnectedMachineAgent" `
  -OutFile "$env:TEMP\AzureConnectedMachineAgent.msi"

msiexec /i "$env:TEMP\AzureConnectedMachineAgent.msi" /qn /l*v `
  "$env:TEMP\InstallationLog.txt"
```

### 4. Connect the server to Azure Arc
Replace the placeholder values with the output from the service principal script.

```powershell
$servicePrincipalAppId = "<application-id>"
$servicePrincipalSecret = "<client-secret>"
$tenantId = "<tenant-id>"
$subscriptionId = "<subscription-id>"
$resourceGroup = "arcsql-lab-arc-rg"
$location = "swedencentral"

& "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect `
  --service-principal-id $servicePrincipalAppId `
  --service-principal-secret $servicePrincipalSecret `
  --tenant-id $tenantId `
  --subscription-id $subscriptionId `
  --resource-group $resourceGroup `
  --location $location
```

### 5. Validate the Arc connection
Check the local agent state after the connection completes.

```powershell
& "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" show
```

Then open the Azure portal and confirm that the server appears under **Azure Arc** > **Machines** with the
status **Connected**.

## Validate
- Confirm that the service principal was created with the `Azure Connected Machine Onboarding` role.
- Confirm that the server appears in `arcsql-lab-arc-rg` in `swedencentral`.
- Confirm that `azcmagent show` reports a connected machine.
- Confirm that the Azure portal shows the server as **Connected**.

## Troubleshooting
- If service principal creation fails with `ServiceManagementReference field is required for Create`, ask a
  Microsoft Entra ID administrator to grant `Application Administrator` or
  `Cloud Application Administrator`.
- If `azcmagent connect` fails, rerun [Module 1](01-network-validation.md) and confirm that all required Azure
  resource providers are registered.
- If the machine does not appear in Azure after the command succeeds, review
  `%ProgramData%\AzureConnectedMachineAgent\Log\azcmagent.log` on the server.

Back to the [module index](../README.md#modules).
