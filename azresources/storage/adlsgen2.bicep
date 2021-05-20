// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param privateEndpointSubnetId string
param blobPrivateZoneId string
param dfsPrivateZoneId string
param name string = 'datalake${uniqueString(resourceGroup().id)}'
param tags object = {}


resource datalake 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  location: resourceGroup().location
  name: name
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_GRS'
  }
  properties: {
    accessTier: 'Hot'
    isHnsEnabled: true
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices,Logging,Metrics'
    }
  }
}

resource datalake_blob_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: resourceGroup().location
  name: '${datalake.name}-blob-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${datalake.name}-blob-endpoint'
        properties: {
          privateLinkServiceId: datalake.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource datalake_dfs_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: resourceGroup().location
  name: '${datalake.name}-dfs-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${datalake.name}-dfs-endpoint'
        properties: {
          privateLinkServiceId: datalake.id
          groupIds: [
            'dfs'
          ]
        }
      }
    ]
  }
}

resource datalake_blob_pe_dns_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${datalake_blob_pe.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink_blob_core_windows_net'
        properties: {
          privateDnsZoneId: blobPrivateZoneId
        }
      }
    ]
  }
}


resource datalake_dfs_pe_dns_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${datalake_dfs_pe.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink_dfs_core_windows_net'
        properties: {
          privateDnsZoneId: dfsPrivateZoneId
        }
      }
    ]
  }
}

output storageId string = datalake.id
