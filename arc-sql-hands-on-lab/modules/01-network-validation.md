# Module 1: Network validation

Version: v1.2026.09
Last updated: 2026-09-30

Test outbound connectivity from the target Windows Server before you install the Arc agent. When you finish,
you know whether DNS, HTTPS, and required Azure endpoints are ready for onboarding.

## Prerequisites
- Review [Prerequisites](../PREREQUISITES.md).
- Complete [Module 0](00-infrastructure.md).
- Run the checks on the Windows Server that you will connect to Azure Arc.

## Steps
### 1. Run the connectivity script
Use [Test-ArcConnectivity.ps1](../scripts/Test-ArcConnectivity.ps1) from the `arc-sql-hands-on-lab` folder.

```powershell
Set-Location .\scripts
pwsh .\scripts\Test-ArcConnectivity.ps1 -Region "swedencentral" -ExportReport -Verbose
```

### 2. Review the script output
The script checks DNS resolution, ICMP reachability, and HTTPS access where the endpoint supports it. It also
downloads the current Service Bus allowlist for `swedencentral` and can save the results to a JSON report.

### 3. Compare the results with current Azure Arc requirements
Confirm that outbound TCP 443 access is available for these endpoint groups:

- `management.azure.com`
- `login.microsoftonline.com`
- `*.login.microsoft.com`
- `pas.windows.net`
- `*.his.arc.azure.com`
- `*.guestconfiguration.azure.com`
- `guestnotificationservice.azure.com` and the regional `*.servicebus.windows.net` endpoints
- `*.swedencentral.arcdataservices.com`
- `download.microsoft.com` for the Connected Machine agent installation package

The script covers the core endpoints, but your firewall rules must also allow the regional Microsoft Entra ID
token endpoints under `*.login.microsoft.com`.

### 4. Fix any blocked paths before onboarding
Update firewall or proxy rules until the required checks pass. If your environment uses a proxy, configure the
server so PowerShell, the Arc agent, and SQL Server extension traffic can all reach the required endpoints.

## Validate
- Confirm that the script reports successful DNS resolution for the required endpoints.
- Confirm that the script returns the dynamic Service Bus endpoints for `swedencentral`.
- Confirm that a `connectivity-report-<timestamp>.json` file exists in the `scripts` folder.
- Confirm that no required outbound TCP 443 path remains blocked.

## Troubleshooting
- If DNS resolution fails, fix name resolution first. Azure Arc onboarding and extension deployment both depend
  on it.
- If the Service Bus allowlist request fails, allow `guestnotificationservice.azure.com` and rerun the script.
- If HTTPS checks fail behind a proxy, review the system proxy settings and confirm that the server can reach the
  required endpoints without TLS interception problems.

Back to the [module index](../README.md#modules).
