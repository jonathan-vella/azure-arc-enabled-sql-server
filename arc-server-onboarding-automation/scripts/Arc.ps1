$global:scriptPath = $myinvocation.mycommand.definition

$ErrorActionPreference = 'Stop'

$csvPath = "./test_cmdb.csv"

function Restart-AsAdmin {
    $pwshCommand = "powershell"
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        $pwshCommand = "pwsh"
    }

    try {
        Write-Host "This script requires administrator permissions to install the Azure Connected Machine Agent. Attempting to restart script with elevated permissions..."
        $arguments = "-NoExit -Command `"& '$scriptPath'`""
        Start-Process $pwshCommand -Verb runAs -ArgumentList $arguments
        exit 0
    } catch {
        throw "Failed to elevate permissions. Please run this script as Administrator."
    }
}

# extract customer env info from csv based on the hostname
function Get-CustomerInfo {
    param (
        [Parameter(Mandatory=$true)]
        [string]$csvPath,
        [Parameter(Mandatory=$true)]
        [string]$hostname
    )

    # test filepath exists
    if (-not (Test-Path $csvPath)) {
        throw "CSV file not found at location: $csvPath"
        exit 0
    }

    $cmdbData = Import-Csv -Path $csvPath -Delimiter ";" 

    # matchingRow returns multiple objects if there are multiple sql instances on the server
    # assumption: server hostname is unique per customer
    try {
        $matchingRow = $cmdbData | Where-Object { $_.Server_Unique_Identifier -eq $hostname}
        $customer = $matchingRow[0]
    }
    catch {
        throw "Failed to find customer with server $hostname in the CMDB. Please check the CSV file for the correct server name."
        exit 0
    }
    
    # resourcegroup should be named custoername + "-rg"
    $resourceGroup = $customer.Name + "-arc-rg"

    $customerInfo = @{
        "SubscriptionId" = $customer.Subscription_Id
        "ResourceGroup" = $resourceGroup
        "TenantId" = $customer.Tenant_Id
        "ServicePrincipalId" = $customer.AppId
        "ServicePrincipalSecret" = $customer.App_Secret
    }
    return $customerInfo
}

$customerInfo = Get-CustomerInfo -csvPath $csvPath -hostname $env:COMPUTERNAME


try {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        if ([System.Environment]::UserInteractive) {
            Restart-AsAdmin
        } else {
            throw "This script requires administrator permissions to install the Azure Connected Machine Agent. Please run this script as Administrator."
        }
    }

    # Add the service principal application ID and secret here
    $ServicePrincipalId=$customerInfo.ServicePrincipalId;
    $ServicePrincipalClientSecret=$customerInfo.ServicePrincipalSecret;

    $env:SUBSCRIPTION_ID = $customerInfo.SubscriptionId;
    $env:RESOURCE_GROUP = $customerInfo.ResourceGroup;
    $env:TENANT_ID = $customerInfo.TenantId;
    $env:LOCATION = "westeurope";
    $env:AUTH_TYPE = "principal";
    $env:CLOUD = "AzureCloud";
    

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072;

    # Download the installation package
    Invoke-WebRequest -UseBasicParsing -Uri "https://aka.ms/azcmagent-windows" -TimeoutSec 30 -OutFile "$env:TEMP\install_windows_azcmagent.ps1";

    # Install the hybrid agent
    & "$env:TEMP\install_windows_azcmagent.ps1";
    if ($LASTEXITCODE -ne 0) { exit 1; }

    # Run connect command
    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect --service-principal-id "$ServicePrincipalId" --service-principal-secret "$ServicePrincipalClientSecret" --resource-group "$env:RESOURCE_GROUP" --tenant-id "$env:TENANT_ID" --location "$env:LOCATION" --subscription-id "$env:SUBSCRIPTION_ID" --cloud "$env:CLOUD" ;
}
catch {
    $logBody = @{subscriptionId="$env:SUBSCRIPTION_ID";resourceGroup="$env:RESOURCE_GROUP";tenantId="$env:TENANT_ID";location="$env:LOCATION";authType="$env:AUTH_TYPE";operation="onboarding";messageType=$_.FullyQualifiedErrorId;message="$_";};
    Invoke-WebRequest -UseBasicParsing -Uri "https://gbl.his.arc.azure.com/log" -Method "PUT" -Body ($logBody | ConvertTo-Json) | out-null;
    Write-Host  -ForegroundColor red $_.Exception;
}




