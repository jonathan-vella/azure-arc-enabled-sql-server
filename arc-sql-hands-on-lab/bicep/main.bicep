// ============================================================================
// Azure Arc-Enabled SQL Server - Hands-on Lab Infrastructure
// ============================================================================
// This Bicep template creates the required Azure infrastructure for the lab:
// - Resource group for Azure Arc resources
// - Resource group for Log Analytics workspace
// - Log Analytics workspace for monitoring and best practices assessment
//
// Target Region: Sweden Central
// ============================================================================

targetScope = 'subscription'

// ============================================================================
// Parameters
// ============================================================================

@description('Base name for resources (will be used to generate resource names)')
param baseName string = 'arcsql-lab'

@description('Azure region for all resources')
param location string = 'swedencentral'

@description('Environment identifier (dev, test, prod)')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string = 'dev'

@description('Tags to apply to all resources')
param tags object = {
  Environment: environment
  Purpose: 'Azure Arc SQL Server Lab'
  ManagedBy: 'Bicep'
  CreatedDate: utcNow('yyyy-MM-dd')
}

// ============================================================================
// Variables
// ============================================================================

var arcResourceGroupName = '${baseName}-arc-rg'
var monitoringResourceGroupName = '${baseName}-monitoring-rg'
var logAnalyticsWorkspaceName = '${baseName}-law-${uniqueString(subscription().subscriptionId, location)}'

// ============================================================================
// Resource Group for Azure Arc Resources
// ============================================================================

resource arcResourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: arcResourceGroupName
  location: location
  tags: tags
}

// ============================================================================
// Resource Group for Monitoring Resources
// ============================================================================

resource monitoringResourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: monitoringResourceGroupName
  location: location
  tags: union(tags, {
    ResourceType: 'Monitoring'
  })
}

// ============================================================================
// Log Analytics Workspace Module
// ============================================================================

module logAnalyticsWorkspace 'modules/log-analytics.bicep' = {
  name: 'deploy-log-analytics'
  scope: monitoringResourceGroup
  params: {
    workspaceName: logAnalyticsWorkspaceName
    location: location
    tags: tags
    retentionInDays: 30
    sku: 'PerGB2018'
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Name of the Azure Arc resource group')
output arcResourceGroupName string = arcResourceGroup.name

@description('Name of the monitoring resource group')
output monitoringResourceGroupName string = monitoringResourceGroup.name

@description('Resource ID of the Log Analytics workspace')
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.outputs.workspaceId

@description('Name of the Log Analytics workspace')
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.outputs.workspaceName

@description('Customer ID (workspace ID) of the Log Analytics workspace')
output logAnalyticsCustomerId string = logAnalyticsWorkspace.outputs.workspaceCustomerId

@description('Location of all resources')
output location string = location

@description('Deployment summary')
output deploymentSummary object = {
  arcResourceGroup: arcResourceGroup.name
  monitoringResourceGroup: monitoringResourceGroup.name
  logAnalyticsWorkspace: logAnalyticsWorkspace.outputs.workspaceName
  region: location
  environment: environment
}
