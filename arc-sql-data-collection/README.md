# Data Collection and Reporting for SQL Server enabled by Azure Arc

Version: v1.2025.12
Last updated: 2025-12-16

This guide provides detailed information about the data that SQL Server enabled by Azure Arc collects and transmits to Microsoft. Understanding this data collection is essential for compliance, security, and performance monitoring objectives.

## Overview

SQL Server enabled by Azure Arc collects usage and monitoring data while respecting privacy guidelines:

- No personally identifiable information (PII) or end-user identifiable information is collected
- No customer data is stored during the collection process
- The Azure Connected Machine agent transmits data to `*.<region>.arcdataservices.com` endpoints

## Data Collection Categories

### SQL Server - Azure Arc Resource Information

Basic information about your SQL Server instance is collected, including:

| Property | Type | Description |
|----------|------|-------------|
| Name | string | SQL Server instance name |
| Version | string | SQL Server version (e.g., "SQL Server 2022") |
| Edition | string | SQL Server edition (e.g., "Enterprise") |
| Container Resource ID | string | Resource ID of the hosting Azure Arc for Servers resource |
| vCore | string | Number of virtual cores |
| Status | string | Connection status |
| Patch Level | string | SQL Server patch level |
| Collation | string | SQL Server collation |
| Instance Name | string | SQL Server instance name |
| TCP Dynamic Ports | string | Dynamic TCP ports configuration |
| TCP Static Ports | string | Static TCP ports configuration |
| Product ID | string | SQL Server product ID |
| License Type | string | License type (e.g., "PAYG") |
| Defender Status | string | Microsoft Defender status |

### Monitoring Data (When Enabled)

The following data categories are collected when monitoring is enabled. Data collection frequency varies by category.

#### Active Sessions (30-second intervals)
Sessions that are running a request, have a blocker, or have an open transaction:
- Session IDs and status
- Database information
- Connection details

#### CPU Utilization (10-second intervals)
- SQL process CPU percent
- Idle CPU percent
- Other process CPU percent
- System-wide CPU utilization metrics

#### Database Properties (5-minute intervals)
- Collation, compatibility level, containment settings
- Creation date and configuration details
- Recovery model and isolation settings
- Access controls and updateability status

#### Database Storage Utilization (1-minute intervals)
- Data and log file counts and sizes
- Storage allocation and usage metrics
- Version store information
- Replication status

#### Memory Utilization (10-second intervals)
- Memory clerk usage
- Memory allocation by type
- Total memory consumption

#### Performance Counters
Collected at 1-minute intervals:

**Common counters:**
- Buffer cache hit ratio
- Batch requests/sec
- Transaction metrics
- Temp table usage
- Connection counts

**Detailed counters:**
- Wait time statistics
- Memory usage breakdowns
- Database file sizes
- Log usage metrics
- I/O throughput measurements

#### Storage I/O (10-second intervals)
- IOPS metrics (read/write)
- Throughput statistics
- Latency measurements
- File size and utilization

#### Wait Statistics (10-second intervals)
- Wait types and categories
- Resource wait times
- Signal wait metrics
- Task counts

### Migration Assessment Metrics

The following metrics are automatically collected to support migration assessment recommendations:

- CPU and memory utilization percentages
- Read/write IOPS for data and log files
- Throughput measurements (MB/s)
- I/O operation latency
- Database sizes and file organization

## Log Files

Log files for data collection activities can be found in the following locations:

- **Latest version**: `unifiedagent.log`
- **Version 1.1.24724.69 and earlier**: `ExtensionLog_0.log`

## Managing Data Collection

You can control the monitoring data collection through the Azure portal:

1. Navigate to your SQL Server - Azure Arc resource
2. Select **Settings > Monitoring**
3. Toggle data collection features on/off as needed

For detailed information on monitoring configuration, see [Monitor SQL Server enabled by Azure Arc (preview)](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/sql-monitoring?view=sql-server-ver17).

## Security and Privacy

SQL Server enabled by Azure Arc adheres to strict security and privacy standards:

- Data is transmitted securely over HTTPS
- No personal data is collected or stored
- Collection is limited to operational and performance metrics only
- Compliance with Microsoft privacy policies

## Related Documentation

- [Monitor Azure Arc-enabled SQL Server](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/sql-monitoring?view=sql-server-ver17)
- [Select the optimal Azure SQL target using Migration assessment](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/migration-assessment?view=sql-server-ver16)
- [Configure best practices assessment](https://learn.microsoft.com/en-us/sql/sql-server/azure-arc/assess?view=sql-server-ver17)
- [Connected Machine agent network requirements](https://learn.microsoft.com/en-us/azure/azure-arc/servers/network-requirements?tabs=azure-cloud#urls)