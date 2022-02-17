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

@description('Internal Load Balancer Name.')
param name string 

// vnet
@description('Backend Virtaul Network Resource Id.')
param backendVnetId string

// backend pool
@description('Boolean flag to determine whether to create an empty backend pool.')
param configureEmptyBackendPool bool

// external
@description('External Facing - Frontend Subnet Resource Id.')
param frontendSubnetIdExt string

@description('External Facing - Frontend IP.')
param frontendIPExt string

@description('External Facing - Backend IP #1.')
param backendIP1Ext string

@description('External Facing - Backend IP #2.')
param backendIP2Ext string

// internal
@description('Internal Facing - Frontend Subnet Resource Id.')
param frontendSubnetIdInt string

@description('Internal Facing - Frontend IP.')
param frontendIPInt string

@description('Internal Facing - Backend IP #1.')
param backendIP1Int string

@description('Internal Facing - Backend IP #2.')
param backendIP2Int string

// probe
@description('Load Balancer Probe Tcp Port.')
param lbProbeTcpPort int 

resource ILB 'Microsoft.Network/loadBalancers@2020-11-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: '${name}-Frontend-ext'
        properties: {
          privateIPAddress: frontendIPExt
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: frontendSubnetIdExt
          }
          privateIPAddressVersion: 'IPv4'
        }
        zones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: '${name}-Frontend-int'
        properties: {
          privateIPAddress: frontendIPInt
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: frontendSubnetIdInt
          }
          privateIPAddressVersion: 'IPv4'
        }
        zones: [
          '1'
          '2'
          '3'
        ]
      }
    ]
    backendAddressPools: [
      {
        name: '${name}-Backend-ext'
      }
      {
        name: '${name}-Backend-int'
      }
    ]
    loadBalancingRules: [
      {
        name: 'lbruleFE2all-ext'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', name,'${name}-Frontend-ext')
          }
          frontendPort: 0
          backendPort: 0
          enableFloatingIP: true
          idleTimeoutInMinutes: 5
          protocol: 'All'
          enableTcpReset: false
          loadDistribution: 'Default'
          disableOutboundSnat: false
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools',name,'${name}-Backend-ext')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes',name,'lbprobe')
          }
        }
      }
      {
        name: 'lbruleFE2all-int'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', name,'${name}-Frontend-int')
          }
          frontendPort: 0
          backendPort: 0
          enableFloatingIP: true
          idleTimeoutInMinutes: 5
          protocol: 'All'
          enableTcpReset: false
          loadDistribution: 'Default'
          disableOutboundSnat: false
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools',name,'${name}-Backend-int')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes',name,'lbprobe')
          }
        }
      }
    ]
    probes: [
      {
        name: 'lbprobe'
        properties: {
          protocol: 'Tcp'
          port: lbProbeTcpPort
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}

// BackendAddressPool
resource ILBBackendExt 'Microsoft.Network/loadBalancers/backendAddressPools@2020-11-01' = {
  name: '${ILB.name}/${name}-Backend-ext'
  properties: {
    loadBalancerBackendAddresses: configureEmptyBackendPool ? null : [
      {
        name: '${ILB.name}-ext1'
        properties: {
          ipAddress: backendIP1Ext
          virtualNetwork: {
            id: backendVnetId
          }
        }
      }
      {
        name: '${ILB.name}-ext2'
        properties: {
          ipAddress: backendIP2Ext
          virtualNetwork: {
            id: backendVnetId
          }
        }
      }
    ]
  }
}

resource ILBBackendInt 'Microsoft.Network/loadBalancers/backendAddressPools@2020-11-01' = {
  name: '${ILB.name}/${name}-Backend-int'
  properties: {
    loadBalancerBackendAddresses: configureEmptyBackendPool ? null : [
      {
        name: '${ILB.name}-int1'
        properties: {
          ipAddress: backendIP1Int
          virtualNetwork: {
            id: backendVnetId
          }
        }
      }
      {
        name: '${ILB.name}-int2'
        properties: {
          ipAddress: backendIP2Int
          virtualNetwork: {
            id: backendVnetId
          }
        }
      }
    ]
  }
}

// Outputs
output lbId string = ILB.id
