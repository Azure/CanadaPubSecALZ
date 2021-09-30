// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Private DNS Zone Name.')
param zone string

@description('Virtual Network Resource Id.')
param vnetId string

@description('Boolean flag to enable automatic DNS registration for VMs.')
param registrationEnabled bool

@description('Boolean flag to determine whether to create new Private DNS Zones or to reference existing ones.')
param dnsCreateNewZone bool

@description('Boolean flag to determine whether to link the DNS zone to the virtual network.')
param dnsLinkToVirtualNetwork bool

@description('Private DNS Zones Subscription Id.  Required when dnsCreateNewZone=false')
param dnsExistingZoneSubscriptionId string

@description('Private DNS Zones Resource Group.  Required when dnsCreateNewZone=false')
param dnsExistingZoneResourceGroupName string

// When DNS Zone is managed in the Spoke
resource privateDnsZoneNew 'Microsoft.Network/privateDnsZones@2018-09-01' = if (dnsCreateNewZone) {
  name: zone
  location: 'global'
}

module privateDnsZoneVirtualNetworkLinkNew 'private-dns-zone-virtual-network-link.bicep' = if (dnsCreateNewZone && dnsLinkToVirtualNetwork) {
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

module privateDnsZoneVirtualNetworkLinkExisting 'private-dns-zone-virtual-network-link.bicep' = if (!dnsCreateNewZone && dnsLinkToVirtualNetwork) {
  name: 'configure-vnetlink-use-existing-${uniqueString(zone, vnetId)}'
  scope: resourceGroup(dnsExistingZoneSubscriptionId, dnsExistingZoneResourceGroupName)
  params: {
    name: uniqueString(vnetId)
    vnetId: vnetId
    zone: privateDnsZoneExisting.name
    registrationEnabled: registrationEnabled
  }
}

// Outputs
output privateDnsZoneId string = dnsCreateNewZone ? privateDnsZoneNew.id : privateDnsZoneExisting.id
