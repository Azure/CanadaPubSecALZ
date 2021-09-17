// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Storage Account Resource Group Name.')
param storageResourceGroupName string

@description('Storage Account Name.')
param storageAccountName string

@description('Azure Key Vault Resource Group Name.')
param keyVaultResourceGroupName string

@description('Azure Key Vault Name.')
param keyVaultName string

@description('Deployment Script Identity Resource Id.  This identity is used to execute Azure CLI as part of the deployment.')
param deploymentScriptIdentityId string

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  scope: resourceGroup(storageResourceGroupName)
  name: storageAccountName
}

resource akv 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  scope: resourceGroup(keyVaultResourceGroupName)
  name: keyVaultName
}

module roleAssignForAKV '../iam/resource/key-vault-role-assignment-to-sp.bicep' = {
  name: 'rbac-${storage.name}-key-vault'
  scope: resourceGroup(keyVaultResourceGroupName)
  params: {
    keyVaultName: keyVaultName
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e147488a-f6f5-4113-8e2d-b22465e65bf6') // Key Vault Crypto Service Encryption User
    resourceSPObjectIds: array(storage.identity.principalId)
  }
}

module akvKey '../security/key-vault-key-rsa2048.bicep' = {
  scope: resourceGroup(keyVaultResourceGroupName)
  name: 'add-cmk-storage-${storage.name}'
  params: {
    akvName: keyVaultName
    keyName: 'cmk-storage-${storage.name}'
  }  
}

var cliCommand = '''
  az storage account update \
  --resource-group {0} \
  --name {1} \
  --encryption-key-vault {2} \
  --encryption-key-name {3} \
  --encryption-key-source Microsoft.Keyvault
'''

module enableCmk '../util/deployment-script.bicep' = {
  dependsOn: [
    roleAssignForAKV
  ]
  
  name: 'enable-cmk-${storage.name}'
  params: {
    deploymentScript: format(cliCommand, resourceGroup().name, storage.name, akv.properties.vaultUri, akvKey.outputs.keyName)
    deploymentScriptName: 'enable-cmk-${storage.name}-ds'
    deploymentScriptIdentityId: deploymentScriptIdentityId
  }
}
