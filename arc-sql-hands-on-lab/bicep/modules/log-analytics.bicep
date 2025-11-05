// ============================================================================
// Log Analytics Workspace Module
// ============================================================================
// Creates a Log Analytics workspace for SQL Server monitoring and BPA
// ============================================================================

@description('Name of the Log Analytics workspace')
param workspaceName string

@description('Location for the workspace')
param location string

@description('Tags to apply to the workspace')
param tags object = {}

@description('Workspace retention in days')
@minValue(30)
@maxValue(730)
param retentionInDays int = 30

@description('Workspace SKU')
@allowed([
  'PerGB2018'
  'Free'
  'Standard'
  'Premium'
])
param sku string = 'PerGB2018'

@description('Enable daily cap on ingestion')
param enableDailyQuotaGb int = -1

// ============================================================================
// Log Analytics Workspace
// ============================================================================

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: enableDailyQuotaGb
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Resource ID of the Log Analytics workspace')
output workspaceId string = logAnalyticsWorkspace.id

@description('Name of the Log Analytics workspace')
output workspaceName string = logAnalyticsWorkspace.name

@description('Customer ID (workspace ID) of the Log Analytics workspace')
output workspaceCustomerId string = logAnalyticsWorkspace.properties.customerId
