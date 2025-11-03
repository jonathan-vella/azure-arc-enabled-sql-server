# ============================================================================
# Test-ArcConnectivity.ps1
# ============================================================================
# This script validates network connectivity to Azure Arc required endpoints
# Run this script on the on-premises server before onboarding to Azure Arc
# ============================================================================

#Requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Region = "swedencentral",
    
    [Parameter(Mandatory = $false)]
    [string]$ProxyServer = "",
    
    [Parameter(Mandatory = $false)]
    [switch]$ExportReport
)

# ============================================================================
# Functions
# ============================================================================

function Write-TestResult {
    param(
        [string]$TestName,
        [bool]$Success,
        [string]$Message = ""
    )
    
    $status = if ($Success) { "✓ PASS" } else { "✗ FAIL" }
    $color = if ($Success) { "Green" } else { "Red" }
    
    Write-Host "[$status] " -NoNewline -ForegroundColor $color
    Write-Host "$TestName" -NoNewline
    if ($Message) {
        Write-Host " - $Message" -ForegroundColor Gray
    } else {
        Write-Host ""
    }
}

function Test-Endpoint {
    param(
        [string]$Url,
        [int]$Port = 443,
        [string]$ProxyServer = ""
    )
    
    try {
        $uri = [System.Uri]$Url
        $hostname = $uri.Host
        
        # Test DNS resolution
        $dnsResult = $null
        try {
            $dnsResult = [System.Net.Dns]::GetHostAddresses($hostname)
        } catch {
            return @{
                Success = $false
                Error = "DNS resolution failed: $_"
                DNSResolved = $false
                PortOpen = $false
            }
        }
        
        # Test TCP connection
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.ReceiveTimeout = 5000
        $tcpClient.SendTimeout = 5000
        
        if ($ProxyServer) {
            # If using proxy, test proxy connection
            $proxyUri = [System.Uri]$ProxyServer
            $connectTask = $tcpClient.ConnectAsync($proxyUri.Host, $proxyUri.Port)
        } else {
            $connectTask = $tcpClient.ConnectAsync($hostname, $Port)
        }
        
        $timeout = 5000
        if ($connectTask.Wait($timeout)) {
            $tcpClient.Close()
            return @{
                Success = $true
                DNSResolved = $true
                PortOpen = $true
                IPAddress = ($dnsResult | Select-Object -First 1).ToString()
            }
        } else {
            $tcpClient.Close()
            return @{
                Success = $false
                Error = "Connection timeout after $timeout ms"
                DNSResolved = $true
                PortOpen = $false
                IPAddress = ($dnsResult | Select-Object -First 1).ToString()
            }
        }
    } catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
            DNSResolved = ($null -ne $dnsResult)
            PortOpen = $false
        }
    }
}

# ============================================================================
# Main Script
# ============================================================================

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Azure Arc Connectivity Test" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Required endpoints for Azure Arc
$endpoints = @(
    @{ Name = "Azure Resource Manager"; Url = "https://management.azure.com" }
    @{ Name = "Microsoft Entra ID (Login)"; Url = "https://login.microsoftonline.com" }
    @{ Name = "Microsoft Entra ID (Login - alternate)"; Url = "https://login.microsoft.com" }
    @{ Name = "Microsoft Entra ID (Enterprise Registration)"; Url = "https://enterpriseregistration.windows.net" }
    @{ Name = "Azure Arc Agent Download"; Url = "https://aka.ms" }
    @{ Name = "Guest Configuration"; Url = "https://$Region.guestconfiguration.azure.com" }
    @{ Name = "Hybrid Identity Service"; Url = "https://$Region.his.arc.azure.com" }
    @{ Name = "Azure Arc Data Services"; Url = "https://$Region.arcdataservices.com" }
    @{ Name = "Hybrid Connectivity Service"; Url = "https://$Region.service.waconazure.com" }
    @{ Name = "Microsoft Download Center"; Url = "https://download.microsoft.com" }
    @{ Name = "Azure Portal (optional)"; Url = "https://portal.azure.com"; Optional = $true }
)

$results = @()

Write-Host "Target Region: " -NoNewline
Write-Host $Region -ForegroundColor Yellow
if ($ProxyServer) {
    Write-Host "Proxy Server: " -NoNewline
    Write-Host $ProxyServer -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Testing connectivity to required endpoints..." -ForegroundColor Cyan
Write-Host ""

foreach ($endpoint in $endpoints) {
    $testName = $endpoint.Name
    $isOptional = $endpoint.Optional -eq $true
    
    if ($isOptional) {
        $testName += " (optional)"
    }
    
    Write-Host "Testing: $testName..." -NoNewline
    
    $result = Test-Endpoint -Url $endpoint.Url -ProxyServer $ProxyServer
    
    Write-Host "`r" -NoNewline
    
    if ($result.Success) {
        Write-TestResult -TestName $testName -Success $true -Message "Connected ($($result.IPAddress))"
        $results += @{
            Endpoint = $endpoint.Name
            Url = $endpoint.Url
            Status = "Success"
            IPAddress = $result.IPAddress
            Optional = $isOptional
        }
    } else {
        $failMessage = $result.Error
        if (-not $result.DNSResolved) {
            $failMessage = "DNS resolution failed"
        } elseif (-not $result.PortOpen) {
            $failMessage = "Port 443 not reachable"
        }
        
        Write-TestResult -TestName $testName -Success $false -Message $failMessage
        $results += @{
            Endpoint = $endpoint.Name
            Url = $endpoint.Url
            Status = "Failed"
            Error = $failMessage
            Optional = $isOptional
        }
    }
}

# Summary
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$requiredResults = $results | Where-Object { -not $_.Optional }
$failedRequired = $requiredResults | Where-Object { $_.Status -eq "Failed" }
$passedRequired = $requiredResults | Where-Object { $_.Status -eq "Success" }

$optionalResults = $results | Where-Object { $_.Optional }
$failedOptional = $optionalResults | Where-Object { $_.Status -eq "Failed" }

Write-Host ""
Write-Host "Required Endpoints: " -NoNewline
Write-Host "$($passedRequired.Count)/$($requiredResults.Count) passed" -ForegroundColor $(if ($passedRequired.Count -eq $requiredResults.Count) { "Green" } else { "Red" })

if ($optionalResults.Count -gt 0) {
    Write-Host "Optional Endpoints: " -NoNewline
    $passedOptional = $optionalResults.Count - $failedOptional.Count
    Write-Host "$passedOptional/$($optionalResults.Count) passed" -ForegroundColor Gray
}

Write-Host ""

if ($failedRequired.Count -eq 0) {
    Write-Host "✓ All required connectivity tests passed!" -ForegroundColor Green
    Write-Host "  You can proceed with Azure Arc onboarding." -ForegroundColor Green
    $exitCode = 0
} else {
    Write-Host "✗ Some required connectivity tests failed!" -ForegroundColor Red
    Write-Host "  Please resolve connectivity issues before proceeding." -ForegroundColor Red
    Write-Host ""
    Write-Host "Failed Endpoints:" -ForegroundColor Red
    foreach ($failed in $failedRequired) {
        Write-Host "  - $($failed.Endpoint): $($failed.Url)" -ForegroundColor Red
        Write-Host "    Error: $($failed.Error)" -ForegroundColor Gray
    }
    $exitCode = 1
}

# Recommendations
if ($failedRequired.Count -gt 0) {
    Write-Host ""
    Write-Host "Recommendations:" -ForegroundColor Yellow
    Write-Host "  1. Verify firewall allows outbound HTTPS (port 443) to Azure" -ForegroundColor Gray
    Write-Host "  2. Check DNS resolution for failed endpoints" -ForegroundColor Gray
    Write-Host "  3. If using a proxy, ensure it's configured correctly" -ForegroundColor Gray
    Write-Host "  4. Review https://learn.microsoft.com/azure/azure-arc/servers/network-requirements" -ForegroundColor Gray
}

# Export report
if ($ExportReport) {
    $reportPath = Join-Path $PSScriptRoot "connectivity-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $results | ConvertTo-Json -Depth 10 | Out-File $reportPath
    Write-Host ""
    Write-Host "Report exported to: $reportPath" -ForegroundColor Cyan
}

Write-Host ""
exit $exitCode
