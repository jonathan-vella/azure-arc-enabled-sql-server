# ============================================================================
# Azure Arc-Enabled SQL Server - Hands-On Lab Commands
# ============================================================================
# Copy and paste these commands module by module
# Replace all placeholder values with your actual values
# ============================================================================

#Requires -Version 7.0

# ============================================================================
# IMPORTANT: Replace these variables with your actual values
# ============================================================================
$subscriptionId = "<your-subscription-id>"           # Your Azure subscription ID
$baseName = "arcsql-lab"                             # Base name for resources
$environment = "dev"                                  # Environment: dev, test, or prod
$location = "swedencentral"                          # Azure region
$resourceGroup = "arcsql-lab-arc-rg"                 # Arc resource group name

# These will be provided by Create-ArcServicePrincipal.ps1
$servicePrincipalAppId = "<Application-ID>"          # From service principal creation
$servicePrincipalSecret = "<Secret>"                 # From service principal creation
$tenantId = "<Tenant-ID>"                            # From service principal creation

# These will be discovered after Arc onboarding
$serverName = "<your-server-name>"                   # Your Arc-enabled server name
$sqlInstanceName = "<your-sql-instance-name>"        # Your SQL instance name

# ============================================================================
# MODULE 0: Deploy Infrastructure (5 minutes)
# ============================================================================
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "MODULE 0: Deploy Infrastructure" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to lab directory
Set-Location "c:\Users\jovella\Documents\GitHub\azure-arc-enabled-sql-server\arc-sql-hands-on-lab"

# Connect to Azure
Write-Host "Connecting to Azure..." -ForegroundColor Yellow
Connect-AzAccount

# Set subscription context
Write-Host "Setting subscription context..." -ForegroundColor Yellow
Set-AzContext -SubscriptionId $subscriptionId

# Deploy Bicep infrastructure
Write-Host "Deploying infrastructure..." -ForegroundColor Yellow
Set-Location "bicep"
.\deploy.ps1 -BaseName $baseName -Environment $environment -Location $location

Write-Host ""
Write-Host "✅ Infrastructure deployed successfully!" -ForegroundColor Green
Write-Host "📝 Review the deployment-outputs.json file" -ForegroundColor Gray
Write-Host ""

# ============================================================================
# MODULE 1: Network Connectivity Test (5 minutes)
# ============================================================================
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "MODULE 1: Network Connectivity Test" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  Run this on your ON-PREMISES SQL Server" -ForegroundColor Yellow
Write-Host ""

# Navigate to scripts directory
Set-Location "..\scripts"

# Test connectivity
Write-Host "Testing connectivity to Azure Arc endpoints..." -ForegroundColor Yellow
.\Test-ArcConnectivity.ps1 -Region $location -Verbose

# Optional: Export detailed report
Write-Host ""
Write-Host "Exporting connectivity report..." -ForegroundColor Yellow
.\Test-ArcConnectivity.ps1 -Region $location -ExportReport

Write-Host ""
Write-Host "✅ Connectivity test completed!" -ForegroundColor Green
Write-Host ""

# ============================================================================
# MODULE 2: Arc Server Onboarding with Service Principal (20 minutes)
# ============================================================================
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "MODULE 2: Arc Server Onboarding" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# ----------------------------------------------------------------------------
# PART A: Create Service Principal (Run on WORKSTATION)
# ----------------------------------------------------------------------------
Write-Host "Part A: Create Service Principal" -ForegroundColor Yellow
Write-Host "--------------------------------" -ForegroundColor Yellow
Write-Host ""

# Create service principal
.\Create-ArcServicePrincipal.ps1 `
    -ServicePrincipalName "Arc-SQL-Lab-Onboarding-SP" `
    -Scope "Subscription"

Write-Host ""
Write-Host "⚠️  CRITICAL: Save the credentials from service-principal-credentials.json" -ForegroundColor Red
Write-Host "   - Store in Azure Key Vault or secure password manager" -ForegroundColor Gray
Write-Host "   - Update variables at the top of this script" -ForegroundColor Gray
Write-Host "   - Delete the JSON file after securing credentials" -ForegroundColor Gray
Write-Host ""
Write-Host "Press Enter after saving credentials to continue..." -ForegroundColor Yellow
Read-Host

# ----------------------------------------------------------------------------
# PART B: Install Arc Agent (Run on ON-PREMISES SQL SERVER)
# ----------------------------------------------------------------------------
Write-Host ""
Write-Host "Part B: Install Arc Agent" -ForegroundColor Yellow
Write-Host "-------------------------" -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  Switch to your ON-PREMISES SQL Server now!" -ForegroundColor Red
Write-Host "   Copy and run the following commands in elevated PowerShell:" -ForegroundColor Gray
Write-Host ""

$arcCommands = @"
# 1. Download Azure Connected Machine agent
`$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri "https://aka.ms/AzureConnectedMachineAgent" ``
    -OutFile "`$env:TEMP\AzureConnectedMachineAgent.msi"

# 2. Install the agent
msiexec /i "`$env:TEMP\AzureConnectedMachineAgent.msi" /qn /l*v "`$env:TEMP\InstallationLog.txt"

# Wait for installation to complete (30 seconds)
Start-Sleep -Seconds 30

# 3. Connect to Azure Arc using Service Principal
`$servicePrincipalAppId = "$servicePrincipalAppId"
`$servicePrincipalSecret = "$servicePrincipalSecret"
`$tenantId = "$tenantId"
`$subscriptionId = "$subscriptionId"
`$resourceGroup = "$resourceGroup"
`$location = "$location"

& "`$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect ``
    --service-principal-id `$servicePrincipalAppId ``
    --service-principal-secret `$servicePrincipalSecret ``
    --tenant-id `$tenantId ``
    --subscription-id `$subscriptionId ``
    --resource-group `$resourceGroup ``
    --location `$location

# 4. Verify agent status
& "`$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" show
"@

Write-Host $arcCommands -ForegroundColor White
Write-Host ""
Write-Host "Press Enter after completing Arc onboarding..." -ForegroundColor Yellow
Read-Host

Write-Host ""
Write-Host "✅ Arc server onboarding completed!" -ForegroundColor Green
Write-Host "⏱️  Wait 5-10 minutes for SQL discovery to complete" -ForegroundColor Gray
Write-Host ""

# ============================================================================
# MODULE 3: Verify SQL Discovery (10 minutes)
# ============================================================================
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "MODULE 3: Verify SQL Discovery" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⏱️  Waiting 5 minutes for SQL discovery..." -ForegroundColor Yellow
Start-Sleep -Seconds 300

# List all Arc SQL Server instances
Write-Host "Listing Arc-enabled SQL Server instances..." -ForegroundColor Yellow
Get-AzSqlInstanceArc -ResourceGroupName $resourceGroup

# Get detailed information
Write-Host ""
Write-Host "Getting detailed instance information..." -ForegroundColor Yellow
$instances = Get-AzSqlInstanceArc -ResourceGroupName $resourceGroup
foreach ($instance in $instances) {
    Write-Host ""
    Write-Host "Instance: $($instance.Name)" -ForegroundColor Cyan
    $instance | Format-List Name, Version, Edition, Status, LicenseType, Location
}

# Check extension status
Write-Host ""
Write-Host "Checking SQL Server extension status..." -ForegroundColor Yellow
if ($serverName -ne "<your-server-name>") {
    Get-AzConnectedMachineExtension -ResourceGroupName $resourceGroup `
        -MachineName $serverName -Name "WindowsAgent.SqlServer"
} else {
    Write-Host "⚠️  Update `$serverName variable with your actual server name" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ SQL discovery verification completed!" -ForegroundColor Green
Write-Host ""

# ============================================================================
# MODULE 4: License Management (10 minutes)
# ============================================================================
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "MODULE 4: License Management" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

if ($sqlInstanceName -eq "<your-sql-instance-name>") {
    Write-Host "⚠️  Update `$sqlInstanceName variable with your actual SQL instance name" -ForegroundColor Yellow
    Write-Host "   You can find it from the output of Module 3" -ForegroundColor Gray
    Write-Host ""
} else {
    # Step 1: Set to PAYG
    Write-Host "Step 1: Setting license type to PAYG (Pay-As-You-Go)..." -ForegroundColor Yellow
    Update-AzSqlInstanceArc -ResourceGroupName $resourceGroup `
        -Name $sqlInstanceName `
        -LicenseType "PAYG"
    
    Write-Host "✅ License type set to PAYG" -ForegroundColor Green
    Write-Host "⏱️  Waiting 2 minutes..." -ForegroundColor Gray
    Start-Sleep -Seconds 120
    
    # Step 2: Change to Paid
    Write-Host ""
    Write-Host "Step 2: Changing license type to Paid (Software Assurance)..." -ForegroundColor Yellow
    Update-AzSqlInstanceArc -ResourceGroupName $resourceGroup `
        -Name $sqlInstanceName `
        -LicenseType "Paid"
    
    Write-Host "✅ License type set to Paid" -ForegroundColor Green
    
    # Verify
    Write-Host ""
    Write-Host "Verifying license type change..." -ForegroundColor Yellow
    Get-AzSqlInstanceArc -ResourceGroupName $resourceGroup `
        -Name $sqlInstanceName | 
        Select-Object Name, LicenseType, Status, Version, Edition | 
        Format-List
}

Write-Host ""
Write-Host "✅ License management completed!" -ForegroundColor Green
Write-Host ""

# ============================================================================
# MODULE 5: Monitoring (Portal-based - No commands)
# ============================================================================
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "MODULE 5: Monitoring Configuration" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 This module is completed in the Azure portal:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Navigate to your SQL Server - Azure Arc resource" -ForegroundColor White
Write-Host "2. Go to: Settings > Monitoring" -ForegroundColor White
Write-Host "3. Enable monitoring features" -ForegroundColor White
Write-Host "4. Configure Log Analytics workspace" -ForegroundColor White
Write-Host ""
Write-Host "Press Enter after completing monitoring configuration..." -ForegroundColor Yellow
Read-Host

# ============================================================================
# MODULE 6: Best Practices Assessment (15 minutes)
# ============================================================================
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "MODULE 6: Best Practices Assessment" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Configure BPA in the Azure portal:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Navigate to: SQL Server instance > Best practices assessment" -ForegroundColor White
Write-Host "2. Click: Configure" -ForegroundColor White
Write-Host "3. Select Log Analytics workspace: arcsql-lab-law-dev" -ForegroundColor White
Write-Host "4. Set schedule: Weekly, Sunday 12:00 AM" -ForegroundColor White
Write-Host "5. Click: Enable" -ForegroundColor White
Write-Host "6. Click: Run assessment now" -ForegroundColor White
Write-Host ""
Write-Host "Press Enter after enabling BPA..." -ForegroundColor Yellow
Read-Host

# Verify BPA configuration
if ($sqlInstanceName -ne "<your-sql-instance-name>") {
    Write-Host ""
    Write-Host "Verifying BPA configuration..." -ForegroundColor Yellow
    $instance = Get-AzSqlInstanceArc -ResourceGroupName $resourceGroup -Name $sqlInstanceName
    Write-Host "Assessment enabled: $($instance.Properties.AssessmentProperties.IsEnabled)" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "✅ Best Practices Assessment configured!" -ForegroundColor Green
Write-Host ""

# ============================================================================
# MODULE 7: Azure Policy for BPA at Scale (10 minutes)
# ============================================================================
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "MODULE 7: Azure Policy for BPA at Scale" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Deploy Azure Policy in the portal:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Navigate to: Azure Policy > Definitions" -ForegroundColor White
Write-Host "2. Search: 'Configure Arc-enabled Servers with SQL Server extension'" -ForegroundColor White
Write-Host "3. Click: Assign" -ForegroundColor White
Write-Host "4. Configure:" -ForegroundColor White
Write-Host "   - Scope: Your subscription" -ForegroundColor Gray
Write-Host "   - Enable BPA: true" -ForegroundColor Gray
Write-Host "   - Select Log Analytics workspace" -ForegroundColor Gray
Write-Host "   - Create remediation task with System MI" -ForegroundColor Gray
Write-Host "5. Click: Review + Create > Create" -ForegroundColor White
Write-Host ""
Write-Host "Press Enter after deploying policy..." -ForegroundColor Yellow
Read-Host

# Verify policy assignment
Write-Host ""
Write-Host "Verifying policy assignments..." -ForegroundColor Yellow
$policies = Get-AzPolicyAssignment | Where-Object {$_.Properties.DisplayName -like "*Arc*SQL*"}
if ($policies) {
    Write-Host "✅ Found Arc SQL policy assignments:" -ForegroundColor Green
    $policies | Select-Object Name, @{Name="DisplayName";Expression={$_.Properties.DisplayName}}, Scope | Format-Table
} else {
    Write-Host "⚠️  No Arc SQL policy assignments found yet" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Azure Policy deployment completed!" -ForegroundColor Green
Write-Host ""

# ============================================================================
# MODULE 8: Cleanup (5 minutes)
# ============================================================================
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "MODULE 8 (or 13 if optional modules completed): Cleanup Lab Resources" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  This will delete all lab resources!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Do you want to run cleanup now? (Y/N): " -ForegroundColor Yellow -NoNewline
$cleanup = Read-Host

if ($cleanup -eq "Y" -or $cleanup -eq "y") {
    Write-Host ""
    Write-Host "Running cleanup script..." -ForegroundColor Yellow
    .\Cleanup-Lab.ps1 -SubscriptionId $subscriptionId -BaseName $baseName
    
    Write-Host ""
    Write-Host "✅ Lab cleanup completed!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Cleanup skipped. Run manually when ready:" -ForegroundColor Gray
    Write-Host ".\Cleanup-Lab.ps1 -SubscriptionId `"$subscriptionId`" -BaseName `"$baseName`"" -ForegroundColor White
}

# ============================================================================
# OPTIONAL ADVANCED MODULES (Preview Features)
# ============================================================================
Write-Host ""
Write-Host "=============================================" -ForegroundColor Magenta
Write-Host "⚠️  OPTIONAL ADVANCED MODULES" -ForegroundColor Magenta
Write-Host "=============================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "The following modules use PREVIEW features." -ForegroundColor Yellow
Write-Host "Skip these if time is limited or if you want to avoid preview features." -ForegroundColor Gray
Write-Host ""
Write-Host "Continue with optional modules? (Y/N): " -ForegroundColor Yellow -NoNewline
$continueOptional = Read-Host

if ($continueOptional -ne "Y" -and $continueOptional -ne "y") {
    Write-Host ""
    Write-Host "Skipping optional modules. Jumping to completion summary..." -ForegroundColor Gray
    Write-Host ""
} else {

# ============================================================================
# OPTIONAL MODULE 9: Configure Automatic Updates (10 minutes)
# ============================================================================
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "OPTIONAL MODULE 9: Configure Automatic Updates" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  Preview Feature Notice" -ForegroundColor Yellow
Write-Host "This feature is subject to Azure Preview Terms." -ForegroundColor Gray
Write-Host ""

# Install Az.Maintenance module if not already installed
Write-Host "Checking for Az.Maintenance module..." -ForegroundColor Yellow
if (-not (Get-Module -ListAvailable -Name Az.Maintenance)) {
    Write-Host "Installing Az.Maintenance module..." -ForegroundColor Yellow
    Install-Module -Name Az.Maintenance -AllowClobber -Force -Scope CurrentUser
}

# Create maintenance configuration
Write-Host ""
Write-Host "Creating maintenance configuration for automatic updates..." -ForegroundColor Yellow
$maintenanceConfigName = "SQL-Sunday-Updates"
$maintenanceConfig = New-AzMaintenanceConfiguration `
    -ResourceGroupName $resourceGroup `
    -Name $maintenanceConfigName `
    -Location $location `
    -MaintenanceScope "InGuestPatch" `
    -StartDateTime "2024-11-17 02:00" `
    -Duration "03:00" `
    -RecurEvery "Week Sunday"

Write-Host "✅ Maintenance configuration created" -ForegroundColor Green

# Assign to Arc server
if ($serverName -ne "<your-server-name>") {
    Write-Host ""
    Write-Host "Assigning maintenance configuration to Arc server..." -ForegroundColor Yellow
    New-AzConfigurationAssignment `
        -ResourceGroupName $resourceGroup `
        -Location $location `
        -ResourceName $serverName `
        -ResourceType "Microsoft.HybridCompute/machines" `
        -ProviderName "Microsoft.Maintenance" `
        -ConfigurationAssignmentName "SQL-Updates-Assignment" `
        -MaintenanceConfigurationId $maintenanceConfig.Id
    
    Write-Host "✅ Maintenance configuration assigned to server" -ForegroundColor Green
} else {
    Write-Host "⚠️  Update `$serverName variable to assign maintenance config" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 You can also configure updates via Azure Portal:" -ForegroundColor Yellow
Write-Host "   1. Go to: Arc Server > Operations > SQL Server Configuration" -ForegroundColor Gray
Write-Host "   2. Under Update section, enable automatic updates" -ForegroundColor Gray
Write-Host "   3. Set maintenance schedule (e.g., Sunday 02:00)" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ Automatic updates configuration completed!" -ForegroundColor Green
Write-Host ""

# ============================================================================
# OPTIONAL MODULE 10: Advanced SQL Monitoring (20 minutes)
# ============================================================================
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "OPTIONAL MODULE 10: Advanced SQL Monitoring" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  Preview Feature Notice" -ForegroundColor Yellow
Write-Host "This feature is subject to Azure Preview Terms." -ForegroundColor Gray
Write-Host ""

if ($sqlInstanceName -ne "<your-sql-instance-name>") {
    # Enable advanced monitoring
    Write-Host "Enabling advanced SQL monitoring..." -ForegroundColor Yellow
    
    $resourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.AzureArcData/SqlServerInstances/$sqlInstanceName"
    
    az resource update `
        --ids $resourceId `
        --set 'properties.monitoring.enabled=true' `
        --api-version 2023-09-01-preview
    
    Write-Host "✅ Advanced monitoring enabled" -ForegroundColor Green
    Write-Host "⏱️  Wait 5-15 minutes for data to appear in Performance Dashboard" -ForegroundColor Gray
    
    # Verify monitoring status
    Write-Host ""
    Write-Host "Verifying monitoring status..." -ForegroundColor Yellow
    $monitoringStatus = az resource show `
        --ids $resourceId `
        --api-version 2023-09-01-preview `
        --query "properties.monitoring" `
        | ConvertFrom-Json
    
    Write-Host "Monitoring enabled: $($monitoringStatus.enabled)" -ForegroundColor Cyan
} else {
    Write-Host "⚠️  Update `$sqlInstanceName variable to enable monitoring" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Explore Performance Dashboard in Azure Portal:" -ForegroundColor Yellow
Write-Host "   1. Go to: SQL Server Arc > Performance Dashboard (preview)" -ForegroundColor Gray
Write-Host "   2. View CPU, Memory, Storage I/O metrics" -ForegroundColor Gray
Write-Host "   3. Analyze Active Sessions and Wait Statistics" -ForegroundColor Gray
Write-Host "   4. Review Database properties and storage utilization" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ Advanced SQL monitoring configuration completed!" -ForegroundColor Green
Write-Host ""

# ============================================================================
# OPTIONAL MODULE 11: Automated Backups & PITR (40 minutes)
# ============================================================================
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "OPTIONAL MODULE 11: Automated Backups & PITR" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  Preview Feature Notice" -ForegroundColor Yellow
Write-Host "This feature is subject to Azure Preview Terms." -ForegroundColor Gray
Write-Host ""

# Part A: Configure Instance-Level Backup Policy
Write-Host "Part A: Configure Instance-Level Backup Policy" -ForegroundColor Yellow
Write-Host "----------------------------------------------" -ForegroundColor Yellow
Write-Host ""

if ($sqlInstanceName -ne "<your-sql-instance-name>") {
    Write-Host "Creating instance-level backup policy..." -ForegroundColor Yellow
    
    az sql server-arc backups-policy create `
        --name $sqlInstanceName `
        --resource-group $resourceGroup `
        --retention-days 14 `
        --full-backup-days 7 `
        --diff-backup-hours 24 `
        --tlog-backup-mins 5
    
    Write-Host "✅ Instance-level backup policy configured" -ForegroundColor Green
    
    # View backup policy
    Write-Host ""
    Write-Host "Viewing backup policy..." -ForegroundColor Yellow
    az sql server-arc backups-policy show `
        --name $sqlInstanceName `
        --resource-group $resourceGroup
    
} else {
    Write-Host "⚠️  Update `$sqlInstanceName variable to configure backups" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 You can also configure backups via Azure Portal:" -ForegroundColor Yellow
Write-Host "   1. Go to: SQL Server Arc > Backups" -ForegroundColor Gray
Write-Host "   2. Click: Configure policies" -ForegroundColor Gray
Write-Host "   3. Set retention and backup schedules" -ForegroundColor Gray
Write-Host "   4. Click: Apply" -ForegroundColor Gray
Write-Host ""

# Part B: Configure Database-Level Backup (Example)
Write-Host "Part B: Configure Database-Level Backup (Optional)" -ForegroundColor Yellow
Write-Host "---------------------------------------------------" -ForegroundColor Yellow
Write-Host ""
Write-Host "To configure database-level policy (overrides instance policy):" -ForegroundColor Gray
Write-Host ""
$dbBackupCmd = @"
`$databaseName = "<your-database-name>"

az sql db-arc backups-policy create ``
    --name `$databaseName ``
    --server $sqlInstanceName ``
    --resource-group $resourceGroup ``
    --retention-days 21 ``
    --full-backup-days 1 ``
    --diff-backup-hours 12 ``
    --tlog-backup-mins 10
"@
Write-Host $dbBackupCmd -ForegroundColor White
Write-Host ""

# Part C: Verify Backups
Write-Host "Part C: Verify Backups" -ForegroundColor Yellow
Write-Host "----------------------" -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  Run these commands on the SQL Server host:" -ForegroundColor Yellow
Write-Host ""
$verifyBackupCmd = @"
# Check default backup location
`$backupPath = "C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup"
Get-ChildItem -Path `$backupPath -Recurse | 
    Where-Object {`$_.Extension -in '.bak','.trn','.dif'} |
    Select-Object Name, Length, LastWriteTime |
    Sort-Object LastWriteTime -Descending | 
    Format-Table
"@
Write-Host $verifyBackupCmd -ForegroundColor White
Write-Host ""

$verifyBackupSQL = @"
-- Query backup history in SQL Server
SELECT TOP 20
    bs.database_name,
    bs.backup_start_date,
    bs.backup_finish_date,
    CASE bs.type
        WHEN 'D' THEN 'Full'
        WHEN 'I' THEN 'Differential'
        WHEN 'L' THEN 'Transaction Log'
    END AS BackupType,
    bs.backup_size / 1024 / 1024 AS BackupSizeMB,
    bmf.physical_device_name
FROM msdb.dbo.backupset bs
JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
ORDER BY bs.backup_start_date DESC;
"@
Write-Host "SQL Query to check backup history:" -ForegroundColor Gray
Write-Host $verifyBackupSQL -ForegroundColor Cyan
Write-Host ""

# Part D: Point-in-Time Restore
Write-Host "Part D: Point-in-Time Restore (PITR)" -ForegroundColor Yellow
Write-Host "------------------------------------" -ForegroundColor Yellow
Write-Host ""
Write-Host "After backups are running, perform PITR:" -ForegroundColor Gray
Write-Host ""
$pitrCmd = @"
`$sourceDatabaseName = "<source-database>"
`$targetDatabaseName = "`${sourceDatabaseName}_PITR_`$(Get-Date -Format 'yyyyMMddHHmm')"
`$restorePointInTime = "2024-11-10T14:30:00Z"  # ISO 8601 format

# Initiate restore
az sql db-arc restore ``
    --name `$targetDatabaseName ``
    --server $sqlInstanceName ``
    --resource-group $resourceGroup ``
    --source-database `$sourceDatabaseName ``
    --restore-point-in-time `$restorePointInTime
"@
Write-Host $pitrCmd -ForegroundColor White
Write-Host ""
Write-Host "📋 You can also perform PITR via Azure Portal:" -ForegroundColor Yellow
Write-Host "   1. Go to: SQL Server Arc > Backups" -ForegroundColor Gray
Write-Host "   2. Find database, click: Restore" -ForegroundColor Gray
Write-Host "   3. Select point-in-time and new database name" -ForegroundColor Gray
Write-Host "   4. Click: Create" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ Automated backups & PITR configuration completed!" -ForegroundColor Green
Write-Host ""

# End of optional modules
}

# ============================================================================
# Lab Completion Summary
# ============================================================================
Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "🎉 Lab Completed Successfully!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "What you accomplished:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Core Modules:" -ForegroundColor Yellow
Write-Host "  ✅ Deployed Azure infrastructure with Bicep" -ForegroundColor White
Write-Host "  ✅ Validated network connectivity to Azure Arc" -ForegroundColor White
Write-Host "  ✅ Onboarded server to Azure Arc using Service Principal" -ForegroundColor White
Write-Host "  ✅ Discovered SQL Server instances automatically" -ForegroundColor White
Write-Host "  ✅ Managed SQL Server licensing (PAYG and Paid)" -ForegroundColor White
Write-Host "  ✅ Configured monitoring and observability" -ForegroundColor White
Write-Host "  ✅ Enabled Best Practices Assessment" -ForegroundColor White
Write-Host "  ✅ Deployed Azure Policy for governance at scale" -ForegroundColor White

if ($continueOptional -eq "Y" -or $continueOptional -eq "y") {
    Write-Host ""
    Write-Host "Optional Advanced Modules (Preview):" -ForegroundColor Yellow
    Write-Host "  ✅ Configured automatic Windows and SQL Server updates" -ForegroundColor White
    Write-Host "  ✅ Enabled advanced performance monitoring with DMV metrics" -ForegroundColor White
    Write-Host "  ✅ Set up automated backups with custom retention policies" -ForegroundColor White
    Write-Host "  ✅ Configured point-in-time database restore capability" -ForegroundColor White
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  • Review BPA findings in Azure portal" -ForegroundColor Gray
Write-Host "  • Explore monitoring dashboards and performance metrics" -ForegroundColor Gray
Write-Host "  • Test backup and restore operations" -ForegroundColor Gray
Write-Host "  • Apply learnings to production environments" -ForegroundColor Gray
Write-Host "  • Explore additional Azure Arc features (Defender, Purview, etc.)" -ForegroundColor Gray
Write-Host ""
Write-Host "📚 Additional Resources:" -ForegroundColor Cyan
Write-Host "  • Microsoft Learn: https://learn.microsoft.com/sql/sql-server/azure-arc/" -ForegroundColor Gray
Write-Host "  • Azure Arc Jumpstart: https://azurearcjumpstart.io/" -ForegroundColor Gray
Write-Host "  • GitHub Repo: https://github.com/microsoft/azure-arc-enabled-sql-server" -ForegroundColor Gray
Write-Host ""
Write-Host "Thank you for completing this lab! 🚀" -ForegroundColor Green
Write-Host ""
