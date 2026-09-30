# Lab scripts
Version: v1.2026.09
Last updated: 2026-09-30

This folder contains PowerShell scripts used by the hands-on lab.

## Scripts

- `Create-ArcServicePrincipal.ps1` creates a Microsoft Entra ID service principal for Arc
  onboarding.
- `Test-ArcConnectivity.ps1` checks outbound connectivity to Azure Arc endpoints.
- `Cleanup-Lab.ps1` removes lab resources, including Azure resources and Arc components.

## Example files

- `service-principal-credentials.example.json` shows the expected service principal output.
- `connectivity-report.example.json` shows the connectivity report structure.

## Generated files

The lab scripts can generate local files such as:

- `service-principal-credentials.json`
- `connectivity-report-<timestamp>.json`

These files are excluded from source control by `.gitignore`.

## Usage

Run each script from the lab steps that reference it. For the full workflow, start with the
[hands-on lab module index](../README.md#modules).

## Sensitive data

> [!IMPORTANT]
> Generated files can contain secrets or environment details. Store them securely and delete
> them when you no longer need them.
