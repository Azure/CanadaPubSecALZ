// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Azure Databricks Name.')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

@description('Azure Databricks Managed Resource Group Id')
param managedResourceGroupId string

@description('Azure Databricks Pricing Tier.')
@allowed([
  'trial'
  'standard'
  'premium'
])
param pricingTier string

// Networking
@description('Virtual Network Resource Id')
param vnetId string

@description('Public Subnet Name.')
param publicSubnetName string

@description('Private Subnet Name.')
param privateSubnetName string

@description('Egress Azure Load Balancer Resource Id.')
param loadbalancerId string

@description('Egress Azure Load Balancer Backend Pool Name.')
param loadBalancerBackendPoolName string

// Create Azure Databricks without Public IPs and use Egress Load Balancer for integrating with Azure.
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
