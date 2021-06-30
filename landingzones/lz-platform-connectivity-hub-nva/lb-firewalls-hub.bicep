// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string 

// vnet
param backendVnetId string

// backend pool
param configureEmptyBackendPool bool

// external
param frontendSubnetIdExt string
param frontendIPExt string
param backendIP1Ext string
param backendIP2Ext string

// management
param frontendSubnetIdMrz string
param frontendIPMrz string
param backendIP1Mrz string
param backendIP2Mrz string

// internal
param frontendSubnetIdInt string
param frontendIPInt string
param backendIP1Int string
param backendIP2Int string

// probe
param lbProbeTcpPort int 

resource ILB 'Microsoft.Network/loadBalancers@2020-11-01' = {
  name: name
  location: resourceGroup().location
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
        name: '${name}-Frontend-mrz'
        properties: {
          privateIPAddress: frontendIPMrz
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: frontendSubnetIdMrz
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
    backendAddressPools: [ {
      name: '${name}-Backend-ext'
    }
    {
      name: '${name}-Backend-mrz'
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
        name: 'lbruleFE2all-mrz'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', name,'${name}-Frontend-mrz')
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
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools',name,'${name}-Backend-mrz')
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


//define the BackendAddressPool
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

resource ILBBackendMrz 'Microsoft.Network/loadBalancers/backendAddressPools@2020-11-01' = {
  name: '${ILB.name}/${name}-Backend-mrz'
  properties: {
    loadBalancerBackendAddresses: configureEmptyBackendPool ? null : [
      {
        name: '${ILB.name}-mrz1'
        properties: {
          ipAddress: backendIP1Mrz
          virtualNetwork: {
            id: backendVnetId
          }
        }
      }
      {
        name: '${ILB.name}-mrz2'
        properties: {
          ipAddress: backendIP2Mrz
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


output lbId string = ILB.id
