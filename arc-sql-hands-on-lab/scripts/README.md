# Lab Scripts Directory

This directory contains PowerShell scripts for the Azure Arc-enabled SQL Server hands-on lab.

## Scripts

### `Create-ArcServicePrincipal.ps1`
Creates an Azure AD Service Principal with the Azure Connected Machine Onboarding role for Arc server onboarding.

**Output:** `service-principal-credentials.json` (sensitive - not committed to repo)

### `Test-ArcConnectivity.ps1`
Validates network connectivity to Azure Arc endpoints before onboarding.

**Output:** `connectivity-report-<timestamp>.json` (not committed to repo)

### `Cleanup-Lab.ps1`
Removes lab resources including Arc agent and Azure resources.

## Template Files

The following `.example.json` files serve as templates to show the structure of generated files:

- **`service-principal-credentials.example.json`** - Example of service principal output structure
- **`connectivity-report.example.json`** - Example of connectivity test report structure

## Generated Files (Not in Source Control)

The following files are generated during lab execution and are **excluded from source control** via `.gitignore`:

- `service-principal-credentials.json` - Contains actual service principal secret
- `connectivity-report-*.json` - Contains connectivity test results with timestamps

## Security Note

⚠️ **Never commit files containing real credentials, secrets, or sensitive configuration data to source control.**

The `.gitignore` file is configured to prevent accidental commits of sensitive files, but always verify before committing changes.

## Usage

1. Review the `.example.json` files to understand output structure
2. Run the scripts as documented in the lab guide
3. Generated files will be created in this directory
4. Store sensitive credentials securely (Azure Key Vault, password manager)
5. Delete sensitive files after securing credentials elsewhere
