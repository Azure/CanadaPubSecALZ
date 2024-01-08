// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Location for the deployment.')
param location string = resourceGroup().location

@description('Network Security Group Name.')
param name string

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: name
  location: location
  properties: {
      securityRules: [
          {
              name: 'AllowHttpsInbound'
              properties: {
                  priority: 120
                  direction: 'Inbound'
                  access: 'Allow'
                  protocol: 'Tcp'
                  sourceAddressPrefix: 'Internet'
                  sourcePortRange: '*'
                  destinationAddressPrefix: '*'
                  destinationPortRanges: [
                    '22'
                    '443'
                  ]
              }
          }
      ]
  }
}

// Outputs
output nsgId string = nsg.id
