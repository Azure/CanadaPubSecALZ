// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Private DNS Zone Name.')
param zoneName string

@description('Role Definition Id.')
param roleDefinitionId string

@description('Array of Service Principal Object Ids.')
param resourceSPObjectIds array = []

resource scopeOfRoleAssignment 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: zoneName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for spId in resourceSPObjectIds: {
  name: guid(scopeOfRoleAssignment.id, spId, roleDefinitionId)
  scope: scopeOfRoleAssignment
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: spId
    principalType: 'ServicePrincipal'
  }
}]

module roleAssignmentWait '../../util/wait.bicep' = [for (spId, idx) in resourceSPObjectIds: {
  name: '${roleAssignment[idx].name}-wait'
  scope: resourceGroup()
  params: {
    waitNamePrefix: roleAssignment[idx].name
    loopCounter: 10
  }
}]
