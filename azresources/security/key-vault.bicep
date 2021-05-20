// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param privateEndpointSubnetId string
param privateZoneId string
param name string = 'akv${uniqueString(resourceGroup().id)}'
param tags object = {}

resource akv 'Microsoft.KeyVault/vaults@2019-09-01' = {
  location: resourceGroup().location
  name: name
  tags: tags
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
    enableSoftDelete: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 90
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    enableRbacAuthorization: true
  }
}

resource akv_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: resourceGroup().location
  name: '${akv.name}-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${akv.name}-endpoint'
        properties: {
          privateLinkServiceId: akv.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}

resource akv_pe_dns_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${akv_pe.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink_vaultcore_azure_net'
        properties: {
          privateDnsZoneId: privateZoneId
        }
      }
    ]
  }
}

output akvId string = akv.id
