// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string
param tags object = {}
param capacityvalue int = 1
param privateEndpointSubnetId string
param privateZoneEventHubId string

resource eventhub 'Microsoft.EventHub/namespaces@2021-01-01-preview' = {
  name: name
  location: resourceGroup().location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: capacityvalue
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    isAutoInflateEnabled: false
    zoneRedundant: true
  }
}

resource eventhub_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: resourceGroup().location
  name: '${eventhub.name}-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${eventhub.name}-endpoint'
        properties: {
          privateLinkServiceId: eventhub.id
          groupIds: [
            'namespace'
          ]
        }
      }
    ]
  }

  resource eventhub_dns_reg 'privateDnsZoneGroups@2020-06-01' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-eventhub-ms'
          properties: {
            privateDnsZoneId: privateZoneEventHubId
          }
        }
      ]
    }
  }
}
