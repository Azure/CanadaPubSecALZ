// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

@description('Management Group scope for the policy assignment.')
param policyAssignmentManagementGroupId string

@allowed([
  'Default'
  'DoNotEnforce'
])
@description('Policy set assignment enforcement mode.  Possible values are { Default, DoNotEnforce }.  Default value:  Default')
param enforcementMode string = 'Default'

@description('Log Analytics Workspace Data Retention in days.')
param requiredRetentionDays string

@description('An array of approved VM extensions.')
param approvedVMExtensions array

@description('Network Watcher Resource Group Name.  Default:  NetworkWatcherRG')
param networkWatcherRgName string = 'NetworkWatcherRG'

@description('Linux Python Version.')
param linuxPythonLatestVersion string

var policyId = '612b5213-9160-4969-8578-1518bd2a000c' // CIS Microsoft Azure Foundations Benchmark 1.3.0
var assignmentName = 'CIS Microsoft Azure Foundations Benchmark 1.3.0'

var scope = tenantResourceId('Microsoft.Management/managementGroups', policyAssignmentManagementGroupId)
var policyScopedId = resourceId('Microsoft.Authorization/policySetDefinitions', policyId)

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../../config/telemetry.json'))
module telemetryCustomerUsageAttribution '../../../azresources/telemetry/customer-usage-attribution-management-group.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.policy}'
}

resource policySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'cis130-${uniqueString('cis-msft-130-',policyAssignmentManagementGroupId)}'
  properties: {
    displayName: assignmentName
    policyDefinitionId: policyScopedId
    scope: scope
    notScopes: [
    ]
    parameters: {
      requiredRetentionDays: {
        value: requiredRetentionDays
      }
      'resourceGroupName-b6e2945c-0b7b-40f5-9233-7a5323b5cdc6': {
        value: networkWatcherRgName
      }
      'approvedExtensions-c0e996f8-39cf-4af9-9f45-83fbde810432': {
        value: approvedVMExtensions
      }
      LinuxPythonLatestVersion: {
        value: linuxPythonLatestVersion
      }
    }
    enforcementMode: enforcementMode
  }
  identity: {
    type: 'SystemAssigned'
  }
  location: deployment().location
}
