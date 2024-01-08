param name string
param scaleUnits int = 1

@description('Location for the deployment.')
param location string = resourceGroup().location

@description('A set of key/value pairs of tags assigned to the resource group and resources.')
param tags object

param vHUBId string

resource resERGW 'Microsoft.Network/expressRouteGateways@2023-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    virtualHub: {
      id: vHUBId
    }
    autoScaleConfiguration: {
      bounds: {
        min: scaleUnits
      }
    }
  }
}

output resourceId string = resERGW.id
output resourceName string = resERGW.name
