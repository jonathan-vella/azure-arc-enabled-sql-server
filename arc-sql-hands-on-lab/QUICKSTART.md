# Quick Start Guide

This quick start guide provides a condensed version of the **core lab modules** for experienced users who want to quickly complete the exercises.

> [!NOTE]
> This quick start covers **core modules only** (Modules 0-7). The lab also includes 4 optional preview modules (Modules 8-11) covering automated patching, advanced monitoring, backup management, and point-in-time restore. See the [full lab guide](README.md) for details on optional modules.

## Prerequisites Checklist

- ☐ Azure subscription with Owner permissions
- ☐ Windows Server 2022+ with SQL Server 2017+ installed and licensed
- ☐ PowerShell 7.0+
- ☐ Azure PowerShell modules installed
- ☐ Network connectivity to Azure (HTTPS/443)

## Quick Setup (15 minutes)

### 1. Deploy Infrastructure

```powershell
# Clone repository
git clone https://github.com/microsoft/azure-arc-enabled-sql-server.git
cd azure-arc-enabled-sql-server/arc-sql-hands-on-lab

# Connect to Azure and deploy
Connect-AzAccount
Set-AzContext -SubscriptionId "<your-subscription-id>"

# Deploy Bicep template
cd bicep
.\deploy.ps1 -BaseName "arcsql-lab" -Environment "dev"
```

### 2. Validate Network Connectivity

```powershell
cd ../scripts
.\Test-ArcConnectivity.ps1 -Region "swedencentral" -Verbose
```

### 3. Onboard to Azure Arc

1. Generate script in Azure portal: **Azure Arc > Servers > Add > Generate script**
2. Configure: `arcsql-lab-arc-rg`, `Sweden Central`, `Windows`
3. Run on-premises server:
   ```powershell
   .\OnboardingScript.ps1
   ```

### 4. Verify SQL Extension & Discovery

- Check: **Azure Arc > Infrastructure > Servers > [YourServer] > Extensions**
- Verify: **Azure Arc > Data services > SQL Server instances**

### 5. Configure License Type

```powershell
# Set to PAYG first
Update-AzSqlInstanceArc -ResourceGroupName "arcsql-lab-arc-rg" `
    -Name "<sql-instance-name>" -LicenseType "PAYG"

# Then change to Paid (Software Assurance)
Update-AzSqlInstanceArc -ResourceGroupName "arcsql-lab-arc-rg" `
    -Name "<sql-instance-name>" -LicenseType "Paid"
```

### 6. Enable Best Practices Assessment

Portal: **SQL Server instance > Best practices assessment > Configure**
- Select Log Analytics workspace: `arcsql-lab-law-*`
- Schedule: Weekly, Sunday 12:00 AM
- Click **Enable**
- Click **Run assessment now**

### 7. Deploy Azure Policy for BPA at Scale

1. Navigate to: **Azure Policy > Definitions**
2. Search: "Configure Arc-enabled Servers with SQL Server extension"
3. Click **Assign**
4. Configure:
   - Scope: Your subscription
   - Parameters: Enable = true, Select Log Analytics workspace
   - Remediation: Create task, System-assigned MI
5. Click **Create**

### 8. Cleanup

```powershell
cd scripts
.\Cleanup-Lab.ps1 -SubscriptionId "<your-subscription-id>" -BaseName "arcsql-lab"
```

## Optional Preview Modules

The full lab includes 4 optional modules covering preview features:
- **Module 8**: Automated Patching (~15 min)
- **Module 9**: Advanced Monitoring (~15 min)
- **Module 10**: Backup Management (~20 min)
- **Module 11**: Point-in-Time Restore (~20 min)

These modules are optional and can be skipped. See the [full lab guide](README.md) for detailed instructions.

## Key Commands Reference

```powershell
# Check Arc agent status
azcmagent show

# List Arc SQL Server instances
Get-AzSqlInstanceArc -ResourceGroupName "arcsql-lab-arc-rg"

# Update license type
Update-AzSqlInstanceArc -ResourceGroupName "arcsql-lab-arc-rg" `
    -Name "<name>" -LicenseType "Paid"

# Check extension status
Get-AzConnectedMachineExtension -ResourceGroupName "arcsql-lab-arc-rg" `
    -MachineName "<server-name>"
```

## Troubleshooting Quick Tips

| Issue | Solution |
|-------|----------|
| Agent install fails | Check `Test-ArcConnectivity.ps1` output |
| SQL extension not deploying | Wait 30 mins or manually deploy |
| BPA can't enable | Verify license type is Paid/PAYG |
| Policy not working | Check MI permissions on Log Analytics |

## Time Estimates

- Infrastructure deployment: 5 min
- Arc onboarding: 5 min
- SQL discovery: 5 min
- License configuration: 5 min
- BPA setup & run: 15 min
- Azure Policy deployment: 10 min
- Cleanup: 5 min

**Total: ~50 minutes** (excluding assessment run time)

## Next Steps

For detailed instructions and explanations, see the [full lab guide](README.md).
