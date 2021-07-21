// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string = 'aml-${uniqueString(resourceGroup().id)}'
param storageAccountId string
param containerRegistryId string
param appInsightsId string
param privateEndpointSubnetId string
param privateZoneAzureMLApiId string
param privateZoneAzureMLNotebooksId string
param tags object = {}

@description('When true, customer managed key will be enabled')
param useCMK bool
@description('Required when useCMK=true')
param akvResourceGroupName string
@description('Required when useCMK=true')
param akvName string
@description('Enabling high business impact workspace')
param enableHbiWorkspace bool = true

resource akv 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  scope: resourceGroup(akvResourceGroupName)
  name: akvName  
}
module amlWithoutCMK 'aml-without-cmk.bicep' = if (!useCMK) {
  name: 'deploy-aml-without-cmk'
  params: {
    name: name
    tags: tags
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

module amlWithCMK 'aml-with-cmk.bicep' = if (useCMK) {
  name: 'deploy-aml-with-cmk'
  params: {
    name: name
    tags: tags
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
