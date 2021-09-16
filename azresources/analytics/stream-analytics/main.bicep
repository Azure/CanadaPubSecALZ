// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string
param tags object = {}


resource streamanalytics 'Microsoft.StreamAnalytics/streamingjobs@2017-04-01-preview' = {
  name: name
  tags: tags
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Standard'
    }
  }
}
