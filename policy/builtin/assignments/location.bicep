// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

param policyAssignmentManagementGroupId string

var scope = tenantResourceId('Microsoft.Management/managementGroups', policyAssignmentManagementGroupId)

resource rgLocationAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'assign-${uniqueString('rg-location-', policyAssignmentManagementGroupId)}'
  properties: {
    displayName: 'Restrict to Canada Central and Canada East regions for Resource Groups'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988'
    scope: scope
    notScopes: []
    parameters: {
      listOfAllowedLocations: {
        value: [
          'canadacentral'
          'canadaeast'
        ]
      }
    }
    enforcementMode: 'Default'
  }
  location: deployment().location
}

resource resourceLocationAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'assign-${uniqueString('resource-location-', policyAssignmentManagementGroupId)}'
  properties: {
    displayName: 'Restrict to Canada Central and Canada East regions for Resources'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
    scope: scope
    notScopes: []
    parameters: {
      listOfAllowedLocations: {
        value: [
          'canadacentral'
          'canadaeast'
        ]
      }
    }
    enforcementMode: 'Default'
  }
  location: deployment().location
}
