// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Azure App Service Plan Name.')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

@description('App Service Plan SKU Name')
param skuName string

@description('App Service Plan SKU Tier')
param skuTier string

resource plan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: name
  location: resourceGroup().location
  tags: tags
  kind: 'Linux'
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    reserved: true
  }
}

output planId string = plan.id
