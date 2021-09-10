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
    zone: 'privatelink.blob.${environment().suffixes.storage}'
    groupId: 'blob'
  }
  {
    zone: 'privatelink.blob.${environment().suffixes.storage}'
    groupId: 'blob_secondary'
  }
  {
    zone: 'privatelink.table.${environment().suffixes.storage}'
    groupId: 'table'
  }
  {
    zone: 'privatelink.table.${environment().suffixes.storage}'
    groupId: 'table_secondary'
  }
  {
    zone: 'privatelink.queue.${environment().suffixes.storage}'
    groupId: 'queue'
  }
  {
    zone: 'privatelink.queue.${environment().suffixes.storage}'
    groupId: 'queue_secondary'
  }
]

resource dnsPolicySet 'Microsoft.Authorization/policySetDefinitions@2020-03-01' = {
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
    policyDefinitions: [for privateDNSZone in privateDNSZones: {
        groupNames: [
          'NETWORK'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'DNS-PrivateEndpoints')
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
