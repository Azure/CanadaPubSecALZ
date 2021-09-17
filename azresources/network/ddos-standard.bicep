// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Azure DDOS Standard Plan Name.')
param name string

resource ddosPlan 'Microsoft.Network/ddosProtectionPlans@2020-07-01' = {
  name: name
  location: resourceGroup().location
  properties: {}
}

// Outputs
output ddosPlanId string = ddosPlan.id
