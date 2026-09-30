# SQL Server monitoring and feature flags

Version: v1.2026.09
Last updated: 2026-09-30

This folder contains the script and notes used to configure monitoring-related feature flags on the Azure extension
for SQL Server.

> [!NOTE]
> Advanced SQL monitoring is still preview. Review the [preview terms][preview-terms] before you enable it in
> production.

## When to use this folder

- Enable or disable monitoring-related feature flags on a machine.
- Enable discovery for availability groups or failover cluster instances.
- Review the script inputs before you change extension settings.

## Prerequisites

- Azure PowerShell modules `Az.Accounts` and `Az.ConnectedMachine`.
- Azure Connected Machine Resource Administrator on the target machine.
- An authenticated Azure PowerShell session.
- A current Azure extension for SQL Server build. Microsoft supports only extension versions released within the
  last year.

## Available feature flags

| Feature flag | Description |
| --- | --- |
| `SqlManagement` | Enables SQL Server management features and telemetry. |
| `AvailabilityGroupDiscovery` | Enables discovery of Always On availability groups. |
| `SqlFailoverClusterInstanceDiscovery` | Enables discovery of SQL Server failover cluster instances. |

## Quick start

```powershell
.\set-feature-flags.ps1 `
  -Subscription "<subscription-id>" `
  -ResourceGroup "<resource-group>" `
  -MachineName "<machine-name>" `
  -FeatureFlagsToEnable "SqlManagement"
```

## Script parameters

| Parameter | Required | Description |
| --- | --- | --- |
| `-Subscription` | Yes | Azure subscription ID that contains the machine. |
| `-ResourceGroup` | Yes | Resource group that contains the Arc-enabled machine. |
| `-MachineName` | Yes | Arc-enabled machine name. |
| `-FeatureFlagsToEnable` | No | Array of feature flags to enable. |
| `-FeatureFlagsToDisable` | No | Array of feature flags to disable. |
| `-Force` | No | Continue when the script finds an unrecognized feature flag. |
| `-DryRun` | No | Preview the change without applying it. |

## Examples

### Example 1: enable SQL management

```powershell
.\set-feature-flags.ps1 `
  -Subscription "<subscription-id>" `
  -ResourceGroup "contoso-rg" `
  -MachineName "contoso-sql-host" `
  -FeatureFlagsToEnable "SqlManagement"
```

### Example 2: enable availability group discovery

```powershell
.\set-feature-flags.ps1 `
  -Subscription "<subscription-id>" `
  -ResourceGroup "contoso-rg" `
  -MachineName "contoso-sql-host" `
  -FeatureFlagsToEnable "AvailabilityGroupDiscovery"
```

### Example 3: enable multiple features

```powershell
.\set-feature-flags.ps1 `
  -Subscription "<subscription-id>" `
  -ResourceGroup "contoso-rg" `
  -MachineName "contoso-sql-host" `
  -FeatureFlagsToEnable "SqlManagement", "AvailabilityGroupDiscovery"
```

### Example 4: disable a feature

```powershell
.\set-feature-flags.ps1 `
  -Subscription "<subscription-id>" `
  -ResourceGroup "contoso-rg" `
  -MachineName "contoso-sql-host" `
  -FeatureFlagsToDisable "SqlManagement"
```

### Example 5: preview a change

```powershell
.\set-feature-flags.ps1 `
  -Subscription "<subscription-id>" `
  -ResourceGroup "contoso-rg" `
  -MachineName "contoso-sql-host" `
  -FeatureFlagsToEnable "SqlManagement" `
  -DryRun
```

## Hands-on lab

- [Module 5: Basic monitoring](../arc-sql-hands-on-lab/modules/05-basic-monitoring.md)
- [Module 9: Configure advanced monitoring](../arc-sql-hands-on-lab/modules/09-advanced-monitoring.md)

## Related documentation

- [Manage SQL Server enabled by Azure Arc configuration][learn-config]
- [Monitor SQL Server enabled by Azure Arc][learn-monitoring]
- [Preview terms][preview-terms]

[learn-config]: https://learn.microsoft.com/sql/sql-server/azure-arc/manage-configuration?view=sql-server-ver17
[learn-monitoring]: https://learn.microsoft.com/sql/sql-server/azure-arc/sql-monitoring?view=sql-server-ver17
[preview-terms]: https://azure.microsoft.com/support/legal/preview-supplemental-terms/
