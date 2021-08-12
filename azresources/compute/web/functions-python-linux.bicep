// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------
param name string
param appServicePlanId string

@allowed([
  'PYTHON|3.9'
  'PYTHON|3.8'
  'PYTHON|3.7'
  'PYTHON|3.6'
])
param stack string = 'PYTHON|3.9'

param storageName string
param storageId string

param aiIKey string
param vnetIntegrationSubnetId string

param tags object = {}

resource function_app 'Microsoft.Web/sites@2020-06-01' = {
  name: name
  tags: tags
  location: resourceGroup().location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlanId
    clientAffinityEnabled: true
    clientCertEnabled: true
    siteConfig: {
      linuxFxVersion: stack
      use32BitWorkerProcess: false
      vnetRouteAllEnabled: true
      ftpsState: 'FtpsOnly'
      http20Enabled: true
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
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageName};AccountKey=${listKeys(storageId, '2021-04-01').keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
      ]
    }
  }

  resource function_app_vnet 'networkConfig@2020-06-01' = {
    name: 'virtualNetwork'
    properties: {
      subnetResourceId: vnetIntegrationSubnetId
      swiftSupported: true
    }
  }
}
