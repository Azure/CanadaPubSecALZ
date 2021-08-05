// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

param roleDefinitionId string
param groupObjectIds array = []

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for groupId in groupObjectIds: {
  name: guid(subscription().id, groupId, roleDefinitionId)
  scope: subscription()
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: groupId
    principalType: 'Group'
  }
}]
