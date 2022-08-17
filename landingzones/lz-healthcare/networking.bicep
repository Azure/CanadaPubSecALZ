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
//       "databricksPublic": {
//         "comments": "Databricks Public Delegated Subnet",
//         "name": "databrickspublic",
//         "addressPrefix": "10.2.6.0/25"
//       },
//       "databricksPrivate": {
//         "comments": "Databricks Private Delegated Subnet",
//         "name": "databricksprivate",
//         "addressPrefix": "10.2.7.0/25"
//       },
//       "web": {
//         "comments": "Azure Web App Delegated Subnet",
//         "name": "webapp",
//         "addressPrefix": "10.2.8.0/25"
//       },
//       "optional": [
//           {
//          "comments": "Optional Subnet 1",
//          "name": "virtualMachines",
//          "addressPrefix": "10.2.9.0/25",
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
//          "addressPrefix": "10.2.10.0/25",
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
//     databricksPublic: {
//       comments: 'Databricks Public Delegated Subnet'
//       name: 'databrickspublic'
//       addressPrefix: '10.2.5.0/25'
//     }
//     databricksPrivate: {
//       comments: 'Databricks Private Delegated Subnet'
//       name: 'databricksprivate'
//       addressPrefix: '10.2.6.0/25'
//     }
//     privateEndpoints: {
//       comments: 'Private Endpoints Subnet'
//       name: 'privateendpoints'
//       addressPrefix: '10.2.7.0/25'
//     }
//     web: {
//       comments: 'Azure Web App Delegated Subnet'
//       name: 'webapp'
//       addressPrefix: '10.2.8.0/25'
//     }
//     optional: [
//      {
//        comments: 'Optional Subnet 1'
//        name: 'virtualMachines'
//        addressPrefix: '10.2.9.0/25'
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
//        addressPrefix: '10.2.10.0/25'
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
@description('Network configuration.  Includes peerToHubVirtualNetwork flag, useRemoteGateway flag, name, dnsServers, addressPrefixes and subnets (privateEndpoints, databricksPublic, databricksPrivate, web, optional [array of optional subnets]).')
param network object

var hubVnetIdSplit = split(hubNetwork.virtualNetworkId, '/')
var usingCustomDNSServers = length(network.dnsServers) > 0

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

module nsgPrivateEndpoints '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-private-endpoints'
  params: {
    name: '${network.subnets.privateEndpoints.name}Nsg'
    location: location
  }
}

module nsgDatabricks '../../azresources/network/nsg/nsg-databricks.bicep' = {
  name: 'deploy-nsg-databricks'
  params: {
    namePublic: '${network.subnets.databricksPublic.name}Nsg'
    namePrivate: '${network.subnets.databricksPrivate.name}Nsg'
    location: location
  }
}

// Network security groups (NSGs): You can block outbound traffic with an NSG that's placed on your integration subnet.
// The inbound rules don't apply because you can't use VNet Integration to provide inbound access to your app.
// At the moment, there are no outbound rules to block outbound traffic
// See https://docs.microsoft.com/azure/app-service/web-sites-integrate-with-vnet#regional-vnet-integration
module nsgWebApp '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-webapp'
  params: {
    name: '${network.subnets.web.name}Nsg'
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

module udrDatabricksPublic '../../azresources/network/udr/udr-databricks-public.bicep' = {
  name: 'deploy-route-table-databricks-public'
  params: {
    name: '${network.subnets.databricksPublic.name}Udr'
    location: location
  }
}

module udrDatabricksPrivate '../../azresources/network/udr/udr-databricks-private.bicep' = {
  name: 'deploy-route-table-databricks-private'
  params: {
    name: '${network.subnets.databricksPrivate.name}Udr'
    location: location
  }
}

// Route tables (UDRs): You can place a route table on the integration subnet to send outbound traffic where you want.
// At the moment, the route table is empty but rules can be added to force tunnel.
// See https://docs.microsoft.com/azure/app-service/web-sites-integrate-with-vnet#regional-vnet-integration
module udrWebApp '../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-web-app'
  params: {
    name: '${network.subnets.web.name}Udr'
    routes: []
    location: location
  }
}

// Virtual Network
var requiredSubnets = [
  {
    name: network.subnets.privateEndpoints.name
    properties: {
      addressPrefix: network.subnets.privateEndpoints.addressPrefix
      privateEndpointNetworkPolicies: 'Enabled'
      networkSecurityGroup: {
        id: nsgPrivateEndpoints.outputs.nsgId
      }
      serviceEndpoints: [
        {
          service: 'Microsoft.Storage'
        }
      ]
    }
  }
  {
    name: network.subnets.web.name
    properties: {
      addressPrefix: network.subnets.web.addressPrefix
      networkSecurityGroup: {
        id: nsgWebApp.outputs.nsgId
      }
      routeTable: {
        id: udrWebApp.outputs.udrId
      }
      delegations: [
        {
          name: 'webapp'
          properties: {
            serviceName: 'Microsoft.Web/serverFarms'
          }
        }
      ]
    }
  }
  {
    name: network.subnets.databricksPublic.name
    properties: {
      addressPrefix: network.subnets.databricksPublic.addressPrefix
      networkSecurityGroup: {
        id: nsgDatabricks.outputs.publicNsgId
      }
      routeTable: {
        id: udrDatabricksPublic.outputs.udrId
      }
      delegations: [
        {
          name: 'databricks-delegation-public'
          properties: {
            serviceName: 'Microsoft.Databricks/workspaces'
          }
        }
      ]
    }
  }
  {
    name: network.subnets.databricksPrivate.name
    properties: {
      addressPrefix: network.subnets.databricksPrivate.addressPrefix
      networkSecurityGroup: {
        id: nsgDatabricks.outputs.privateNsgId
      }
      routeTable: {
        id: udrDatabricksPrivate.outputs.udrId
      }
      delegations: [
        {
          name: 'databricks-delegation-private'
          properties: {
            serviceName: 'Microsoft.Databricks/workspaces'
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

var allSubnets = union(requiredSubnets, optionalSubnets)

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

// Private DNS Zones
module privatezone_sqldb '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-sqldb'
  scope: resourceGroup()
  params: {
    zone: 'privatelink${environment().suffixes.sqlServerHostname}'
    vnetId: vnet.id

    dnsCreateNewZone: !hubNetwork.privateDnsManagedByHub
    dnsLinkToVirtualNetwork: !hubNetwork.privateDnsManagedByHub || (hubNetwork.privateDnsManagedByHub && !usingCustomDNSServers)
    dnsExistingZoneSubscriptionId: hubNetwork.privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: hubNetwork.privateDnsManagedByHubResourceGroupName
    registrationEnabled: false
  }
}

module privatezone_adf_datafactory '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-adf-datafactory'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.datafactory.azure.net'
    vnetId: vnet.id

    dnsCreateNewZone: !hubNetwork.privateDnsManagedByHub
    dnsLinkToVirtualNetwork: !hubNetwork.privateDnsManagedByHub || (hubNetwork.privateDnsManagedByHub && !usingCustomDNSServers)
    dnsExistingZoneSubscriptionId: hubNetwork.privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: hubNetwork.privateDnsManagedByHubResourceGroupName
    registrationEnabled: false
  }
}

module privatezone_keyvault '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-keyvault'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.vaultcore.azure.net'
    vnetId: vnet.id

    dnsCreateNewZone: !hubNetwork.privateDnsManagedByHub
    dnsLinkToVirtualNetwork: !hubNetwork.privateDnsManagedByHub || (hubNetwork.privateDnsManagedByHub && !usingCustomDNSServers)
    dnsExistingZoneSubscriptionId: hubNetwork.privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: hubNetwork.privateDnsManagedByHubResourceGroupName
    registrationEnabled: false
  }
}

module privatezone_acr '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-acr'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.azurecr.io'
    vnetId: vnet.id

    dnsCreateNewZone: !hubNetwork.privateDnsManagedByHub
    dnsLinkToVirtualNetwork: !hubNetwork.privateDnsManagedByHub || (hubNetwork.privateDnsManagedByHub && !usingCustomDNSServers)
    dnsExistingZoneSubscriptionId: hubNetwork.privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: hubNetwork.privateDnsManagedByHubResourceGroupName
    registrationEnabled: false
  }
}

module privatezone_datalake_blob '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-blob'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.blob.${environment().suffixes.storage}'
    vnetId: vnet.id

    dnsCreateNewZone: !hubNetwork.privateDnsManagedByHub
    dnsLinkToVirtualNetwork: !hubNetwork.privateDnsManagedByHub || (hubNetwork.privateDnsManagedByHub && !usingCustomDNSServers)
    dnsExistingZoneSubscriptionId: hubNetwork.privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: hubNetwork.privateDnsManagedByHubResourceGroupName
    registrationEnabled: false
  }
}

module privatezone_datalake_dfs '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-dfs'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.dfs.${environment().suffixes.storage}'
    vnetId: vnet.id

    dnsCreateNewZone: !hubNetwork.privateDnsManagedByHub
    dnsLinkToVirtualNetwork: !hubNetwork.privateDnsManagedByHub || (hubNetwork.privateDnsManagedByHub && !usingCustomDNSServers)
    dnsExistingZoneSubscriptionId: hubNetwork.privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: hubNetwork.privateDnsManagedByHubResourceGroupName
    registrationEnabled: false
  }
}

module privatezone_datalake_file '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-file'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.file.${environment().suffixes.storage}'
    vnetId: vnet.id

    dnsCreateNewZone: !hubNetwork.privateDnsManagedByHub
    dnsLinkToVirtualNetwork: !hubNetwork.privateDnsManagedByHub || (hubNetwork.privateDnsManagedByHub && !usingCustomDNSServers)
    dnsExistingZoneSubscriptionId: hubNetwork.privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: hubNetwork.privateDnsManagedByHubResourceGroupName
    registrationEnabled: false
  }
}

module privatezone_azureml_api '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-azureml-api'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.api.azureml.ms'
    vnetId: vnet.id

    dnsCreateNewZone: !hubNetwork.privateDnsManagedByHub
    dnsLinkToVirtualNetwork: !hubNetwork.privateDnsManagedByHub || (hubNetwork.privateDnsManagedByHub && !usingCustomDNSServers)
    dnsExistingZoneSubscriptionId: hubNetwork.privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: hubNetwork.privateDnsManagedByHubResourceGroupName
    registrationEnabled: false
  }
}

module privatezone_azureml_notebook '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-azureml-notebook'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.notebooks.azure.net'
    vnetId: vnet.id

    dnsCreateNewZone: !hubNetwork.privateDnsManagedByHub
    dnsLinkToVirtualNetwork: !hubNetwork.privateDnsManagedByHub || (hubNetwork.privateDnsManagedByHub && !usingCustomDNSServers)
    dnsExistingZoneSubscriptionId: hubNetwork.privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: hubNetwork.privateDnsManagedByHubResourceGroupName
    registrationEnabled: false
  }
}

module privatezone_fhir '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-fhir'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.azurehealthcareapis.com'
    vnetId: vnet.id

    dnsCreateNewZone: !hubNetwork.privateDnsManagedByHub
    dnsLinkToVirtualNetwork: !hubNetwork.privateDnsManagedByHub || (hubNetwork.privateDnsManagedByHub && !usingCustomDNSServers)
    dnsExistingZoneSubscriptionId: hubNetwork.privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: hubNetwork.privateDnsManagedByHubResourceGroupName
    registrationEnabled: false
  }
}

module privatezone_eventhub '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-eventhub'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.servicebus.windows.net'
    vnetId: vnet.id

    dnsCreateNewZone: !hubNetwork.privateDnsManagedByHub
    dnsLinkToVirtualNetwork: !hubNetwork.privateDnsManagedByHub || (hubNetwork.privateDnsManagedByHub && !usingCustomDNSServers)
    dnsExistingZoneSubscriptionId: hubNetwork.privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: hubNetwork.privateDnsManagedByHubResourceGroupName
    registrationEnabled: false
  }
}

module privatezone_synapse '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-synapse'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.azuresynapse.net'
    vnetId: vnet.id

    dnsCreateNewZone: !hubNetwork.privateDnsManagedByHub
    dnsLinkToVirtualNetwork: !hubNetwork.privateDnsManagedByHub || (hubNetwork.privateDnsManagedByHub && !usingCustomDNSServers)
    dnsExistingZoneSubscriptionId: hubNetwork.privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: hubNetwork.privateDnsManagedByHubResourceGroupName
    registrationEnabled: false
  }
}

module privatezone_synapse_dev '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-synapse-dev'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.dev.azuresynapse.net'
    vnetId: vnet.id

    dnsCreateNewZone: !hubNetwork.privateDnsManagedByHub
    dnsLinkToVirtualNetwork: !hubNetwork.privateDnsManagedByHub || (hubNetwork.privateDnsManagedByHub && !usingCustomDNSServers)
    dnsExistingZoneSubscriptionId: hubNetwork.privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: hubNetwork.privateDnsManagedByHubResourceGroupName
    registrationEnabled: false
  }
}

module privatezone_synapse_sql '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-synapse-sql'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.sql.azuresynapse.net'
    vnetId: vnet.id

    dnsCreateNewZone: !hubNetwork.privateDnsManagedByHub
    dnsLinkToVirtualNetwork: !hubNetwork.privateDnsManagedByHub || (hubNetwork.privateDnsManagedByHub && !usingCustomDNSServers)
    dnsExistingZoneSubscriptionId: hubNetwork.privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: hubNetwork.privateDnsManagedByHubResourceGroupName
    registrationEnabled: false
  }
}

output vnetId string = vnet.id

output privateEndpointSubnetId string = '${vnet.id}/subnets/${network.subnets.privateEndpoints.name}'
output webAppSubnetId string = '${vnet.id}/subnets/${network.subnets.web.name}'

output databricksPublicSubnetName string = network.subnets.databricksPublic.name
output databricksPrivateSubnetName string = network.subnets.databricksPrivate.name

output dataLakeDfsPrivateDnsZoneId string = privatezone_datalake_dfs.outputs.privateDnsZoneId
output dataLakeBlobPrivateDnsZoneId string = privatezone_datalake_blob.outputs.privateDnsZoneId
output dataLakeFilePrivateDnsZoneId string = privatezone_datalake_file.outputs.privateDnsZoneId
output adfDataFactoryPrivateDnsZoneId string = privatezone_adf_datafactory.outputs.privateDnsZoneId
output keyVaultPrivateDnsZoneId string = privatezone_keyvault.outputs.privateDnsZoneId
output acrPrivateDnsZoneId string = privatezone_acr.outputs.privateDnsZoneId
output sqlDBPrivateDnsZoneId string = privatezone_sqldb.outputs.privateDnsZoneId
output amlApiPrivateDnsZoneId string = privatezone_azureml_api.outputs.privateDnsZoneId
output amlNotebooksPrivateDnsZoneId string = privatezone_azureml_notebook.outputs.privateDnsZoneId
output fhirPrivateDnsZoneId string = privatezone_fhir.outputs.privateDnsZoneId
output eventhubPrivateDnsZoneId string = privatezone_eventhub.outputs.privateDnsZoneId
output synapsePrivateDnsZoneId string = privatezone_synapse.outputs.privateDnsZoneId
output synapseDevPrivateDnsZoneId string = privatezone_synapse_dev.outputs.privateDnsZoneId
output synapseSqlPrivateDnsZoneId string = privatezone_synapse_sql.outputs.privateDnsZoneId
