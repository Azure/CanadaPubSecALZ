// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------
@description('Location for the deployment.')
param location string = resourceGroup().location

@description('Public Access Zone Route Table Name')
param publicAccessZoneUdrName string

@description('Management Restricted Zone Virtual Network Route Table Name')
param managementRestrictedZoneUdrName string

@description('Virtual Network address space for RFC 1918.')
param hubVnetAddressPrefixRFC1918 string

@description('Virtual Network address space for RFC 6598 (CG NAT).')
param hubVnetAddressPrefixRFC6598 string

@description('Azure Firewall Private IP address')
param azureFirwallPrivateIp string

resource routeTable 'Microsoft.Network/routeTables@2021-02-01' existing = {
  name: publicAccessZoneUdrName
}

var routes = [
  {
    name: 'Hub-AzureFirewall-Default-Route'
    properties: {
      nextHopType: 'VirtualAppliance'
      addressPrefix: '0.0.0.0/0'
      nextHopIpAddress: azureFirwallPrivateIp
    }
  }
  {
    name: 'Hub-AzureFirewall-RFC1918-Route'
    properties: {
      nextHopType: 'VirtualAppliance'
      addressPrefix: hubVnetAddressPrefixRFC1918
      nextHopIpAddress: azureFirwallPrivateIp
    }
  }
  {
    name: 'Hub-AzureFirewall-RFC6598-Route'
    properties: {
      nextHopType: 'VirtualAppliance'
      addressPrefix: hubVnetAddressPrefixRFC6598
      nextHopIpAddress: azureFirwallPrivateIp
    }
  }
]

module publicAccessZoneUdr '../../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-${publicAccessZoneUdrName}'
  params: {
    name: publicAccessZoneUdrName
    routes: routes
    location: location
  }
}

module managementRestrictedZoneUdr '../../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-${managementRestrictedZoneUdrName}'
  params: {
    name: managementRestrictedZoneUdrName
    routes: routes
    location: location
  }
}
