// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('SQL Managed Instance Name.')
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

resource sqlmiKey 'Microsoft.Sql/managedInstances/keys@2021-02-01-preview' = {
  name: '${sqlServerName}/${tdeKeyName}'
  properties: {
    serverKeyType: 'AzureKeyVault'
    uri: keyUriWithVersion
  }
}

resource sqlmiTDE 'Microsoft.Sql/managedInstances/encryptionProtector@2021-02-01-preview' = {
  dependsOn: [
    sqlmiKey
  ]

  name: '${sqlServerName}/current'
  properties: {
    serverKeyType: 'AzureKeyVault'
    serverKeyName: tdeKeyName
    autoRotationEnabled: true
  }
}
