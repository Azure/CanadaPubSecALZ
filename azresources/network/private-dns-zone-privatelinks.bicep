// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param vnetId string

param dnsCreateNewZone bool = true

@description('Required when dnsCreateNewZone=false')
param dnsExistingZoneSubscriptionId string = ''

@description('Required when dnsCreateNewZone=false')
param dnsExistingZoneResourceGroupName string = ''

param privateDnsZones array = [
  'privatelink.azure-automation.net'
  'privatelink${environment().suffixes.sqlServerHostname}'
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
  'privatelink.canadacentral.backup.windowsazure.com'
  'privatelink.canadaeast.backup.windowsazure.com'
  'canadacentral.privatelink.siterecovery.windowsazure.com'
  'canadaeast.privatelink.siterecovery.windowsazure.com'
  'privatelink.servicebus.windows.net'
  'privatelink.azure-devices.net'
  'privatelink.eventgrid.azure.net'
  'privatelink.azurewebsites.net'
  'privatelink.api.azureml.ms'
  'privatelink.notebooks.azure.net'
  'privatelink.service.signalr.net'
  'privatelink.monitor.azure.com'
  'privatelink.oms.opinsights.azure.com'
  'privatelink.ods.opinsights.azure.com'
  'privatelink.agentsvc.azure-automation.net'
  'privatelink.cognitiveservices.azure.com'
  'privatelink.afs.azure.net'
  'privatelink.datafactory.azure.net'
  'privatelink.adf.azure.com'
  'privatelink.redis.cache.windows.net'
]

module dnsZone 'private-zone.bicep' = [for zone in privateDnsZones: {
  name: replace(zone, '.', '_')
  scope: resourceGroup()
  params: {
    zone: zone
    vnetId: vnetId

    registrationEnabled: false

    dnsCreateNewZone: dnsCreateNewZone
    dnsExistingZoneSubscriptionId: dnsExistingZoneSubscriptionId
    dnsExistingZoneResourceGroupName: dnsExistingZoneResourceGroupName
  }
}]
