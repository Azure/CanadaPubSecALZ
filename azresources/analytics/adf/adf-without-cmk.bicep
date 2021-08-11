// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string = 'adf${uniqueString(resourceGroup().id)}'
param tags object = {}

param privateEndpointSubnetId string
param privateZoneId string

param userAssignedIdentityId string

resource adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  location: resourceGroup().location
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
  }
}

resource adfIR 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  name: '${adf.name}/SelfHostedIR'
  properties: {
    type: 'SelfHosted'
  }
}

resource adf_datafactory_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: resourceGroup().location
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
            privateDnsZoneId: privateZoneId
          }
        }
      ]
    }
  }
}

resource adf_portal_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: resourceGroup().location
  name: '${adf.name}-portal-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${adf.name}-portal-endpoint'
        properties: {
          privateLinkServiceId: adf.id
          groupIds: [
            'portal'
          ]
        }
      }
    ]
  }

  resource adf_portal_pe_dns_reg 'privateDnsZoneGroups@2020-06-01' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink_servicebus_windows_net'
          properties: {
            privateDnsZoneId: privateZoneId
          }
        }
      ]
    }
  }
}
