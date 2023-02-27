// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param linkName string
param vnetId string
param forwardingRulesetName string

resource dnsResolver 'Microsoft.Network/dnsForwardingRulesets@2022-07-01' existing = {
   name: forwardingRulesetName
}

resource resolverLink 'Microsoft.Network/dnsForwardingRulesets/virtualNetworkLinks@2022-07-01' = {
  name: linkName
  parent: dnsResolver
  properties: {
    virtualNetwork: {
       id: vnetId
    }
  }
}
