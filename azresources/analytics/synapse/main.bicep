// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param synapseName string
param tags object = {}

param adlsResourceGroupName string
param adlsName string
param adlsFSName string

param managedResourceGroupName string

param synapseUsername string
@secure()
param synapsePassword string

param privateEndpointSubnetId string
param synapsePrivateZoneId string
param synapseDevPrivateZoneId string
param synapseSqlPrivateZoneId string

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

resource synapsePrivateLinkHub 'Microsoft.Synapse/privateLinkHubs@2021-03-01' = {
  name: '${toLower(synapseName)}plhub'
  tags: tags
  location: resourceGroup().location
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

    managedVirtualNetwork: 'default'
    managedVirtualNetworkSettings: {
      preventDataExfiltration: true
    }

    publicNetworkAccess: 'Disabled'

    defaultDataLakeStorage: {
      accountUrl: adls.properties.primaryEndpoints.dfs
      filesystem: adlsFSName
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource synapse_workspace_web_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: resourceGroup().location
  name: '${synapse.name}-web-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${synapse.name}-web-endpoint'
        properties: {
          privateLinkServiceId: synapsePrivateLinkHub.id
          groupIds: [
            'web'
          ]
        }
      }
    ]
  }
}

resource synapse_workspace_web_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${synapse_workspace_web_pe.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-synapse-workspace-web'
        properties: {
          privateDnsZoneId: synapsePrivateZoneId
        }
      }
    ]
  }
}

resource synapse_workspace_dev_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: resourceGroup().location
  name: '${synapse.name}-workspace-dev-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${synapse.name}-workspace-dev-endpoint'
        properties: {
          privateLinkServiceId: synapse.id
          groupIds: [
            'dev'
          ]
        }
      }
    ]
  }
}

resource synapse_workspace_dev_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${synapse_workspace_dev_pe.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-synapse-workspace-dev'
        properties: {
          privateDnsZoneId: synapseDevPrivateZoneId
        }
      }
    ]
  }
}

resource synapse_workspace_sql_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: resourceGroup().location
  name: '${synapse.name}-workspace-sql-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${synapse.name}-workspace-sql-endpoint'
        properties: {
          privateLinkServiceId: synapse.id
          groupIds: [
            'sql'
          ]
        }
      }
    ]
  }
}

resource synapse_workspace_sql_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${synapse_workspace_sql_pe.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-synapse-workspace-sql'
        properties: {
          privateDnsZoneId: synapseSqlPrivateZoneId
        }
      }
    ]
  }
}

resource synapse_workspace_sql_on_demand_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: resourceGroup().location
  name: '${synapse.name}-workspace-sql-ondemand-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${synapse.name}-workspace-sql-ondemand-endpoint'
        properties: {
          privateLinkServiceId: synapse.id
          groupIds: [
            'sqlondemand'
          ]
        }
      }
    ]
  }
}

resource synapse_workspace_sql_on_demand_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${synapse_workspace_sql_on_demand_pe.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-synapse-workspace-sql-ondemand'
        properties: {
          privateDnsZoneId: synapseSqlPrivateZoneId
        }
      }
    ]
  }
}

// Assign the workspace's system-assigned managed identity CONTROL permissions to SQL pools for pipeline integration
resource synapse_msi_sql_control_settings 'Microsoft.Synapse/workspaces/managedIdentitySqlControlSettings@2021-05-01' = {
  name: '${synapse.name}/default'
  properties: {
    grantSqlControlToManagedIdentity: {
      desiredState: 'Enabled'
    }
  }
}
