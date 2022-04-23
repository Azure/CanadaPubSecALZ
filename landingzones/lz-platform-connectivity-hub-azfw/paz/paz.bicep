targetScope = 'subscription'

@description('Location for the deployment.')
param location string = deployment().location

@description('A set of key/value pairs of tags assigned to the resource group and resources.')
param resourceTags object

@description('Public Access Zone configuration.  See docs/archetypes/hubnetwork-azfw.md for configuration settings.')
param publicAccessZone object

// Create Public Access Zone Resource Group
resource rgPaz 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: publicAccessZone.resourceGroupName
  location: location
  tags: resourceTags
}

module rgPazDeleteLock '../../../azresources/util/delete-lock.bicep' = {
  name: 'deploy-delete-lock-${publicAccessZone.resourceGroupName}'
  scope: rgPaz
}

