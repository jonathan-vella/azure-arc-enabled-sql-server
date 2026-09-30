# Lab troubleshooting

Version: v1.2026.09
Last updated: 2026-09-30

Use this guide when a lab step fails and the module doesn't include a specific fix. Return to the
[module index](README.md#modules) when you're ready to continue.

## Connection and onboarding

### Arc agent installation fails

Fix:

- Run `scripts\Test-ArcConnectivity.ps1` to validate outbound access on port `443`.
- Verify that you started PowerShell with local administrator rights.
- Review `%ProgramData%\AzureConnectedMachineAgent\Log\azcmagent.log` on the server.
- Confirm that the server can reach the required Azure Arc endpoints for `swedencentral`.

### SQL Server extension doesn't deploy automatically

Fix:

- Confirm that SQL Server is installed and the service is running.
- Check the resource group tags. The SQL extension doesn't auto-deploy when
  `ArcSQLServerExtensionDeployment = Disabled`.
- Wait up to 30 minutes after server onboarding for the extension deployment to start.
- If the extension still doesn't appear, use the manual deployment steps from the SQL extension
  module.

## Assessment and policy

### Best practices assessment can't be enabled

Fix:

- Confirm that the instance uses `Paid` or `PAYG` licensing. `LicenseOnly` doesn't support best
  practices assessment.
- Recheck the SQL Server configuration in the Azure portal after the license update completes.
- If the license changed recently, wait a few minutes and try again.

### Policy remediation fails

Fix:

- Verify that the remediation identity has the required permissions on the Log Analytics workspace.
- Confirm that the policy assignment parameters match the workspace and target scope.
- Review the remediation task details in **Azure Policy** > **Remediation**.
- Rerun the remediation task after you correct the missing permission or parameter.

## Monitoring

### Monitoring data doesn't appear

Fix:

- Confirm that the instance uses `Paid` or `PAYG` licensing.
- Verify that the Azure extension for SQL Server is on a supported build. For backup permission
  automation, use `1.1.2504.99` or later. The current auto-upgrade target is `1.1.3518.465`.
- Confirm that the server can reach `*.swedencentral.arcdataservices.com`.
- Wait at least 15 minutes for the first data upload.
- Review the extension logs on the server for connection or ingestion failures.

## Related resources

- [SQL Server enabled by Azure Arc overview](https://learn.microsoft.com/sql/sql-server/azure-arc/overview?view=sql-server-ver17)
- [Connect your SQL Server to Azure Arc](https://learn.microsoft.com/sql/sql-server/azure-arc/connect?view=sql-server-ver17)
- [Manage licensing and billing](https://learn.microsoft.com/sql/sql-server/azure-arc/manage-license-billing?view=sql-server-ver17)
- [Best practices assessment](https://learn.microsoft.com/sql/sql-server/azure-arc/assess?view=sql-server-ver17)
- [Monitor SQL Server enabled by Azure Arc (preview)](https://learn.microsoft.com/sql/sql-server/azure-arc/sql-monitoring?view=sql-server-ver17)
- [Manage automated backups (preview)](https://learn.microsoft.com/sql/sql-server/azure-arc/backup-local?view=sql-server-ver17)
- [Restore to a point-in-time](https://learn.microsoft.com/sql/sql-server/azure-arc/point-in-time-restore?view=sql-server-ver17)
- [Azure Arc Jumpstart](https://azurearcjumpstart.io/)
- [SQL Server enabled by Azure Arc pricing](https://azure.microsoft.com/pricing/details/azure-arc/sqlserver/)
