// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param keyVaultName string
param roleDefinitionId string
param resourceSPObjectIds array = []

resource scopeOfRoleAssignment 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  name: keyVaultName
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
