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

@description('An array of allowed Azure Regions.')
param allowedLocations array

var scope = tenantResourceId('Microsoft.Management/managementGroups', policyAssignmentManagementGroupId)

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../../config/telemetry.json'))
module telemetryCustomerUsageAttribution '../../../azresources/telemetry/customer-usage-attribution-management-group.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.policy}'
}

resource rgLocationAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'locrg-${uniqueString('rg-location-', policyAssignmentManagementGroupId)}'
  properties: {
    displayName: 'Restrict to Canada Central and Canada East regions for Resource Groups'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988'
    scope: scope
    notScopes: []
    parameters: {
      listOfAllowedLocations: {
        value: allowedLocations
      }
    }
    enforcementMode: enforcementMode
  }
  location: deployment().location
}

resource resourceLocationAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'locr-${uniqueString('resource-location-', policyAssignmentManagementGroupId)}'
  properties: {
    displayName: 'Restrict to Canada Central and Canada East regions for Resources'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
    scope: scope
    notScopes: []
    parameters: {
      listOfAllowedLocations: {
        value: allowedLocations
      }
    }
    enforcementMode: enforcementMode
  }
  location: deployment().location
}
