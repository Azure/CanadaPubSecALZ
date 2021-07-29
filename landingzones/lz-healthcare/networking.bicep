// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

// VNET
param vnetName string
param vnetAddressSpace string

param hubVnetId string

// Virtual Appliance IP
param egressVirtualApplianceIp string

// Hub IP Ranges
param hubRFC1918IPRange string
param hubCGNATIPRange string

// Internal Foundational Elements (OZ) Subnet
param subnetFoundationalElementsName string
param subnetFoundationalElementsPrefix string

// Presentation Zone (PAZ) Subnet
param subnetPresentationName string
param subnetPresentationPrefix string

// Application zone (RZ) Subnet
param subnetApplicationName string
param subnetApplicationPrefix string

// Data Zone (HRZ) Subnet
param subnetDataName string
param subnetDataPrefix string

// Databricks Subnets
param subnetDatabricksPublicName string
param subnetDatabricksPublicPrefix string

param subnetDatabricksPrivateName string
param subnetDatabricksPrivatePrefix string

// Azure PaaS private endpoint subnet
param subnetPrivateEndpointsName string
param subnetPrivateEndpointsPrefix string

// Synapse Analytics Subnet
param subnetSynapseName string
param subnetSynapsePrefix string

// Network Security Groups
resource nsgFoundationalElements 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: '${subnetFoundationalElementsName}Nsg'
  location: resourceGroup().location
  properties: {
    securityRules: []
  }
}

resource nsgPresentation 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: '${subnetPresentationName}Nsg'
  location: resourceGroup().location
  properties: {
    securityRules: []
  }
}

resource nsgApplication 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: '${subnetApplicationName}Nsg'
  location: resourceGroup().location
  properties: {
    securityRules: []
  }
}

resource nsgData 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: '${subnetDataName}Nsg'
  location: resourceGroup().location
  properties: {
    securityRules: []
  }
}

module nsgDatabricks '../../azresources/network/nsg/nsg-databricks.bicep' = {
  name: 'deploy-nsg-databricks'
  params: {
    namePublic: '${subnetDatabricksPublicName}Nsg'
    namePrivate: '${subnetDatabricksPrivateName}Nsg'
  }
}

// Route Tables
resource udrFoundationalElements 'Microsoft.Network/routeTables@2020-06-01' = {
  name: '${subnetFoundationalElementsName}Udr'
  location: resourceGroup().location
  properties: {
    routes: [
      // Force Routes to Hub IPs (RFC1918 range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubRFC1918FWRoute'
        properties: {
          addressPrefix: hubRFC1918IPRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
      // Force Routes to Hub IPs (CGNAT range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubCGNATFWRoute'
        properties: {
          addressPrefix: hubCGNATIPRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
      {
        name: 'RouteToEgressFirewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
    ]
  }
}

resource udrPresentation 'Microsoft.Network/routeTables@2020-06-01' = {
  name: '${subnetPresentationName}Udr'
  location: resourceGroup().location
  properties: {
    routes: [
      // Force Routes to Hub IPs (RFC1918 range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubRFC1918FWRoute'
        properties: {
          addressPrefix: hubRFC1918IPRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
      // Force Routes to Hub IPs (CGNAT range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubCGNATFWRoute'
        properties: {
          addressPrefix: hubCGNATIPRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
      {
        name: 'RouteToEgressFirewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
    ]
  }
}

resource udrApplication 'Microsoft.Network/routeTables@2020-06-01' = {
  name: '${subnetApplicationName}Udr'
  location: resourceGroup().location
  properties: {
    routes: [
      // Force Routes to Hub IPs (RFC1918 range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubRFC1918FWRoute'
        properties: {
          addressPrefix: hubRFC1918IPRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
      // Force Routes to Hub IPs (CGNAT range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubCGNATFWRoute'
        properties: {
          addressPrefix: hubCGNATIPRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
      {
        name: 'RouteToEgressFirewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
    ]
  }
}

resource udrData 'Microsoft.Network/routeTables@2020-06-01' = {
  name: '${subnetDataName}Udr'
  location: resourceGroup().location
  properties: {
    routes: [
      // Force Routes to Hub IPs (RFC1918 range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubRFC1918FWRoute'
        properties: {
          addressPrefix: hubRFC1918IPRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
      // Force Routes to Hub IPs (CGNAT range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubCGNATFWRoute'
        properties: {
          addressPrefix: hubCGNATIPRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
      {
        name: 'RouteToEgressFirewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
    ]
  }
}

module udrDatabricksPublic '../../azresources/network/udr/udr-databricks-public.bicep' = {
  name: 'deploy-route-table-databricks-public'
  params: {
    name: '${subnetDatabricksPublicName}Udr'
  }
}

module udrDatabricksPrivate '../../azresources/network/udr/udr-databricks-private.bicep' = {
  name: 'deploy-route-table-databricks-private'
  params: {
    name: '${subnetDatabricksPrivateName}Udr'
  }
}

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      {
        name: subnetFoundationalElementsName
        properties: {
          addressPrefix: subnetFoundationalElementsPrefix
          routeTable: {
            id: udrFoundationalElements.id
          }
          networkSecurityGroup: {
            id: nsgFoundationalElements.id
          }
        }
      }
      {
        name: subnetPresentationName
        properties: {
          addressPrefix: subnetPresentationPrefix
          routeTable: {
            id: udrPresentation.id
          }
          networkSecurityGroup: {
            id: nsgPresentation.id
          }
        }
      }
      {
        name: subnetApplicationName
        properties: {
          addressPrefix: subnetApplicationPrefix
          routeTable: {
            id: udrApplication.id
          }
          networkSecurityGroup: {
            id: nsgApplication.id
          }
        }
      }
      {
        name: subnetDataName
        properties: {
          addressPrefix: subnetDataPrefix
          routeTable: {
            id: udrData.id
          }
          networkSecurityGroup: {
            id: nsgData.id
          }
        }
      }
      {
        name: subnetPrivateEndpointsName
        properties: {
          addressPrefix: subnetPrivateEndpointsPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
      {
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
      {
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
      {
        name: subnetSynapseName
        properties: {
          addressPrefix: subnetSynapsePrefix
        }
      }
    ]
  }
}

module vnetPeeringSpokeToHub '../../azresources/network/vnet-peering.bicep' = if (!empty(hubVnetId)) {
  name: 'deploy-vnet-peering-spoke-to-hub'
  scope: resourceGroup()
  params: {
    peeringName: 'SpokeToHub-${vnet.name}'
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    sourceVnetName: vnet.name
    targetVnetId: hubVnetId
    //useRemoteGateways: true
  }
}

// Private Zones
module privatezone_sqldb '../../azresources/network/private-zone.bicep' = {
  name: 'deploy-privatezone-sqldb'
  scope: resourceGroup()
  params: {
    zone: 'privatelink${environment().suffixes.sqlServerHostname}'
    vnetId: vnet.id
  }
}

module privatezone_adf '../../azresources/network/private-zone.bicep' = {
  name: 'deploy-privatezone-adf'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.datafactory.azure.net'
    vnetId: vnet.id
  }
}

module privatezone_keyvault '../../azresources/network/private-zone.bicep' = {
  name: 'deploy-privatezone-keyvault'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.vaultcore.azure.net'
    vnetId: vnet.id
  }
}

module privatezone_acr '../../azresources/network/private-zone.bicep' = {
  name: 'deploy-privatezone-acr'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.azurecr.io'
    vnetId: vnet.id
  }
}

module privatezone_datalake_blob '../../azresources/network/private-zone.bicep' = {
  name: 'deploy-privatezone-blob'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.blob.${environment().suffixes.storage}'
    vnetId: vnet.id
  }
}

module privatezone_datalake_dfs '../../azresources/network/private-zone.bicep' = {
  name: 'deploy-privatezone-dfs'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.dfs.${environment().suffixes.storage}'
    vnetId: vnet.id
  }
}

module privatezone_datalake_file '../../azresources/network/private-zone.bicep' = {
  name: 'deploy-privatezone-file'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.file.${environment().suffixes.storage}'
    vnetId: vnet.id
  }
}

module privatezone_azureml_api '../../azresources/network/private-zone.bicep' = {
  name: 'deploy-privatezone-azureml-api'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.api.azureml.ms'
    vnetId: vnet.id
  }
}

module privatezone_azureml_notebook '../../azresources/network/private-zone.bicep' = {
  name: 'deploy-privatezone-azureml-notebook'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.notebooks.azure.net'
    vnetId: vnet.id
  }
}

module privatezone_fhir '../../azresources/network/private-zone.bicep' = {
  name: 'deploy-privatezone-fhir'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.azurehealthcareapis.com'
    vnetId: vnet.id
  }
}

output vnetId string = vnet.id

output foundationalElementSubnetId string = '${vnet.id}/subnets/${subnetFoundationalElementsName}'
output presentationSubnetId string = '${vnet.id}/subnets/${subnetPresentationName}'
output applicationSubnetId string = '${vnet.id}/subnets/${subnetApplicationName}'
output dataSubnetId string = '${vnet.id}/subnets/${subnetDataName}'
output privateEndpointSubnetId string = '${vnet.id}/subnets/${subnetPrivateEndpointsName}'
output synapseSubnetId string = '${vnet.id}/subnets/${subnetSynapseName}'

output databricksPublicSubnetName string = subnetDatabricksPublicName
output databricksPrivateSubnetName string = subnetDatabricksPrivateName

output dataLakeDfsPrivateZoneId string = privatezone_datalake_dfs.outputs.privateZoneId
output dataLakeBlobPrivateZoneId string = privatezone_datalake_blob.outputs.privateZoneId
output dataLakeFilePrivateZoneId string = privatezone_datalake_file.outputs.privateZoneId
output adfPrivateZoneId string = privatezone_adf.outputs.privateZoneId
output keyVaultPrivateZoneId string = privatezone_keyvault.outputs.privateZoneId
output acrPrivateZoneId string = privatezone_acr.outputs.privateZoneId
output sqlDBPrivateZoneId string = privatezone_sqldb.outputs.privateZoneId
output amlApiPrivateZoneId string = privatezone_azureml_api.outputs.privateZoneId
output amlNotebooksPrivateZoneId string = privatezone_azureml_notebook.outputs.privateZoneId
output fhirPrivateZoneId string = privatezone_fhir.outputs.privateZoneId
