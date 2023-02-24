// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

@description('Management Group scope for the policy definition.')

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
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', 'a8eff44f-8c92-45c3-a3fb-9880802d67a7')
        policyDefinitionReferenceId: toLower(replace('Deploy Azure Policy Add-on to Azure Kubernetes Service clusters', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'AKS'
        ]
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', '3fc4dc25-5baf-40d8-9b05-7fe74c1bc64e')
        policyDefinitionReferenceId: toLower(replace('Kubernetes clusters should use internal load balancers', ' ', '-'))
        parameters: {}
      }
    ]
  }
}
