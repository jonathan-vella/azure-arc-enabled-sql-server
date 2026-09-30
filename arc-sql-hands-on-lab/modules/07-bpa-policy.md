# Module 7: Azure Policy for best practices assessment

Version: v1.2026.09
Last updated: 2026-09-30

In this module you assign the built-in Azure Policy that enables Best Practices Assessment at scale. You use the lab
workspace in `arcsql-lab-monitoring-rg` and verify compliance on the lab SQL Server resource.

## Prerequisites
- Complete [Module 6](06-best-practices-assessment.md).
- Have permission to assign policy at the target scope. Resource Policy Contributor is the minimum documented role.
- Use the lab workspace in `arcsql-lab-monitoring-rg`. Because the workspace and SQL Server resource groups are
  different, assign the policy at subscription scope.

## Steps
### 1. Confirm the built-in policy definition
1. Open PowerShell with the Az modules installed and authenticated to the lab subscription.
2. Run the following command to confirm the built-in definition that this module uses:

```powershell
Get-AzPolicyDefinition -Id `
  "/providers/Microsoft.Authorization/policyDefinitions/f36de009-cacb-47b3-b936-9c4c9120d064" |
  Select-Object PolicyType, DisplayName, Id
```

3. Confirm that the policy display name is **Configure Arc-enabled Servers with SQL Server extension installed to
   enable or disable SQL best practices assessment**.

### 2. Assign the policy at subscription scope
1. In the Azure portal, open **Azure Policy** > **Definitions**.
2. Search for **Configure Arc-enabled Servers with SQL Server extension installed to enable or disable SQL best
   practices assessment** and select it.
3. Select **Assign**.
4. On **Basics**, set **Scope** to your subscription. Use subscription scope because the lab SQL Server resource group
   and the Log Analytics workspace resource group are different.
5. On **Parameters**:
   1. Select **Only show parameters that need input for review**.
   2. Select the Log Analytics workspace from `arcsql-lab-monitoring-rg`.
   3. Set **Log Analytics workspace location** to `swedencentral`.
   4. Set **Enablement** to `true`.
6. On **Remediation**, select **Create a remediation task** and use **System assigned managed identity** unless your
   environment requires a user-assigned identity.
7. Select **Review + Create**, then select **Create**.

### 3. Monitor compliance and remediation
1. Open **Azure Policy** > **Assignments** and select the assignment that you just created.
2. Open **Compliance** and watch the first evaluation complete.
3. Open **Remediation** and confirm that the remediation task starts.
4. Wait for the policy to bring the lab SQL Server resource into compliance.

> [!NOTE]
> Do not change other extension settings while Azure Policy remediation is updating noncompliant resources.

### 4. Verify the result on the lab SQL Server resource
1. Return to **Azure Arc** > **SQL Server instances** and open your lab instance.
2. Open **Best practices assessment**.
3. Confirm that the workspace and schedule match the policy settings.
4. If needed, open the policy assignment again and review **Resource compliance** for the current state.

## Validate
- The PowerShell lookup returns the built-in policy definition with ID
  `f36de009-cacb-47b3-b936-9c4c9120d064`.
- The policy assignment exists at subscription scope.
- The remediation task starts for the assignment.
- The lab SQL Server resource shows Best Practices Assessment enabled with the lab workspace.

## Troubleshooting
- If the workspace dropdown is empty during assignment, confirm that the workspace exists in the current subscription
  and that you can read it.
- If assignment at resource group scope fails to remediate the lab instance, re-create the assignment at subscription
  scope. The documented guidance requires subscription scope when the workspace is in a different resource group.
- If the resource stays noncompliant, review the remediation task details before changing any extension settings.

Back to the [module index](../README.md#modules).
