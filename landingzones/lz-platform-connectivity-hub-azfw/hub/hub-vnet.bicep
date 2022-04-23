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

@description('Hub Virtual network configuration.  See docs/archetypes/hubnetwork-azfw.md for configuration settings.')
param hubNetwork object

// Public Access Zone Route Table (i.e. Application Gateways)
@description('Public Access Zone (i.e. Application Gateway) Route Table Resource Id.')
param pazUdrId string

// Common Route Table
@description('Route Table Resource Id for optional subnets in Hub Virtual Network')
param hubUdrId string

@description('Azure Firewall is deployed in Forced Tunneling mode where a route table must be added as the next hop.')
param azureFirewallForcedTunnelingEnabled bool

@description('Next Hop for AzureFirewallSubnet when Azure Firewall is deployed in forced tunneling mode.')
param azureFirewallForcedTunnelingNextHop string

// DDOS
@description('DDoS Standard Plan Resource Id.')
param ddosStandardPlanId string

var azureFirewallForcedTunnelRoutes = [
  {
    name: 'AzureFirewall-Default-Route'
    properties: {
      nextHopType: 'VirtualAppliance'
      addressPrefix: '0.0.0.0/0'
      nextHopIpAddress: azureFirewallForcedTunnelingNextHop
    }
  }
]

var requiredSubnets = [
  {
    name: hubNetwork.subnets.publicAccess.name
    properties: {
      addressPrefix: hubNetwork.subnets.publicAccess.addressPrefix
      networkSecurityGroup: {
        id: publicAccessZoneNsg.outputs.nsgId
      }
      routeTable: {
        id: pazUdrId
      }
    }
  }
  {
    name: hubNetwork.subnets.firewall.name
    properties: {
      addressPrefix: hubNetwork.subnets.firewall.addressPrefix
      routeTable: azureFirewallForcedTunnelingEnabled ? {
        id: azureFirewallSubnetUdr.outputs.udrId
      } : null
    }
  }
  {
    name: hubNetwork.subnets.firewallManagement.name
    properties: {
      addressPrefix: hubNetwork.subnets.firewallManagement.addressPrefix
    }
  }
  {
    name: hubNetwork.subnets.bastion.name
    properties: {
      addressPrefix: hubNetwork.subnets.bastion.addressPrefix
      networkSecurityGroup: {
        id: bastionNsg.outputs.nsgId
      }
    }
  }
  {
    name: hubNetwork.subnets.gateway.name
    properties: {
      addressPrefix: hubNetwork.subnets.gateway.addressPrefix
    }
  }
]

var optionalSubnets = [for (subnet, i) in hubNetwork.subnets.optional: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.addressPrefix
    networkSecurityGroup: (subnet.nsg.enabled) ? {
      id: nsg[i].id
    } : null
    routeTable: (subnet.udr.enabled) ? {
      id: hubUdrId
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

// Network Security Groups
module publicAccessZoneNsg '../../../azresources/network/nsg/nsg-appgwv2.bicep' = {
  name: 'deploy-nsg-${hubNetwork.subnets.publicAccess.name}Nsg'
  params: {
    name: '${hubNetwork.subnets.publicAccess.name}Nsg'
    location: location
  }
}

module bastionNsg '../../../azresources/network/nsg/nsg-bastion.bicep' = {
  name: 'deploy-nsg-AzureBastionNsg'
  params: {
    name: 'AzureBastionNsg'
    location: location
  }
}

// Network Security Group
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = [for subnet in hubNetwork.subnets.optional: if (subnet.nsg.enabled) {
  name: '${subnet.name}Nsg'
  location: location
  properties: {
    securityRules: []
  }
}]

// Route Tables
module azureFirewallSubnetUdr '../../../azresources/network/udr/udr-custom.bicep' = if (azureFirewallForcedTunnelingEnabled) {
  name: 'deploy-route-table-AzureFirewallSubnet'
  params: {
    name: 'AzureFirewallSubnetUdr'
    routes: azureFirewallForcedTunnelRoutes
    location: location
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  location: location
  name: hubNetwork.name
  properties: {
    enableDdosProtection: !empty(ddosStandardPlanId)
    ddosProtectionPlan: (!empty(ddosStandardPlanId)) ? {
      id: ddosStandardPlanId
    } : null
    addressSpace: {
      addressPrefixes: union(hubNetwork.addressPrefixes, array(hubNetwork.addressPrefixBastion))
    }
    subnets: allSubnets
  }
}

output vnetName string = vnet.name
output vnetId string = vnet.id

output publicAccessZoneSubnetId string = '${vnet.id}/subnets/${hubNetwork.subnets.publicAccess.name}'

output GatewaySubnetId string = '${vnet.id}/subnets/${hubNetwork.subnets.gateway.name}'
output AzureBastionSubnetId string = '${vnet.id}/subnets/${hubNetwork.subnets.bastion.name}'
output AzureFirewallSubnetId string = '${vnet.id}/subnets/${hubNetwork.subnets.firewall.name}'
output AzureFirewallManagementSubnetId string = '${vnet.id}/subnets/${hubNetwork.subnets.firewallManagement.name}'
