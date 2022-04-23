targetScope = 'subscription'

param location string = deployment().location
param resourceTags object

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

