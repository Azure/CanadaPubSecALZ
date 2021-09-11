// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param zone string
param vnetId string
param registrationEnabled bool = false

param dnsManagedBySpoke bool = false
param dnsManagedByHubSubscriptionId string = ''
param dnsManagedByHubResourceGroupName string = ''

// When DNS Zone is managed in the Spoke
resource privateDnsZoneInSpoke 'Microsoft.Network/privateDnsZones@2018-09-01' = if (dnsManagedBySpoke) {
  name: zone
  location: 'global'
}

module privateDnsZoneVirtualNetworkLinkInSpoke 'private-dns-zone-virtual-network-link.bicep' = if (dnsManagedBySpoke) {
  name: 'configure-${zone}-vnetlink-in-spoke'
  params: {
    name: uniqueString(vnetId)
    vnetId: vnetId
    zone: zone
    registrationEnabled: registrationEnabled
  }
}

// When DNS Zone is managed in the Hub
resource privateDnsZoneInHub 'Microsoft.Network/privateDnsZones@2018-09-01' existing = if (!dnsManagedBySpoke) {
  scope: resourceGroup(dnsManagedByHubSubscriptionId, dnsManagedByHubResourceGroupName)
  name: zone
}

module privateDnsZoneVirtualNetworkLinkInHub 'private-dns-zone-virtual-network-link.bicep' = if (!dnsManagedBySpoke) {
  name: 'configure-${zone}-vnetlink-in-hub'
  scope: resourceGroup(dnsManagedByHubSubscriptionId, dnsManagedByHubResourceGroupName)
  params: {
    name: uniqueString(vnetId)
    vnetId: vnetId
    zone: zone
    registrationEnabled: registrationEnabled
  }
}

output privateZoneId string = dnsManagedBySpoke ? privateDnsZoneInSpoke.id : privateDnsZoneInHub.id
