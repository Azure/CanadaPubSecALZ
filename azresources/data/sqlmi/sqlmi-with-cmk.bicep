// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string = 'sqlmi${uniqueString(resourceGroup().id)}'

param skuName string = 'GP_Gen5'
param vCores int = 4
param storageSizeInGB int = 32
param subnetId string

param storagePath string
param securityContactEmail string
param saLoggingName string

param tags object = {}

@secure()
param sqlmiUsername string

@secure()
param sqlmiPassword string

param akvResourceGroupName string
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
    keyName: 'cmk-sqlmi-${name}'
  }
}

resource sqlmi 'Microsoft.Sql/managedInstances@2020-11-01-preview' = {
  name: name
  location: resourceGroup().location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: skuName
  }
  properties: {
    administratorLogin: sqlmiUsername
    administratorLoginPassword: sqlmiPassword
    subnetId: subnetId
    licenseType: 'LicenseIncluded'
    vCores: vCores
    storageSizeInGB: storageSizeInGB
  }
}

module akvRoleAssignmentForCMK '../../iam/resource/key-vault-role-assignment-to-sp.bicep' = {
  name: 'rbac-${name}-key-vault'
  scope: resourceGroup(akvResourceGroupName)
  params: {
    keyVaultName: akv.name
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e147488a-f6f5-4113-8e2d-b22465e65bf6') // Key Vault Crypto Service Encryption User
    resourceSPObjectIds: array(sqlmi.identity.principalId)
  }
}

module roleAssignSQLMIToSALogging '../../iam/resource/storage-role-assignment-to-sp.bicep' = {
  name: 'rbac-${name}-logging-storage-account'
  params: {
    storageAccountName: saLoggingName
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    resourceSPObjectIds: array(sqlmi.identity.principalId)
  }
}

module enableTDE 'sqlmi-with-cmk-enable-tde.bicep' = {
  dependsOn: [
    akvRoleAssignmentForCMK
  ]

  name: 'deploy-tde-with-cmk'
  params: {
    sqlmiName: sqlmi.name

    akvName: akvName
    akvKeyName: akvKey.outputs.keyName
    akvKeyVersion: akvKey.outputs.keyVersion
    keyUriWithVersion: akvKey.outputs.keyUriWithVersion
  }
}

resource sqlmi_sap 'Microsoft.Sql/managedInstances/securityAlertPolicies@2020-11-01-preview' = {
  name: '${name}/default'
  dependsOn: [
    sqlmi
  ]
  properties: {
    state: 'Enabled'
    emailAccountAdmins: false
  }
}

resource sqlmi_va 'Microsoft.Sql/managedInstances/vulnerabilityAssessments@2020-11-01-preview' = {
  name: '${name}/default'
  dependsOn: [
    sqlmi
    sqlmi_sap
    roleAssignSQLMIToSALogging
  ]
  properties: {
    storageContainerPath: '${storagePath}vulnerability-assessment'
    recurringScans: {
      isEnabled: true
      emailSubscriptionAdmins: true
      emails: [
        securityContactEmail
      ]
    }
  }
}

output sqlMiFqdn string = sqlmi.properties.fullyQualifiedDomainName
