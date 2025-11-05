# ============================================================================
# Test-ArcConnectivity.ps1
# ============================================================================
# This script validates network connectivity to Azure Arc required endpoints
# Run this script on the on-premises server before onboarding to Azure Arc
# Based on Azure Jumpstart Drop: Azure Arc Connectivity Check
# ============================================================================

#Requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Region = "swedencentral",
    
    [Parameter(Mandatory = $false)]
    [string]$Cloud = "AzureCloud",
    
    [Parameter(Mandatory = $false)]
    [switch]$EnableArcAgentCheck,
    
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
        [string]$Message = "",
        [string]$Details = ""
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
    
    if ($Details) {
        Write-Host "       $Details" -ForegroundColor DarkGray
    }
}

function Test-DnsResolution {
    param([string]$Endpoint)
    
    try {
        Write-Verbose "Testing DNS resolution for: $Endpoint"
        $dnsResult = Resolve-DnsName -Name $Endpoint -ErrorAction Stop -DnsOnly
        $ipAddress = ($dnsResult | Where-Object { $_.Type -eq 'A' } | Select-Object -First 1).IPAddress
        
        if (-not $ipAddress) {
            $ipAddress = ($dnsResult | Where-Object { $_.Type -eq 'AAAA' } | Select-Object -First 1).IPAddress
        }
        
        return @{
            Success = $true
            Result = $dnsResult
            IPAddress = $ipAddress
        }
    } catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

function Test-NetworkConnectivity {
    param([string]$Endpoint)
    
    try {
        $pingResult = Test-Connection -ComputerName $Endpoint -Count 1 -ErrorAction Stop
        return @{
            Success = $true
            ResponseTime = $pingResult.ResponseTime
        }
    } catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

function Test-HttpEndpoint {
    param([string]$Endpoint)
    
    try {
        $webResponse = $null
        $response_time = Measure-Command { 
            $webResponse = Invoke-WebRequest -Uri "https://$Endpoint" -Method Get -ErrorAction Stop
        }
        
        return @{
            Success = $true
            StatusCode = $webResponse.StatusCode
            ResponseTime = [math]::Round($response_time.TotalSeconds, 2)
        }
    } catch {
        # HTTP 401 is expected for many Arc endpoints (authentication required)
        if ($_.Exception.Message -like "*401*" -or $_.Exception.Response.StatusCode -eq 401) {
            return @{
                Success = $true
                StatusCode = 401
                Message = "Expected (401 - Authentication Required)"
            }
        }
        
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

# ============================================================================
# Main Script
# ============================================================================

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Azure Arc Connectivity Test" -ForegroundColor Cyan
Write-Host "Based on Azure Jumpstart Drop" -ForegroundColor Gray
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Define static endpoints based on Azure Jumpstart Drop script
$staticEndpoints = @(
    @{ Name = "Microsoft Entra ID (Windows)"; Endpoint = "login.windows.net"; Category = "AAD" }
    @{ Name = "Microsoft Entra ID (Microsoft Online)"; Endpoint = "login.microsoftonline.com"; Category = "AAD" }
    @{ Name = "Microsoft Entra ID (PAS)"; Endpoint = "pas.windows.net"; Category = "AAD" }
    @{ Name = "Azure Resource Manager"; Endpoint = "management.azure.com"; Category = "ARM" }
    @{ Name = "Azure Monitor Control"; Endpoint = "global.handler.control.monitor.azure.com"; Category = "AMA" }
    @{ Name = "Arc Hybrid Identity Service (Global)"; Endpoint = "gbl.his.arc.azure.com"; Category = "Arc" }
    @{ Name = "Arc Guest Configuration API"; Endpoint = "agentserviceapi.guestconfiguration.azure.com"; Category = "Arc" }
    @{ Name = "Arc Data Processing Service"; Endpoint = "dataprocessingservice.$Region.arcdataservices.com".Replace('$Region', $Region); Category = "ArcData"; TestHttp = $true }
    @{ Name = "Arc Telemetry Service"; Endpoint = "telemetry.$Region.arcdataservices.com".Replace('$Region', $Region); Category = "ArcData"; TestHttp = $true }
)

# Fetch dynamic endpoints for Service Bus (notification service)
Write-Host "Fetching dynamic Service Bus endpoints for region: $Region..." -ForegroundColor Yellow
$dynamicEndpoints = @()
try {
    $response = Invoke-WebRequest -Uri "https://guestnotificationservice.azure.com/urls/allowlist?api-version=2020-01-01&location=$Region" -ErrorAction Stop
    $serviceBusUrls = ($response.Content -replace '\[|\]|"|\\n','').Split(',') | Where-Object { $_ -ne '' }
    foreach ($url in $serviceBusUrls) {
        $dynamicEndpoints += @{ 
            Name = "Service Bus Endpoint"
            Endpoint = $url.Trim()
            Category = "ServiceBus"
            Optional = $true
        }
    }
    Write-Host "  Found $($dynamicEndpoints.Count) Service Bus endpoints" -ForegroundColor Green
} catch {
    Write-Host "  Warning: Could not fetch dynamic Service Bus endpoints: $_" -ForegroundColor Yellow
    Write-Host "  Continuing with static endpoints only..." -ForegroundColor Gray
}

# Combine all endpoints
$allEndpoints = $staticEndpoints + $dynamicEndpoints

Write-Host ""
Write-Host "Target Region: " -NoNewline
Write-Host $Region -ForegroundColor Yellow
Write-Host "Cloud: " -NoNewline
Write-Host $Cloud -ForegroundColor Yellow
Write-Host ""
Write-Host "Testing connectivity to required endpoints..." -ForegroundColor Cyan
Write-Host ""

$results = @()
$testNumber = 1
$totalTests = $allEndpoints.Count

foreach ($endpoint in $allEndpoints) {
    $testName = $endpoint.Name
    $endpointUrl = $endpoint.Endpoint
    $isOptional = $endpoint.Optional -eq $true
    
    Write-Host "[$testNumber/$totalTests] " -NoNewline -ForegroundColor DarkGray
    Write-Host "$testName " -NoNewline -ForegroundColor White
    Write-Host "($endpointUrl)" -ForegroundColor DarkGray
    
    # DNS Resolution Test
    Write-Host "  → DNS Resolution..." -NoNewline
    $dnsResult = Test-DnsResolution -Endpoint $endpointUrl
    
    if ($dnsResult.Success) {
        Write-Host " ✓" -ForegroundColor Green
        $dnsStatus = "Success"
        $ipAddress = $dnsResult.IPAddress
    } else {
        Write-Host " ✗ FAILED" -ForegroundColor Red
        Write-Host "     Error: $($dnsResult.Error)" -ForegroundColor Red
        $dnsStatus = "Failed"
        $ipAddress = $null
    }
    
    # Network Connectivity Test (ping)
    if ($dnsResult.Success) {
        Write-Host "  → Network Connectivity..." -NoNewline
        $pingResult = Test-NetworkConnectivity -Endpoint $endpointUrl
        
        if ($pingResult.Success) {
            Write-Host " ✓ ($($pingResult.ResponseTime)ms)" -ForegroundColor Green
            $pingStatus = "Success"
        } else {
            Write-Host " ✗ No Response" -ForegroundColor Yellow
            $pingStatus = "No Response (ICMP may be blocked)"
        }
    } else {
        $pingStatus = "Skipped"
    }
    
    # HTTP/HTTPS Test (for specific endpoints)
    $httpStatus = "Not Applicable"
    if ($endpoint.TestHttp -and $dnsResult.Success) {
        Write-Host "  → HTTPS Endpoint Test..." -NoNewline
        $httpResult = Test-HttpEndpoint -Endpoint $endpointUrl
        
        if ($httpResult.Success) {
            if ($httpResult.StatusCode -eq 401) {
                Write-Host " ✓ Expected (401)" -ForegroundColor Green
                $httpStatus = "Success (401 Expected)"
            } else {
                Write-Host " ✓ ($($httpResult.StatusCode))" -ForegroundColor Green
                $httpStatus = "Success ($($httpResult.StatusCode))"
            }
        } else {
            Write-Host " ✗ FAILED" -ForegroundColor Red
            Write-Host "     Error: $($httpResult.Error)" -ForegroundColor Red
            $httpStatus = "Failed"
        }
    }
    
    # Overall status
    $overallSuccess = $dnsResult.Success
    
    $results += [PSCustomObject]@{
        Number = $testNumber
        Name = $testName
        Endpoint = $endpointUrl
        Category = $endpoint.Category
        DNSStatus = $dnsStatus
        IPAddress = $ipAddress
        PingStatus = $pingStatus
        HttpStatus = $httpStatus
        Optional = $isOptional
        OverallSuccess = $overallSuccess
    }
    
    Write-Host ""
    $testNumber++
}

# Azure Arc Agent Check (if enabled and agent is installed)
if ($EnableArcAgentCheck) {
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "Azure Arc Agent Check" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host ""
    
    $azcmagentPath = Join-Path $env:PROGRAMFILES "AzureConnectedMachineAgent\azcmagent.exe"
    if (Test-Path $azcmagentPath) {
        Write-Host "Running azcmagent check..." -ForegroundColor Yellow
        Write-Host ""
        
        try {
            & $azcmagentPath check --location $Region --cloud $Cloud --extensions sql --enable-pls-check
            Write-Host ""
            Write-Host "✓ Azure Arc agent check completed" -ForegroundColor Green
        } catch {
            Write-Host "✗ Azure Arc agent check failed: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "⚠ Azure Arc agent (azcmagent.exe) not found at: $azcmagentPath" -ForegroundColor Yellow
        Write-Host "  Install the agent to run comprehensive Arc connectivity checks" -ForegroundColor Gray
    }
    Write-Host ""
}

# Summary
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

$requiredResults = $results | Where-Object { -not $_.Optional }
$failedRequired = $requiredResults | Where-Object { -not $_.OverallSuccess }
$passedRequired = $requiredResults | Where-Object { $_.OverallSuccess }

$optionalResults = $results | Where-Object { $_.Optional }
$passedOptional = $optionalResults | Where-Object { $_.OverallSuccess }

# Group by category
$groupedResults = $requiredResults | Group-Object -Property Category
Write-Host "Results by Category:" -ForegroundColor Cyan
foreach ($group in $groupedResults) {
    $passed = ($group.Group | Where-Object { $_.OverallSuccess }).Count
    $total = $group.Count
    $status = if ($passed -eq $total) { "✓" } else { "✗" }
    $color = if ($passed -eq $total) { "Green" } else { "Red" }
    
    Write-Host "  [$status] " -NoNewline -ForegroundColor $color
    Write-Host "$($group.Name): " -NoNewline
    Write-Host "$passed/$total passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Red" })
}

Write-Host ""
Write-Host "Overall Results:" -ForegroundColor Cyan
Write-Host "  Required Endpoints: " -NoNewline
Write-Host "$($passedRequired.Count)/$($requiredResults.Count) passed" -ForegroundColor $(if ($passedRequired.Count -eq $requiredResults.Count) { "Green" } else { "Red" })

if ($optionalResults.Count -gt 0) {
    Write-Host "  Optional Endpoints: " -NoNewline
    Write-Host "$($passedOptional.Count)/$($optionalResults.Count) passed" -ForegroundColor Gray
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
        Write-Host "  - $($failed.Name): $($failed.Endpoint)" -ForegroundColor Red
        Write-Host "    DNS: $($failed.DNSStatus) | Ping: $($failed.PingStatus)" -ForegroundColor Gray
    }
    $exitCode = 1
}

# Recommendations
if ($failedRequired.Count -gt 0) {
    Write-Host ""
    Write-Host "Recommendations:" -ForegroundColor Yellow
    Write-Host "  1. Verify firewall allows outbound HTTPS (port 443) to Azure" -ForegroundColor Gray
    Write-Host "  2. Check DNS resolution for failed endpoints" -ForegroundColor Gray
    Write-Host "  3. ICMP (ping) may be blocked - this is OK if DNS and HTTPS work" -ForegroundColor Gray
    Write-Host "  4. Review https://learn.microsoft.com/azure/azure-arc/servers/network-requirements" -ForegroundColor Gray
    Write-Host "  5. Consider using Azure Arc gateway to reduce required endpoints" -ForegroundColor Gray
}

# Export report
if ($ExportReport) {
    $reportPath = Join-Path $PSScriptRoot "connectivity-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    
    $reportData = @{
        TestDate = (Get-Date -Format 'o')
        Region = $Region
        Cloud = $Cloud
        TotalEndpoints = $results.Count
        RequiredEndpoints = $requiredResults.Count
        OptionalEndpoints = $optionalResults.Count
        PassedRequired = $passedRequired.Count
        FailedRequired = $failedRequired.Count
        PassedOptional = $passedOptional.Count
        OverallSuccess = ($failedRequired.Count -eq 0)
        Results = $results
    }
    
    $reportData | ConvertTo-Json -Depth 10 | Out-File $reportPath -Encoding UTF8
    Write-Host ""
    Write-Host "Report exported to: $reportPath" -ForegroundColor Cyan
}

Write-Host ""
exit $exitCode
