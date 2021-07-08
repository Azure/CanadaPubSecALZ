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

resource aksPolicySet 'Microsoft.Authorization/policySetDefinitions@2020-03-01' = {
  name: 'custom-aks'
  properties: {
    displayName: 'Custom - Azure Kubernetes Service'
    policyDefinitionGroups: [
      {
        name: 'AKS'
        displayName: 'AKS Controls'
      }
    ]
    policyDefinitions: [
      {
        groupNames: [
          'AKS'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/a8eff44f-8c92-45c3-a3fb-9880802d67a7'
        policyDefinitionReferenceId: toLower(replace('Deploy Azure Policy Add-on to Azure Kubernetes Service clusters', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'AKS'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/42b8ef37-b724-4e24-bbc8-7a7708edfe00'
        policyDefinitionReferenceId: toLower(replace('Kubernetes cluster pod security restricted standards for Linux-based workloads', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'AKS'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/a8640138-9b0a-4a28-b8cb-1666c838647d'
        policyDefinitionReferenceId: toLower(replace('Kubernetes cluster pod security baseline standards for Linux-based workloads', ' ', '-'))
        parameters: {}
      }
    ]
  }
}
