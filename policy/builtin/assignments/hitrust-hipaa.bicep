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

@description('A semicolon-separated list of the names of the applications that should be installed. e.g. \'Microsoft SQL Server 2014 (64-bit); Microsoft Visual Studio Code\' or \'Microsoft SQL Server 2014*\' (to match any application starting with \'Microsoft SQL Server 2014\')')
param installedApplicationsOnWindowsVM string

@description('This prefix will be combined with the network security group location to form the created storage account name.')
param deployDiagnosticSettingsforNetworkSecurityGroupsStoragePrefix string

@description('The resource group that the storage account will be created in. This resource group must already exist.')
param deployDiagnosticSettingsforNetworkSecurityGroupsRgName string

@description('A semicolon-separated list of certificate thumbprints that should exist under the Trusted Root certificate store (Cert:\\LocalMachine\\Root). e.g. THUMBPRINT1;THUMBPRINT2;THUMBPRINT3')
param certificateThumbprints string

@description('Log Analytics Workspace Data Retention in days.')
param requiredRetentionDays string

var policyId = 'a169a624-5599-4385-a696-c8d643089fab' // HITRUST/HIPAA
var assignmentName = 'HITRUST/HIPAA'

var scope = tenantResourceId('Microsoft.Management/managementGroups', policyAssignmentManagementGroupId)
var policyScopedId = resourceId('Microsoft.Authorization/policySetDefinitions', policyId)

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../../config/telemetry.json'))
module telemetryCustomerUsageAttribution '../../../azresources/telemetry/customer-usage-attribution-management-group.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.policy}'
}

resource policySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'hipaa-${uniqueString('hitrust-hipaa-', policyAssignmentManagementGroupId)}'
  properties: {
    displayName: assignmentName
    policyDefinitionId: policyScopedId
    scope: scope
    notScopes: []
    parameters: {
      // A semicolon-separated list of the names of the applications that should be installed.
      // e.g. 'Microsoft SQL Server 2014 (64-bit); Microsoft Visual Studio Code' or 'Microsoft SQL Server 2014*'
      // (to match any application starting with 'Microsoft SQL Server 2014')
      installedApplicationsOnWindowsVM: {
        value: installedApplicationsOnWindowsVM
      }

      // This prefix will be combined with the network security group location to form the created storage account name.
      DeployDiagnosticSettingsforNetworkSecurityGroupsstoragePrefix: {
        value: deployDiagnosticSettingsforNetworkSecurityGroupsStoragePrefix
      }

      // The resource group that the storage account will be created in. This resource group must already exist.
      DeployDiagnosticSettingsforNetworkSecurityGroupsrgName: {
        value: deployDiagnosticSettingsforNetworkSecurityGroupsRgName
      }

      // A semicolon-separated list of certificate thumbprints that should exist under the Trusted Root certificate store
      // (Cert:\LocalMachine\Root). e.g. THUMBPRINT1;THUMBPRINT2;THUMBPRINT3      
      CertificateThumbprints: {
        value: certificateThumbprints
      }

      requiredRetentionDays: {
        value: requiredRetentionDays
      }

      listOfResourceTypes: {
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
  name: guid(policyAssignmentManagementGroupId, 'hitrust-hipaa-contributor')
  scope: managementGroup()
  properties: {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
    principalId: policySetAssignment.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource policySetRoleAssignmentVMContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(policyAssignmentManagementGroupId, 'hitrust-hipaa-virtual-machine-contributor')
  scope: managementGroup()
  properties: {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
    principalId: policySetAssignment.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource policySetRoleAssignmentNetworkContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(policyAssignmentManagementGroupId, 'hitrust-hipaa-network-contributor')
  scope: managementGroup()
  properties: {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7'
    principalId: policySetAssignment.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource policySetRoleAssignmentMonitoringContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(policyAssignmentManagementGroupId, 'hitrust-hipaa-monitoring-contributor')
  scope: managementGroup()
  properties: {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
    principalId: policySetAssignment.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource policySetRoleAssignmentStorageAccountContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(policyAssignmentManagementGroupId, 'hitrust-hipaa-storage-account-contributor')
  scope: managementGroup()
  properties: {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/17d1049b-9a84-46fb-8f53-869881c3d3ab'
    principalId: policySetAssignment.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
