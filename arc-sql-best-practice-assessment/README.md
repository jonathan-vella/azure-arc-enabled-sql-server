# Best practices assessment for SQL Server enabled by Azure Arc

Version: v1.2026.09
Last updated: 2026-09-30

Use Best Practices Assessment (BPA) to review SQL Server configuration, surface recommendations, and track
remediation over time.

> [!IMPORTANT]
> BPA works only when the host license type is **Pay-as-you-go** or **License with Software Assurance**. LicenseOnly
> is not supported. Review the billing impact before you change the license type.

## What BPA does

- Assesses all SQL Server instances discovered on the Arc-enabled machine.
- Stores results in a Log Analytics workspace.
- Supports scheduled and on-demand runs.
- Helps you validate changes before a migration or policy rollout.

## Prerequisites

- Windows host with SQL Server enabled by Azure Arc.
- Log Analytics workspace in the same subscription as the SQL Server Arc resource.
- SQL Server Browser running for named instances.
- Azure roles to configure and view the workspace and Arc resources.
- Outbound TCP 443 to Azure Monitor and Log Analytics endpoints.

For the supported matrix and full prerequisites, see [Configure best practices assessment][learn-bpa].

## Enable BPA in the portal

1. Open **Azure Arc** > **SQL Server instances** and select the instance.
2. Select **Best practices assessment**.
3. Select the Log Analytics workspace.
4. Select **Enable assessment**.
5. After setup finishes, use **Run assessment** for an on-demand run or **Configuration** to change the schedule.

## Enable BPA at scale

Use the built-in Azure Policy definition to roll out BPA across many servers. Use subscription scope when the
Log Analytics workspace is in a different resource group from the SQL resources.

For a PowerShell example, see [Enable Best Practices Assessment at scale](enable-at-scale.md).

## Review results

- Use the **All**, **New**, **Resolved**, and **Insights** tabs to sort findings.
- Start with High severity findings.
- Export results when you need a point-in-time copy.
- Open **Logs** to query historical data in Log Analytics.

```kusto
SqlAssessment_CL
| extend assessment = parse_csv(RawData)
| extend CheckId = tostring(assessment[2]),
         TargetType = case(assessment[6] == 1, "Server", assessment[6] == 2, "Database", ""),
         TargetName = tostring(assessment[7]),
         Severity = case(toint(assessment[8]) == 30, "High",
                         toint(assessment[8]) == 20, "Medium",
                         toint(assessment[8]) == 10, "Low", "Information"),
         Message = tostring(assessment[9])
| where CheckId == "LockedPagesInMemory"
| project TargetType, TargetName, Severity, CheckId, Message
| distinct TargetType, TargetName, Severity, CheckId, Message
```

## Hands-on lab

- [Module 6: Best practices assessment](../arc-sql-hands-on-lab/modules/06-best-practices-assessment.md)
- [Module 7: Azure Policy for best practices assessment](../arc-sql-hands-on-lab/modules/07-bpa-policy.md)

## Troubleshooting

- Confirm the required Azure roles on both the workspace and Arc resources.
- Check Azure Monitor Agent deployment and proxy configuration if results do not appear.
- Use the official troubleshooting article for common BPA failures.

## Related documentation

- [Configure best practices assessment][learn-bpa]
- [Troubleshoot best practices assessment][learn-troubleshoot]
- [Manage SQL Server enabled by Azure Arc configuration][learn-manage]
- [Azure Monitor Agent proxy configuration][learn-ama-proxy]

[learn-ama-proxy]: https://learn.microsoft.com/azure/azure-monitor/agents/azure-monitor-agent-data-collection-endpoint?tabs=ArmPolicy#proxy-configuration
[learn-bpa]: https://learn.microsoft.com/sql/sql-server/azure-arc/assess?view=sql-server-ver17&tabs=portal
[learn-manage]: https://learn.microsoft.com/sql/sql-server/azure-arc/manage-configuration?view=sql-server-ver17
[learn-troubleshoot]: https://learn.microsoft.com/sql/sql-server/azure-arc/troubleshoot-assessment?view=sql-server-ver17
