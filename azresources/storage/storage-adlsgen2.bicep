// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string = 'datalake${uniqueString(resourceGroup().id)}'
param tags object = {}

param privateEndpointSubnetId string
param blobPrivateZoneId string
param dfsPrivateZoneId string

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
      defaultAction: 'Deny'
      bypass: 'AzureServices,Logging,Metrics'
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
resource datalake_blob_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
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

resource datalake_dfs_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
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

output storageId string = storage.id
output storageName string = storage.name
