# Lab Bicep Templates

This directory contains Infrastructure as Code (IaC) templates for deploying the Azure Arc-enabled SQL Server hands-on lab infrastructure.

## Files

### `main.bicep`
Main Bicep template that orchestrates the lab infrastructure deployment.

**Creates:**
- Resource group for Azure Arc resources (`arcsql-lab-arc-rg`)
- Resource group for monitoring resources (`arcsql-lab-monitoring-rg`)
- Log Analytics workspace with SQL Assessment solution

### `modules/log-analytics.bicep`
Bicep module for creating and configuring Log Analytics workspace.

### `deploy.ps1`
PowerShell deployment script that wraps the Bicep deployment.

**Output:** `deployment-outputs.json` (sensitive - not committed to repo)

## Template Files

- **`deployment-outputs.example.json`** - Example of deployment output structure

## Generated Files (Not in Source Control)

The following files are generated during deployment and are **excluded from source control** via `.gitignore`:

- `deployment-outputs.json` - Contains actual workspace IDs and keys

## Usage

```powershell
# Set Azure context
Set-AzContext -SubscriptionId "<your-subscription-id>"

# Deploy infrastructure
.\deploy.ps1 -BaseName "arcsql-lab" -Environment "dev"
```

## Outputs

The deployment provides the following outputs:
- Arc resource group name
- Monitoring resource group name
- Log Analytics workspace ID and name
- Log Analytics customer ID (workspace ID)
- Region where resources are deployed

## Security Note

⚠️ The `deployment-outputs.json` file contains sensitive information including Log Analytics workspace keys. This file is automatically excluded from source control but should be handled securely.
