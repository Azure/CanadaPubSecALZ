param name string

@description('Location for the deployment.')
param location string = resourceGroup().location

@description('A set of key/value pairs of tags assigned to the resource group and resources.')
param tags object

// Create VWAN resource
resource resVWAN 'Microsoft.Network/virtualWans@2023-04-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    allowBranchToBranchTraffic: true
    allowVnetToVnetTraffic: true
    disableVpnEncryption: false
    type: 'Standard'
  }
}

output resourceId string = resVWAN.id
