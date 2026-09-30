# Module 6: Best practices assessment

Version: v1.2026.09
Last updated: 2026-09-30

In this module you enable SQL Server Best Practices Assessment on the lab host, run an on-demand assessment, and
review the first recommendations in Azure.

## Prerequisites
- Complete [Module 0](00-infrastructure.md) so that the Log Analytics workspace exists in
  `arcsql-lab-monitoring-rg`.
- Complete [Module 4](04-license-management.md) with **Pay-as-you-go** or **License with
  Software Assurance**.
- Use a Windows host. Best Practices Assessment does not run on Linux.
- If your lab uses a named SQL Server instance, make sure the SQL Server Browser service is running.

## Steps
### 1. Confirm the workspace and eligibility
1. In the Azure portal, open **Azure Arc** > **SQL Server instances** and select your lab instance.
2. Confirm that the host license type is **Pay-as-you-go** or **License with Software Assurance**.
3. Confirm that the SQL Server resource is in the same subscription as the Log Analytics workspace.
4. Run the following query to find the workspace that the lab deployment created:

```powershell
Search-AzGraph -Query @'
resources
| where type =~ "microsoft.operationalinsights/workspaces"
| where resourceGroup =~ "arcsql-lab-monitoring-rg"
| project workspaceName = name, location, resourceGroup
'@
```

### 2. Enable best practices assessment
1. On the SQL Server resource, select **Best practices assessment**.
2. In **Log Analytics Workspace**, select the workspace from `arcsql-lab-monitoring-rg`.
3. Select **Enable assessment**.
4. Wait for setup to finish.
5. Confirm that the default weekly schedule appears. By default, Azure schedules the assessment for Sunday at
   12:00 AM local time.

> [!NOTE]
> Best Practices Assessment uses Azure Monitor Agent. If AMA is already installed, the feature reuses it. If the
> feature installs AMA for you, configure proxy settings separately if your environment uses a proxy.

### 3. Run an on-demand assessment
1. Stay on **Best practices assessment**.
2. Select **Run assessment**.
3. Wait for the run to start.
4. Keep this pane open or return later. **View assessment results** can stay unavailable until Azure finishes
   processing the data in Log Analytics.

### 4. Review the results
1. When **View assessment results** becomes available, open it.
2. Start with the **High** severity items.
3. Use **All**, **New**, **Resolved**, and **Insights** to review the output.
4. Select a recommendation to read the details and remediation guidance.
5. If you need a copy of the current results, select **Export to Excel**.

## Validate
- **Best practices assessment** shows as enabled on the SQL Server resource.
- The assessment schedule is visible on the configuration pane.
- An on-demand run starts from the portal.
- **View assessment results** becomes available after the data is processed.

## Troubleshooting
- If no Log Analytics workspace appears in the dropdown, confirm that the workspace is in the same subscription and
  that your account has Log Analytics Contributor on the workspace scope.
- If enablement fails, verify outbound TCP 443 access to `global.handler.control.monitor.azure.com`,
  `*.handler.control.monitor.azure.com`, `<workspace-id>.ods.opinsights.azure.com`, and
  `*.ingest.monitor.azure.com`.
- If results do not appear, allow more time. Microsoft Learn states that the results can take up to two hours to
  become available after data processing starts.

Back to the [module index](../README.md#modules).
