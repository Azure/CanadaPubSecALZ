param vHubName string

resource vHUB 'Microsoft.Network/virtualHubs@2023-05-01' existing = {
  name: vHubName
}

param assosiatedRouteTableId string
param propagatedRouteTableIds array = []

var routeTableIds = [for id in propagatedRouteTableIds: {
  id: id
}]

param vHubConnName string
param remoteVirtualNetworkId string

resource vHUBconnection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2023-05-01' = {
  name: vHubConnName
  parent: vHUB
  properties: {
    remoteVirtualNetwork: {
      id: remoteVirtualNetworkId
    }
    routingConfiguration: {
      associatedRouteTable: {
        id: assosiatedRouteTableId
      }
      propagatedRouteTables: {
        ids: propagatedRouteTableIds == [] ? json('null') : routeTableIds
      }
    }
  }
}
