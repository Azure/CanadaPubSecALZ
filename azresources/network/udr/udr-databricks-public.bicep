// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string

resource udr 'Microsoft.Network/routeTables@2020-06-01' = {
  location: resourceGroup().location
  name: name
  properties: {
    disableBgpRoutePropagation: false
  }
}

output udrId string = udr.id
