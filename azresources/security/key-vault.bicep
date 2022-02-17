// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Location for the deployment.')
param location string = resourceGroup().location

@description('Azure Key Vault Name.')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

@description('Boolean flag to enable Azure Key Vault for Deployment.  Default: false')
param enabledForDeployment bool = false

@description('Boolean flag to enable Azure Key Vault for Disk Encryption.  Default: false')
param enabledForDiskEncryption bool = false

@description('Boolean flag to enable Azure Key Vault for Template Deployment.  Default: false')
param enabledForTemplateDeployment bool = false

@description('Soft Delete Retention in Days.  Default: 90')
@minValue(7)
param softDeleteRetentionInDays int = 90

@description('Private Endpoint Subnet Resource Id.')
param privateEndpointSubnetId string = ''

@description('Private DNS Zone Resource Id.')
param privateZoneId string = ''

resource akv 'Microsoft.KeyVault/vaults@2019-09-01' = {
  location: location
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
      defaultAction: !(empty(privateZoneId)) ? 'Deny' : 'Allow'
    }
    enableRbacAuthorization: true
  }
}

resource akv_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = if (!(empty(privateZoneId))) {
  location: location
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

// Outputs
output akvName string = akv.name
output akvId string = akv.id
