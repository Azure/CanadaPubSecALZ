// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Location for the deployment.')
param location string = resourceGroup().location

// VNET
@description('Virtual Network Name.')
param vnetName string

@description('Virtual Network Address Space (RFC 1918).')
param vnetAddressPrefixRFC1918 string

@description('Virtual Network Address Space (RFC 6598) - CGNAT.')
param vnetAddressPrefixRFC6598 string

@description('Virtual Network Address Space for Azure Bastion (RFC 1918).')
param vnetAddressPrefixBastion string

// Public Access Zone (i.e. Application Gateways)
@description('Public Access Zone (i.e. Application Gateway) Subnet Name.')
param pazSubnetName string

@description('Public Access Zone (i.e. Application Gateway) Subnet Address Prefix.')
param pazSubnetAddressPrefix string

@description('Public Access Zone (i.e. Application Gateway) User Defined Route Resource Id.')
param pazUdrId string

// Gateway Subnet
@description('Virtual Network Gateway Subnet Address Prefix (based on RFC 1918).')
param gatewaySubnetAddressPrefix string

// Azure Bastion
@description('Azure Bastion Subnet Address Prefix.')
param bastionSubnetAddressPrefix string

// Azure Firweall
@description('Azure Firewall Subnet Address Prefix.')
param azureFirewallSubnetAddressPrefix string

@description('Azure Firewall Management Subnet Address Prefix.')
param azureFirewallManagementSubnetAddressPrefix string

@description('Azure Firewall is deployed in Forced Tunneling mode where a route table must be added as the next hop.')
param azureFirewallForcedTunnelingEnabled bool

@description('Next Hop for AzureFirewallSubnet when Azure Firewall is deployed in forced tunneling mode.')
param azureFirewallForcedTunnelingNextHop string

// DDOS
param ddosStandardPlanId string

module publicAccessZoneNsg '../../../azresources/network/nsg/nsg-appgwv2.bicep' = {
  name: 'deploy-nsg-${pazSubnetName}Nsg'
  params: {
    name: '${pazSubnetName}Nsg'
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
  name: vnetName
  properties: {
    enableDdosProtection: !empty(ddosStandardPlanId)
    ddosProtectionPlan: (!empty(ddosStandardPlanId)) ? {
      id: ddosStandardPlanId
    } : null
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefixRFC1918
        vnetAddressPrefixRFC6598
        vnetAddressPrefixBastion
      ]
    }
    subnets: [
      {
        name: pazSubnetName
        properties: {
          addressPrefix: pazSubnetAddressPrefix
          networkSecurityGroup: {
            id: publicAccessZoneNsg.outputs.nsgId
          }
          routeTable: {
            id: pazUdrId
          }
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: azureFirewallSubnetAddressPrefix
          routeTable: azureFirewallForcedTunnelingEnabled ? {
            id: azureFirewallSubnetUdr.outputs.udrId
          } : null
        }
      }
      {
        name: 'AzureFirewallManagementSubnet'
        properties: {
          addressPrefix: azureFirewallManagementSubnetAddressPrefix
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionSubnetAddressPrefix
          networkSecurityGroup: {
            id: bastionNsg.outputs.nsgId
          }
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: gatewaySubnetAddressPrefix
        }
      }
    ]
  }
}

output vnetName string = vnet.name
output vnetId string = vnet.id

output publicAccessZoneSubnetId string = '${vnet.id}/subnets/${pazSubnetName}'

output GatewaySubnetId string = '${vnet.id}/subnets/GatewaySubnet'
output AzureBastionSubnetId string = '${vnet.id}/subnets/AzureBastionSubnet'
output AzureFirewallSubnetId string = '${vnet.id}/subnets/AzureFirewallSubnet'
output AzureFirewallManagementSubnetId string = '${vnet.id}/subnets/AzureFirewallManagementSubnet'
