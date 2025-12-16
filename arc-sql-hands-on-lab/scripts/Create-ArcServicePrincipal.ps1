# ============================================================================
# Create-ArcServicePrincipal.ps1
# ============================================================================
# This script creates a Service Principal for Azure Arc onboarding at scale
# with the required permissions (Azure Connected Machine Onboarding role)
# ============================================================================

#Requires -Version 7.0
#Requires -Modules @{ ModuleName="Az.Accounts"; ModuleVersion="2.0.0" }
#Requires -Modules @{ ModuleName="Az.Resources"; ModuleVersion="6.0.0" }

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $false)]
    [string]$ServicePrincipalName = "Arc-SQL-Lab-Onboarding-SP",
    
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('Subscription', 'ResourceGroup')]
    [string]$Scope = 'Subscription',
    
    [Parameter(Mandatory = $false)]
    [int]$SecretExpirationMonths = 12
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

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Azure Arc Service Principal Creation" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

try {
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
    
    # Determine scope
    if ($Scope -eq 'ResourceGroup' -and -not $ResourceGroupName) {
        Write-LogMessage "ResourceGroup scope selected but no ResourceGroupName provided!" -Level Error
        throw "Please provide -ResourceGroupName when using ResourceGroup scope"
    }
    
    $scopePath = if ($Scope -eq 'ResourceGroup') {
        "/subscriptions/$($currentSubscription.Id)/resourceGroups/$ResourceGroupName"
    } else {
        "/subscriptions/$($currentSubscription.Id)"
    }
    
    Write-LogMessage "Service Principal will be scoped to: $Scope" -Level Info
    if ($Scope -eq 'ResourceGroup') {
        Write-LogMessage "Resource Group: $ResourceGroupName" -Level Info
    }
    Write-Host ""
    
    # Check if service principal already exists
    Write-LogMessage "Checking if service principal already exists..." -Level Info
    $existingSP = Get-AzADServicePrincipal -DisplayName $ServicePrincipalName -ErrorAction SilentlyContinue
    
    if ($existingSP) {
        Write-LogMessage "Service Principal '$ServicePrincipalName' already exists!" -Level Warning
        Write-Host ""
        Write-Host "Existing Service Principal Details:" -ForegroundColor Yellow
        Write-Host "  Display Name: $($existingSP.DisplayName)" -ForegroundColor Gray
        Write-Host "  Application ID: $($existingSP.AppId)" -ForegroundColor Gray
        Write-Host "  Object ID: $($existingSP.Id)" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "Do you want to:" -ForegroundColor Yellow
        Write-Host "  1. Use existing service principal (create new secret)" -ForegroundColor Gray
        Write-Host "  2. Delete and recreate service principal" -ForegroundColor Gray
        Write-Host "  3. Cancel operation" -ForegroundColor Gray
        $choice = Read-Host "Enter choice (1-3)"
        
        switch ($choice) {
            "1" {
                Write-LogMessage "Using existing service principal, creating new secret..." -Level Info
                $sp = $existingSP
            }
            "2" {
                Write-LogMessage "Deleting existing service principal..." -Level Warning
                Remove-AzADServicePrincipal -ObjectId $existingSP.Id -Force
                Start-Sleep -Seconds 5
                $sp = $null
            }
            default {
                Write-LogMessage "Operation cancelled by user" -Level Warning
                exit 0
            }
        }
    }
    
    # Create service principal if needed
    if (-not $sp) {
        Write-LogMessage "Creating new service principal: $ServicePrincipalName" -Level Info
        
        # Calculate expiration date
        $endDate = (Get-Date).AddMonths($SecretExpirationMonths)
        
        # Create service principal with Azure Connected Machine Onboarding role
        $sp = New-AzADServicePrincipal `
            -DisplayName $ServicePrincipalName `
            -Role "Azure Connected Machine Onboarding" `
            -Scope $scopePath `
            -EndDate $endDate
        
        Write-LogMessage "Service principal created successfully!" -Level Success
        Start-Sleep -Seconds 5  # Allow time for propagation
    }
    
    # Create new secret
    Write-LogMessage "Creating new client secret..." -Level Info
    $endDate = (Get-Date).AddMonths($SecretExpirationMonths)
    
    $credential = New-AzADAppCredential `
        -ApplicationId $sp.AppId `
        -EndDate $endDate
    
    # Get tenant ID
    $tenantId = (Get-AzContext).Tenant.Id
    
    # Display results
    Write-Host ""
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host "Service Principal Created Successfully!" -ForegroundColor Green
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "IMPORTANT: Save these credentials securely!" -ForegroundColor Yellow
    Write-Host "The secret cannot be retrieved again after this session." -ForegroundColor Yellow
    Write-Host ""
    
    $output = @{
        DisplayName = $sp.DisplayName
        ApplicationId = $sp.AppId
        ObjectId = $sp.Id
        TenantId = $tenantId
        SubscriptionId = $currentSubscription.Id
        Secret = $credential.SecretText
        SecretExpiresOn = $endDate.ToString('yyyy-MM-dd')
        Scope = $Scope
    }
    
    if ($Scope -eq 'ResourceGroup') {
        $output.ResourceGroup = $ResourceGroupName
    }
    
    Write-Host "Service Principal Details:" -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor Cyan
    Write-Host "Display Name        : $($output.DisplayName)" -ForegroundColor White
    Write-Host "Application ID      : " -NoNewline -ForegroundColor White
    Write-Host "$($output.ApplicationId)" -ForegroundColor Yellow
    Write-Host "Object ID           : $($output.ObjectId)" -ForegroundColor White
    Write-Host "Tenant ID           : " -NoNewline -ForegroundColor White
    Write-Host "$($output.TenantId)" -ForegroundColor Yellow
    Write-Host "Subscription ID     : $($output.SubscriptionId)" -ForegroundColor White
    Write-Host "Secret              : " -NoNewline -ForegroundColor White
    Write-Host "$($output.Secret)" -ForegroundColor Red
    Write-Host "Secret Expires      : $($output.SecretExpiresOn)" -ForegroundColor White
    Write-Host "Role Assignment     : Azure Connected Machine Onboarding" -ForegroundColor White
    Write-Host "Scope               : $($output.Scope)" -ForegroundColor White
    if ($Scope -eq 'ResourceGroup') {
        Write-Host "Resource Group      : $($output.ResourceGroup)" -ForegroundColor White
    }
    
    # Save to file
    $outputPath = Join-Path $PSScriptRoot "service-principal-credentials.json"
    $output | ConvertTo-Json -Depth 10 | Out-File $outputPath -Force
    
    Write-Host ""
    Write-LogMessage "Credentials saved to: $outputPath" -Level Success
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Store the credentials securely (Key Vault, Password Manager)" -ForegroundColor Gray
    Write-Host "  2. Delete the JSON file after securing credentials" -ForegroundColor Gray
    Write-Host "  3. Use these credentials in your Arc onboarding script" -ForegroundColor Gray
    Write-Host "  4. Set calendar reminder for secret expiration: $($output.SecretExpiresOn)" -ForegroundColor Gray
    Write-Host ""
    
    # Show example azcmagent command
    Write-Host "Example azcmagent connect command:" -ForegroundColor Cyan
    Write-Host "===================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "azcmagent connect ``" -ForegroundColor White
    Write-Host "  --service-principal-id `"$($output.ApplicationId)`" ``" -ForegroundColor White
    Write-Host "  --service-principal-secret `"$($output.Secret)`" ``" -ForegroundColor White
    Write-Host "  --tenant-id `"$($output.TenantId)`" ``" -ForegroundColor White
    Write-Host "  --subscription-id `"$($output.SubscriptionId)`" ``" -ForegroundColor White
    Write-Host "  --resource-group `"<your-resource-group>`" ``" -ForegroundColor White
    Write-Host "  --location `"<azure-region>`"" -ForegroundColor White
    Write-Host ""
    
    # Security reminders
    Write-Host "Security Best Practices:" -ForegroundColor Yellow
    Write-Host "  ⚠ Treat the secret like a password - never commit to source control" -ForegroundColor Gray
    Write-Host "  ⚠ Store in Azure Key Vault or secure password manager" -ForegroundColor Gray
    Write-Host "  ⚠ Rotate secrets before expiration ($($output.SecretExpiresOn))" -ForegroundColor Gray
    Write-Host "  ⚠ Use minimum required permissions (already configured)" -ForegroundColor Gray
    Write-Host "  ⚠ Monitor service principal usage in Microsoft Entra ID logs" -ForegroundColor Gray
    Write-Host ""
    
} catch {
    Write-LogMessage "An error occurred: $_" -Level Error
    Write-LogMessage $_.Exception.Message -Level Error
    exit 1
}
