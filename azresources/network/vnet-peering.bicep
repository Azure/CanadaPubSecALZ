// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Source Virtual Network Name.')
param sourceVnetName string

@description('Target Virtual Network Resource Id.')
param targetVnetId string

@description('Virtual Network Peering Name.')
param peeringName string

@description('Boolean flag to determine whether remote gateways are used.  Default: false')
param useRemoteGateways bool = false

@description('Boolean flag to determine virtual network access through the peer.  Default: true')
param allowVirtualNetworkAccess bool = true

@description('Boolean flag to determine traffic forwarding.  Default: true')
param allowForwardedTraffic bool = true

resource vnetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
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
