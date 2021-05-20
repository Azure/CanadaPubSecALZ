// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------


param roleDefinitionId string
param resourceSPObjectIds array = []
param storageName string

resource roleAssignment 'Microsoft.Storage/storageAccounts/providers/roleAssignments@2018-09-01-preview' = [for spId in resourceSPObjectIds: {
  name: '${storageName}/Microsoft.Authorization/${guid(resourceGroup().id, spId, roleDefinitionId)}'
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: spId
    principalType: 'ServicePrincipal'
  }
}]
