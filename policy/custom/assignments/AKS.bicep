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

@description('Management Group scope for the policy assignment.')
param policyAssignmentManagementGroupId string

@allowed([
  'Default'
  'DoNotEnforce'
])
@description('Policy set assignment enforcement mode.  Possible values are { Default, DoNotEnforce }.  Default value:  Default')
param enforcementMode string = 'Default'

var policyId = 'custom-aks'
var assignmentName = 'Custom - Azure Kubernetes Service'

var scope = tenantResourceId('Microsoft.Management/managementGroups', policyAssignmentManagementGroupId)
var policyScopedId = '/providers/Microsoft.Management/managementGroups/${policyDefinitionManagementGroupId}/providers/Microsoft.Authorization/policySetDefinitions/${policyId}'

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../../config/telemetry.json'))
module telemetryCustomerUsageAttribution '../../../azresources/telemetry/customer-usage-attribution-management-group.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.policy}'
}

resource policySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'aks-${uniqueString(policyAssignmentManagementGroupId)}'
  properties: {
    displayName: assignmentName
    policyDefinitionId: policyScopedId
    scope: scope
    notScopes: []
    parameters: {}
    enforcementMode: enforcementMode
  }
  identity: {
    type: 'SystemAssigned'
  }
  location: deployment().location
}

resource podSecurityRestrictedStandardsPolicySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'aks-res-${uniqueString(policyAssignmentManagementGroupId)}'
  properties: {
    displayName: 'Kubernetes cluster pod security restricted standards for Linux-based workloads'
    policyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/42b8ef37-b724-4e24-bbc8-7a7708edfe00'
    scope: scope
    notScopes: []
    parameters: {}
    enforcementMode: enforcementMode
  }
  identity: {
    type: 'SystemAssigned'
  }
  location: deployment().location
}

resource podSecurityBaselineStandardsPolicySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'aks-std-${uniqueString(policyAssignmentManagementGroupId)}'
  properties: {
    displayName: 'Kubernetes cluster pod security baseline standards for Linux-based workloads'
    policyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/a8640138-9b0a-4a28-b8cb-1666c838647d'
    scope: scope
    notScopes: []
    parameters: {}
    enforcementMode: enforcementMode
  }
  identity: {
    type: 'SystemAssigned'
  }
  location: deployment().location
}

// These role assignments are required to allow Policy Assignment to remediate.
// Contributor role is required to support customer-managed keys for AKS.  Permission: Microsoft.Compute/diskEncryptionSets/read
// A custom role can be created to support this scenario as well.
resource policySetRoleAssignmentContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(policyAssignmentManagementGroupId, 'aks', 'Contributor')
  scope: managementGroup()
  properties: {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
    principalId: policySetAssignment.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
