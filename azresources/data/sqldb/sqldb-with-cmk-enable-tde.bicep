// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param sqldbName string

param akvName string
param akvKeyName string
param akvKeyVersion string
param keyUriWithVersion string

var tdeKeyName = '${akvName}_${akvKeyName}_${akvKeyVersion}'

resource sqldbKey 'Microsoft.Sql/servers/keys@2021-02-01-preview' = {
  name: '${sqldbName}/${tdeKeyName}'
  properties: {
    serverKeyType: 'AzureKeyVault'
    uri: keyUriWithVersion
  }
}

resource sqldbTDE 'Microsoft.Sql/servers/encryptionProtector@2021-02-01-preview' = {
  dependsOn: [
    sqldbKey
  ]

  name: '${sqldbName}/current'
  properties: {
    serverKeyType: 'AzureKeyVault'
    serverKeyName: tdeKeyName
    autoRotationEnabled: true
  }
}
