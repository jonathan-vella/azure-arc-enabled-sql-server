# Prerequisites

Version: v1.2026.09
Last updated: 2026-09-30

This page is the single source of prerequisites for the hands-on lab. The lab uses a narrower baseline than the product
supports. For the full supported matrix, see
[Prerequisites for SQL Server enabled by Azure Arc](https://learn.microsoft.com/sql/sql-server/azure-arc/prerequisites?view=sql-server-ver17).

## Table of contents

- [Lab baseline](#lab-baseline)
- [Management workstation](#management-workstation)
- [Azure subscription](#azure-subscription)
- [Target server](#target-server)
- [Cost](#cost)
- [Checklist](#checklist)

## Lab baseline

| Component | Lab requirement | Notes |
| --- | --- | --- |
| Target server OS | Windows Server 2022 or later | Linux is supported by the product but not covered by the lab |
| SQL Server | SQL Server 2022 or later, Standard or Enterprise | [Module 11](modules/11-disable-sql-auth.md) needs SQL Server 2025 |
| Region | `swedencentral` | Any region that supports Azure Arc and SQL Server enabled by Azure Arc works |
| Skills | SQL Server and Windows Server administration, PowerShell basics, Azure portal navigation | |

## Management workstation

Run the lab commands and scripts from Windows 11 or macOS.

| Tool | Version | Install and verify |
| --- | --- | --- |
| PowerShell | 7.4 or later | `winget install Microsoft.PowerShell` or `brew install --cask powershell`, then `pwsh --version` |
| Azure CLI | Current release | `winget install Microsoft.AzureCLI` or `brew install azure-cli`, then `az --version` |
| Bicep CLI | Current release | `az bicep install`, then `az bicep version` |
| Az PowerShell modules | Current release | `Install-Module -Name Az -Scope CurrentUser`, then `Get-Module Az -ListAvailable` |

Git and Visual Studio Code with the PowerShell and Bicep extensions are optional. If you use a proxy, set the
`HTTP_PROXY` and `HTTPS_PROXY` environment variables.

## Azure subscription

- An active Azure subscription with the Owner role, or Contributor plus User Access Administrator.
  The lab creates a service principal and assigns roles.
- No existing resource groups named `arcsql-lab-arc-rg` or `arcsql-lab-monitoring-rg`.
- These resource providers registered. [Module 0](modules/00-infrastructure.md) registers them if needed.

| Resource provider | Purpose |
| --- | --- |
| `Microsoft.HybridCompute` | Azure Arc-enabled servers |
| `Microsoft.AzureArcData` | SQL Server enabled by Azure Arc |
| `Microsoft.OperationalInsights` | Log Analytics workspace |
| `Microsoft.GuestConfiguration` | Guest configuration and policy |

Check a registration:

```powershell
Get-AzResourceProvider -ProviderNamespace Microsoft.HybridCompute | Select-Object ProviderNamespace, RegistrationState
```

## Target server

The server must already run SQL Server, and you must have these permissions:

- Local administrator on Windows, with RDP access from your workstation.
- SQL Server `sysadmin` for the initial setup. After onboarding, the Azure extension runs with least privilege by
  default and uses the `NT SERVICE\SqlServerExtension` login that it creates.
- Outbound HTTPS (TCP 443) to Azure. [Module 1](modules/01-network-validation.md) tests this.
- 2 vCPUs, 4 GB RAM, and 20 GB free disk at minimum. Use 4 vCPUs, 8 GB RAM, and 100 GB for the backup module.

Do not use these configurations:

- A server that is already connected to Azure Arc.
- A failover cluster instance or an Always On availability group secondary replica.
- SQL Server in a container.
- An Azure SQL virtual machine.

If you complete [Module 10](modules/10-backups-pitr.md), configure a default backup location with enough space
for the retention period. If it is a network share, `NT AUTHORITY\SYSTEM` needs write permission.

## Cost

Costs depend on the license type you choose and the modules you complete. The billable items are:

- The PAYG license for SQL Server enabled by Azure Arc, billed per core.
- Log Analytics data ingestion and retention.
- Any resources you create in the optional [Module 12](modules/12-migration.md) migration exercise.

Finish with [Module 13](modules/13-cleanup.md) to stop charges, and review spending in Azure Cost Management.

## Checklist

Workstation:

- [ ] PowerShell 7.4 or later, Azure CLI, Bicep CLI, and Az modules installed
- [ ] Network access to Azure and to the target server

Azure:

- [ ] Owner role (or Contributor plus User Access Administrator) on the subscription
- [ ] No conflicting resource group names

Target server:

- [ ] Windows Server 2022 or later with SQL Server 2022 or later
- [ ] Local administrator and SQL Server `sysadmin` access
- [ ] Outbound HTTPS to Azure
- [ ] Not already in Azure Arc, not a failover cluster instance or availability group secondary replica

Next: [Module 0: Infrastructure setup](modules/00-infrastructure.md) or the [Quickstart](QUICKSTART.md).

## Help

- [Azure Arc Jumpstart](https://azurearcjumpstart.io/)
- [Open an issue](https://github.com/jonathan-vella/azure-arc-enabled-sql-server/issues)
