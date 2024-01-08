param vHUBName string
param vHUBConnName string
param remoteVirtualNetworkId string

resource vHUB 'Microsoft.Network/virtualHubs@2023-05-01' existing = {
  name: vHUBName
}

resource vHUBconnection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2023-05-01' = {
  name: vHUBConnName
  parent: vHUB
  properties: {
    remoteVirtualNetwork: {
      id: remoteVirtualNetworkId
    }
  }
}
