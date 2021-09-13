// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

param policyDefinitionManagementGroupId string
param policyAssignmentManagementGroupId string

param privateDNSZoneSubscriptionId string
param privateDNSZoneResourceGroupName string

var policyId = 'custom-central-dns-private-endpoints'
var assignmentName = 'Custom - Central DNS for Private Endpoints'

var scope = tenantResourceId('Microsoft.Management/managementGroups', policyAssignmentManagementGroupId)
var policyScopedId = '/providers/Microsoft.Management/managementGroups/${policyDefinitionManagementGroupId}/providers/Microsoft.Authorization/policySetDefinitions/${policyId}'

resource policySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'dns-pe-${uniqueString(policyAssignmentManagementGroupId)}'
  properties: {
    displayName: assignmentName
    policyDefinitionId: policyScopedId
    scope: scope
    notScopes: [
      // exclude the resource group where the private dns zones will be created.  This allows for Private DNS Zone creation in this resource group
      // but blocked in all other scopes
      subscriptionResourceId(privateDNSZoneSubscriptionId, 'Microsoft.Resources/resourceGroups', privateDNSZoneResourceGroupName)
    ]
    parameters: {
      privateDNSZoneSubscriptionId: {
        value: privateDNSZoneSubscriptionId
      }
      privateDNSZoneResourceGroupName: {
        value: privateDNSZoneResourceGroupName
      }
    }
    enforcementMode: 'Default'
  }
  identity: {
    type: 'SystemAssigned'
  }
  location: deployment().location
}

// role assignment
resource policySetRoleAssignmentNetworkContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(policyAssignmentManagementGroupId, 'dns-private-endpoint', 'Network Contributor')
  scope: managementGroup()
  properties: {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7'
    principalId: policySetAssignment.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
