// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

param policyDefinitionManagementGroupId string

var customPolicyDefinitionMgScope = tenantResourceId('Microsoft.Management/managementGroups', policyDefinitionManagementGroupId)

resource tagsInheritedFromResourceGroup 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: 'custom-tags-inherited-from-resource-group'
  properties: {
    displayName: 'Custom - Inherited tags from resource group if missing'
    policyDefinitions: [
      {
        policyDefinitionId: resourceId('Microsoft.Authorization/policyDefinitions', 'ea3f2387-9b95-492a-a190-fcdc54f7b070')
        policyDefinitionReferenceId: toLower(replace('Inherit ClientOrganization tag from the resource group if missing', ' ', '-'))
        parameters: {
          tagName: {
            value: 'ClientOrganization'
          }
        }
      }
      {
        policyDefinitionId: resourceId('Microsoft.Authorization/policyDefinitions', 'ea3f2387-9b95-492a-a190-fcdc54f7b070')
        policyDefinitionReferenceId: toLower(replace('Inherit CostCenter tag from the resource group if missing', ' ', '-'))
        parameters: {
          tagName: {
            value: 'CostCenter'
          }
        }
      }
      {
        policyDefinitionId: resourceId('Microsoft.Authorization/policyDefinitions', 'ea3f2387-9b95-492a-a190-fcdc54f7b070')
        policyDefinitionReferenceId: toLower(replace('Inherit DataSensitivity tag from the resource group if missing', ' ', '-'))
        parameters: {
          tagName: {
            value: 'DataSensitivity'
          }
        }
      }
      {
        policyDefinitionId: resourceId('Microsoft.Authorization/policyDefinitions', 'ea3f2387-9b95-492a-a190-fcdc54f7b070')
        policyDefinitionReferenceId: toLower(replace('Inherit ProjectContact tag from the resource group if missing', ' ', '-'))
        parameters: {
          tagName: {
            value: 'ProjectContact'
          }
        }
      }
      {
        policyDefinitionId: resourceId('Microsoft.Authorization/policyDefinitions', 'ea3f2387-9b95-492a-a190-fcdc54f7b070')
        policyDefinitionReferenceId: toLower(replace('Inherit ProjectName tag from the resource group if missing', ' ', '-'))
        parameters: {
          tagName: {
            value: 'ProjectName'
          }
        }
      }
      {
        policyDefinitionId: resourceId('Microsoft.Authorization/policyDefinitions', 'ea3f2387-9b95-492a-a190-fcdc54f7b070')
        policyDefinitionReferenceId: toLower(replace('Inherit TechnicalContact tag from the resource group if missing', ' ', '-'))
        parameters: {
          tagName: {
            value: 'TechnicalContact'
          }
        }
      }
    ]
  }
}

resource requiredOnResourceGroup 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: 'required-tags-on-resource-group'
  properties: {
    displayName: 'Custom - Tags required on resource group'
    policyDefinitions: [
      {
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'Tags-Require-Tag-ResourceGroup-ClientOrganization')
        policyDefinitionReferenceId: toLower(replace('Require ClientOrganization tag on resource group', ' ', '-'))
        parameters: {}
      }
      {
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'Tags-Require-Tag-ResourceGroup-CostCenter')
        policyDefinitionReferenceId: toLower(replace('Require CostCenter tag on resource group', ' ', '-'))
        parameters: {}
      }
      {
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'Tags-Require-Tag-ResourceGroup-DataSensitivity')
        policyDefinitionReferenceId: toLower(replace('Require DataSensitivity tag on resource group', ' ', '-'))
        parameters: {}
      }
      {
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'Tags-Require-Tag-ResourceGroup-ProjectContact')
        policyDefinitionReferenceId: toLower(replace('Require ProjectContact tag on resource group', ' ', '-'))
        parameters: {}
      }
      {
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'Tags-Require-Tag-ResourceGroup-ProjectName')
        policyDefinitionReferenceId: toLower(replace('Require ProjectName tag on resource group', ' ', '-'))
        parameters: {}
      }
      {
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'Tags-Require-Tag-ResourceGroup-TechnicalContact')
        policyDefinitionReferenceId: toLower(replace('Require TechnicalContact tag on resource group', ' ', '-'))
        parameters: {}
      }
    ]
  }
}

resource auditOnResources 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: 'audit-required-tags-on-resources'
  properties: {
    displayName: 'Custom - Audit for required tags on resources'
    policyDefinitions: [
      {
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'Tags-Audit-Missing-Tag-Resource-ClientOrganization')
        policyDefinitionReferenceId: toLower(replace('Audit for ClientOrganization tag on resource', ' ', '-'))
        parameters: {}
      }
      {
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'Tags-Audit-Missing-Tag-Resource-CostCenter')
        policyDefinitionReferenceId: toLower(replace('Audit for CostCenter tag on resource', ' ', '-'))
        parameters: {}
      }
      {
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'Tags-Audit-Missing-Tag-Resource-DataSensitivity')
        policyDefinitionReferenceId: toLower(replace('Audit for DataSensitivity tag on resource', ' ', '-'))
        parameters: {}
      }
      {
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'Tags-Audit-Missing-Tag-Resource-ProjectContact')
        policyDefinitionReferenceId: toLower(replace('Audit for ProjectContact tag on resource', ' ', '-'))
        parameters: {}
      }
      {
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'Tags-Audit-Missing-Tag-Resource-ProjectName')
        policyDefinitionReferenceId: toLower(replace('Audit for ProjectName tag on resource', ' ', '-'))
        parameters: {}
      }
      {
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'Tags-Audit-Missing-Tag-Resource-TechnicalContact')
        policyDefinitionReferenceId: toLower(replace('Audit for TechnicalContact tag on resource', ' ', '-'))
        parameters: {}
      }
    ]
  }
}
