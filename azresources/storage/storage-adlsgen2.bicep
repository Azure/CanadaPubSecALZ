// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('ADLS Gen2 Storage Account Name')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

@description('Private Endpoint Subnet Id')
param privateEndpointSubnetId string

@description('Private DNS Zone Resource Id for blob.')
param blobPrivateZoneId string

@description('Private DNS Zone Resource Id for dfs.')
param dfsPrivateZoneId string

@description('Default Network Acls.  Default: deny')
param defaultNetworkAcls string = 'deny'

@description('Bypass Network Acls.  Default: AzureServices,Logging,Metrics')
param bypassNetworkAcls string = 'AzureServices,Logging,Metrics'

@description('Array of Subnet Resource Ids for Virtual Network Access')
param subnetIdForVnetAccess array = []

// Customer Managed Key
@description('Boolean flag that determines whether to enable Customer Managed Key.')
param useCMK bool

// Azure Key Vault
@description('Azure Key Vault Resource Group Name.  Required when useCMK=true.')
param akvResourceGroupName string

@description('Azure Key Vault Name.  Required when useCMK=true.')
param akvName string

// Deployment Script Identity
@description('Deployment Script Identity Resource Id.  This identity is used to execute Azure CLI as part of the deployment.')
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
      virtualNetworkRules: [for subnetId in subnetIdForVnetAccess: {
        id: subnetId
        action: 'Allow'
      }]
    }
  }
}

resource threatProtection 'Microsoft.Security/advancedThreatProtectionSettings@2019-01-01' = {
  name: 'current'
  scope: storage
  properties: {
    isEnabled: true
  }
}

/* Customer Managed Keys - configured after the storage account is created with managed key */
module enableCMK 'storage-enable-cmk.bicep' = if (useCMK) {
  name: 'deploy-cmk-${name}'
  params: {
    storageAccountName: storage.name
    storageResourceGroupName: resourceGroup().name

    keyVaultResourceGroupName: akvResourceGroupName
    keyVaultName: akvName
    
    deploymentScriptIdentityId: deploymentScriptIdentityId
  }
}

/* Private Endpoints */
resource datalake_blob_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = if (!empty(blobPrivateZoneId)) {
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

  resource datalake_blob_pe_dns_reg 'privateDnsZoneGroups@2020-06-01' = {
    name: 'default'
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
}

resource datalake_dfs_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = if (!empty(dfsPrivateZoneId)) {
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

  resource datalake_dfs_pe_dns_reg 'privateDnsZoneGroups@2020-06-01' = {
    name: 'default'
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
}

// Outputs
output storageName string = storage.name
output storageId string = storage.id
output primaryDfsEndpoint string = storage.properties.primaryEndpoints.dfs
