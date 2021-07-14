// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

param policyAssignmentManagementGroupId string
param logAnalyticsWorkspaceId string

var policyId = 'cf25b9c1-bd23-4eb6-bd2c-f4f3ac644a5f' // NIST SP 800-53 R4 
var assignmentName = 'NIST SP 800-53 R4'

var scope = tenantResourceId('Microsoft.Management/managementGroups', policyAssignmentManagementGroupId)
var policyScopedId = resourceId('Microsoft.Authorization/policySetDefinitions', policyId)

resource policySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'assign-${uniqueString('nist-sp-800-53-r4-',policyAssignmentManagementGroupId)}'
  properties: {
    displayName: assignmentName
    policyDefinitionId: policyScopedId
    scope: scope
    notScopes: [
    ]
    parameters: {
      logAnalyticsWorkspaceIdforVMReporting: {
        value: logAnalyticsWorkspaceId
       }
       listOfMembersToExcludeFromWindowsVMAdministratorsGroup: {
        value: 'excludedUser'
       }
       listOfMembersToIncludeInWindowsVMAdministratorsGroup: {
        value: 'includedUser'
       }
    }
    enforcementMode: 'Default'
  }
  identity: {
    type: 'SystemAssigned'
  }
  location: deployment().location
}

// These role assignments are required to allow Policy Assignment to remediate.

resource policySetRoleAssignmentContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(policyAssignmentManagementGroupId, 'nist-sp-800-53-r4-contributor')
  scope: managementGroup()
  properties: {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
    principalId: policySetAssignment.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
