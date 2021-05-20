// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param sourceVnetName string
param targetVnetId string
param peeringName string

param useRemoteGateways bool = false
param allowVirtualNetworkAccess bool = true
param allowForwardedTraffic bool = true

resource vnetPeeringFromEdgeFirewall 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  name: '${sourceVnetName}/${peeringName}'
  properties: {
    useRemoteGateways: useRemoteGateways
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    allowForwardedTraffic: allowForwardedTraffic
    remoteVirtualNetwork: {
      id: targetVnetId
    }
  }
}
