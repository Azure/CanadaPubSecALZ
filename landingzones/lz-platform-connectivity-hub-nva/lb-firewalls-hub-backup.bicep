// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param FrontendSubnetID string
param name string = 'PrdPbPubIlb'
param FrontendIP string
param BackendIP1 string
param BackendIP2 string

resource ILB 'Microsoft.Network/loadBalancers@2020-06-01' = {
  name: name
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: '${name}-Frontend'
        properties: {
          privateIPAddress: FrontendIP
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: FrontendSubnetID
          }
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    backendAddressPools: [ {
      name: '${name}-Backend'
      }
    ]
    loadBalancingRules: [
      {
        name: 'LBRuleHttp'
        properties: {
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false //this was true in the Fortigate HA template, don't know why
          idleTimeoutInMinutes: 4
          protocol: 'Tcp'
          enableTcpReset: false
          loadDistribution: 'Default'
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', name,'${name}-Frontend')
          }
          backendAddressPool: {
            //gotta refer to himself using resourceId() https://github.com/Azure/bicep/issues/1852 , fix in https://github.com/Azure/bicep/issues/1470
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools',name,'${name}-Backend')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes',name,'myHealthProbeHttp')
          }
        }
      }
      {
        name: 'LBRuleHttps'
        properties: {
          frontendPort: 443
          backendPort: 443
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          protocol: 'Tcp'
          enableTcpReset: false
          loadDistribution: 'Default'
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', name,'${name}-Frontend')
          }
          backendAddressPool: {
            //gotta refer to himself using resourceId() https://github.com/Azure/bicep/issues/1852 , fix in https://github.com/Azure/bicep/issues/1470
            id: resourceId('Microsoft.Network/LoadBalancers/backendAddressPools',name,'${name}-Backend')
          }
          probe: {
            id: resourceId('Microsoft.Network/LoadBalancers/probes',name,'myHealthProbeHttps')
          }
        }
      }
    ]
    probes: [
      {
        name: 'myHealthProbeHttp'
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 15
          numberOfProbes: 2
        }
      }
      {
        name: 'myHealthProbeHttps'
        properties: {
          protocol: 'Tcp'
          port: 443
          intervalInSeconds: 15
          numberOfProbes: 2
        }
      }
    ]
  }
}

//define the BackendAddressPool as its own resource, otherwise it doesn't work
resource ILBBackend 'Microsoft.Network/loadBalancers/backendAddressPools@2020-07-01' = {
  name: '${ILB.name}/${name}-Backend'
  properties: {
    loadBalancerBackendAddresses: [
      {
          name: 'FW1'
          properties: {
              ipAddress: BackendIP1
          }
      }
      {
        name: 'FW2'
        properties: {
            ipAddress: BackendIP2
        }
      }
    ]
  }
}

output lbId string = ILB.id
