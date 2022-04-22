// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Location for the deployment.')
param location string = resourceGroup().location

param hubNetwork object

// Public Access Zone (i.e. Application Gateways)
@description('Public Access Zone (i.e. Application Gateway) User Defined Route Resource Id.')
param pazUdrId string

@description('Azure Firewall is deployed in Forced Tunneling mode where a route table must be added as the next hop.')
param azureFirewallForcedTunnelingEnabled bool

@description('Next Hop for AzureFirewallSubnet when Azure Firewall is deployed in forced tunneling mode.')
param azureFirewallForcedTunnelingNextHop string

// DDOS
param ddosStandardPlanId string

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

var subnets = [
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
    subnets: subnets
  }
}

output vnetName string = vnet.name
output vnetId string = vnet.id

output publicAccessZoneSubnetId string = '${vnet.id}/subnets/${hubNetwork.subnets.publicAccess.name}'

output GatewaySubnetId string = '${vnet.id}/subnets/GatewaySubnet'
output AzureBastionSubnetId string = '${vnet.id}/subnets/AzureBastionSubnet'
output AzureFirewallSubnetId string = '${vnet.id}/subnets/AzureFirewallSubnet'
output AzureFirewallManagementSubnetId string = '${vnet.id}/subnets/AzureFirewallManagementSubnet'
