// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

// Required parameters
param policyAssignmentManagementGroupId string

// Unused parameters with default values
param policyDefinitionManagementGroupId string = ''
param logAnalyticsResourceId string = ''
param logAnalyticsWorkspaceId string = ''

var policyId = '612b5213-9160-4969-8578-1518bd2a000c' // CIS Microsoft Azure Foundations Benchmark 1.3.0
var assignmentName = 'CIS Microsoft Azure Foundations Benchmark 1.3.0'

var scope = tenantResourceId('Microsoft.Management/managementGroups', policyAssignmentManagementGroupId)
var policyScopedId = resourceId('Microsoft.Authorization/policySetDefinitions', policyId)

resource policySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'assign-${uniqueString('cis-msft-130-',policyAssignmentManagementGroupId)}'
  properties: {
    displayName: assignmentName
    policyDefinitionId: policyScopedId
    scope: scope
    notScopes: [
    ]
    parameters: {
      requiredRetentionDays: {
        value: '730'
      }
      'resourceGroupName-b6e2945c-0b7b-40f5-9233-7a5323b5cdc6': {
        value: 'NetworkWatcherRG'
      }
      'approvedExtensions-c0e996f8-39cf-4af9-9f45-83fbde810432': {
        value: [
          'AzureDiskEncryption'
          'AzureDiskEncryptionForLinux'
          'ConfigurationforWindows'
          'DependencyAgentWindows'
          'DependencyAgentLinux'
          'IaaSAntimalware'
          'IaaSDiagnostics'
          'LinuxDiagnostic'
          'MicrosoftMonitoringAgent'
          'NetworkWatcherAgentLinux'
          'NetworkWatcherAgentWindows'
          'OmsAgentForLinux'
          'VMSnapshot'
          'VMSnapshotLinux'
          'WindowsAgent.AzureSecurityCenter'
        ]
      }
    }
    enforcementMode: 'Default'
  }
  identity: {
    type: 'SystemAssigned'
  }
  location: deployment().location
}
