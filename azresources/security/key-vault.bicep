// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string = 'akv${uniqueString(resourceGroup().id)}'
param tags object = {}

param enabledForDeployment bool = false
param enabledForDiskEncryption bool = false
param enabledForTemplateDeployment bool = false

@minValue(7)
param softDeleteRetentionInDays int = 90

@description('When true, blob private zone is created')
param deployPrivateEndpoint bool = false

@description('Required when deployPrivateEndpoint=true')
param privateEndpointSubnetId string = ''

@description('Required when deployPrivateEndpoint=true')
param privateZoneId string = ''

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
    softDeleteRetentionInDays: softDeleteRetentionInDays

    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment

    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: deployPrivateEndpoint ? 'Deny' : 'Allow'
    }
    enableRbacAuthorization: true
  }
}

resource akv_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = if (deployPrivateEndpoint) {
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

  resource akv_pe_dns_reg 'privateDnsZoneGroups@2020-06-01' = {
    name: 'default'
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
}

output akvName string = akv.name
output akvId string = akv.id
