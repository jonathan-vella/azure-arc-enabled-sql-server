# Set Feature Flags for SQL Server Extension

Version: v1.2025.12
Last updated: 2025-12-16

## Overview

This script enables or disables feature flags on the Azure extension for SQL Server on a specific Arc-enabled machine. Feature flags control which capabilities are enabled for SQL Server monitoring and discovery.

## Available Feature Flags

| Feature Flag | Description |
|--------------|-------------|
| `SqlManagement` | Enables SQL Server management features and telemetry |
| `AvailabilityGroupDiscovery` | Enables discovery of Always On Availability Groups |
| `SqlFailoverClusterInstanceDiscovery` | Enables discovery of SQL Server Failover Cluster Instances |

## Prerequisites

- Azure PowerShell modules installed (`Az.Accounts`, `Az.ConnectedMachine`)
- Azure Connected Machine Resource Administrator role on the target machine
- Logged in to Azure (`Connect-AzAccount`)

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Subscription` | Yes | The Azure subscription ID containing the machine |
| `-ResourceGroup` | Yes | The resource group containing the Arc-enabled machine |
| `-MachineName` | Yes | The name of the Arc-enabled SQL Server machine |
| `-FeatureFlagsToEnable` | No | Array of feature flags to enable |
| `-FeatureFlagsToDisable` | No | Array of feature flags to disable |
| `-Force` | No | Proceed even if unrecognized feature flags are provided |
| `-DryRun` | No | Preview changes without applying them |

## Examples

### Example 1: Enable SQL Management

```PowerShell
.\set-feature-flags.ps1 `
    -Subscription "<subscription-id>" `
    -ResourceGroup "contoso-rg" `
    -MachineName "contoso-sql-host" `
    -FeatureFlagsToEnable "SqlManagement"
```

### Example 2: Enable Availability Group Discovery

```PowerShell
.\set-feature-flags.ps1 `
    -Subscription "<subscription-id>" `
    -ResourceGroup "contoso-rg" `
    -MachineName "contoso-sql-host" `
    -FeatureFlagsToEnable "AvailabilityGroupDiscovery"
```

### Example 3: Enable Multiple Features

```PowerShell
.\set-feature-flags.ps1 `
    -Subscription "<subscription-id>" `
    -ResourceGroup "contoso-rg" `
    -MachineName "contoso-sql-host" `
    -FeatureFlagsToEnable "SqlManagement", "AvailabilityGroupDiscovery"
```

### Example 4: Disable a Feature

```PowerShell
.\set-feature-flags.ps1 `
    -Subscription "<subscription-id>" `
    -ResourceGroup "contoso-rg" `
    -MachineName "contoso-sql-host" `
    -FeatureFlagsToDisable "SqlManagement"
```

### Example 5: Preview Changes (Dry Run)

```PowerShell
.\set-feature-flags.ps1 `
    -Subscription "<subscription-id>" `
    -ResourceGroup "contoso-rg" `
    -MachineName "contoso-sql-host" `
    -FeatureFlagsToEnable "SqlManagement" `
    -DryRun
```

## Notes

- Unknown feature flags will generate a warning and may prompt for confirmation (use `-Force` to bypass)
- Use `-DryRun` to verify changes before applying them
- Feature flag changes require the extension to update, which may take a few minutes

## Related Documentation

- [Configure SQL Server enabled by Azure Arc](https://learn.microsoft.com/sql/sql-server/azure-arc/manage-configuration)
- [Monitor SQL Server enabled by Azure Arc](https://learn.microsoft.com/sql/sql-server/azure-arc/sql-monitoring)
