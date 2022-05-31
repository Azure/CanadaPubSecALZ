// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Location for the deployment.')
param location string = resourceGroup().location

@description('Function App Name.')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

@description('Technology Stack.  Default: PYTHON|3.9')
@allowed([
  'PYTHON|3.9'
  'PYTHON|3.8'
  'PYTHON|3.7'
  'PYTHON|3.6'
])
param stack string = 'PYTHON|3.9'

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

// Function App with Virtual Network Integration
resource function_app 'Microsoft.Web/sites@2020-06-01' = {
  name: name
  tags: tags
  location: location
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
