// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Azure Key Vault Name.')
param akvName string

@description('Secret Name.')
param secretName string

@description('Secret Value')
@secure()
param secretValue string

@description('Secret Expiry in days.')
param secretExpiryInDays int

@description('Expiry Year.')
param yearNow int = int(trim(utcNow(' yyyy ')))

@description('Expiry Month.')
param monthNow int = int(trim(utcNow(' M ')))

@description('Expiry Day.')
param dayNow int = int(trim(utcNow(' d ')))

var expSeconds = (yearNow - 1970) * 31536000 + monthNow * 2628000 + dayNow * 86400 + secretExpiryInDays * 86400

resource akvSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${akvName}/${secretName}'
  properties: {
    attributes: {
      enabled: true
      exp: expSeconds
    }
    value: secretValue
  }
}
