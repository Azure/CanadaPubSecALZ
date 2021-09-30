// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('SQL Database Logical Server Name.')
param sqlServerName string

@description('Azure Key Vault Name.')
param akvName string

@description('Azure Key Vault Key Name.')
param akvKeyName string

@description('Azure Key Vault Key Version.')
param akvKeyVersion string

@description('Azure Key Vault Key Uri with Version.')
param keyUriWithVersion string

var tdeKeyName = '${akvName}_${akvKeyName}_${akvKeyVersion}'

resource sqldbKey 'Microsoft.Sql/servers/keys@2021-02-01-preview' = {
  name: '${sqlServerName}/${tdeKeyName}'
  properties: {
    serverKeyType: 'AzureKeyVault'
    uri: keyUriWithVersion
  }
}

resource sqldbTDE 'Microsoft.Sql/servers/encryptionProtector@2021-02-01-preview' = {
  dependsOn: [
    sqldbKey
  ]

  name: '${sqlServerName}/current'
  properties: {
    serverKeyType: 'AzureKeyVault'
    serverKeyName: tdeKeyName
    autoRotationEnabled: true
  }
}
