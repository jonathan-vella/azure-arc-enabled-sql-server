# SQL Server Monitoring and Feature Flags

Version: v1.2025.12  
Last updated: 2025-12-16

## Overview

This folder contains tools for configuring monitoring and feature flags on the Azure extension
for SQL Server. Feature flags control which capabilities are enabled for monitoring, discovery,
and telemetry.

> [!NOTE]
> Advanced SQL monitoring is a **preview feature**. Review the
> [preview terms][preview-terms] before enabling in production.

## When to use

- You want to enable or disable SQL Server monitoring features
- You need to discover Always On Availability Groups or Failover Cluster Instances
- You are configuring monitoring at scale across multiple Arc-enabled servers

## Prerequisites

- Azure PowerShell modules: `Az.Accounts`, `Az.ConnectedMachine`
- Azure Connected Machine Resource Administrator role on the target machine
- Logged in to Azure (`Connect-AzAccount`)

## Quick start

Enable SQL monitoring on a single machine:

```powershell
.\set-feature-flags.ps1 `
    -Subscription "<subscription-id>" `
    -ResourceGroup "<resource-group>" `
    -MachineName "<machine-name>" `
    -FeatureFlagsToEnable "SqlManagement"
```

## Available feature flags

| Feature Flag | Description |
|--------------|-------------|
| `SqlManagement` | Enables SQL Server management features and telemetry |
| `AvailabilityGroupDiscovery` | Enables discovery of Always On Availability Groups |
| `SqlFailoverClusterInstanceDiscovery` | Enables discovery of SQL Server Failover Cluster Instances |

## Script: set-feature-flags.ps1

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Subscription` | Yes | The Azure subscription ID containing the machine |
| `-ResourceGroup` | Yes | The resource group containing the Arc-enabled machine |
| `-MachineName` | Yes | The name of the Arc-enabled SQL Server machine |
| `-FeatureFlagsToEnable` | No | Array of feature flags to enable |
| `-FeatureFlagsToDisable` | No | Array of feature flags to disable |
| `-Force` | No | Proceed even if unrecognized feature flags are provided |
| `-DryRun` | No | Preview changes without applying them |

### Examples

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

## Troubleshooting

| Symptom | Cause | Resolution |
|---------|-------|------------|
| Feature flag not taking effect | Extension update pending | Wait a few minutes for extension to update |
| Unknown feature flag warning | Typo or unsupported flag | Verify flag name; use `-Force` if intentional |
| Permission denied | Missing RBAC role | Ensure Azure Connected Machine Resource Administrator role |

## Related documentation

- [Configure SQL Server enabled by Azure Arc][learn-config]
- [Monitor SQL Server enabled by Azure Arc][learn-monitoring]
- [Preview terms][preview-terms]

<!-- Reference links -->
[learn-config]: https://learn.microsoft.com/sql/sql-server/azure-arc/manage-configuration
[learn-monitoring]: https://learn.microsoft.com/sql/sql-server/azure-arc/sql-monitoring
[preview-terms]: https://azure.microsoft.com/support/legal/preview-supplemental-terms/
