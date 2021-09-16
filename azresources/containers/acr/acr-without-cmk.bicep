// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string = 'acr${uniqueString(resourceGroup().id)}'
param tags object = {}

param userAssignedIdentityId string

param quarantinePolicy string = 'disabled'
param trustPolicyType string = 'Notary'
param trustPolicyStatus string = 'enabled'
param retentionPolicyDays int = 30
param retentionPolicyStatus string = 'enabled'

param deployPrivateZone bool
param privateEndpointSubnetId string
param privateZoneId string

/* Configure ACR */
resource acr 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  name: name
  tags: tags
  location: resourceGroup().location
  sku: {
    name: 'Premium'
  }
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  properties: {
    adminUserEnabled: true

    networkRuleSet: {
      defaultAction: 'Deny'
    }

    policies: {
      quarantinePolicy: {
        status: quarantinePolicy
      }
      trustPolicy: {
        type: trustPolicyType
        status: trustPolicyStatus
      }
      retentionPolicy: {
        days: retentionPolicyDays
        status: retentionPolicyStatus
      }
    }

    dataEndpointEnabled: false
    publicNetworkAccess: 'Disabled'
  }
}

resource acr_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = if (deployPrivateZone) {
  location: resourceGroup().location
  name: '${acr.name}-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${acr.name}-endpoint'
        properties: {
          privateLinkServiceId: acr.id
          groupIds: [
            'registry'
          ]
        }
      }
    ]
  }

  resource acr_pe_dns_reg 'privateDnsZoneGroups@2020-06-01' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-azurecr-io'
          properties: {
            privateDnsZoneId: privateZoneId
          }
        }
      ]
    }
  }
}

output acrId string = acr.id
