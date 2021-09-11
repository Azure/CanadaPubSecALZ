// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

param policyDefinitionManagementGroupId string

/*
Format of the array of objects
[
  {
    privateLinkServiceNamespace: 'Microsoft.AzureCosmosDB/databaseAccounts'
    zone: 'privatelink.documents.azure.com'
    groupId: 'SQL'
  }
]
*/
param privateDNSZones array

var policySetName = 'custom-central-dns-private-endpoints'
var policySetDisplayName = 'Custom - Central DNS for Private Endpoints'

var customPolicyDefinitionMgScope = tenantResourceId('Microsoft.Management/managementGroups', policyDefinitionManagementGroupId)
var customPolicyDefinition = json(loadTextContent('templates/DNS-PrivateEndpoints/azurepolicy.json'))

// To batch delete policies using Azure CLI, use:
// az policy definition list --management-group pubsec --query "[?contains(id,'dns-pe-')].name" -o tsv | xargs -tn1 -P 5 az policy definition delete --management-group pubsec --name

resource policy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = [for privateDNSZone in privateDNSZones: {
  name: 'dns-pe-${uniqueString(privateDNSZone.privateLinkServiceNamespace, privateDNSZone.zone, privateDNSZone.groupId)}'
  properties: {
    metadata: {
      privateLinkServiceNamespace: privateDNSZone.privateLinkServiceNamespace
      zone: privateDNSZone.zone
      groupId: privateDNSZone.groupId
    }
    displayName: '${customPolicyDefinition.properties.displayName} - ${privateDNSZone.zone} - ${privateDNSZone.privateLinkServiceNamespace} - ${privateDNSZone.groupId}'
    mode: customPolicyDefinition.properties.mode
    policyRule: customPolicyDefinition.properties.policyRule
    parameters: customPolicyDefinition.properties.parameters
  }
}]

resource policySet 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: policySetName
  properties: {
    displayName: policySetDisplayName
    parameters: {
      privateDNSZoneSubscriptionId: {
        type: 'String'
      }
      privateDNSZoneResourceGroupName: {
        type: 'String'
      }
    }
    policyDefinitionGroups: [
      {
        name: 'NETWORK'
        displayName: 'DNS for Private Endpoints'
      }
    ]
    policyDefinitions: [for (privateDNSZone, i) in privateDNSZones: {
        groupNames: [
          'NETWORK'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope,'Microsoft.Authorization/policyDefinitions', policy[i].name)
        policyDefinitionReferenceId: toLower('${privateDNSZone.zone}-${privateDNSZone.groupId}-${uniqueString(privateDNSZone.privateLinkServiceNamespace)}')
        parameters: {
          privateLinkServiceNamespace: {
            value: privateDNSZone.privateLinkServiceNamespace
          }
          privateDnsZoneId: {
            value: '[[concat(\'/subscriptions/\',parameters(\'privateDNSZoneSubscriptionId\'),\'/resourcegroups/\',parameters(\'privateDNSZoneResourceGroupName\'),\'/providers/Microsoft.Network/privateDnsZones/${privateDNSZone.zone}\')]'
          }
          groupId: {
            value: privateDNSZone.groupId
          }
        }
    }]
  }
}
