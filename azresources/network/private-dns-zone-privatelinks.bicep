// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Virtual Network Resource Id')
param vnetId string

@description('Boolean flag to determine whether to create new Private DNS Zones or to reference existing ones.')
param dnsCreateNewZone bool

@description('Boolean flag to determine whether to link the DNS zone to the virtual network.')
param dnsLinkToVirtualNetwork bool

@description('Private DNS Zones Subscription Id.  Required when dnsCreateNewZone=false')
param dnsExistingZoneSubscriptionId string

@description('Private DNS Zones Resource Group.  Required when dnsCreateNewZone=false')
param dnsExistingZoneResourceGroupName string

@description('Array of Private DNS Zones to provision.')
param privateDnsZones array = [
  'privatelink.azure-automation.net'
  'privatelink${environment().suffixes.sqlServerHostname}'
  'privatelink.sql.azuresynapse.net'
  'privatelink.dev.azuresynapse.net'
  'privatelink.azuresynapse.net'
  'privatelink.blob.${environment().suffixes.storage}'
  'privatelink.table.${environment().suffixes.storage}'
  'privatelink.queue.${environment().suffixes.storage}'
  'privatelink.file.${environment().suffixes.storage}'
  'privatelink.web.${environment().suffixes.storage}'
  'privatelink.dfs.${environment().suffixes.storage}'
  'privatelink.documents.azure.com'
  'privatelink.mongo.cosmos.azure.com'
  'privatelink.cassandra.cosmos.azure.com'
  'privatelink.gremlin.cosmos.azure.com'
  'privatelink.table.cosmos.azure.com'
  'privatelink.postgres.database.azure.com'
  'privatelink.mysql.database.azure.com'
  'privatelink.mariadb.database.azure.com'
  'privatelink.vaultcore.azure.net'
  'privatelink.canadacentral.azmk8s.io'
  'privatelink.canadaeast.azmk8s.io'
  'privatelink.search.windows.net'
  'privatelink.azurecr.io'
  'privatelink.azconfig.io'
  'privatelink.cnc.backup.windowsazure.com'
  'privatelink.cne.backup.windowsazure.com'
  'privatelink.siterecovery.windowsazure.com'
  'privatelink.servicebus.windows.net'
  'privatelink.azure-devices.net'
  'privatelink.eventgrid.azure.net'
  'privatelink.azurewebsites.net'
  'privatelink.api.azureml.ms'
  'privatelink.notebooks.azure.net'
  'privatelink.service.signalr.net'
//  'privatelink.monitor.azure.com'
  'privatelink.oms.opinsights.azure.com'
  'privatelink.ods.opinsights.azure.com'
  'privatelink.agentsvc.azure-automation.net'
  'privatelink.cognitiveservices.azure.com'
  'privatelink.afs.azure.net'
  'privatelink.datafactory.azure.net'
  'privatelink.redis.cache.windows.net'
  'privatelink.redisenterprise.cache.azure.net'
  'privatelink.purview.azure.com'
  'privatelink.azurehealthcareapis.com'
]

module dnsZone 'private-dns-zone.bicep' = [for zone in privateDnsZones: {
  name: replace(zone, '.', '_')
  scope: resourceGroup()
  params: {
    zone: zone
    vnetId: vnetId

    registrationEnabled: false

    dnsCreateNewZone: dnsCreateNewZone
    dnsLinkToVirtualNetwork: dnsLinkToVirtualNetwork
    dnsExistingZoneSubscriptionId: dnsExistingZoneSubscriptionId
    dnsExistingZoneResourceGroupName: dnsExistingZoneResourceGroupName
  }
}]
