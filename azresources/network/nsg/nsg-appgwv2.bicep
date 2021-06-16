// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: name
  location: resourceGroup().location
  properties: {
      securityRules: [
          {
              name: 'AllowGatewayManagerInbound'
              properties: {
                  priority: 100
                  direction: 'Inbound'
                  access: 'Allow'
                  protocol: 'Tcp'
                  sourceAddressPrefix: 'GatewayManager'
                  sourcePortRange: '65200-65535'
                  destinationAddressPrefix: '*'
                  destinationPortRange: '*'
              }
          }
      ]
  }
}

output nsgId string = nsg.id
