// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param privateEndpointSubnetId string
param blobPrivateZoneId string
param filePrivateZoneId string
param name string = 'stg${uniqueString(resourceGroup().id)}'
param deployBlobPrivateZone bool
param deployFilePrivateZone bool
param defaultNetworkAcls string = 'deny'
param bypassNetworkAcls string = 'AzureServices,Logging,Metrics'
param tags object = {}


resource storage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  tags: tags
  location: resourceGroup().location
  name: name
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_GRS'
  }
  properties: {
    accessTier: 'Hot'
    isHnsEnabled: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: defaultNetworkAcls
      bypass: bypassNetworkAcls
    }
  }
}

resource storage_blob_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = if (deployBlobPrivateZone == true) {
  location: resourceGroup().location
  name: '${storage.name}-blob-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${storage.name}-blob-endpoint'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource storage_file_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = if (deployFilePrivateZone == true){
  location: resourceGroup().location
  name: '${storage.name}-file-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${storage.name}-file-endpoint'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            'file'
          ]
        }
      }
    ]
  }
}

resource storage_blob_pe_dns_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = if (deployBlobPrivateZone == true) {
  name: '${storage_blob_pe.name}/default'
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

resource storage_file_pe_dns_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = if (deployFilePrivateZone == true) {
  name: '${storage_file_pe.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink_file_core_windows_net'
        properties: {
          privateDnsZoneId: filePrivateZoneId
        }
      }
    ]
  }
}

output storageName string = storage.name
output storageId string = storage.id
output storagePath string = storage.properties.primaryEndpoints.blob
