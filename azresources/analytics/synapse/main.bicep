// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param synapseName string
param tags object = {}

param adlsDfsUri string
param adlsFSName string

param managedResourceGroupName string
param computeSubnetId string

param synapseUsername string
@secure()
param synapsePassword string

resource synapse 'Microsoft.Synapse/workspaces@2021-03-01' = {
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
      accountUrl: adlsDfsUri
      filesystem: adlsFSName
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}
