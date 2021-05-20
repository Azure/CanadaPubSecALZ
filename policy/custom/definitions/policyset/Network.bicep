// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

// Required parameters
param policyAssignmentManagementGroupId string = ''

// Unused parameters with default values
param policyDefinitionManagementGroupId string = ''
param logAnalyticsResourceId string = ''
param logAnalyticsWorkspaceId string = ''

var customPolicyDefinitionMgScope = tenantResourceId('Microsoft.Management/managementGroups', policyAssignmentManagementGroupId)

resource networkPolicySet 'Microsoft.Authorization/policySetDefinitions@2020-03-01' = {
  name: 'custom-network'
  properties: {
    displayName: 'Custom - Network'
    policyDefinitionGroups: [
      {
        name: 'NETWORK'
        displayName: 'Networking Controls'
      }
    ]
    policyDefinitions: [
      {
        groupNames: [
          'NETWORK'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-e51f44264114'
        policyDefinitionReferenceId: toLower(replace('Network interfaces should not have public IPs', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'NETWORK'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'Network-Audit-Missing-UDR')
        policyDefinitionReferenceId: toLower(replace('Audit for missing UDR on subnets', ' ', '-'))
        parameters: {}
      }
    ]
  }
}
