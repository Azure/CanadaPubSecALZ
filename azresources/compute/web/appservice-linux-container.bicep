// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Azure App Service Name.')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

@description('App Service Plan Resource Id.')
param appServicePlanId string

@description('Storage Account Name.')
param storageName string

@description('Storage Account Resource Id.')
param storageId string

@description('Application Insights Instrumentation Key.')
param aiIKey string

@description('Virtual Network Integration Subnet Resource Id.')
param vnetIntegrationSubnetId string

// Linux Web App with Virtual Network Integration
resource app 'Microsoft.Web/sites@2021-02-01' = {
  name: name
  tags: tags
  location: resourceGroup().location
  kind: 'app,linux,container'
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
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/appsvc/staticsite:latest'
      vnetRouteAllEnabled: true
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

  resource app_vnet 'networkConfig@2020-06-01' = {
    name: 'virtualNetwork'
    properties: {
      subnetResourceId: vnetIntegrationSubnetId
      swiftSupported: true
    }
  }
}
