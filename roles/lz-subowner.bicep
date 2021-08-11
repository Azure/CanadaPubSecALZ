// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED 'AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------


targetScope = 'managementGroup'

param assignableMgId string
var scope = tenantResourceId('Microsoft.Management/managementGroups', assignableMgId)

var roleName = 'Custom - Landing Zone Subscription Owner'

resource roleDefn 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' = {
  name: guid(roleName)
  scope: managementGroup()
  properties: {
    roleName: roleName
    description: ''
    permissions: [
      {
        actions: []
        notActions: [
          'Microsoft.Authorization/*/write'
          'Microsoft.Network/vpnGateways/*'
          'Microsoft.Network/expressRouteCircuits/*'
          'Microsoft.Network/routeTables/write'
          'Microsoft.Network/vpnSites/*'
        ]
        dataActions: []
        notDataActions: []
      }
    ]
    assignableScopes: [
      scope
    ]
  }
}
