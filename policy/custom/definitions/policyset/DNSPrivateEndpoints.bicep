// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

param policyDefinitionManagementGroupId string

var customPolicyDefinitionMgScope = tenantResourceId('Microsoft.Management/managementGroups', policyDefinitionManagementGroupId)

var privateDNSZones = [
  {
    serviceName: 'Storage Account'
    zone: 'privatelink.blob.${environment().suffixes.storage}'
    groupId: 'blob'
  }
  {
    serviceName: 'Storage Account'
    zone: 'privatelink.blob.${environment().suffixes.storage}'
    groupId: 'blob_secondary'
  }
]

var policyDefinition = json(loadTextContent('templates/DNS-PrivateEndpoints/azurepolicy.json'))

resource policy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = [for privateDNSZone in privateDNSZones: {
  name: toLower(replace('${policyDefinition.name} ${privateDNSZone.serviceName} ${privateDNSZone.groupId}', ' ', '-'))
  properties: {
    metadata: {
      zone: privateDNSZone.zone
      groupId: privateDNSZone.groupId
    }
    displayName: '${policyDefinition.properties.displayName} - ${privateDNSZone.zone} - ${privateDNSZone.groupId}'
    mode: policyDefinition.properties.mode
    policyRule: policyDefinition.properties.policyRule
    parameters: policyDefinition.properties.parameters
  }
}]

resource policySet 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: 'custom-central-dns-private-endpoints'
  properties: {
    displayName: 'Custom - Central DNS for Private Endpoints'
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
        policyDefinitionReferenceId: toLower('${privateDNSZone.zone}-${privateDNSZone.groupId}')
        parameters: {
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
