// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

param hubVnetId string

param spokeSubId string
param spokeRgName string
param spokeVnetName string

var hubRgName = split(hubVnetId, '/')[4]
var hubVnetName = split(hubVnetId, '/')[8]

module hubToSpokePeering '../../../azresources/network/vnet-peering.bicep' = {
  name: 'hubToSpokePeering'
  scope: resourceGroup(hubRgName)
  params: {
    useRemoteGateways: false
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    peeringName: '${spokeVnetName}-HubToSpoke'
    sourceVnetName: hubVnetName
    targetVnetId: '/subscriptions/${spokeSubId}/resourceGroups/${spokeRgName}/providers/Microsoft.Network/virtualNetworks/${spokeVnetName}'
  }
}
