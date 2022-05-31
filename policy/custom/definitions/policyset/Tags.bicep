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

@description('Required set of tags that must exist on resource groups and resources.')
param requiredResourceTags array = []

@description('Policy effect to whether deny or audit when tag is missing.  Default:  Deny')
@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
param policyEnforcement string = 'Deny'

var customPolicyDefinitionMgScope = tenantResourceId('Microsoft.Management/managementGroups', policyDefinitionManagementGroupId)

// Retrieve the templated azure policies as json object
var tagsInheritedFromSubscriptionToResourceGroupPolicyTemplate = json(loadTextContent('templates/Tags-Inherit-Tag-From-Subscription-To-ResourceGroup/azurepolicy.json'))
var tagsInheritedFromResourceGroupPolicyTemplate = json(loadTextContent('templates/Tags-Inherit-Tag-From-ResourceGroup/azurepolicy.json'))
var tagsRequiredOnResourceGroupPolicyTemplate = json(loadTextContent('templates/Tags-Require-Tag-ResourceGroup/azurepolicy.json'))
var tagsAuditOnResourcePolicyTemplate = json(loadTextContent('templates/Tags-Audit-Missing-Tag-Resource/azurepolicy.json'))

// Inherit tags from subscription to resource group
resource tagsInheritedFromSubscriptionToResourceGroupPolicy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = [for tag in requiredResourceTags: {
  name: toLower(replace('tags-inherited-from-sub-to-rg-${tag}', ' ', '-'))
  properties: {
    metadata: {
      'tag': tag
    }
    displayName: '${tagsInheritedFromSubscriptionToResourceGroupPolicyTemplate.properties.displayName}: ${tag}'
    mode: tagsInheritedFromSubscriptionToResourceGroupPolicyTemplate.properties.mode
    policyRule: tagsInheritedFromSubscriptionToResourceGroupPolicyTemplate.properties.policyRule
    parameters: tagsInheritedFromSubscriptionToResourceGroupPolicyTemplate.properties.parameters
  }
}]

resource tagsInheritedFromSubscriptionToResourceGroupPolicySet 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: 'custom-tags-inherited-from-subscription-to-resource-group'
  properties: {
    displayName: 'Custom - Inherited tags from subscription to resource group if missing'
    policyDefinitions: [for (tag, i) in requiredResourceTags: {
      policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', tagsInheritedFromSubscriptionToResourceGroupPolicy[i].name)
      policyDefinitionReferenceId: toLower(replace('Inherit ${tag} tag from the subscription to resource group if missing', ' ', '-'))
      parameters: {
        tagName: {
          value: tag
        }
      }
    }]
  }
}

// Inherit tags from resource group to resources
resource tagsInheritedFromResourceGroupPolicy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = [for tag in requiredResourceTags: {
  name: toLower(replace('tags-inherited-from-rg-${tag}', ' ', '-'))
  properties: {
    metadata: {
      'tag': tag
    }
    displayName: '${tagsInheritedFromResourceGroupPolicyTemplate.properties.displayName}: ${tag}'
    mode: tagsInheritedFromResourceGroupPolicyTemplate.properties.mode
    policyRule: tagsInheritedFromResourceGroupPolicyTemplate.properties.policyRule
    parameters: tagsInheritedFromResourceGroupPolicyTemplate.properties.parameters
  }
}]

resource tagsInheritedFromResourceGroupPolicySet 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: 'custom-tags-inherited-from-resource-group'
  properties: {
    displayName: 'Custom - Inherited tags from resource group if missing'
    policyDefinitions: [for (tag, i) in requiredResourceTags: {
      policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', tagsInheritedFromResourceGroupPolicy[i].name)
      policyDefinitionReferenceId: toLower(replace('Inherit ${tag} tag from the resource group if missing', ' ', '-'))
      parameters: {
        tagName: {
          value: tag
        }
      }
    }]
  }
}

// Required tags on resource groups
resource tagsRequiredOnResourceGroupPolicy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = [for tag in requiredResourceTags: {
  name: toLower(replace('Tags-Require-Tag-ResourceGroup-${tag}', ' ', '-'))
  properties: {
    metadata: {
      'tag': tag
    }
    displayName: '${tagsRequiredOnResourceGroupPolicyTemplate.properties.displayName}: ${tag}'
    mode: tagsRequiredOnResourceGroupPolicyTemplate.properties.mode
    policyRule: tagsRequiredOnResourceGroupPolicyTemplate.properties.policyRule
    parameters: tagsRequiredOnResourceGroupPolicyTemplate.properties.parameters
  }
}]

resource tagsRequiredOnResourceGroupPolicySet 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: 'required-tags-on-resource-group'
  properties: {
    displayName: 'Custom - Tags required on resource group'
    policyDefinitions: [for (tag, i) in requiredResourceTags: {
      policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', tagsRequiredOnResourceGroupPolicy[i].name)
      policyDefinitionReferenceId: toLower(replace('Require ${tag} tag on resource group', ' ', '-'))
      parameters: {
        tagName: {
          value: tag
        }
        policyEnforcement: {
          value: policyEnforcement
        }
      }
    }]
  }
}

// Audit for tags on resources
resource tagsAuditOnResourcePolicy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = [for tag in requiredResourceTags: {
  name: toLower(replace('Tags-Audit-Missing-Tag-Resource-${tag}', ' ', '-'))
  properties: {
    metadata: {
      'tag': tag
    }
    displayName: '${tagsAuditOnResourcePolicyTemplate.properties.displayName}: ${tag}'
    mode: tagsAuditOnResourcePolicyTemplate.properties.mode
    policyRule: tagsAuditOnResourcePolicyTemplate.properties.policyRule
    parameters: tagsAuditOnResourcePolicyTemplate.properties.parameters
  }
}]

resource tagsAuditOnResourcePolicySet 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: 'audit-required-tags-on-resources'
  properties: {
    displayName: 'Custom - Audit for required tags on resources'
    policyDefinitions: [for (tag, i) in requiredResourceTags: {
      policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', tagsAuditOnResourcePolicy[i].name)
      policyDefinitionReferenceId: toLower(replace('Audit for ${tag} tag on resource', ' ', '-'))
      parameters: {
        tagName: {
          value: tag
        }
      }
    }]
  }
}
