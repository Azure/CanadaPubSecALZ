// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string

@allowed([
  'trial'
  'standard'
  'premium'
])
param pricingTier string
param vnetId string
param publicSubnetName string
param privateSubnetName string

param loadbalancerId string
param loadBalancerBackendPoolName string

param managedResourceGroupId string

param tags object = {}

resource databricks 'Microsoft.Databricks/workspaces@2018-04-01' = {
  name: name
  tags: tags
  location: resourceGroup().location
  sku: {
    name: pricingTier
  }
  properties: {
    managedResourceGroupId: managedResourceGroupId
    parameters: {
      customVirtualNetworkId: {
        value: vnetId
      } 
      customPrivateSubnetName: {
        value: privateSubnetName
      }
      customPublicSubnetName: {
        value: publicSubnetName
      }
      enableNoPublicIp: {
        value: true
      }
      loadBalancerId: {
        value: loadbalancerId
      }
      loadBalancerBackendPoolName: {
        value: loadBalancerBackendPoolName
      }
    }
  }
}
