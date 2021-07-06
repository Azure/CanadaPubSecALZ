// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param synapseName string
param tags object = {}
param managedResourceGroupName string
param synapseUsername string
@secure()
param synapsePassword string

param computeSubnetId string

resource synapseadlegen2 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  location: resourceGroup().location
  name: 'synadlsg2${uniqueString(resourceGroup().id)}'
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_GRS'
  }
  tags: tags
  properties: {
    accessTier: 'Hot'
    isHnsEnabled: true
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  dependsOn: [
    synapseadlegen2
  ]
  name: '${synapseadlegen2.name}/default/synapsecontainer'
}


resource synapse 'Microsoft.Synapse/workspaces@2021-03-01' = {
  dependsOn: [
    synapseadlegen2
    container
  ]
  name: synapseName
  tags: tags
  location: resourceGroup().location
  properties: {
    sqlAdministratorLoginPassword: synapsePassword
    managedResourceGroupName: managedResourceGroupName
    sqlAdministratorLogin: synapseUsername
    virtualNetworkProfile: {
      computeSubnetId: computeSubnetId
    }

    managedVirtualNetwork: 'default'
    managedVirtualNetworkSettings: {
      preventDataExfiltration: false
    }
    networkSettings: {
      publicNetworkAccess: 'Disabled'
    }
    defaultDataLakeStorage: {
      accountUrl: synapseadlegen2.properties.primaryEndpoints.dfs
      filesystem: 'synapsecontainer'
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}
