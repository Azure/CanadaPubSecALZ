// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

param policyAssignmentManagementGroupId string

var policyId = '1f3afdf9-d0c9-4c3d-847f-89da613e70a8' // Azure Security Benchmark
var assignmentName = 'Azure Security Benchmark'

var scope = tenantResourceId('Microsoft.Management/managementGroups', policyAssignmentManagementGroupId)
var policyScopedId = resourceId('Microsoft.Authorization/policySetDefinitions', policyId)

resource policySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'assign-${uniqueString('asb-',policyAssignmentManagementGroupId)}'
  properties: {
    displayName: assignmentName
    policyDefinitionId: policyScopedId
    scope: scope
    notScopes: [
    ]
    parameters: {
    }
    enforcementMode: 'Default'
  }
  identity: {
    type: 'SystemAssigned'
  }
  location: deployment().location
}
