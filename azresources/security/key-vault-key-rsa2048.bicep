// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------


param akvName string
param keyName string

resource akvKey 'Microsoft.KeyVault/vaults/keys@2020-04-01-preview' = {
  name: '${akvName}/${keyName}'
  properties: {
    kty: 'RSA'
    keySize: 2048
    attributes: {
      enabled: true
    }
  }  
}

output keyName string = keyName
output keyId string = akvKey.id
output keyUri string = akvKey.properties.keyUri

