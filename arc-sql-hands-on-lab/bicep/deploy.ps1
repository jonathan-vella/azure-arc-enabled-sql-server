# ============================================================================
# Azure Arc-Enabled SQL Server Lab - Deployment Script
# ============================================================================
# This script deploys the lab infrastructure using Bicep templates
# ============================================================================

#Requires -Version 7.0
#Requires -Modules @{ ModuleName="Az.Accounts"; ModuleVersion="2.0.0" }
#Requires -Modules @{ ModuleName="Az.Resources"; ModuleVersion="6.0.0" }

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $false)]
    [string]$BaseName = "arcsql-lab",
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('dev', 'test', 'prod')]
    [string]$Environment = "dev",
    
    [Parameter(Mandatory = $false)]
    [string]$Location = "swedencentral"
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

# ============================================================================
# Main Script
# ============================================================================

try {
    Write-LogMessage "Starting Azure Arc SQL Server Lab deployment..." -Level Info
    Write-LogMessage "=============================================" -Level Info
    
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
    Write-LogMessage "Using subscription: $($currentSubscription.Name) ($($currentSubscription.Id))" -Level Info
    
    # Register required resource providers
    Write-LogMessage "Registering required resource providers..." -Level Info
    $providers = @('Microsoft.HybridCompute', 'Microsoft.AzureArcData', 'Microsoft.OperationalInsights')
    
    foreach ($provider in $providers) {
        $registration = Get-AzResourceProvider -ProviderNamespace $provider
        if ($registration.RegistrationState -ne 'Registered') {
            Write-LogMessage "Registering $provider..." -Level Info
            Register-AzResourceProvider -ProviderNamespace $provider | Out-Null
        } else {
            Write-LogMessage "$provider is already registered" -Level Success
        }
    }
    
    # Deploy Bicep template
    Write-LogMessage "Deploying infrastructure using Bicep..." -Level Info
    $deploymentName = "arc-sql-lab-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    $templateFile = Join-Path $PSScriptRoot "main.bicep"
    
    $deploymentParams = @{
        Name              = $deploymentName
        Location          = $Location
        TemplateFile      = $templateFile
        baseName          = $BaseName
        location          = $Location
        environment       = $Environment
        Verbose           = $VerbosePreference
    }
    
    $deployment = New-AzDeployment @deploymentParams
    
    if ($deployment.ProvisioningState -eq 'Succeeded') {
        Write-LogMessage "=============================================" -Level Success
        Write-LogMessage "Deployment completed successfully!" -Level Success
        Write-LogMessage "=============================================" -Level Success
        Write-LogMessage "" -Level Info
        Write-LogMessage "Deployment Outputs:" -Level Info
        Write-LogMessage "  Arc Resource Group: $($deployment.Outputs.arcResourceGroupName.Value)" -Level Info
        Write-LogMessage "  Monitoring Resource Group: $($deployment.Outputs.monitoringResourceGroupName.Value)" -Level Info
        Write-LogMessage "  Log Analytics Workspace: $($deployment.Outputs.logAnalyticsWorkspaceName.Value)" -Level Info
        Write-LogMessage "  Region: $($deployment.Outputs.location.Value)" -Level Info
        Write-LogMessage "" -Level Info
        Write-LogMessage "Next Steps:" -Level Info
        Write-LogMessage "  1. Proceed to Module 1 of the lab guide" -Level Info
        Write-LogMessage "  2. Validate network connectivity to Azure Arc endpoints" -Level Info
        Write-LogMessage "  3. Begin Arc onboarding of your SQL Server" -Level Info
        
        # Save outputs to file for reference
        $outputFile = Join-Path $PSScriptRoot "deployment-outputs.json"
        $deployment.Outputs | ConvertTo-Json -Depth 10 | Out-File $outputFile
        Write-LogMessage "Deployment outputs saved to: $outputFile" -Level Success
    } else {
        Write-LogMessage "Deployment failed with state: $($deployment.ProvisioningState)" -Level Error
        exit 1
    }
    
} catch {
    Write-LogMessage "An error occurred during deployment: $_" -Level Error
    Write-LogMessage $_.Exception.Message -Level Error
    exit 1
}
