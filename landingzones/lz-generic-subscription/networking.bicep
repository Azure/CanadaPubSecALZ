// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Location for the deployment.')
param location string = resourceGroup().location

// Networking
// Example (JSON)
// -----------------------------
// "hubNetwork": {
//   "value": {
//       "virtualNetworkId": "/subscriptions/ed7f4eed-9010-4227-b115-2a5e37728f27/resourceGroups/pubsec-hub-networking-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet",
//       "rfc1918IPRange": "10.18.0.0/22",
//       "rfc6598IPRange": "100.60.0.0/16",
//       "egressVirtualApplianceIp": "10.18.0.36"
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   virtualNetworkId: '/subscriptions/ed7f4eed-9010-4227-b115-2a5e37728f27/resourceGroups/pubsec-hub-networking-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet'
//   rfc1918IPRange: '10.18.0.0/22'
//   rfc6598IPRange: '100.60.0.0/16'
//   egressVirtualApplianceIp: '10.18.0.36'
// }
@description('Hub Network configuration that includes virtualNetworkId, rfc1918IPRange, rfc6598IPRange and egressVirtualApplianceIp.')
param hubNetwork object

// Example (JSON)
// -----------------------------
// "network": {
//   "value": {
//       "deployVnet": true,
//
//       "peerToHubVirtualNetwork": true,
//       "useRemoteGateway": false,
//
//       "name": "vnet",
//       "dnsServers": [
//          "10.18.1.4"
//       ],
//       "addressPrefixes": [
//           "10.2.0.0/16"
//       ],
//       "subnets": {
//           "oz": {
//               "comments": "App Management Zone (OZ)",
//               "name": "oz",
//               "addressPrefix": "10.2.1.0/25",
//               "nsg": {
//                   "enabled": true
//               },
//               "udr": {
//                   "enabled": true
//               }
//           },
//           "paz": {
//               "comments": "Presentation Zone (PAZ)",
//               "name": "paz",
//               "addressPrefix": "10.2.2.0/25",
//               "nsg": {
//                   "enabled": true
//               },
//               "udr": {
//                   "enabled": true
//               }
//           },
//           "rz": {
//               "comments": "Application Zone (RZ)",
//               "name": "rz",
//               "addressPrefix": "10.2.3.0/25",
//               "nsg": {
//                   "enabled": true
//               },
//               "udr": {
//                   "enabled": true
//               }
//           },
//           "hrz": {
//               "comments": "Data Zone (HRZ)",
//               "name": "hrz",
//               "addressPrefix": "10.2.4.0/25",
//               "nsg": {
//                   "enabled": true
//               },
//               "udr": {
//                   "enabled": true
//               }
//           },
//           "optional": [
//               {
//                   "comments": "App Service",
//                   "name": "appservice",
//                   "addressPrefix": "10.2.5.0/25",
//                   "nsg": {
//                       "enabled": false
//                   },
//                   "udr": {
//                       "enabled": false
//                   },
//                   "delegations": {
//                       "serviceName": "Microsoft.Web/serverFarms"
//                   }
//               }
//           ]
//       }
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   deployVnet: true
//
//   peerToHubVirtualNetwork: true
//   useRemoteGateway: false
//
//   name: 'vnet'
//   dnsServers: [
//     '10.18.1.4'
//   ]
//   addressPrefixes: [
//     '10.2.0.0/16'
//   ]
//   subnets: {
//     oz: {
//       comments: 'App Management Zone (OZ)'
//       name: 'oz'
//       addressPrefix: '10.2.1.0/25'
//       nsg: {
//         enabled: true
//       }
//       udr: {
//         enabled: true
//       }
//     }
//     paz: {
//       comments: 'Presentation Zone (PAZ)'
//       name: 'paz'
//       addressPrefix: '10.2.2.0/25'
//       nsg: {
//         enabled: true
//       }
//       udr: {
//         enabled: true
//       }
//     }
//     rz: {
//       comments: 'Application Zone (RZ)'
//       name: 'rz'
//       addressPrefix: '10.2.3.0/25'
//       nsg: {
//         enabled: true
//       }
//       udr: {
//         enabled: true
//       }
//     }
//     hrz: {
//       comments: 'Data Zone (HRZ)'
//       name: 'hrz'
//       addressPrefix: '10.2.4.0/25'
//       nsg: {
//         enabled: true
//       }
//       udr: {
//         enabled: true
//       }
//     }
//     optional: [
//       {
//         comments: 'App Service'
//         name: 'appservice'
//         addressPrefix: '10.2.5.0/25'
//         nsg: {
//           enabled: false
//         }
//         udr: {
//           enabled: false
//         }
//         delegations: {
//           'serviceName: 'Microsoft.Web/serverFarms'
//         }
//       }
//     ]
//   }
// }
@description('Network configuration for the spoke virtual network.  It includes name, dnsServers, address spaces, vnet peering and subnets.')
param network object

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
  location: location
  properties: {
    securityRules: []
  }
}]

// Route Tables
resource udr 'Microsoft.Network/routeTables@2021-02-01' = [for subnet in allSubnets: if (subnet.udr.enabled) {
  name: '${subnet.name}Udr'
  location: location
  properties: {
    routes: network.peerToHubVirtualNetwork ? routesToHub : null
  }
}]

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: network.name
  location: location
  properties: {
    dhcpOptions: {
      dnsServers: network.dnsServers
    }
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
