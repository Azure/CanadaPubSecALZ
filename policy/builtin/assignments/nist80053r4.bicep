// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

@description('Management Group scope for the policy assignment.')
param policyAssignmentManagementGroupId string

@allowed([
  'Default'
  'DoNotEnforce'
])
@description('Policy set assignment enforcement mode.  Possible values are { Default, DoNotEnforce }.  Default value:  Default')
param enforcementMode string = 'Default'

@description('Log Analytics Resource Id to integrate Microsoft Defender for Cloud.')
param logAnalyticsWorkspaceId string

@description('List of members that should be excluded from Windows VM Administrator Group.')
param listOfMembersToExcludeFromWindowsVMAdministratorsGroup string

@description('List of members that should be included in Windows VM Administrator Group.')
param listOfMembersToIncludeInWindowsVMAdministratorsGroup string

var policyId = 'cf25b9c1-bd23-4eb6-bd2c-f4f3ac644a5f' // NIST SP 800-53 R4 
var assignmentName = 'NIST SP 800-53 R4'

var scope = tenantResourceId('Microsoft.Management/managementGroups', policyAssignmentManagementGroupId)
var policyScopedId = resourceId('Microsoft.Authorization/policySetDefinitions', policyId)

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../../config/telemetry.json'))
module telemetryCustomerUsageAttribution '../../../azresources/telemetry/customer-usage-attribution-management-group.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.policy}'
}

resource policySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'nistr4-${uniqueString('nist-sp-800-53-r4-',policyAssignmentManagementGroupId)}'
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
        value: listOfMembersToExcludeFromWindowsVMAdministratorsGroup
       }
       listOfMembersToIncludeInWindowsVMAdministratorsGroup: {
        value: listOfMembersToIncludeInWindowsVMAdministratorsGroup
       }
    }
    enforcementMode: enforcementMode
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
