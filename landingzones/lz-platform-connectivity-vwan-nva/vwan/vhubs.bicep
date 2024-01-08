param VirtualWanHUBName string
param VirtualHubAddressPrefix string
param VirtualRouterAutoScaleConfiguration int
param HubRoutingPreference string

@description('Location for the deployment.')
param location string = resourceGroup().location

@description('A set of key/value pairs of tags assigned to the resource group and resources.')
param tags object

param VWANId string

//Create VWAN vHUBs
resource VHUB 'Microsoft.Network/virtualHubs@2023-04-01' = {
  name: VirtualWanHUBName
  location: location
  tags: tags
  properties: {
    addressPrefix: VirtualHubAddressPrefix
    sku: 'Standard'
    virtualWan: {
      id: VWANId
    }
    virtualRouterAutoScaleConfiguration: {
      minCapacity: VirtualRouterAutoScaleConfiguration
    }
    hubRoutingPreference: HubRoutingPreference
  }
}

output resourceId string = VHUB.id
output resourceName string = VHUB.name
