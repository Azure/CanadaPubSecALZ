// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------
targetScope = 'subscription'

param deploymentScriptResourceGroupName string
param deploymentScriptIdentitylId string
param deploymentScriptIdentityPrincipalId string

param akvResourceGroupName string
param akvName string

param storageAccountResourceGroupName string
param storageAccountName string

var cliCommand = '''
  sleep 1m
  az storage account update \
  --resource-group {0} \
  --name {1} \
  --encryption-key-vault {2} \
  --encryption-key-name {3} \
  --encryption-key-source Microsoft.Keyvault
'''

resource rgDeploymentScripts 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: deploymentScriptResourceGroupName
}

resource rgKeyVault 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: akvResourceGroupName
}

resource rgStorage 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: storageAccountResourceGroupName
}

resource akv 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  scope: rgKeyVault
  name: akvName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  scope: rgStorage
  name: storageAccountName
}

module roleAssignForDeploymentScript '../../iam/resource/storageRoleAssignmentToSP.bicep' = {
  name: 'cmk-role-assign-deployment-script-${storageAccountName}'
  scope: rgStorage
  params: {
    storageAccountName: storageAccount.name
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // Contributor
    resourceSPObjectIds: array(deploymentScriptIdentityPrincipalId)
  }
}

module roleAssignForAKV '../../iam/resource/keyVaultRoleAssignmentToSP.bicep' = {
  name: 'cmk-role-assign-${storageAccountName}-key-vault'
  scope: rgKeyVault
  params: {
    keyVaultName: akv.name
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '12338af0-0e69-4776-bea7-57ae8d297424')
    resourceSPObjectIds: array(storageAccount.identity.principalId)
  }
}

module akvKey '../../security/key-vault-key-rsa2048.bicep' = {
  scope: rgKeyVault
  name: 'cmk-key-${storageAccountName}'
  params: {
    akvName: akv.name
    keyName: 'cmk-${storageAccount.name}'
  }  
}

module enableCmk '../../util/deploymentScript.bicep' = {
  dependsOn: [
    roleAssignForDeploymentScript
    roleAssignForAKV
  ]
  
  scope: rgDeploymentScripts
  name: 'enable-cmk-${storageAccountName}'
  params: {
    deploymentScript: format(cliCommand, storageAccountResourceGroupName, storageAccountName, akv.properties.vaultUri, akvKey.outputs.keyName)
    deploymentScriptName: 'enable-cmk-${storageAccountName}'
    deploymentScriptIdentitylId: deploymentScriptIdentitylId
  }
}
