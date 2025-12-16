# Data Collection for SQL Server enabled by Azure Arc

Version: v1.2025.12
Last updated: 2025-12-16

## Overview

SQL Server enabled by Azure Arc collects usage and monitoring data to support inventory, billing, performance monitoring, and migration assessment. This page provides a summary of what data is collected.

> **For complete details**, see [View collected data - SQL Server enabled by Azure Arc](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/view-collected-data?view=sql-server-ver17)

## Key Points

| Category | Details |
|----------|---------|
| **Privacy** | No PII or customer data is collected |
| **Transmission** | Secure HTTPS to `*.<region>.arcdataservices.com` |
| **Monitoring Limitations** | Windows only, SQL Server 2016 SP1+, Standard/Enterprise editions, no FCI support |

## Data Categories

### Always Collected
- SQL Server instance metadata (name, version, edition, cores, license type)
- Database inventory (names, sizes, recovery models)
- Connection status and health

### When Monitoring is Enabled
- CPU, memory, and storage utilization (10-second to 1-minute intervals)
- Active sessions and wait statistics
- Performance counters (buffer cache, transactions, connections)
- Storage I/O metrics (IOPS, throughput, latency)

### For Migration Assessment
- CPU and memory utilization percentages
- Read/write IOPS and throughput
- Database sizes and file organization

## Log Files

| Extension Version | Log File |
|-------------------|----------|
| Latest | `unifiedagent.log` |
| 1.1.24724.69 and earlier | `ExtensionLog_0.log` |

**Location**: `C:\ProgramData\GuestConfig\extension_logs\Microsoft.AzureData.WindowsAgent.SqlServer\`

## Related Documentation

- [View collected data](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/view-collected-data?view=sql-server-ver17)
- [Monitor SQL Server enabled by Azure Arc](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/sql-monitoring?view=sql-server-ver17)
- [Migration assessment](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/migration-assessment?view=sql-server-ver17)
- [Connected Machine agent network requirements](https://learn.microsoft.com/en-us/azure/azure-arc/servers/network-requirements)