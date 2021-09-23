// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param hubNetwork object = {
  virtualNetworkId: ''
  egressVirtualApplianceIp: ''
  rfc1918IPRange: ''
  rfc6598IPRange: ''
}

param network object = {
  name: ''
  addressPrefixes: [
    ''
  ]
  subnets: {
    oz: {
      comment: 'Foundational Element (OZ)'
      name: ''
      addressPrefix: ''
    }
    paz: {
      comment: 'Presentation Zone (PAZ)'
      name: ''
      addressPrefix: ''
    }
    rz: {
      comment: 'Application Zone (RZ)'
      name: ''
      addresssPrefix: ''
    }
    hrz: {
      comment: 'Data Zone (HRZ)'
      name: ''
      addressPrefix: ''
    }
    optional: [
      {
        comment: 'Optional Subnet 1'
        name: ''
        addressPrefix: ''
      }
    ]
  }
  useRemoteGateway: false
  peerToHubVirtualNetwork: true
}

var hubVnetIdSplit = split(hubNetwork.virtualNetworkId, '/')

var routesToHub = [
  // Force Routes to Hub IPs (RFC1918 range) via FW despite knowing that route via peering
  {
    name: 'PrdSpokesUdrHubRFC1918FWRoute'
    properties: {
      addressPrefix: hubNetwork.rfc1918IPRange
      nextHopType: 'VirtualAppliance'
      nextHopIpAddress: hubNetwork.egressVirtualApplianceIp
    }
  }
  // Force Routes to Hub IPs (CGNAT range) via FW despite knowing that route via peering
  {
    name: 'PrdSpokesUdrHubRFC6598FWRoute'
    properties: {
      addressPrefix: hubNetwork.rfc6598IPRange
      nextHopType: 'VirtualAppliance'
      nextHopIpAddress: hubNetwork.egressVirtualApplianceIp
    }
  }
  {
    name: 'RouteToEgressFirewall'
    properties: {
      addressPrefix: '0.0.0.0/0'
      nextHopType: 'VirtualAppliance'
      nextHopIpAddress: hubNetwork.egressVirtualApplianceIp
    }
  }
]

// Merge the required and optional subnets into a single array and use this array to create the resources
var requiredSubnets = [
  network.subnets.oz
  network.subnets.paz
  network.subnets.rz
  network.subnets.hrz
]

var allSubnets = union(requiredSubnets, network.subnets.optional)

// Network Security Groups
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = [for subnet in allSubnets: if (subnet.nsg.enabled) {
  name: '${subnet.name}Nsg'
  location: resourceGroup().location
  properties: {
    securityRules: []
  }
}]

// Route Tables
resource udr 'Microsoft.Network/routeTables@2021-02-01' = [for subnet in allSubnets: if (subnet.udr.enabled) {
  name: '${subnet.name}Udr'
  location: resourceGroup().location
  properties: {
    routes: network.peerToHubVirtualNetwork ? routesToHub : null
  }
}]

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: network.name
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: network.addressPrefixes
    }
    subnets: [for (subnet, i) in allSubnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        networkSecurityGroup: (subnet.nsg.enabled) ? {
          id: nsg[i].id
        } : null
        routeTable: (subnet.udr.enabled) ? {
          id: udr[i].id
        } : null
        delegations: contains(subnet, 'delegations') ? [
          {
            name: replace(subnet.delegations.serviceName, '/', '.')
            properties: {
              serviceName: subnet.delegations.serviceName
            }
          }
        ] : null
      }
    }]
  }
}

// Virtual Network Peering - Spoke to Hub
module vnetPeeringSpokeToHub '../../azresources/network/vnet-peering.bicep' = if (network.peerToHubVirtualNetwork) {
  name: 'deploy-vnet-peering-spoke-to-hub'
  scope: resourceGroup()
  params: {
    peeringName: 'Hub-${vnet.name}-to-${last(hubVnetIdSplit)}'
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    sourceVnetName: vnet.name
    targetVnetId: hubNetwork.virtualNetworkId
    useRemoteGateways: network.useRemoteGateway
  }
}

// Virtual Network Peering - Hub to Spoke
// We must rescope the deployment to the subscription id & resource group of where the Hub VNET is located.
module vnetPeeringHubToSpoke '../../azresources/network/vnet-peering.bicep' = if (network.peerToHubVirtualNetwork) {
  name: 'deploy-vnet-peering-${subscription().subscriptionId}'
  // vnet id = /subscriptions/<<SUBSCRIPTION ID>>/resourceGroups/<<RESOURCE GROUP>>/providers/Microsoft.Network/virtualNetworks/<<VNET NAME>>
  scope: resourceGroup(network.peerToHubVirtualNetwork ? hubVnetIdSplit[2] : '', network.peerToHubVirtualNetwork ? hubVnetIdSplit[4] : '')
  params: {
    peeringName: 'Spoke-${last(hubVnetIdSplit)}-to-${vnet.name}-${uniqueString(vnet.id)}'
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    sourceVnetName: last(hubVnetIdSplit)
    targetVnetId: vnet.id
    useRemoteGateways: false
  }
}

// Outputs
output vnetId string = vnet.id
output vnetName string = vnet.name
output vnetPeered bool = network.peerToHubVirtualNetwork

output ozSubnetId string = '${vnet.id}/subnets/${network.subnets.oz.name}'
output pazSubnetId string = '${vnet.id}/subnets/${network.subnets.paz.name}'
output rzSubnetId string = '${vnet.id}/subnets/${network.subnets.rz.name}'
output hrzSubnetId string = '${vnet.id}/subnets/${network.subnets.hrz.name}'

output optionalSubnets array = [for subnet in network.subnets.optional: {
  'id': '${vnet.id}/subnets/${subnet.name}'
}]
