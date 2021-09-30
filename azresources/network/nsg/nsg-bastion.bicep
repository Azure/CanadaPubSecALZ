// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Network Security Group Name.')
param name string

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: name
  location: resourceGroup().location
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
                  destinationPortRange: '443'
              }
          }
          {
              name: 'AllowGatewayManagerInbound'
              properties: {
                  priority: 130
                  direction: 'Inbound'
                  access: 'Allow'
                  protocol: 'Tcp'
                  sourceAddressPrefix: 'GatewayManager'
                  sourcePortRange: '*'
                  destinationAddressPrefix: '*'
                  destinationPortRange: '443'
              }
          }
          {
              name: 'AllowSshRdpOutbound'
              properties: {
                  priority: 100
                  direction: 'Outbound'
                  access: 'Allow'
                  protocol: '*'
                  sourceAddressPrefix: '*'
                  sourcePortRange: '*'
                  destinationAddressPrefix: 'VirtualNetwork'
                  destinationPortRanges: [
                      '22'
                      '3389'
                  ]
              }
          }
          {
              name: 'AllowAzureCloudOutbound'
              properties: {
                  priority: 110
                  direction: 'Outbound'
                  access: 'Allow'
                  protocol: 'Tcp'
                  sourceAddressPrefix: '*'
                  sourcePortRange: '*'
                  destinationAddressPrefix: 'AzureCloud'
                  destinationPortRange: '443'
              }
          }
      ]
  }
}

// Outputs
output nsgId string = nsg.id
