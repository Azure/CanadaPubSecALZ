// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param BackendVNet_ID string
param FrontendSubnetID_ext string
param FrontendSubnetID_mrz string
param FrontendSubnetID_int string
param name string 
param FrontendIP_ext string
param BackendIP1_ext string
param BackendIP2_ext string
param FrontendIP_mrz string
param BackendIP1_mrz string
param BackendIP2_mrz string
param FrontendIP_int string
param BackendIP1_int string
param BackendIP2_int string
param LB_Probe_tcp_port int 
param configureEmptyBackendPool bool

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
          privateIPAddress: FrontendIP_ext
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: FrontendSubnetID_ext
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
          privateIPAddress: FrontendIP_mrz
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: FrontendSubnetID_mrz
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
          privateIPAddress: FrontendIP_int
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: FrontendSubnetID_int
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
          port: LB_Probe_tcp_port
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}


//define the BackendAddressPool
resource ILBBackend_ext 'Microsoft.Network/loadBalancers/backendAddressPools@2020-11-01' = {
  name: '${ILB.name}/${name}-Backend-ext'
  properties: {
    loadBalancerBackendAddresses: configureEmptyBackendPool ? null : [
      {
        name: '${ILB.name}-ext1'
        properties: {
          ipAddress: BackendIP1_ext
          virtualNetwork: {
            id: BackendVNet_ID
          }
        }
      }
      {
        name: '${ILB.name}-ext2'
        properties: {
          ipAddress: BackendIP2_ext
          virtualNetwork: {
            id: BackendVNet_ID
          }
        }
      }
    ]
  }
}

resource ILBBackend_mrz 'Microsoft.Network/loadBalancers/backendAddressPools@2020-11-01' = {
  name: '${ILB.name}/${name}-Backend-mrz'
  properties: {
    loadBalancerBackendAddresses: configureEmptyBackendPool ? null : [
      {
        name: '${ILB.name}-mrz1'
        properties: {
          ipAddress: BackendIP1_mrz
          virtualNetwork: {
            id: BackendVNet_ID
          }
        }
      }
      {
        name: '${ILB.name}-mrz2'
        properties: {
          ipAddress: BackendIP2_mrz
          virtualNetwork: {
            id: BackendVNet_ID
          }
        }
      }
    ]
  }
}

resource ILBBackend_int 'Microsoft.Network/loadBalancers/backendAddressPools@2020-11-01' = {
  name: '${ILB.name}/${name}-Backend-int'
  properties: {
    loadBalancerBackendAddresses: configureEmptyBackendPool ? null : [
      {
        name: '${ILB.name}-int1'
        properties: {
          ipAddress: BackendIP1_int
          virtualNetwork: {
            id: BackendVNet_ID
          }
        }
      }
      {
        name: '${ILB.name}-int2'
        properties: {
          ipAddress: BackendIP2_int
          virtualNetwork: {
            id: BackendVNet_ID
          }
        }
      }
    ]
  }
}


output lbId string = ILB.id
