// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param zone string
param vnetId string
param registrationEnabled bool = false

param dnsCreateNewZone bool = true

@description('Required when dnsCreateNewZone=false')
param dnsExistingZoneSubscriptionId string = ''

@description('Required when dnsCreateNewZone=false')
param dnsExistingZoneResourceGroupName string = ''

// When DNS Zone is managed in the Spoke
resource privateDnsZoneNew 'Microsoft.Network/privateDnsZones@2018-09-01' = if (dnsCreateNewZone) {
  name: zone
  location: 'global'
}

module privateDnsZoneVirtualNetworkLinkNew 'private-dns-zone-virtual-network-link.bicep' = if (dnsCreateNewZone) {
  name: 'configure-vnetlink-use-new-${uniqueString(zone, vnetId)}'
  params: {
    name: uniqueString(vnetId)
    vnetId: vnetId
    zone: privateDnsZoneNew.name
    registrationEnabled: registrationEnabled
  }
}

// When DNS Zone is managed in the Hub
resource privateDnsZoneExisting 'Microsoft.Network/privateDnsZones@2018-09-01' existing = if (!dnsCreateNewZone) {
  scope: resourceGroup(dnsExistingZoneSubscriptionId, dnsExistingZoneResourceGroupName)
  name: zone
}

module privateDnsZoneVirtualNetworkLinkExisting 'private-dns-zone-virtual-network-link.bicep' = if (!dnsCreateNewZone) {
  name: 'configure-vnetlink-use-existing-${uniqueString(zone, vnetId)}'
  scope: resourceGroup(dnsExistingZoneSubscriptionId, dnsExistingZoneResourceGroupName)
  params: {
    name: uniqueString(vnetId)
    vnetId: vnetId
    zone: privateDnsZoneExisting.name
    registrationEnabled: registrationEnabled
  }
}

output privateDnsZoneId string = dnsCreateNewZone ? privateDnsZoneNew.id : privateDnsZoneExisting.id