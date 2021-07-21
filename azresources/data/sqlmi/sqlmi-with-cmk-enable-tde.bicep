// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param sqlmiName string

param akvName string
param akvKeyName string
param akvKeyVersion string
param keyUriWithVersion string

var tdeKeyName = '${akvName}_${akvKeyName}_${akvKeyVersion}'

resource sqlmiKey 'Microsoft.Sql/managedInstances/keys@2021-02-01-preview' = {
  name: '${sqlmiName}/${tdeKeyName}'
  properties: {
    serverKeyType: 'AzureKeyVault'
    uri: keyUriWithVersion
  }
}

resource sqlmiTDE 'Microsoft.Sql/managedInstances/encryptionProtector@2021-02-01-preview' = {
  dependsOn: [
    sqlmiKey
  ]

  name: '${sqlmiName}/current'
  properties: {
    serverKeyType: 'AzureKeyVault'
    serverKeyName: tdeKeyName
    autoRotationEnabled: true
  }
}
