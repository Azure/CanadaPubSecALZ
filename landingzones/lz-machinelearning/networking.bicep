// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param vnetName string
param vnetId string

param subnetDatabricksPublicName string
param subnetDatabricksPublicPrefix string

param subnetDatabricksPrivateName string
param subnetDatabricksPrivatePrefix string

param subnetSqlMIName string
param subnetSqlMIPrefix string

param subnetPrivateEndpointsName string
param subnetPrivateEndpointsPrefix string

param subnetAKSName string
param subnetAKSPrefix string

param deploySQLDB bool
param deploySQLMI bool

// Network Security Groups
module nsgDatabricks '../../azresources/network/nsg/nsg-databricks.bicep' = {
  name: 'nsgDatabricks'
  params: {
    namePublic: '${subnetDatabricksPublicName}Nsg'
    namePrivate: '${subnetDatabricksPrivateName}Nsg'
  }
}

module nsgSqlMi '../../azresources/network/nsg/nsg-sqlmi.bicep' = if (deploySQLMI == true){
  name: 'nsgSqlMi'
  params: {
    name: '${subnetSqlMIName}Nsg'
  }
}

// Route Tables
module udrSqlMi '../../azresources/network/udr/udr-sqlmi.bicep' = if (deploySQLMI == true){
  name: 'udrSqlMi'
  params: {
    name: '${subnetSqlMIName}Udr'
  }
}

module udrDatabricksPublic '../../azresources/network/udr/udr-databricks-public.bicep' = {
  name: 'udrDatabricksPublic'
  params: {
    name: '${subnetDatabricksPublicName}Udr'
  }
}

module udrDatabricksPrivate '../../azresources/network/udr/udr-databricks-private.bicep' = {
  name: 'udrDatabricksPrivate'
  params: {
    name: '${subnetDatabricksPrivateName}Udr'
  }
}

// Private Zones
module privatezone_datalake_dfs '../../azresources/network/private-zone.bicep' = {
  name: 'datalake_dfs_private_zone'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.dfs.core.windows.net'
    vnetId: vnetId
  }
}

module privatezone_sqldb '../../azresources/network/private-zone.bicep' = if (deploySQLDB == true){
  name: 'sqldb_private_zone'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.database.windows.net'
    vnetId: vnetId
  }
}

module privatezone_adf '../../azresources/network/private-zone.bicep' = {
  name: 'adf_private_zone'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.datafactory.azure.net'
    vnetId: vnetId
  }
}

module privatezone_keyvault '../../azresources/network/private-zone.bicep' = {
  name: 'keyvault_private_zone'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.vaultcore.azure.net'
    vnetId: vnetId
  }
}

module privatezone_acr '../../azresources/network/private-zone.bicep' = {
  name: 'acr_private_zone'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.azurecr.io'
    vnetId: vnetId
  }
}

module privatezone_datalake_blob '../../azresources/network/private-zone.bicep' = {
  name: 'datalake_blob_private_zone'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.blob.core.windows.net'
    vnetId: vnetId
  }
}
module privatezone_datalake_file '../../azresources/network/private-zone.bicep' = {
  name: 'datalake_file_private_zone'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.file.core.windows.net'
    vnetId: vnetId
  }
}

module privatezone_azureml_api '../../azresources/network/private-zone.bicep' = {
  name: 'privatezone_azureml_api'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.api.azureml.ms'
    vnetId: vnetId
  }
}

module privatezone_azureml_notebook '../../azresources/network/private-zone.bicep' = {
  name: 'privatezone_azureml_notebook'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.notebooks.azure.net'
    vnetId: vnetId
  }
}

// Landing Zone specific subnets - required for private endpoints
resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: vnetName
}

resource subnetPrivateEndpoints 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = {
  parent: vnet
  name: subnetPrivateEndpointsName
  properties: {
    addressPrefix: subnetPrivateEndpointsPrefix
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

resource subnetAks 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = {
  dependsOn: [
    subnetPrivateEndpoints
  ]
  parent: vnet
  name: subnetAKSName
  properties: {
    addressPrefix: subnetAKSPrefix
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

// Landing Zone specific subnets - required due to subnet delegation
resource subnetDatabricksPublic 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = {
  dependsOn: [
    subnetAks
  ]
  parent: vnet
  name: subnetDatabricksPublicName
  properties: {
    addressPrefix: subnetDatabricksPublicPrefix
    networkSecurityGroup: {
      id: nsgDatabricks.outputs.publicNsgId
    }
    routeTable: {
      id: udrDatabricksPublic.outputs.udrId
    }
    delegations: [
      {
        name: 'databricks-delegation-public'
        properties: {
          serviceName: 'Microsoft.Databricks/workspaces'
        }
      }
    ]
  }
}

resource subnetDatabricksPrivate 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = {
  dependsOn: [
    subnetDatabricksPublic
  ]
  parent: vnet
  name: subnetDatabricksPrivateName
  properties: {
    addressPrefix: subnetDatabricksPrivatePrefix
    networkSecurityGroup: {
      id: nsgDatabricks.outputs.privateNsgId
    }
    routeTable: {
      id: udrDatabricksPrivate.outputs.udrId
    }
    delegations: [
      {
        name: 'databricks-delegation-private'
        properties: {
          serviceName: 'Microsoft.Databricks/workspaces'
        }
      }
    ]
  }
}

resource subnetSqlMI 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = if (deploySQLMI == true){
  dependsOn: [
    subnetDatabricksPrivate
  ]
  parent: vnet
  name: subnetSqlMIName
  properties: {
    addressPrefix: subnetSqlMIPrefix
    routeTable: {
      id: '${deploySQLMI ? udrSqlMi.outputs.udrId : ''}'
    }
    networkSecurityGroup: {
      id: '${deploySQLMI ? nsgSqlMi.outputs.nsgId : ''}'
    }
    delegations: [
      {
        name: 'sqlmi-delegation'
        properties: {
          serviceName: 'Microsoft.Sql/managedInstances'
        }
      }
    ]
  }
}

output privateEndpointSubnetId string = '${vnetId}/subnets/${subnetPrivateEndpoints.name}'
output sqlMiSubnetId string = deploySQLMI ? '${vnetId}/subnets/${subnetSqlMI.name}': ''
output aksSubnetId string = '${vnetId}/subnets/${subnetAks.name}'

output databricksPublicSubnetName string = subnetDatabricksPublic.name
output databricksPrivateSubnetName string = subnetDatabricksPrivate.name

output dataLakeDfsPrivateZoneId string = privatezone_datalake_dfs.outputs.privateZoneId
output dataLakeBlobPrivateZoneId string = privatezone_datalake_blob.outputs.privateZoneId
output dataLakeFilePrivateZoneId string = privatezone_datalake_file.outputs.privateZoneId
output adfPrivateZoneId string = privatezone_adf.outputs.privateZoneId
output keyVaultPrivateZoneId string = privatezone_keyvault.outputs.privateZoneId
output acrPrivateZoneId string = privatezone_acr.outputs.privateZoneId
output sqlDBPrivateZoneId string = deploySQLDB ? privatezone_sqldb.outputs.privateZoneId: ''
output amlApiPrivateZoneId string = privatezone_azureml_api.outputs.privateZoneId
output amlNotebooksPrivateZoneId string = privatezone_azureml_notebook.outputs.privateZoneId
