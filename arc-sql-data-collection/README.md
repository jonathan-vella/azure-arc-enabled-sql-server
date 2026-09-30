# Data collection for SQL Server enabled by Azure Arc

Version: v1.2026.09
Last updated: 2026-09-30

This page summarizes the data that SQL Server enabled by Azure Arc collects for inventory, billing, migration
assessment, and optional monitoring.

For the authoritative list of collected properties, metrics, and log records, see
[Data collection and reporting][learn-collected-data].

## What data is collected

| Area | Summary |
| --- | --- |
| Inventory | Machine, SQL Server, and database inventory used for discovery and management. |
| Billing | License configuration and related resource metadata. |
| Migration assessment | Performance and capacity signals used by the migration assessment workflow. |
| Monitoring | Performance telemetry when monitoring is enabled. Monitoring is still preview. |

## Monitoring and migration notes

- Migration assessment is generally available.
- Advanced monitoring is still preview.
- Monitoring data collection depends on the monitoring features that you enable on the resource.

## Extension logs

Extension logs are stored under
`C:\ProgramData\GuestConfig\extension_logs\Microsoft.AzureData.WindowsAgent.SqlServer\`.

Recent extension builds use `unifiedagent.log`. Older builds might use `ExtensionLog_0.log`.

## Related documentation

- [Data collection and reporting][learn-collected-data]
- [Monitor SQL Server enabled by Azure Arc][learn-monitoring]
- [Migration assessment][learn-migration]
- [Azure Arc-enabled servers network requirements][learn-network]

[learn-collected-data]: https://learn.microsoft.com/sql/sql-server/azure-arc/data-collection?view=sql-server-ver17
[learn-migration]: https://learn.microsoft.com/sql/sql-server/azure-arc/migration-assessment?view=sql-server-ver17
[learn-monitoring]: https://learn.microsoft.com/sql/sql-server/azure-arc/sql-monitoring?view=sql-server-ver17
[learn-network]: https://learn.microsoft.com/azure/azure-arc/servers/network-requirements
