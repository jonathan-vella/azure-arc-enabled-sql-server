# Enable Best Practices Assessment at scale (Azure Policy + PowerShell)

This guide enables Best Practices Assessment (BPA) for many Arc-enabled SQL Server instances using a single Azure Policy assignment. It uses two resource groups: one for Arc resources and one dedicated to a Log Analytics workspace.

## Architecture

Arc RG (servers + SQL extension)         Policy Assignment (subscription scope)        Logs RG (workspace)
+-----------------------------------+     +--------------------------------------+     +---------------------------+
| Arc-enabled servers (Windows)     | <-- | Configure Arc-enabled Servers with   | --> | Log Analytics Workspace   |
|  • SQL extension (WindowsAgent...)|     | SQL Server extension installed to    |     |  (BPA results in Logs)    |
|  • Instances discovered           |     | enable or disable SQL best practices |     +---------------------------+
|  • Assessment runs weekly         |     | assessment                           |
+-----------------------------------+     +--------------------------------------+

Notes
- BPA supports SQL Server license types Paid or PAYG; LicenseOnly isn’t supported.
- Windows-only; Linux instances aren’t supported.
- If the workspace is in a different resource group than the SQL resources (recommended separation), assign the policy at subscription scope.

## Prerequisites

- Roles at target scope (subscription or resource group): Resource Policy Contributor (for policy assignment). If creating a user-assigned identity, also User Access Administrator; this guide uses system-assigned identity.
- Azure extension for SQL Server (WindowsAgent.SqlServer) minimum version: single-instance ≥ 1.1.2202.47; multi-instance > 1.1.2231.59.
- Named instances require SQL Server Browser service to be running.
- Azure Monitor Agent (AMA) used for data collection; ensure outbound TCP 443 to Azure Monitor endpoints such as: `global.handler.control.monitor.azure.com`, `*.handler.control.monitor.azure.com`, `<workspaceId>.ods.opinsights.azure.com`, `*.ingest.monitor.azure.com`.

## Steps (PowerShell)

Replace placeholders in angle brackets and run in an elevated PowerShell session with Az modules installed.

```powershell
# 0) Sign in and select subscription
Connect-AzAccount | Out-Null
$subscriptionId = '<subscription-id>'
Set-AzContext -Subscription $subscriptionId | Out-Null

# 1) Create resource groups (separate RGs for Arc resources and LA workspace)
$location = '<region>'                # e.g., westus, westeurope
$arcRg    = '<arc-resources-rg>'      # e.g., rg-arc-sql-prod
$laRg     = '<log-analytics-rg>'      # e.g., rg-ops-logs

New-AzResourceGroup -Name $arcRg -Location $location -ErrorAction SilentlyContinue | Out-Null
New-AzResourceGroup -Name $laRg  -Location $location -ErrorAction SilentlyContinue | Out-Null

# 2) Create Log Analytics workspace
$laName = '<workspace-name>'          # e.g., la-arc-sql-bpa
New-AzOperationalInsightsWorkspace -ResourceGroupName $laRg -Name $laName -Location $location -Sku PerGB2018 -ErrorAction SilentlyContinue | Out-Null

# Capture workspace details
$la = Get-AzOperationalInsightsWorkspace -ResourceGroupName $laRg -Name $laName
$laId = $la.ResourceId
$laLocation = $la.Location

# 3) Locate the built-in policy definition by display name
# Tip: Use -match to avoid punctuation/spacing edge cases
$policyDisplayNamePattern = 'Configure Arc-enabled Servers with SQL Server extension installed to enable or disable SQL best practices assessment'
$policyDefinition = Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -match [regex]::Escape($policyDisplayNamePattern) }

if (-not $policyDefinition) { throw "Policy definition not found: $policyDisplayNamePattern" }

# (Optional) Inspect parameter names to confirm keys
$policyDefinition.Properties.Parameters.GetEnumerator() | Select-Object Name, Value | Format-Table -AutoSize

# 4) Assign the policy (use subscription scope when RGs differ)
$scope = "/subscriptions/$subscriptionId"    # or a resource group scope if workspace and SQL are in the same RG
$policyAssignmentName = 'SQLBestPracticesAssessmentAssignment'

# Typical parameter keys are shown below; confirm with the inspection above if needed.
$parameters = @{
  laWorkspaceId       = $laId
  laWorkspaceLocation = $laLocation
  isEnabled           = $true       # set $false to disable assessment
}

New-AzPolicyAssignment -Name $policyAssignmentName `
  -DisplayName 'Enable SQL Best Practices Assessment (Arc-enabled SQL)' `
  -PolicyDefinition $policyDefinition `
  -Scope $scope `
  -PolicyParameterObject $parameters `
  -IdentityType 'SystemAssigned' `
  -Location $location | Out-Null

# 5) Verify assignment
Get-AzPolicyAssignment -Name $policyAssignmentName -Scope $scope | Format-List Name, Scope, EnforcementMode
```

## Verification and remediation

- In Azure Policy, review Compliance for the assignment. Allow time for evaluation and remediation.
- Don’t change extension configuration while remediation is running. Track remediation progress in Azure Policy.
- If resources are noncompliant due to LicenseOnly, change license type to Paid or PAYG on the Arc SQL resource first.

## References

- Configure best practices assessment (PowerShell and portal)
  - https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/assess?view=sql-server-ver17#enable-best-practices-assessment-at-scale-by-using-azure-policy
- Manage configuration (license types)
  - https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/manage-configuration?view=sql-server-ver17
- AMA proxy configuration
  - https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-data-collection-endpoint?tabs=ArmPolicy#proxy-configuration
