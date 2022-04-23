targetScope = 'subscription'

param location string = deployment().location

param resourceTags object

param hubResourceGroup string
param hubVnetName string
param hubVnetId string

param managementRestrictedZone object
param managementRestrictedZoneUdrId string

param ddosStandardPlanId string

// Create Managemend Restricted Virtual Network Resource Group
resource rgMrzVnet 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: managementRestrictedZone.resourceGroupName
  location: location
  tags: resourceTags
}

module rgMrzDeleteLock '../../../azresources/util/delete-lock.bicep' = {
  name: 'deploy-delete-lock-${managementRestrictedZone.resourceGroupName}'
  scope: rgMrzVnet
}

// Management Restricted Virtual Network
module mrzVnet 'mrz-vnet.bicep' = {
  name: 'deploy-management-vnet-${managementRestrictedZone.network.name}'
  scope: rgMrzVnet
  params: {
    location: location

    network: managementRestrictedZone.network
    udrId: managementRestrictedZoneUdrId

    ddosStandardPlanId: ddosStandardPlanId
  }
}

// Virtual Network Peering - Management Restricted Zone to Hub
module vnetPeeringSpokeToHub '../../../azresources/network/vnet-peering.bicep' = {
  name: 'deploy-vnet-peering-spoke-to-hub'
  scope: resourceGroup(rgMrzVnet.name)
  params: {
    peeringName: '${mrzVnet.outputs.vnetName}-to-${hubVnetName}'
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    sourceVnetName: mrzVnet.outputs.vnetName
    targetVnetId: hubVnetId
    useRemoteGateways: false //to be changed once we have ExpressRoute or VPN GWs 
  }
}

// Virtual Network Peering - Hub to Management Restricted Zone
module vnetPeeringHubToSpoke '../../../azresources/network/vnet-peering.bicep' = if (managementRestrictedZone.enabled) {
  name: 'deploy-vnet-peering-hub-to-spoke'
  scope: resourceGroup(hubResourceGroup)
  params: {
    peeringName: '${hubVnetName}-to-${mrzVnet.outputs.vnetName}'
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    sourceVnetName: hubVnetName
    targetVnetId: mrzVnet.outputs.vnetId
    useRemoteGateways: false
  }
}
