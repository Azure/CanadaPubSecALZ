// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('User Defined Route Name.')
param name string

/*
Example for routes array:

  {
    name: 'table1'
    properties: {
      addressPrefix: '0.0.0.0/0'
      nextHopType: 'VirtualAppliance'
      nextHopIpAddress: '10.0.0.4'
    }
  }
  {
    name: 'table2'
    properties: {
      addressPrefix: '10.1.2.0/24'
      nextHopType: 'VirtualAppliance'
      nextHopIpAddress: '10.0.0.5'
    }
  }
*/
@description('Array of routes')
param routes array = []

resource udr 'Microsoft.Network/routeTables@2020-11-01' = {
  name: name
  location: resourceGroup().location
  properties: {
    disableBgpRoutePropagation: false
    routes: routes
  }
}

// Outputs
output udrName string = udr.name
output udrId string = udr.id
