function Get-GraphAccessToken {
    param (
        [Parameter(Mandatory=$true)]
        [string]$tenantId,

        [Parameter(Mandatory=$true)]
        [string]$clientId,

        [Parameter(Mandatory=$true)]
        [string]$clientSecret
    )

    $scope = "https://management.azure.com/.default"
    $tokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    $body = @{
        grant_type    = "client_credentials"
        client_id     = $clientId
        client_secret = $clientSecret
        scope        = $scope
    }
    $response = Invoke-RestMethod -Uri $tokenUrl -Method Post -ContentType "application/x-www-form-urlencoded" -Body $body
    $accessToken = $response.access_token
    return $accessToken
}

# list all GDAP relationships
function Get-AllGDAPRelationships {
    param (
        [Parameter(Mandatory=$true)]
        [string]$accessToken
    )

    $headers = @{
        Authorization = "Bearer $accessToken"
    }

    $graphApiUrl = "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships"

    $response = Invoke-RestMethod -Method Get -Uri $graphApiUrl -Headers $headers
    $response 
}

# get GDAP relationship for a customer
# GDAP relationship was created by default when the tenant was created
function Get-GDAPRelationship {
    param (
        [Parameter(Mandatory=$true)]
        [string]$accessToken,
        [Parameter(Mandatory=$true)]
        [string]$customerTenantId
    )

    $gdapRelationships = Get-AllGDAPRelationships -accessToken $accessToken
    $customerGDAPRelationships = $gdapRelationships.value | Where-Object { $_.customer.tenantId -eq $customerTenantId }
    # return customer relationship
    return $customerGDAPRelationships[0]
}

# create GDAP access assignment for a customer
function Create-GDAPAccessAssignment {
    param (
        [Parameter(Mandatory=$true)]
        [string]$accessToken,
        [Parameter(Mandatory=$true)]
        [string]$customerTenantId,
        [Parameter(Mandatory=$true)]
        [string]$GDAPGroupID,
        [Parameter(Mandatory=$true)]
        [string]$GDAPRole
    )

    $headers = @{
        Authorization = "Bearer $accessToken"
    }

    $delegatedAdminRelationshipId = (Get-GDAPRelationship -accessToken $accessToken -customerTenantId $customerTenantId).id
    $graphApiUrl = "https://graph.microsoft.com/v1.0/tenantRelationships/delegatedAdminRelationships/$delegatedAdminRelationshipId/accessAssignments"


    $headers = @{
        "Authorization" = "Bearer $accessToken"
        "Content-Type" = "application/json"
    }

    $accessAssignmentBody = @{
        "accessContainer" = @(
            @{
                "accessContainerId" = $GDAPGroupID
                "accessContainerType" = "securityGroup"
            }
        )
        "accessDetails" = @(
            @{
                "unifiedRoles" = $GDAPRole
            }
        )
    }
    
    $body = $accessAssignmentBody | ConvertTo-Json -Depth 10

    try {
        Invoke-RestMethod -Method Post -Uri $graphApiUrl -Headers $headers -Body $body
    }
    catch {
        Write-Error "Failed to create GDAP assignment: $_"
        
    }
}


# $graphAccessToken = Get-GraphAccessToken -tenantId $tenantId -clientId $clientId -clientSecret $clientSecret
# Create-GDAPAccessAssignment -accessToken $graphAccessToken -customerTenantId $customerTenantId -GDAPGroupID $GDAPGroupID -GDAPRole $GDAPRole
