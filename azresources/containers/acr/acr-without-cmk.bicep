// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Azure Container Registry Name.')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

@description('Quarantine Policy.  Default:  disabled')
param quarantinePolicy string = 'disabled'

@description('Trust Policy Type.  Default:  Notary')
param trustPolicyType string = 'Notary'

@description('Trust Policy Status. Default:  enabled')
param trustPolicyStatus string = 'enabled'

@description('Retention Policy in days.  Default:  30')
param retentionPolicyDays int = 30

@description('Retention Policy status.  Default:  enabled')
param retentionPolicyStatus string = 'enabled'

// User Assigned Managed Identity
@description('User Assigned Managed Identity Resource Id.')
param userAssignedIdentityId string

// Networking
@description('Private Endpoint Subnet Resource Id.')
param privateEndpointSubnetId string

@description('Private DNS Zone Resource Id.')
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

resource acr_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = if (!empty(privateZoneId)) {
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
