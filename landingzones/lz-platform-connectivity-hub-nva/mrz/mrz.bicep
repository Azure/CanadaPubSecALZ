// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

@description('Location for the deployment.')
param location string = deployment().location

@description('A set of key/value pairs of tags assigned to the resource group and resources.')
param resourceTags object

@description('Hub Resource Group Name')
param hubResourceGroup string

@description('Hub Virtual Network Name')
param hubVnetName string

@description('Hub Virtual Network Resource Id')
param hubVnetId string

@description('Management Restricted Zone configuration.  See docs/archetypes/hubnetwork-nva.md for configuration settings.')
param managementRestrictedZone object

@description('Route Table Resource Id for subnets in Management Restricted Zone')
param managementRestrictedZoneUdrId string

@description('DDoS Standard Plan Resource Id.')
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
    allowGatewayTransit: true
    sourceVnetName: hubVnetName
    targetVnetId: mrzVnet.outputs.vnetId
    useRemoteGateways: false
  }
}
