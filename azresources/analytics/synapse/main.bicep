// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param synapseName string
param tags object = {}

param deploymentScriptIdentityId string

param adlsResourceGroupName string
param adlsName string
param adlsFSName string

param managedResourceGroupName string
param computeSubnetId string

param synapseUsername string
@secure()
param synapsePassword string

resource adls 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  scope: resourceGroup(adlsResourceGroupName)
  name: adlsName
}

module dataLakeSynapseFS '../../storage/storage-adlsgen2-fs.bicep' = {
  name: 'deploy-datalake-fs-for-synapse'
  scope: resourceGroup(adlsResourceGroupName)
  params: {
    adlsName: adlsName
    fsName: adlsFSName
  }
}

resource synapse 'Microsoft.Synapse/workspaces@2021-03-01' = {
  dependsOn: [
    dataLakeSynapseFS
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
      accountUrl: adls.properties.primaryEndpoints.dfs
      filesystem: adlsFSName
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Grant access from Azure resource instances
var azCliCommand = '''
  az extension add -n storage-preview

  az storage account network-rule add \
  --resource-id {0} \
  --tenant-id {1} \
  -g {2} \
  --account-name {3}
'''

module addResourceAccess '../../util/deploymentScript.bicep' = { 
  name: 'grant-resource-instance-access-${adlsName}'
  params: {
    deploymentScript: format(azCliCommand, synapse.id, subscription().tenantId, adlsResourceGroupName, adlsName)
    deploymentScriptName: 'grant-access-${synapse.name}-${adlsName}'
    deploymentScriptIdentityId: deploymentScriptIdentityId
  }
}
