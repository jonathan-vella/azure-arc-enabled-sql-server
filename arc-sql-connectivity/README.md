# Network connectivity for Azure Arc

Version: v1.2026.09
Last updated: 2026-09-30

Use this guide to validate outbound connectivity for the Azure Connected Machine agent before onboarding or while you
troubleshoot Azure Arc communication issues.

## What to check

The required endpoint list varies by region and by connectivity model. Use the Microsoft Learn network requirements
article as the source of truth for the current URL list, private link guidance, and proxy requirements.

At a minimum, confirm that the server can reach Microsoft Entra ID, Azure Resource Manager, guest configuration, and
the Azure Arc service endpoints that apply to your region.

## Prerequisites

- Azure Connected Machine agent installed on the server.
- PowerShell or Command Prompt access on the server.
- The Azure region name that the server uses, such as `swedencentral` or `westeurope`.

## Check connectivity with azcmagent

The Azure Connected Machine agent installs the `azcmagent` CLI. Use `azcmagent check` to test the required endpoints.

### Public endpoint check

```powershell
azcmagent check --location "swedencentral"
```

### Private link check

```powershell
azcmagent check --location "swedencentral" --enable-pls-check
```

### Proxy check

```powershell
azcmagent check --location "swedencentral"
```

If a proxy is configured on the server, the output shows whether the requests are going through the proxy and which
endpoints are blocked.

## Read the results

- Confirm that every required endpoint is reachable.
- Review DNS, firewall, proxy, and SSL inspection settings for failed checks.
- Re-run the command after each network change.

## Hands-on lab

- [Module 1: Network validation](../arc-sql-hands-on-lab/modules/01-network-validation.md)

## Related documentation

- [Azure Arc-enabled servers network requirements][learn-network]
- [Manage the Azure Connected Machine agent][learn-agent]

[learn-agent]: https://learn.microsoft.com/azure/azure-arc/servers/manage-agent
[learn-network]: https://learn.microsoft.com/azure/azure-arc/servers/network-requirements
