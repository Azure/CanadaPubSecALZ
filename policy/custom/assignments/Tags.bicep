// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

@description('Location for the deployment.')
param location string = deployment().location

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

var scope = tenantResourceId('Microsoft.Management/managementGroups', policyAssignmentManagementGroupId)

// Tags Inherited from Resource Groups
var rgInheritedPolicyId = 'custom-tags-inherited-from-resource-group'
var rgInheritedAssignmentName = 'Custom - Tags inherited from resource group if missing'

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../../config/telemetry.json'))
module telemetryCustomerUsageAttribution '../../../azresources/telemetry/customer-usage-attribution-management-group.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.policy}'
}

resource rgInheritedPolicySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'tags-rg-${uniqueString('tags-from-rg-', policyAssignmentManagementGroupId)}'
  properties: {
    displayName: rgInheritedAssignmentName
    policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${policyDefinitionManagementGroupId}/providers/Microsoft.Authorization/policySetDefinitions/${rgInheritedPolicyId}'
    scope: scope
    notScopes: []
    parameters: {}
    enforcementMode: enforcementMode
  }
  identity: {
    type: 'SystemAssigned'
  }
  location: location
}

resource rgPolicySetRoleAssignmentContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(policyAssignmentManagementGroupId, 'RgRemediation', 'Contributor')
  scope: managementGroup()
  properties: {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
    principalId: rgInheritedPolicySetAssignment.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Required Tags on Resource Group
var rgRequiredPolicyId = 'required-tags-on-resource-group'
var rgRequiredAssignmentName = 'Custom - Required tags on resource group'

resource rgRequiredPolicySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'tags-rg-${uniqueString('tags-required-', policyAssignmentManagementGroupId)}'
  properties: {
    displayName: rgRequiredAssignmentName
    policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${policyDefinitionManagementGroupId}/providers/Microsoft.Authorization/policySetDefinitions/${rgRequiredPolicyId}'
    scope: scope
    notScopes: []
    parameters: {}
    enforcementMode: enforcementMode
  }
  identity: {
    type: 'SystemAssigned'
  }
  location: location
}

// Audit for Tags on Resources
var resourcesPolicyId = 'audit-required-tags-on-resources'
var resourcesAssignmentName = 'Custom - Audit for required tags on resources'

resource resourcesAuditPolicySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'tags-r-${uniqueString('tags-missing-', policyAssignmentManagementGroupId)}'
  properties: {
    displayName: resourcesAssignmentName
    policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${policyDefinitionManagementGroupId}/providers/Microsoft.Authorization/policySetDefinitions/${resourcesPolicyId}'
    scope: scope
    notScopes: []
    parameters: {}
    enforcementMode: enforcementMode
  }
  identity: {
    type: 'SystemAssigned'
  }
  location: location
}
