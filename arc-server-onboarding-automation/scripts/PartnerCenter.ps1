function Get-PartnerCenterAccessToken {
    param (
        [Parameter(Mandatory=$true)]
        [string]$tenantId,

        [Parameter(Mandatory=$true)]
        [string]$clientId,

        [Parameter(Mandatory=$true)]
        [string]$clientSecret
    )

    $resource = "https://graph.windows.net"
    $tokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/token"
    $body = @{
        grant_type    = "client_credentials"
        client_id     = $clientId
        client_secret = $clientSecret
        resource      = $resource
    }
    $response = Invoke-RestMethod -Uri $tokenUrl -Method Post -ContentType "application/x-www-form-urlencoded" -Body $body
    $accessToken = $response.access_token
    return $accessToken
}
function Get-CMDBData {
    param (
        [Parameter(Mandatory=$true)]
        [string]$csvFilePath
    )

    # Import the CSV file and convert each row into a PowerShell object
    $cmdbData = Import-Csv -Path $csvFilePath -Delimiter ';'

    # Convert each row into a custom PowerShell object
    $cmdbObjects = $cmdbData | ForEach-Object {
        [PSCustomObject]@{
            Name                      = $_.Name
            Tenant_Domain_Name        = $_.'Tenant_Domain_Name'
            Company_Name              = $_.'Company_Name'
            Contact_First_Name        = $_.'Contact_First_Name'
            Contact_Last_Name         = $_.'Contact_Last_Name'
            Email                     = $_.'Email'
            Address                   = $_.'Address'
            Postal_Code               = $_.'Postal_Code'
            City                      = $_.'City'
            Country                   = $_.'Country'
            Server_Name               = $_.'Server_Name'
            Server_Unique_Identifier  = $_.'Server_Unique_Identifier'
            SQL_Foreign_Name          = $_.'SQL_Foreign_Name'
            SQL_Server_Version        = $_.'SQL_Server_Version'
            Tenant_Id                 = $_.'Tenant_Id'
            Subscription_Id           = $_.'Subscription_Id'
            AppId                     = $_.'AppId'
            App_Secret                = $_.'App_Secret'
        }
    }

    return $cmdbObjects
}

function Add-NewTenant {
    param (
        [Parameter(Mandatory=$true)]
        $accessToken,
        [Parameter(Mandatory=$true)]
        [string]$domain,
        [Parameter(Mandatory=$true)]
        [string]$companyName,
        [Parameter(Mandatory=$true)]
        [string]$email,
        [Parameter(Mandatory=$true)]
        [string]$firstName,
        [Parameter(Mandatory=$true)]
        [string]$lastName,
        [Parameter(Mandatory=$true)]
        [string]$address,
        [Parameter(Mandatory=$true)]
        [string]$city,
        [Parameter(Mandatory=$true)]
        [string]$postalCode,
        [Parameter(Mandatory=$true)]
        [string]$country
    )

    # API endpoint for creating a new tenant
    $apiUrl = "https://api.partnercenter.microsoft.com/v1/customers"

    $tenantInfo = @{
        "companyProfile" = @{
            "domain"= $domain
            "CompanyName"= $companyName
        }
        "billingProfile"=@{
            "email"= $email
            "companyName"= $companyName
            "culture"= "da-DK"
            "language"= "en"
            "DefaultAddress"= @{
                "FirstName"= $firstName
                "LastName"= $lastName
                "AddressLine1"= $address
                "City"= $city
                "PostalCode"= $postalCode
                "Country"= $country
            }
        }
    }

    # Convert tenant information to JSON
    $jsonBody = $tenantInfo | ConvertTo-Json -Depth 100

    # Generate unique identifiers for MS-RequestId and MS-CorrelationId
    $msRequestId = [guid]::NewGuid().ToString()
    $msCorrelationId = [guid]::NewGuid().ToString()

    $headers = @{
        "Authorization" = "Bearer $accessToken"
        "MS-RequestId" = $msRequestId
        "MS-CorrelationId" = $msCorrelationId
    }

    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $jsonBody -ContentType "application/json"
    }
    catch {
        # Access the StatusCode from the caught exception's Response object
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "HTTP Request failed with status code: $statusCode. Reason: $($_.Exception.Message)"
    }

    $response | Write-Output
}

function Update-CMDB{
    param (
        [Parameter(Mandatory=$true)]
        [string]$csvFilePath,
        [Parameter(Mandatory=$true)]
        [string]$customerName,
        [Parameter(Mandatory=$true)]
        [string]$entry,
        [Parameter(Mandatory=$true)]
        [string]$updatedEntry
    )

    # Import the CSV file
    $cmdbData = Import-Csv -Path $csvFilePath -Delimiter ';'

    # Update Tenant_Id for customers with the specified name
    $updatedData = $cmdbData | ForEach-Object {
        if ($_.Name -eq $customerName) {
            $_.$entry = $updatedEntry
        }
        $_
    }

    # Export the updated data back to the CSV file
    $updatedData | Export-Csv -Path $csvFilePath -Delimiter ';' -NoTypeInformation
}

# extra
function Get-Customers {
    param (
        [Parameter(Mandatory=$true)]
        $accessToken
    )

    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }

    $apiUrl="https://api.partnercenter.microsoft.com/v1/customers"
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers    
    }
    catch {
        $response = $_.Exception.Response
    }
    # Output the response
    $response | Write-Output
}

function Remove-Customer {
    param (
        [Parameter(Mandatory=$true)]
        $accessToken,

        [Parameter(Mandatory=$true)]
        $customerId
    )

    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }

    $apiUrl = "https://api.partnercenter.microsoft.com/v1/customers/$customerId"

    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Delete -Headers $headers
        Write-Output "Customer with ID $customerId removed successfully."
    }
    catch {
        Write-Output "Failed to remove customer. Error: $($_.Exception.Message)"
    }
}
