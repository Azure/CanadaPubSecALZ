// param vHUBName string
// param vNETName string

targetScope = 'subscription'

param remoteVirtualNetworkId string

param SubscriptionConfig object

resource VWANRG 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: SubscriptionConfig.network.vHubConnection.VWANResourceGroupName
}

module vHUBConn 'hubVirtualNetworkConnections.bicep' = if ((SubscriptionConfig.network.deployVnet) && (SubscriptionConfig.network.vHubConnection.deployvHUBConnection)) {
  name: 'Deploy-App1VNET-to-${SubscriptionConfig.network.vHubConnection.VHUBName}'
  scope: VWANRG
  params: {
    remoteVirtualNetworkId: remoteVirtualNetworkId
    vHUBConnName: '${SubscriptionConfig.network.name}-to-${SubscriptionConfig.network.vHubConnection.VHUBName}'
    vHUBName: SubscriptionConfig.network.vHubConnection.VHUBName
  }
}
