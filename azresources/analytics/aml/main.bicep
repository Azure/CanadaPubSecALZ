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

@description('Azure Storage Account Resource Id.')
param storageAccountId string

@description('Azure Container Registry Resource Id.')
param containerRegistryId string

@description('Azure Application Insights Resource Id.')
param appInsightsId string

// Private Endpoints
@description('Private Endpoint Subnet Resource Id.')
param privateEndpointSubnetId string

@description('Private DNS Zone Resource Id for AML API.')
param privateZoneAzureMLApiId string

@description('Private DNS Zone Resource Id for AML Notebooks.')
param privateZoneAzureMLNotebooksId string

// Customer Managed Key
@description('Boolean flag that determines whether to enable Customer Managed Key.')
param useCMK bool

// Azure Key Vault
@description('Azure Key Vault Resource Group Name.  Required when useCMK=true.')
param akvResourceGroupName string

@description('Azure Key Vault Name.  Required when useCMK=true.')
param akvName string

resource akv 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  scope: resourceGroup(akvResourceGroupName)
  name: akvName  
}

// Azure Machine Learning without Customer Managed Key
module amlWithoutCMK 'aml-without-cmk.bicep' = if (!useCMK) {
  name: 'deploy-aml-without-cmk'
  params: {
    name: name
    tags: tags
    location: location
    keyVaultId: akv.id
    containerRegistryId: containerRegistryId
    storageAccountId: storageAccountId
    appInsightsId: appInsightsId
    privateZoneAzureMLApiId: privateZoneAzureMLApiId
    privateZoneAzureMLNotebooksId: privateZoneAzureMLNotebooksId
    privateEndpointSubnetId: privateEndpointSubnetId
    enableHbiWorkspace: enableHbiWorkspace
  }
}

// Azure Machine Learning with Customer Managed Key
module amlWithCMK 'aml-with-cmk.bicep' = if (useCMK) {
  name: 'deploy-aml-with-cmk'
  params: {
    name: name
    tags: tags
    location: location
    keyVaultId: akv.id
    containerRegistryId: containerRegistryId
    storageAccountId: storageAccountId
    appInsightsId: appInsightsId
    privateZoneAzureMLApiId: privateZoneAzureMLApiId
    privateZoneAzureMLNotebooksId: privateZoneAzureMLNotebooksId
    privateEndpointSubnetId: privateEndpointSubnetId

    enableHbiWorkspace: enableHbiWorkspace
    
    akvResourceGroupName: akvResourceGroupName
    akvName: akvName
  }
}
