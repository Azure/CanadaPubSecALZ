// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Egress Azure Load Balancer Name')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

var loadBalancerBackendPoolName = 'lbBackendPool'
var loadBalancerBackendPoolId = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', name, loadBalancerBackendPoolName)

var loadBalancerFrontendConfigName = 'frontendConfig'
var loadBalancerFrontendConfigId = resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', name, loadBalancerFrontendConfigName)

resource lbPublicIp 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: '${name}PublicIp'
  tags: tags
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource lb 'Microsoft.Network/loadBalancers@2020-06-01' = {
  name: name
  tags: tags
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: loadBalancerFrontendConfigName
        properties: {
          publicIPAddress: {
            id: lbPublicIp.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: loadBalancerBackendPoolName
      }
    ]
    outboundRules: [
      {
        name: 'outbound-rule'
        properties: {
          allocatedOutboundPorts: 0
          protocol: 'All'
          enableTcpReset: true
          idleTimeoutInMinutes: 4
          backendAddressPool: {
            id: loadBalancerBackendPoolId
          }
          frontendIPConfigurations: [
            {
              id: loadBalancerFrontendConfigId
            }
          ]
        }
      }
    ]
  }
}

// Outputs
output lbId string = lb.id
output lbBackendPoolName string = loadBalancerBackendPoolName
output lbBackendPoolFullName string = '${lb.name}/${loadBalancerBackendPoolName}'
