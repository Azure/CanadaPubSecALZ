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

resource ascAzureDefender 'Microsoft.Authorization/policySetDefinitions@2020-03-01' = {
  name: 'custom-enable-azure-defender'
  properties: {
    displayName: 'Custom - Azure Defender for Azure Services'
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
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'ASC-Deploy-Defender-ACR')
        policyDefinitionReferenceId: toLower(replace('Deploy Azure Defender for ACR', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'ASC-Deploy-Defender-AKS')
        policyDefinitionReferenceId: toLower(replace('Deploy Azure Defender for AKS', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'ASC-Deploy-Defender-AKV')
        policyDefinitionReferenceId: toLower(replace('Deploy Azure Defender for AKV', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'ASC-Deploy-Defender-AppService')
        policyDefinitionReferenceId: toLower(replace('Deploy Azure Defender for App Service', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'ASC-Deploy-Defender-ARM')
        policyDefinitionReferenceId: toLower(replace('Deploy Azure Defender for ARM', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'ASC-Deploy-Defender-DNS')
        policyDefinitionReferenceId: toLower(replace('Deploy Azure Defender for DNS', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'ASC-Deploy-Defender-OSSDB')
        policyDefinitionReferenceId: toLower(replace('Deploy Azure Defender for Open-source relational databases', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'ASC-Deploy-Defender-SQLDB')
        policyDefinitionReferenceId: toLower(replace('Deploy Azure Defender for SQLDB', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'ASC-Deploy-Defender-SQLDBVM')
        policyDefinitionReferenceId: toLower(replace('Deploy Azure Defender for SQL on VM', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'ASC-Deploy-Defender-Storage')
        policyDefinitionReferenceId: toLower(replace('Deploy Azure Defender for Storage Account', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'EXTRA'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'ASC-Deploy-Defender-VM')
        policyDefinitionReferenceId: toLower(replace('Deploy Azure Defender for VM', ' ', '-'))
        parameters: {}
      }
    ]
  }
}
