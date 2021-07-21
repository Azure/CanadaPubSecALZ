// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string = 'aml-${uniqueString(resourceGroup().id)}'
param keyVaultId string
param storageAccountId string
param containerRegistryId string
param appInsightsId string
param privateEndpointSubnetId string
param privateZoneAzureMLApiId string
param privateZoneAzureMLNotebooksId string
param tags object = {}

resource aml 'Microsoft.MachineLearningServices/workspaces@2020-08-01' = {
  name: name
  tags: tags
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Enterprise'
    tier: 'Enterprise'
  }
  properties: {
    friendlyName: name
    keyVault: keyVaultId
    storageAccount: storageAccountId
    applicationInsights: appInsightsId
    containerRegistry: containerRegistryId
    hbiWorkspace: false
    allowPublicAccessWhenBehindVnet: false
  }
}


resource aml_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: resourceGroup().location
  name: '${aml.name}-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${aml.name}-endpoint'
        properties: {
          privateLinkServiceId: aml.id
          groupIds: [
            'amlworkspace'
          ]
        }
      }
    ]
  }
}

resource aml_pe_dns_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${aml_pe.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-api-azureml-ms'
        properties: {
          privateDnsZoneId: privateZoneAzureMLApiId
        }
      }
      {
        name: 'privatelink-notebooks-azureml-ms'
        properties: {
          privateDnsZoneId: privateZoneAzureMLNotebooksId
        }
      }
    ]
  }
}

output amlId string = aml.id
