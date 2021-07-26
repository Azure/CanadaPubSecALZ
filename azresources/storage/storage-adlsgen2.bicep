// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string = 'datalake${uniqueString(resourceGroup().id)}'
param tags object = {}

@description('Required if private zones are used')
param privateEndpointSubnetId string

@description('When true, blob private zone is created')
param deployBlobPrivateZone bool
@description('Required when deployBlobPrivateZone=true')
param blobPrivateZoneId string

@description('When true, blob private zone is created')
param deployDfsPrivateZone bool
@description('Required when deployFilePrivateZone=true')
param dfsPrivateZoneId string

param defaultNetworkAcls string = 'deny'
param bypassNetworkAcls string = 'AzureServices,Logging,Metrics'
param subnetIdForVnetRestriction array = []

@description('When true, customer managed key is used for encryption')
param useCMK bool
@description('Required when useCMK=true')
param keyVaultName string
@description('Required when useCMK=true')
param keyVaultResourceGroupName string
@description('Required when useCMK=true')
param deploymentScriptIdentityId string

/* Storage Account */
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
    isHnsEnabled: true
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    encryption: {
      requireInfrastructureEncryption: true
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Account'
        }
        table: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
    networkAcls: {
      defaultAction: defaultNetworkAcls
      bypass: bypassNetworkAcls
      virtualNetworkRules: [for subnetId in subnetIdForVnetRestriction: {
        id: subnetId
        action: 'Allow'
      }]
    }
  }
}

/* Customer Managed Keys - configured after the storage account is created with managed key */
module enableCMK 'storage-enable-cmk.bicep' = if (useCMK) {
  name: 'deploy-cmk-${name}'
  params: {
    storageAccountName: storage.name
    storageResourceGroupName: resourceGroup().name

    keyVaultName: keyVaultName
    keyVaultResourceGroupName: keyVaultResourceGroupName

    deploymentScriptIdentityId: deploymentScriptIdentityId
  }  
}

/* Private Endpoints */
resource datalake_blob_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = if (deployBlobPrivateZone) {
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

resource datalake_dfs_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = if (deployDfsPrivateZone) {
  location: resourceGroup().location
  name: '${storage.name}-dfs-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${storage.name}-dfs-endpoint'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            'dfs'
          ]
        }
      }
    ]
  }
}

resource datalake_blob_pe_dns_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = if (deployBlobPrivateZone) {
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

resource datalake_dfs_pe_dns_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = if (deployDfsPrivateZone) {
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

output storageName string = storage.name
output storageId string = storage.id
output primaryDfsEndpoint string = storage.properties.primaryEndpoints.dfs
