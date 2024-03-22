// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

@description('Location for the deployment.')
param location string = deployment().location

@description('Management Group scope for the policy assignment.')
param policyAssignmentManagementGroupId string

@allowed([
  'Default'
  'DoNotEnforce'
])
@description('Policy set assignment enforcement mode.  Possible values are { Default, DoNotEnforce }.  Default value:  Default')
param enforcementMode string = 'Default'

@description('Log Analytics Resource Id to integrate Microsoft Defender for Cloud.')
param logAnalyticsWorkspaceId string

@description('List of members that should be excluded from Windows VM Administrator Group.')
param listOfMembersToExcludeFromWindowsVMAdministratorsGroup string

@description('List of members that should be included in Windows VM Administrator Group.')
param listOfMembersToIncludeInWindowsVMAdministratorsGroup string

var policyId = '4c4a5f27-de81-430b-b4e5-9cbd50595a87' // Canada Federal PBMM
var assignmentName = 'Canada Federal PBMM'

var scope = tenantResourceId('Microsoft.Management/managementGroups', policyAssignmentManagementGroupId)
var policyScopedId = resourceId('Microsoft.Authorization/policySetDefinitions', policyId)

// Telemetry - Azure customer usage attribution
// Reference:  https://learn.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../../config/telemetry.json'))
module telemetryCustomerUsageAttribution '../../../azresources/telemetry/customer-usage-attribution-management-group.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.policy}-pbmm'
}

resource policySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'pbmm-${uniqueString('pbmm-',policyAssignmentManagementGroupId)}'
  properties: {
    displayName: assignmentName
    policyDefinitionId: policyScopedId
    scope: scope
    notScopes: [
    ]
    parameters: {
      logAnalyticsWorkspaceIdforVMReporting: {
        value: logAnalyticsWorkspaceId
       }
       listOfMembersToExcludeFromWindowsVMAdministratorsGroup: {
        value: listOfMembersToExcludeFromWindowsVMAdministratorsGroup
       }
       listOfMembersToIncludeInWindowsVMAdministratorsGroup: {
        value: listOfMembersToIncludeInWindowsVMAdministratorsGroup
       }
       'logsEnabled-7f89b1eb-583c-429a-8828-af049802c1d9': {
         value: true
       }
       'metricsEnabled-7f89b1eb-583c-429a-8828-af049802c1d9': {
         value: false
       }
       listOfResourceTypesWithDiagnosticLogsEnabled: {
         value: [
          'Microsoft.AnalysisServices/servers'
          'Microsoft.ApiManagement/service'
          'Microsoft.Network/applicationGateways'
          'Microsoft.Automation/automationAccounts'
          // 'Microsoft.ContainerInstance/containerGroups'  # Removed since it doesn't have any logs
          'Microsoft.ContainerRegistry/registries'
          'Microsoft.ContainerService/managedClusters'
          'Microsoft.Batch/batchAccounts'
          'Microsoft.Cdn/profiles/endpoints'
          'Microsoft.CognitiveServices/accounts'
          'Microsoft.DocumentDB/databaseAccounts'
          'Microsoft.DataFactory/factories'
          'Microsoft.DataLakeAnalytics/accounts'
          'Microsoft.DataLakeStore/accounts'
          'Microsoft.EventGrid/eventSubscriptions'
          'Microsoft.EventGrid/topics'
          'Microsoft.EventHub/namespaces'
          'Microsoft.Network/expressRouteCircuits'
          'Microsoft.Network/azureFirewalls'
          'Microsoft.HDInsight/clusters'
          'Microsoft.Devices/IotHubs'
          'Microsoft.KeyVault/vaults'
          'Microsoft.Network/loadBalancers'
          'Microsoft.Logic/integrationAccounts'
          'Microsoft.Logic/workflows'
          'Microsoft.DBforMySQL/servers'
          //'Microsoft.Network/networkInterfaces' # Removed since it doesn't have any logs
          'Microsoft.Network/networkSecurityGroups'
          'Microsoft.DBforPostgreSQL/servers'
          'Microsoft.PowerBIDedicated/capacities'
          'Microsoft.Network/publicIPAddresses'
          'Microsoft.RecoveryServices/vaults'
          'Microsoft.Cache/redis'
          'Microsoft.Relay/namespaces'
          'Microsoft.Search/searchServices'
          'Microsoft.ServiceBus/namespaces'
          'Microsoft.SignalRService/SignalR'
          'Microsoft.Sql/servers/databases'
          //'Microsoft.Sql/servers/elasticPools' # Removed since it doesn't have any logs
          'Microsoft.StreamAnalytics/streamingjobs'
          'Microsoft.TimeSeriesInsights/environments'
          'Microsoft.Network/trafficManagerProfiles'
          //'Microsoft.Compute/virtualMachines' # Logs are collected through Microsoft Monitoring Agent
          //'Microsoft.Compute/virtualMachineScaleSets' Removed since it is not supported
          'Microsoft.Network/virtualNetworks'
          'Microsoft.Network/virtualNetworkGateways'
         ]
       }
    }
    enforcementMode: enforcementMode
  }
  identity: {
    type: 'SystemAssigned'
  }
  location: location
}

// These role assignments are required to allow Policy Assignment to remediate.
resource policySetRoleAssignmentContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(policyAssignmentManagementGroupId, 'pbmm-Contributor')
  scope: managementGroup()
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions','b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalId: policySetAssignment.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
