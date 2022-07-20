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

// Management Restricted Zone Virtual Network
@description('Management Restricted Zone virtual network.  See docs/archetypes/hubnetwork-nva.md for configuration settings.')
param network object

// Common Route Table for all subnets that require Udr
@description('Route Table Resource Id for subnets in Management Restricted Zone')
param udrId string

// DDOS
@description('DDOS Standard Plan Resource Id - optional (blank value = DDOS Standard Plan will not be linked to virtual network).')
param ddosStandardPlanId string

// Network Security Group
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = [for subnet in network.subnets: if (subnet.nsg.enabled) {
  name: '${subnet.name}Nsg'
  location: location
  properties: {
    securityRules: []
  }
}]

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  location: location
  name: network.name
  properties: {
    enableDdosProtection: !empty(ddosStandardPlanId)
    ddosProtectionPlan: (!empty(ddosStandardPlanId)) ? {
      id: ddosStandardPlanId
    } : null
    addressSpace: {
      addressPrefixes: network.addressPrefixes
    }
    subnets: [for (subnet, i) in network.subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        networkSecurityGroup: (subnet.nsg.enabled) ? {
          id: nsg[i].id
        } : null
        routeTable: (subnet.udr.enabled) ? {
          id: udrId
        } : null
        delegations: contains(subnet, 'delegations') ? [
          {
            name: replace(subnet.delegations.serviceName, '/', '.')
            properties: {
              serviceName: subnet.delegations.serviceName
            }
          }
        ] : null
      }
    }]
  }
}

// Outputs
output vnetName string = vnet.name
output vnetId string = vnet.id

output subnets array = [for subnet in network.subnets: {
  id: '${vnet.id}/subnets/${subnet.name}'
}]
