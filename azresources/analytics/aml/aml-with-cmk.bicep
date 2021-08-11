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

param akvResourceGroupName string
param akvName string

@description('Enabling high business impact workspace')
param enableHbiWorkspace bool = false

resource akv 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  scope: resourceGroup(akvResourceGroupName)
  name: akvName
}

module akvKey '../../security/key-vault-key-rsa2048.bicep' = {
  name: 'add-cmk-${name}'
  scope: resourceGroup(akvResourceGroupName)
  params: {
    akvName: akvName
    keyName: 'cmk-aml-${name}'
  }
}

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
    hbiWorkspace: enableHbiWorkspace
    allowPublicAccessWhenBehindVnet: false
    encryption: {
      status: 'Enabled'
      keyVaultProperties: {
        keyVaultArmId: akv.id
        keyIdentifier: akvKey.outputs.keyUriWithVersion
      }
    }
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

  resource aml_pe_dns_reg 'privateDnsZoneGroups@2020-06-01' = {
    name: 'default'
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
}
