# Lab Bicep templates
Version: v1.2026.09
Last updated: 2026-09-30

This folder contains the Bicep deployment used by the hands-on lab.

## Files

- `main.bicep` deploys the lab resource groups and the Log Analytics workspace.
- `modules/log-analytics.bicep` creates the Log Analytics workspace used by the lab.
- `deploy.ps1` wraps the Bicep deployment and writes deployment outputs locally.
- `deployment-outputs.example.json` shows the expected output structure.

## Deploy the lab infrastructure

```powershell
Set-AzContext -SubscriptionId "<subscription-id>"
.\deploy.ps1 -BaseName "arcsql-lab" -Environment "dev"
```

## Outputs

The deployment returns:

- Arc resource group name
- Monitoring resource group name
- Log Analytics workspace name
- Log Analytics workspace ID
- Azure region

## Sensitive output

> [!IMPORTANT]
> `deployment-outputs.json` contains workspace identifiers and keys. The file is generated
> locally and is excluded from source control.
