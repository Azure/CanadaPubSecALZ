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
//       "egressVirtualApplianceIp": "10.18.0.36",
//       "privateDnsManagedByHub": true,
//       "privateDnsManagedByHubSubscriptionId": "ed7f4eed-9010-4227-b115-2a5e37728f27",
//       "privateDnsManagedByHubResourceGroupName": "pubsec-dns-rg"
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   virtualNetworkId: '/subscriptions/ed7f4eed-9010-4227-b115-2a5e37728f27/resourceGroups/pubsec-hub-networking-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet'
//   rfc1918IPRange: '10.18.0.0/22'
//   rfc6598IPRange: '100.60.0.0/16'
//   egressVirtualApplianceIp: '10.18.0.36'
//   privateDnsManagedByHub: true,
//   privateDnsManagedByHubSubscriptionId: 'ed7f4eed-9010-4227-b115-2a5e37728f27',
//   privateDnsManagedByHubResourceGroupName: 'pubsec-dns-rg'
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
@description('Network configuration.  Includes peerToHubVirtualNetwork flag, useRemoteGateway flag, name, dnsServers, addressPrefixes and subnets (privateEndpoints, sqlmi, databricksPublic, databricksPrivate, aks, appService, optional [array of optional subnets]).) ')
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

module nsgDatabricks '../../azresources/network/nsg/nsg-databricks.bicep' = {
  name: 'deploy-nsg-databricks'
  params: {
    namePublic: '${network.subnets.databricksPublic.name}Nsg'
    namePrivate: '${network.subnets.databricksPrivate.name}Nsg'
    location: location
  }
}

module nsgSqlMi '../../azresources/network/nsg/nsg-sqlmi.bicep' = {
  name: 'deploy-nsg-sqlmi'
  params: {
    name: '${network.subnets.sqlmi.name}Nsg'
    location: location
  }
}

module nsgAppService '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-app-service-integration'
  params: {
    name: '${network.subnets.appService.name}Nsg'
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

resource udrAKS 'Microsoft.Network/routeTables@2021-02-01' = {
  name: '${network.subnets.aks.name}Udr'
  location: location
  properties: {
    routes: network.peerToHubVirtualNetwork ? routesToHub : null
  }
}
module udrSqlMi '../../azresources/network/udr/udr-sqlmi.bicep' = {
  name: 'deploy-route-table-sqlmi'
  params: {
    name: '${network.subnets.sqlmi.name}Udr'
    location: location
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

module udrAppService '../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-app-service-integration'
  params: {
    name: '${network.subnets.appService.name}Udr'
    location: location
    routes: []
  }
}

// Virtual Network
var requiredSubnets = [
  {
    name: network.subnets.privateEndpoints.name
    properties: {
      addressPrefix: network.subnets.privateEndpoints.addressPrefix
      privateEndpointNetworkPolicies: 'Disabled'
    }
  }
  {
    name: network.subnets.aks.name
    properties: {
      addressPrefix: network.subnets.aks.addressPrefix
      routeTable: {
        id: udrAKS.id
      }
      privateEndpointNetworkPolicies: 'Disabled'
    }
  }
  {
    name: network.subnets.appService.name
    properties: {
      addressPrefix: network.subnets.appService.addressPrefix
      networkSecurityGroup: {
        id: nsgAppService.outputs.nsgId
      }
      routeTable: {
        id: udrAppService.outputs.udrId
      }
      delegations: [
        {
          name: 'app-service-delegation'
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
  {
    name: network.subnets.sqlmi.name
    properties: {
      addressPrefix: network.subnets.sqlmi.addressPrefix
      routeTable: {
        id: udrSqlMi.outputs.udrId
      }
      networkSecurityGroup: {
        id: nsgSqlMi.outputs.nsgId
      }
      serviceEndpoints: [
        {
          service: 'Microsoft.Storage'
        }
      ]
      delegations: [
        {
          name: 'sqlmi-delegation'
          properties: {
            serviceName: 'Microsoft.Sql/managedInstances'
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

module privatezone_as '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-as'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.azurewebsites.net'
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

module privatezone_aks '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-aks'
  scope: resourceGroup()
  params: {
    zone: toLower('privatelink.${location}.azmk8s.io')
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
output sqlMiSubnetId string = '${vnet.id}/subnets/${network.subnets.sqlmi.name}'
output aksSubnetId string = '${vnet.id}/subnets/${network.subnets.aks.name}'
output appServiceSubnetId string = '${vnet.id}/subnets/${network.subnets.appService.name}'

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
output aksPrivateDnsZoneId string = privatezone_aks.outputs.privateDnsZoneId
output asPrivateDnsZoneId string = privatezone_as.outputs.privateDnsZoneId

output aksUdrNAme string = udrAKS.name
