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

@description('Azure Machine Learning name.')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

@description('Boolean flag to enable High Business Impact workspace.  Default: false')
param enableHbiWorkspace bool = false

@description('Azure Key Vault Resource Id')
param keyVaultId string

@description('Azure Storage Account Resource Id.')
param storageAccountId string

@description('Azure Container Registry Resource Id.')
param containerRegistryId string

@description('Azure Application Insights Resource Id.')
param appInsightsId string

// Private Endpoitns
@description('Private Endpoint Subnet Resource Id.')
param privateEndpointSubnetId string

@description('Private DNS Zone Resource Id for AML API.')
param privateZoneAzureMLApiId string

@description('Private DNS Zone Resource Id for AML Notebooks.')
param privateZoneAzureMLNotebooksId string

// Azure Key Vault
@description('Azure Key Vault Resource Group Name.  Required when useCMK=true.')
param akvResourceGroupName string

@description('Azure Key Vault Name.  Required when useCMK=true.')
param akvName string

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
  location: location
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

// Create Private Endpoints and register their IPs with Private DNS Zone
resource aml_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: location
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
