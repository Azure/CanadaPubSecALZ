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
param policyDefinitionManagementGroupId string

var customPolicyDefinitionMgScope = tenantResourceId('Microsoft.Management/managementGroups', policyDefinitionManagementGroupId)

resource ascAzureDefender 'Microsoft.Authorization/policySetDefinitions@2020-03-01' = {
  name: 'custom-enable-azure-defender'
  properties: {
    displayName: 'Custom - Microsoft Defender for Cloud'
    policyDefinitionGroups: [
      {
        name: 'EXTRA'
        displayName: 'Additional Controls'
      }
    ]
    policyDefinitions: [
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/361c2074-3595-4e5d-8cab-4f21dffc835c'
        policyDefinitionReferenceId: toLower(replace('Deploy Advanced Threat Protection on Storage Accounts', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/36d49e87-48c4-4f2e-beed-ba4ed02b71f5'
        policyDefinitionReferenceId: toLower(replace('Deploy Threat Detection on SQL servers', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/feedbf84-6b99-488c-acc2-71c829aa5ffc'
        policyDefinitionReferenceId: toLower(replace('Vulnerabilities on your SQL databases should be remediated', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/6134c3db-786f-471e-87bc-8f479dc890f6'
        policyDefinitionReferenceId: toLower(replace('Deploy Advanced Data Security on SQL servers', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/3c735d8a-a4ba-4a3a-b7cf-db7754cf57f4'
        policyDefinitionReferenceId: toLower(replace('Vulnerabilities in security configuration on your virtual machine scale sets should be remediated', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e1e5fd5d-3e4c-4ce1-8661-7d1873ae6b15'
        policyDefinitionReferenceId: toLower(replace('Vulnerabilities in security configuration on your machines should be remediated', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/501541f7-f7e7-4cd6-868c-4190fdad3ac9'
        policyDefinitionReferenceId: toLower(replace('vulnerability assessment solution should be enabled on your virtual machines', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/13ce0167-8ca6-4048-8e6b-f996402e3c1b'
        policyDefinitionReferenceId: toLower(replace('Configure machines to receive the Qualys vulnerability assessment agent', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/1f725891-01c0-420a-9059-4fa46cb770b7'
        policyDefinitionReferenceId: toLower(replace('Configure Azure Defender for Key Vaults to be enabled', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/b40e7bcd-a1e5-47fe-b9cf-2f534d0bfb7d'
        policyDefinitionReferenceId: toLower(replace('Configure Azure Defender for App Service to be enabled', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/b7021b2b-08fd-4dc0-9de7-3c6ece09faf9'
        policyDefinitionReferenceId: toLower(replace('Configure Azure Defender for Resource Manager to be enabled', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/2370a3c1-4a25-4283-a91a-c9c1a145fb2f'
        policyDefinitionReferenceId: toLower(replace('Configure Azure Defender for DNS to be enabled', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/44433aa3-7ec2-4002-93ea-65c65ff0310a'
        policyDefinitionReferenceId: toLower(replace('Configure Azure Defender for open-source relational databases to be enabled', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/b99b73e7-074b-4089-9395-b7236f094491'
        policyDefinitionReferenceId: toLower(replace('Configure Azure Defender for Azure SQL database to be enabled', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/50ea7265-7d8c-429e-9a7d-ca1f410191c3'
        policyDefinitionReferenceId: toLower(replace('Configure Azure Defender for SQL servers on machines to be enabled', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/74c30959-af11-47b3-9ed2-a26e03f427a3'
        policyDefinitionReferenceId: toLower(replace('Configure Azure Defender for Storage to be enabled', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/8e86a5b6-b9bd-49d1-8e21-4bb8a0862222'
        policyDefinitionReferenceId: toLower(replace('Configure Azure Defender for servers to be enabled', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/c9ddb292-b203-4738-aead-18e2716e858f'
        policyDefinitionReferenceId: toLower(replace('Configure Microsoft Defender for Containers to be enabled', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'DefenderForCloud-Deploy-DefenderPlan-CosmosDB')
        policyDefinitionReferenceId: toLower(replace('Configure Microsoft Defender for Cosmos DB to be enabled', ' ', '-'))
        parameters: {}
      }
    ]
  }
}
