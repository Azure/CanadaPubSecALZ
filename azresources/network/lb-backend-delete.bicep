// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param loadBalancerBackendPoolFullName  string = 'LBname/BackendPoolName'

//just an example
param loadBalancerBackendAddresses_object array = [
  {
    name: 'server1'
    properties: {
      ipAddress: '10.1.1.1'
    }
  }
  {
    name: 'server2'
    properties: {
      ipAddress: '10.1.1.2'
    } 
  }
]

resource loadBalancerBackendPool 'Microsoft.Network/loadBalancers/backendAddressPools@2020-07-01' = {
  name: loadBalancerBackendPoolFullName
  properties: {
    loadBalancerBackendAddresses: loadBalancerBackendAddresses_object
  }
}
