# ============================================================================
# Cleanup-Lab.ps1
# ============================================================================
# This script removes all Azure Arc SQL Server lab resources
# Includes disconnecting Arc agent and deleting Azure resources
# ============================================================================

#Requires -Version 7.0
#Requires -Modules @{ ModuleName="Az.Accounts"; ModuleVersion="2.0.0" }
#Requires -Modules @{ ModuleName="Az.Resources"; ModuleVersion="6.0.0" }
#Requires -Modules @{ ModuleName="Az.ConnectedMachine"; ModuleVersion="0.5.0" }

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $false)]
    [string]$BaseName = "arcsql-lab",
    
    [Parameter(Mandatory = $false)]
    [string]$ServerName,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipArcDisconnect,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# ============================================================================
# Functions
# ============================================================================

function Write-LogMessage {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        'Info' { 'Cyan' }
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
    }
    
    Write-Host "[$timestamp] " -NoNewline -ForegroundColor Gray
    Write-Host "[$Level] " -NoNewline -ForegroundColor $color
    Write-Host $Message
}

function Confirm-Action {
    param([string]$Message)
    
    if ($Force) {
        return $true
    }
    
    Write-Host ""
    Write-Host $Message -ForegroundColor Yellow
    Write-Host "Type 'YES' to confirm: " -NoNewline -ForegroundColor Yellow
    $response = Read-Host
    
    return ($response -eq 'YES')
}

function Disconnect-ArcAgent {
    Write-LogMessage "Checking for Azure Connected Machine agent..." -Level Info
    
    $agentPath = "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe"
    
    if (-not (Test-Path $agentPath)) {
        Write-LogMessage "Arc agent not found on this machine" -Level Warning
        return $false
    }
    
    Write-LogMessage "Arc agent found. Disconnecting from Azure..." -Level Info
    
    try {
        # Disconnect agent
        $disconnectResult = & $agentPath disconnect --force-local-only 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-LogMessage "Agent disconnected successfully" -Level Success
        } else {
            Write-LogMessage "Agent disconnect completed with warnings" -Level Warning
        }
        
        # Uninstall agent
        Write-LogMessage "Uninstalling Arc agent..." -Level Info
        $uninstallResult = & $agentPath uninstall 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-LogMessage "Agent uninstalled successfully" -Level Success
            return $true
        } else {
            Write-LogMessage "Agent uninstall completed with warnings" -Level Warning
            return $false
        }
    } catch {
        Write-LogMessage "Error during agent cleanup: $_" -Level Error
        return $false
    }
}

# ============================================================================
# Main Script
# ============================================================================

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Azure Arc SQL Server Lab - Cleanup" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check Azure PowerShell connection
Write-LogMessage "Checking Azure PowerShell connection..." -Level Info
$context = Get-AzContext -ErrorAction SilentlyContinue

if (-not $context) {
    Write-LogMessage "Not connected to Azure. Initiating login..." -Level Warning
    Connect-AzAccount
    $context = Get-AzContext
}

Write-LogMessage "Connected to Azure as: $($context.Account.Id)" -Level Success

# Set subscription context if provided
if ($SubscriptionId) {
    Write-LogMessage "Setting subscription context to: $SubscriptionId" -Level Info
    Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
}

$currentSubscription = (Get-AzContext).Subscription
Write-LogMessage "Using subscription: $($currentSubscription.Name)" -Level Info
Write-Host ""

# Calculate resource group names
$arcResourceGroupName = "${BaseName}-arc-rg"
$monitoringResourceGroupName = "${BaseName}-monitoring-rg"

# Check what resources exist
Write-LogMessage "Discovering resources to clean up..." -Level Info

$arcRgExists = Get-AzResourceGroup -Name $arcResourceGroupName -ErrorAction SilentlyContinue
$monitoringRgExists = Get-AzResourceGroup -Name $monitoringResourceGroupName -ErrorAction SilentlyContinue

if (-not $arcRgExists -and -not $monitoringRgExists) {
    Write-LogMessage "No lab resource groups found. Nothing to clean up in Azure." -Level Warning
} else {
    # Display resources to be deleted
    Write-Host ""
    Write-Host "The following resources will be DELETED:" -ForegroundColor Yellow
    Write-Host "  Subscription: $($currentSubscription.Name)" -ForegroundColor Gray
    
    if ($arcRgExists) {
        Write-Host "  Resource Group: $arcResourceGroupName" -ForegroundColor Gray
        $arcResources = Get-AzResource -ResourceGroupName $arcResourceGroupName
        foreach ($resource in $arcResources) {
            Write-Host "    - $($resource.ResourceType): $($resource.Name)" -ForegroundColor DarkGray
        }
    }
    
    if ($monitoringRgExists) {
        Write-Host "  Resource Group: $monitoringResourceGroupName" -ForegroundColor Gray
        $monitoringResources = Get-AzResource -ResourceGroupName $monitoringResourceGroupName
        foreach ($resource in $monitoringResources) {
            Write-Host "    - $($resource.ResourceType): $($resource.Name)" -ForegroundColor DarkGray
        }
    }
}

Write-Host ""
Write-Host "Cleanup Actions:" -ForegroundColor Yellow
if (-not $SkipArcDisconnect) {
    Write-Host "  1. Disconnect and uninstall Azure Arc agent from local machine" -ForegroundColor Gray
}
if ($arcRgExists) {
    Write-Host "  2. Delete Arc resource group: $arcResourceGroupName" -ForegroundColor Gray
}
if ($monitoringRgExists) {
    Write-Host "  3. Delete monitoring resource group: $monitoringResourceGroupName" -ForegroundColor Gray
}

# Confirm cleanup
if (-not (Confirm-Action "Do you want to proceed with cleanup?")) {
    Write-LogMessage "Cleanup cancelled by user" -Level Warning
    exit 0
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Starting Cleanup Process" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Disconnect Arc agent
if (-not $SkipArcDisconnect) {
    Write-LogMessage "Step 1: Disconnecting Azure Arc agent..." -Level Info
    $agentDisconnected = Disconnect-ArcAgent
    Write-Host ""
} else {
    Write-LogMessage "Skipping Arc agent disconnect (as requested)" -Level Warning
    Write-Host ""
}

# Step 2: Delete Arc resource group
if ($arcRgExists) {
    Write-LogMessage "Step 2: Deleting Arc resource group..." -Level Info
    try {
        Remove-AzResourceGroup -Name $arcResourceGroupName -Force | Out-Null
        Write-LogMessage "Arc resource group deleted successfully" -Level Success
    } catch {
        Write-LogMessage "Error deleting Arc resource group: $_" -Level Error
    }
    Write-Host ""
}

# Step 3: Delete monitoring resource group
if ($monitoringRgExists) {
    Write-LogMessage "Step 3: Deleting monitoring resource group..." -Level Info
    try {
        Remove-AzResourceGroup -Name $monitoringResourceGroupName -Force | Out-Null
        Write-LogMessage "Monitoring resource group deleted successfully" -Level Success
    } catch {
        Write-LogMessage "Error deleting monitoring resource group: $_" -Level Error
    }
    Write-Host ""
}

# Verification
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Cleanup Verification" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

$verificationPassed = $true

# Verify Arc agent uninstalled
if (-not $SkipArcDisconnect) {
    $agentPath = "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe"
    if (Test-Path $agentPath) {
        Write-LogMessage "✗ Arc agent still present" -Level Error
        $verificationPassed = $false
    } else {
        Write-LogMessage "✓ Arc agent successfully removed" -Level Success
    }
    
    # Check for Arc services
    $arcServices = Get-Service -Name "himds", "GCArcService", "ExtensionService" -ErrorAction SilentlyContinue
    if ($arcServices) {
        Write-LogMessage "✗ Arc services still running" -Level Error
        $verificationPassed = $false
    } else {
        Write-LogMessage "✓ No Arc services found" -Level Success
    }
}

# Verify resource groups deleted
$arcRgCheck = Get-AzResourceGroup -Name $arcResourceGroupName -ErrorAction SilentlyContinue
if ($arcRgCheck) {
    Write-LogMessage "✗ Arc resource group still exists" -Level Error
    $verificationPassed = $false
} else {
    Write-LogMessage "✓ Arc resource group successfully deleted" -Level Success
}

$monitoringRgCheck = Get-AzResourceGroup -Name $monitoringResourceGroupName -ErrorAction SilentlyContinue
if ($monitoringRgCheck) {
    Write-LogMessage "✗ Monitoring resource group still exists" -Level Error
    $verificationPassed = $false
} else {
    Write-LogMessage "✓ Monitoring resource group successfully deleted" -Level Success
}

Write-Host ""
if ($verificationPassed) {
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host "Cleanup Completed Successfully!" -ForegroundColor Green
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host ""
    Write-LogMessage "All lab resources have been removed" -Level Success
    $exitCode = 0
} else {
    Write-Host "=============================================" -ForegroundColor Yellow
    Write-Host "Cleanup Completed with Warnings" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Yellow
    Write-Host ""
    Write-LogMessage "Some resources may still exist. Please verify manually." -Level Warning
    $exitCode = 1
}

Write-Host ""
Write-LogMessage "Thank you for completing the Azure Arc SQL Server lab!" -Level Info
Write-Host ""

exit $exitCode
