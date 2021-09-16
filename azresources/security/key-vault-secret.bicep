// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param akvName string
param secretName string

@secure()
param secretValue string

param secretExpiryInDays int

param yearNow int = int(trim(utcNow(' yyyy ')))
param monthNow int = int(trim(utcNow(' M ')))
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
