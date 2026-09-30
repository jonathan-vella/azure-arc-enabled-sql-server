# Enable Best Practices Assessment at scale

Version: v1.2026.09
Last updated: 2026-09-30

Use Azure Policy to enable Best Practices Assessment (BPA) across multiple Arc-enabled SQL Server hosts with one
assignment. This pattern uses one resource group for Arc resources and one for the Log Analytics workspace.

> [!IMPORTANT]
> BPA requires host license type **Pay-as-you-go** or **License with Software Assurance**. If you change the license
> type, review the billing impact before you save the change.

## Before you start

- Use Windows hosts. BPA does not support SQL Server enabled by Azure Arc on Linux.
- Keep the Log Analytics workspace in the same subscription as the SQL Server Arc resources.
- Use an account that can assign Azure Policy at the target scope.
- Plan to create or reuse a managed identity for remediation.

Use [Configure best practices assessment][learn-bpa] for the full supported matrix and prerequisites.

## Deployment pattern

1. Create or reuse the Arc resource group.
2. Create or reuse a Log Analytics workspace.
3. Assign the built-in BPA policy.
4. Run remediation and track compliance in Azure Policy.

If the workspace and SQL resources are in different resource groups, assign the policy at subscription scope.

## PowerShell example

```powershell
Connect-AzAccount | Out-Null
$subscriptionId = "<subscription-id>"
$location = "<region>"
$arcResourceGroup = "<arc-resource-group>"
$workspaceResourceGroup = "<workspace-resource-group>"
$workspaceName = "<log-analytics-workspace>"
$assignmentName = "EnableSqlBestPracticesAssessment"
$policyDisplayName = @(
  "Configure Arc-enabled Servers with SQL Server extension installed to"
  "enable or disable SQL best practices assessment"
) -join " "

Set-AzContext -Subscription $subscriptionId | Out-Null

New-AzResourceGroup -Name $arcResourceGroup -Location $location -ErrorAction SilentlyContinue | Out-Null
New-AzResourceGroup -Name $workspaceResourceGroup -Location $location -ErrorAction SilentlyContinue | Out-Null

$workspace = Get-AzOperationalInsightsWorkspace `
  -ResourceGroupName $workspaceResourceGroup `
  -Name $workspaceName `
  -ErrorAction SilentlyContinue

if (-not $workspace) {
    $workspace = New-AzOperationalInsightsWorkspace `
      -ResourceGroupName $workspaceResourceGroup `
      -Name $workspaceName `
      -Location $location `
      -Sku PerGB2018
}

$policy = Get-AzPolicyDefinition | Where-Object {
    $_.Properties.DisplayName -eq $policyDisplayName
}

if (-not $policy) {
    throw "Built-in BPA policy definition not found."
}

$parameters = @{
    laWorkspaceId       = $workspace.ResourceId
    laWorkspaceLocation = $workspace.Location
    isEnabled           = $true
}

$scope = "/subscriptions/$subscriptionId"

New-AzPolicyAssignment `
  -Name $assignmentName `
  -DisplayName "Enable SQL Best Practices Assessment" `
  -PolicyDefinition $policy `
  -Scope $scope `
  -PolicyParameterObject $parameters `
  -IdentityType SystemAssigned `
  -Location $location | Out-Null
```

## Verify the rollout

- Open **Azure Policy** > **Assignments** and select the new assignment.
- Review **Compliance** and create a remediation task if required.
- On a server resource, open **Best practices assessment** and confirm that the workspace is attached.

## Hands-on lab

- [Module 6: Best practices assessment](../arc-sql-hands-on-lab/modules/06-best-practices-assessment.md)
- [Module 7: Azure Policy for best practices assessment](../arc-sql-hands-on-lab/modules/07-bpa-policy.md)

## Troubleshooting

- If the workspace is in a different resource group, use subscription scope for the assignment.
- Do not change BPA settings on target machines while remediation is running.
- If Azure Monitor Agent uses a proxy, configure the proxy separately.

## Related documentation

- [Configure best practices assessment][learn-bpa]
- [Troubleshoot best practices assessment][learn-troubleshoot]
- [Manage SQL Server enabled by Azure Arc configuration][learn-manage]
- [Azure Policy documentation][learn-policy]
- [Azure Monitor Agent proxy configuration][learn-ama-proxy]

[learn-ama-proxy]: https://learn.microsoft.com/azure/azure-monitor/agents/azure-monitor-agent-data-collection-endpoint?tabs=ArmPolicy#proxy-configuration
[learn-bpa]: https://learn.microsoft.com/sql/sql-server/azure-arc/assess?view=sql-server-ver17&tabs=portal
[learn-manage]: https://learn.microsoft.com/sql/sql-server/azure-arc/manage-configuration?view=sql-server-ver17
[learn-policy]: https://learn.microsoft.com/azure/governance/policy/
[learn-troubleshoot]: https://learn.microsoft.com/sql/sql-server/azure-arc/troubleshoot-assessment?view=sql-server-ver17
