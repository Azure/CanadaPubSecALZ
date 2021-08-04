// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------
param name string

@allowed([
  'DOTNETCORE|3.1'
  'DOTNETCORE|2.1'
  'NODE|14-lts'
  'NODE|12-lts'
  'Python|3.8'
  'Python|3.7'
  'Python|3.6'
])
param stack string
param appServicePlanId string

param storageName string
param storageId string

param aiIKey string
param vnetIntegrationSubnetId string

param tags object = {}

resource app 'Microsoft.Web/sites@2020-06-01' = {
  name: name
  tags: tags
  location: resourceGroup().location
  kind: 'linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlanId
    clientAffinityEnabled: true
    siteConfig: {
      // for Linux Apps Azure DNS private zones only works if Route All is enabled.
      // https://docs.microsoft.com/azure/app-service/web-sites-integrate-with-vnet#azure-dns-private-zones
      vnetRouteAllEnabled: true

      linuxFxVersion: stack
      use32BitWorkerProcess: false
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      appSettings: [
        {
          name: 'WEBSITE_DNS_SERVER'
          value: '168.63.129.16'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: aiIKey
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageName};AccountKey=${listKeys(storageId, '2021-04-01').keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
      ]
    }
  }
}

resource app_vnet 'Microsoft.Web/sites/networkConfig@2020-06-01' = {
  name: '${app.name}/VirtualNetwork'
  properties: {
    subnetResourceId: vnetIntegrationSubnetId
    swiftSupported: true
  } 
}
