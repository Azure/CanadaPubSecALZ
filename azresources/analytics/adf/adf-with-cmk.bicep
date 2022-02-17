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

@description('Azure Data Factory Name.')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

// Private Endpoints
@description('Private Endpoint Subnet Resource Id.')
param privateEndpointSubnetId string

@description('Private DNS Zone Resource Id for Data Factory.')
param datafactoryPrivateZoneId string

// User Assigned Identity
@description('User Assigned Managed Identity Resource Id.')
param userAssignedIdentityId string

@description('User Assigned Managed Identity Principal Id.')
param userAssignedIdentityPrincipalId string

// Azure Key Vault
@description('Azure Key Vault Resource Group Name.')
param akvResourceGroupName string

@description('Azure Key Vault Name.')
param akvName string

// Reference existing Azure Key Vault & Assign user assigned identity
// 'Key Vault Crypto Service Encryption User' permission.
resource akv 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  scope: resourceGroup(akvResourceGroupName)
  name: akvName
}

module akvRoleAssignmentForCMK '../../iam/resource/key-vault-role-assignment-to-sp.bicep' = {
  name: 'rbac-${name}-key-vault'
  scope: resourceGroup(akvResourceGroupName)
  params: {
    keyVaultName: akv.name
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e147488a-f6f5-4113-8e2d-b22465e65bf6') // Key Vault Crypto Service Encryption User
    resourceSPObjectIds: array(userAssignedIdentityPrincipalId)
  }
}

// Define a RSA 2048 Key for CMK.
module akvKey '../../security/key-vault-key-rsa2048.bicep' = {
  name: 'add-cmk-${name}'
  scope: resourceGroup(akvResourceGroupName)
  params: {
    akvName: akvName
    keyName: 'cmk-adf-${name}'
  }
}

// Deploy Azure Data Factory with Managed Virtual Network & Managed Integration Runtime
resource adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  dependsOn: [
    akvRoleAssignmentForCMK
  ]

  location: location
  name: name
  tags: tags
  identity: {
    type: 'SystemAssigned,UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    encryption: {
      identity: {
        userAssignedIdentity: userAssignedIdentityId
      }
      vaultBaseUrl: akv.properties.vaultUri
      keyName: akvKey.outputs.keyName
      keyVersion: akvKey.outputs.keyVersion
    }
  }

  resource managedVnet 'managedVirtualNetworks@2018-06-01' = {
    name: 'default'
    properties: {}
  }

  resource autoResolveIR 'integrationRuntimes@2018-06-01' = {
    name: 'AutoResolveIntegrationRuntime'
    properties: {
      type: 'Managed'
      managedVirtualNetwork: {
        type: 'ManagedVirtualNetworkReference'
        referenceName: managedVnet.name
      }
      typeProperties: {
        computeProperties: {
          location: 'AutoResolve'
        }
      }
    }
  }
}

// Create Private Endpoints and register their IPs with Private DNS Zone
resource adf_datafactory_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: location
  name: '${adf.name}-df-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${adf.name}-df-endpoint'
        properties: {
          privateLinkServiceId: adf.id
          groupIds: [
            'dataFactory'
          ]
        }
      }
    ]
  }

  resource adf_datafactory_pe_dns_reg 'privateDnsZoneGroups@2020-06-01' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink_datafactory_windows_net'
          properties: {
            privateDnsZoneId: datafactoryPrivateZoneId
          }
        }
      ]
    }
  }
}
