param vHubName string

resource vHUB 'Microsoft.Network/virtualHubs@2023-05-01' existing = {
  name: vHubName
}

param vHubConnName string
param remoteVirtualNetworkId string

resource vHUBconnection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2023-05-01' = {
  name: vHubConnName
  parent: vHUB
  properties: {
    remoteVirtualNetwork: {
      id: remoteVirtualNetworkId
    }
  }
}
