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
//       "virtualNetworkId": "/subscriptions/ed7f4eed-9010-4227-b115-2a5e37728f27/resourceGroups/pubsec-hub-networking/providers/Microsoft.Network/virtualNetworks/hub-vnet",
//       "rfc1918IPRange": "10.18.0.0/22",
//       "rfc6598IPRange": "100.60.0.0/16",
//       "egressVirtualApplianceIp": "10.18.0.36",
//       "privateDnsManagedByHub": true,
//       "privateDnsManagedByHubSubscriptionId": "ed7f4eed-9010-4227-b115-2a5e37728f27",
//       "privateDnsManagedByHubResourceGroupName": "pubsec-dns"
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   virtualNetworkId: '/subscriptions/ed7f4eed-9010-4227-b115-2a5e37728f27/resourceGroups/pubsec-hub-networking/providers/Microsoft.Network/virtualNetworks/hub-vnet'
//   rfc1918IPRange: '10.18.0.0/22'
//   rfc6598IPRange: '100.60.0.0/16'
//   egressVirtualApplianceIp: '10.18.0.36'
//   privateDnsManagedByHub: true,
//   privateDnsManagedByHubSubscriptionId: 'ed7f4eed-9010-4227-b115-2a5e37728f27',
//   privateDnsManagedByHubResourceGroupName: 'pubsec-dns'
// }
@description('Hub Network configuration that includes virtualNetworkId, rfc1918IPRange, rfc6598IPRange, egressVirtualApplianceIp, privateDnsManagedByHub flag, privateDnsManagedByHubSubscriptionId and privateDnsManagedByHubResourceGroupName.')
param hubNetwork object

// Example (JSON)
// -----------------------------
// "network": {
//   "value": {
//     "peerToHubVirtualNetwork": true,
//     "useRemoteGateway": false,
//     "name": "vnet",
//     "dnsServers": [
//       "10.18.1.4"
//     ],
//     "addressPrefixes": [
//       "10.2.0.0/16"
//     ],
//     "subnets": {
//       "privateEndpoints": {
//         "comments": "Private Endpoints Subnet",
//         "name": "privateendpoints",
//         "addressPrefix": "10.2.5.0/25"
//       },
//       "sqlmi": {
//         "comments": "SQL Managed Instances Delegated Subnet",
//         "name": "sqlmi",
//         "addressPrefix": "10.2.6.0/25"
//       },
//       "databricksPublic": {
//         "comments": "Databricks Public Delegated Subnet",
//         "name": "databrickspublic",
//         "addressPrefix": "10.2.7.0/25"
//       },
//       "databricksPrivate": {
//         "comments": "Databricks Private Delegated Subnet",
//         "name": "databricksprivate",
//         "addressPrefix": "10.2.8.0/25"
//       },
//       "aks": {
//         "comments": "AKS Subnet",
//         "name": "aks",
//         "addressPrefix": "10.2.9.0/25"
//       },
//       "appService": {
//         "comments": "App Service Subnet",
//         "name": "appService",
//         "addressPrefix": "10.2.10.0/25"
//       }
//       "optional": [
//           {
//          "comments": "Optional Subnet 1",
//          "name": "virtualMachines",
//          "addressPrefix": "10.6.11.0/25",
//          "nsg": {
//            "enabled": true
//          },
//          "udr": {
//            "enabled": true
//          }
//        },
//        {
//          "comments": "Optional Subnet 2 with delegation for NetApp Volumes",
//          "name": "NetappVolumes",
//          "addressPrefix": "10.6.12.0/25",
//          "nsg": {
//            "enabled": false
//          },
//          "udr": {
//            "enabled": false
//          },
//          "delegations": {
//              "serviceName": "Microsoft.NetApp/volumes"
//          }
//        }
//      ]
//     }
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   peerToHubVirtualNetwork: true
//   useRemoteGateway: false
//   name: 'vnet'
//   dnsServers: [
//     '10.18.1.4'
//   ]
//   addressPrefixes: [
//     '10.2.0.0/16'
//   ]
//   subnets: {
//     privateEndpoints: {
//       comments: 'Private Endpoints Subnet'
//       name: 'privateendpoints'
//       addressPrefix: '10.2.5.0/25'
//     }
//     sqlmi: {
//       comments: 'SQL Managed Instances Delegated Subnet'
//       name: 'sqlmi'
//       addressPrefix: '10.2.6.0/25'
//     }
//     databricksPublic: {
//       comments: 'Databricks Public Delegated Subnet'
//       name: 'databrickspublic'
//       addressPrefix: '10.2.7.0/25'
//     }
//     databricksPrivate: {
//       comments: 'Databricks Private Delegated Subnet'
//       name: 'databricksprivate'
//       addressPrefix: '10.2.8.0/25'
//     }
//     aks: {
//       comments: 'AKS Subnet'
//       name: 'aks'
//       addressPrefix: '10.2.9.0/25'
//     }
//     appService: {
//       comments: 'App Service Subnet'
//       name: 'appService'
//       addressPrefix: '10.2.10.0/25'
//     }
//     optional: [
//      {
//        comments: 'Optional Subnet 1'
//        name: 'virtualMachines'
//        addressPrefix: '10.6.11.0/25'
//        nsg: {
//          enabled: true
//        },
//        udr: {
//          enabled: true
//        }
//      },
//      {
//        comments: 'Optional Subnet 2 with delegation for NetApp Volumes',
//        name: 'NetappVolumes'
//        addressPrefix: '10.6.12.0/25'
//        nsg: {
//          enabled: false
//        },
//        udr: {
//          enabled: false
//        },
//        delegations: {
//            serviceName: 'Microsoft.NetApp/volumes'
//        }
//      }
//    ]
//   }
// }
@description('Network configuration for the spoke virtual network.  It includes name, dnsServers, address spaces, vnet peering and subnets.')
param network object

@description('Get the DNS Private Resolver enabled/disabled setting so the associated subnets can be optionally deployed based on the value.')
param deployDNSResolver object

var hubVnetIdSplit = split(hubNetwork.virtualNetworkId, '/')


var routesToHub = [
  // Force Routes to Hub IPs (RFC1918 range) via FW despite knowing that route via peering
  {
    name: 'SpokeUdrHubRFC1918FWRoute'
    properties: {
      addressPrefix: hubNetwork.rfc1918IPRange
      nextHopType: 'VirtualAppliance'
      nextHopIpAddress: hubNetwork.egressVirtualApplianceIp
    }
  }
  // Force Routes to Hub IPs (CGNAT range) via FW despite knowing that route via peering
  {
    name: 'SpokeUdrHubRFC6598FWRoute'
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

// Network Security Groups
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = [for subnet in network.subnets.optional: if (subnet.nsg.enabled) {
  name: '${subnet.name}Nsg'
  location: location
  properties: {
    securityRules: []
  }
}]

module nsgDomainControllers '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-DomainControllers'
  params: {
    name: '${network.subnets.domainControllers.name}Nsg'
    location: location
  }
}

module nsgDnsResolverInbound '../../azresources/network/nsg/nsg-empty.bicep' = if (deployDNSResolver.enabled) {
  name: 'deploy-nsg-dnsResolverInbound'
  params: {
    name: '${network.subnets.dnsResolverInbound.name}Nsg'
    location: location
  }
}

module nsgDnsResolverOutbound '../../azresources/network/nsg/nsg-empty.bicep' = if (deployDNSResolver.enabled) {
  name: 'deploy-nsg-dnsResolverOutbound'
  params: {
    name: '${network.subnets.dnsResolverOutbound.name}Nsg'
    location: location
  }
}

// Route Tables
resource udr 'Microsoft.Network/routeTables@2021-02-01' = {
  name: 'RouteTable'
  location: location
  properties: {
    routes: network.peerToHubVirtualNetwork ? routesToHub : null
  }
}

// Virtual Network
var requiredSubnets = [
  {
    name: network.subnets.domainControllers.name
    properties: {
      addressPrefix: network.subnets.domainControllers.addressPrefix
      privateEndpointNetworkPolicies: 'Enabled'
      routeTable: {
        id: udr.id
      }
      networkSecurityGroup: {
        id: nsgDomainControllers.outputs.nsgId
      }
    }
  }
]

var dnsResolverSubnets = [
  {
    name: network.subnets.dnsResolverInbound.name
    properties: {
      addressPrefix: network.subnets.dnsResolverInbound.addressPrefix
      privateEndpointNetworkPolicies: 'Enabled'
      routeTable: {
        id: udr.id
      }
      networkSecurityGroup: {
        id: nsgDnsResolverInbound.outputs.nsgId
      }
      delegations: [
        {
          name: 'delAzureDNSResolverInbound'
          properties: {
            serviceName: 'Microsoft.Network/dnsResolvers'
          }
        }
      ]
    }
  }

  {
    name: network.subnets.dnsResolverOutbound.name
    properties: {
      addressPrefix: network.subnets.dnsResolverOutbound.addressPrefix
      privateEndpointNetworkPolicies: 'Enabled'
      routeTable: {
        id: udr.id
      }
      networkSecurityGroup: {
        id: nsgDnsResolverOutbound.outputs.nsgId
      }
      delegations: [
        {
          name: 'delAzureDNSResolverOutbound'
          properties: {
            serviceName: 'Microsoft.Network/dnsResolvers'
          }
        }
      ]
    }
  }
]

var optionalSubnets = [for (subnet, i) in network.subnets.optional: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.addressPrefix
    networkSecurityGroup: (subnet.nsg.enabled) ? {
      id: nsg[i].id
    } : null
    routeTable: (subnet.udr.enabled) ? {
      id: udr.id
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

//Optionally add DNS Resolver subnets based on if the deployDNSResolver parameter is set to true
var allSubnets = deployDNSResolver.enabled ? union(requiredSubnets, optionalSubnets, dnsResolverSubnets) : union(requiredSubnets, optionalSubnets)


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
    subnets: allSubnets
  }
}

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

// For Hub to Spoke vnet peering, we must rescope the deployment to the subscription id & resource group of where the Hub VNET is located.
module vnetPeeringHubToSpoke '../../azresources/network/vnet-peering.bicep' = if (network.peerToHubVirtualNetwork) {
  name: 'deploy-vnet-peering-${subscription().subscriptionId}'
  scope: resourceGroup(network.peerToHubVirtualNetwork ? hubVnetIdSplit[2] : '', network.peerToHubVirtualNetwork ? hubVnetIdSplit[4] : '')
  params: {
    peeringName: 'Spoke-${last(hubVnetIdSplit)}-to-${vnet.name}-${uniqueString(vnet.id)}'
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    allowGatewayTransit: true
    sourceVnetName: last(hubVnetIdSplit)!
    targetVnetId: vnet.id
    useRemoteGateways: false
  }
}





output vnetId string = vnet.id
output vnetName string = vnet.name
