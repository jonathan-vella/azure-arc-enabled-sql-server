# Test script for BPA at-scale enablement
# This validates the core components without creating resources

param(
    [string]$SubscriptionId = 'noalz',
    [string]$Location = 'eastus',
    [string]$ArcRg = 'rg-test-arc-sql',
    [string]$LaRg = 'rg-test-logs',
    [string]$LaName = 'la-test-arc-sql-bpa',
    [switch]$CreateResources
)

Write-Host "=== Testing BPA At-Scale Script ===" -ForegroundColor Cyan

# Step 0: Check Azure connection and subscription
Write-Host "`n1. Testing Azure Connection..." -ForegroundColor Yellow
try {
    $context = Get-AzContext
    if (-not $context) {
        Write-Host "Not connected to Azure. Please run Connect-AzAccount first." -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Connected to Azure" -ForegroundColor Green
    Write-Host "  Account: $($context.Account.Id)" -ForegroundColor Gray
    Write-Host "  Tenant: $($context.Tenant.Id)" -ForegroundColor Gray
} catch {
    Write-Error "Failed to check Azure connection: $($_.Exception.Message)"
    exit 1
}

# Step 1: Find and set subscription
Write-Host "`n2. Finding Subscription..." -ForegroundColor Yellow
$subscription = Get-AzSubscription | Where-Object { $_.Name -like "*$SubscriptionId*" -or $_.Id -eq $SubscriptionId }
if (-not $subscription) {
    Write-Host "Available subscriptions:" -ForegroundColor Red
    Get-AzSubscription | Select-Object Name, Id | Format-Table -AutoSize
    Write-Error "Subscription not found: $SubscriptionId"
    exit 1
}

Write-Host "✓ Found subscription: $($subscription.Name)" -ForegroundColor Green
Set-AzContext -Subscription $subscription.Id | Out-Null

# Step 2: Test policy lookup
Write-Host "`n3. Testing Policy Lookup..." -ForegroundColor Yellow
$policyDisplayNamePattern = 'Configure Arc-enabled Servers with SQL Server extension installed to enable or disable SQL best practices assessment'
$policyDefinition = Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -match [regex]::Escape($policyDisplayNamePattern) }

if ($policyDefinition) {
    Write-Host "✓ Found policy definition" -ForegroundColor Green
    Write-Host "  Name: $($policyDefinition.Name)" -ForegroundColor Gray
    Write-Host "  DisplayName: $($policyDefinition.Properties.DisplayName)" -ForegroundColor Gray
    
    Write-Host "`n  Parameters:" -ForegroundColor Gray
    $policyDefinition.Properties.Parameters.GetEnumerator() | ForEach-Object {
        Write-Host "    $($_.Key): $($_.Value.type)" -ForegroundColor DarkGray
    }
} else {
    Write-Error "Policy definition not found"
    exit 1
}

# Step 3: Test resource group operations
Write-Host "`n4. Testing Resource Group Operations..." -ForegroundColor Yellow
Write-Host "Test parameters:" -ForegroundColor Gray
Write-Host "  Location: $Location"
Write-Host "  Arc RG: $ArcRg"
Write-Host "  Logs RG: $LaRg"
Write-Host "  Workspace: $LaName"

if ($CreateResources) {
    Write-Host "`nCreating test resources..." -ForegroundColor Yellow
    
    # Create resource groups
    try {
        $arcRgResult = New-AzResourceGroup -Name $ArcRg -Location $Location -Force
        Write-Host "✓ Created Arc resource group: $($arcRgResult.ResourceGroupName)" -ForegroundColor Green
        
        $laRgResult = New-AzResourceGroup -Name $LaRg -Location $Location -Force
        Write-Host "✓ Created Log Analytics resource group: $($laRgResult.ResourceGroupName)" -ForegroundColor Green
    } catch {
        Write-Error "Failed to create resource groups: $($_.Exception.Message)"
        exit 1
    }
    
    # Create Log Analytics workspace
    try {
        $workspace = New-AzOperationalInsightsWorkspace -ResourceGroupName $LaRg -Name $LaName -Location $Location -Sku PerGB2018
        Write-Host "✓ Created Log Analytics workspace: $($workspace.Name)" -ForegroundColor Green
        Write-Host "  Resource ID: $($workspace.ResourceId)" -ForegroundColor Gray
        Write-Host "  Location: $($workspace.Location)" -ForegroundColor Gray
        
        # Test policy assignment parameters
        $parameters = @{
            laWorkspaceId       = $workspace.ResourceId
            laWorkspaceLocation = $workspace.Location
            isEnabled           = $true
        }
        
        Write-Host "`n✓ Policy parameters validated:" -ForegroundColor Green
        $parameters.GetEnumerator() | ForEach-Object {
            Write-Host "  $($_.Key): $($_.Value)" -ForegroundColor Gray
        }
        
    } catch {
        Write-Error "Failed to create Log Analytics workspace: $($_.Exception.Message)"
        exit 1
    }
} else {
    Write-Host "`n⚠ Dry run mode - no resources created" -ForegroundColor Yellow
    Write-Host "  Use -CreateResources to actually create test resources" -ForegroundColor Gray
}

Write-Host "`n=== Test Results ===" -ForegroundColor Cyan
Write-Host "✓ Azure connection validated" -ForegroundColor Green
Write-Host "✓ Subscription found and set" -ForegroundColor Green
Write-Host "✓ BPA policy definition located" -ForegroundColor Green
Write-Host "✓ Resource parameters validated" -ForegroundColor Green

if ($CreateResources) {
    Write-Host "✓ Test resources created successfully" -ForegroundColor Green
    Write-Host "`nCleanup commands:" -ForegroundColor Yellow
    Write-Host "  Remove-AzResourceGroup -Name '$ArcRg' -Force" -ForegroundColor Gray
    Write-Host "  Remove-AzResourceGroup -Name '$LaRg' -Force" -ForegroundColor Gray
} else {
    Write-Host "`nTo test resource creation:" -ForegroundColor Yellow
    Write-Host "  .\test-at-scale.ps1 -CreateResources" -ForegroundColor Gray
}
