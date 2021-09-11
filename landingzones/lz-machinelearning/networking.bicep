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

// SQL MI Subnet
param subnetSqlMIName string
param subnetSqlMIPrefix string

// Azure PaaS private endpoint subnet
param subnetPrivateEndpointsName string
param subnetPrivateEndpointsPrefix string

// AKS Subnet
param subnetAKSName string
param subnetAKSPrefix string

// Private DNS Zones
param privateDnsManagedByHub bool
@description('Required when privateDnsManagedByHub=true')
param privateDnsManagedByHubSubscriptionId string
@description('Required when privateDnsManagedByHub=true')
param privateDnsManagedByHubResourceGroupName string

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

module nsgSqlMi '../../azresources/network/nsg/nsg-sqlmi.bicep' = {
  name: 'deploy-nsg-sqlmi'
  params: {
    name: '${subnetSqlMIName}Nsg'
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

module udrSqlMi '../../azresources/network/udr/udr-sqlmi.bicep' = {
  name: 'deploy-route-table-sqlmi'
  params: {
    name: '${subnetSqlMIName}Udr'
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
        }
      }
      {
        name: subnetAKSName
        properties: {
          addressPrefix: subnetAKSPrefix
          privateEndpointNetworkPolicies: 'Disabled'
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
        name: subnetSqlMIName
        properties: {
          addressPrefix: subnetSqlMIPrefix
          routeTable: {
            id: udrSqlMi.outputs.udrId
          }
          networkSecurityGroup: {
            id: nsgSqlMi.outputs.nsgId
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
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

// Private DNS Zones
module privatezone_sqldb '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-sqldb'
  scope: resourceGroup()
  params: {
    zone: 'privatelink${environment().suffixes.sqlServerHostname}'
    vnetId: vnet.id

    dnsCreateNewZone: !privateDnsManagedByHub
    dnsExistingZoneSubscriptionId: privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: privateDnsManagedByHubResourceGroupName
  }
}

module privatezone_adf '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-adf'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.datafactory.azure.net'
    vnetId: vnet.id

    dnsCreateNewZone: !privateDnsManagedByHub
    dnsExistingZoneSubscriptionId: privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: privateDnsManagedByHubResourceGroupName
  }
}

module privatezone_keyvault '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-keyvault'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.vaultcore.azure.net'
    vnetId: vnet.id

    dnsCreateNewZone: !privateDnsManagedByHub
    dnsExistingZoneSubscriptionId: privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: privateDnsManagedByHubResourceGroupName
  }
}

module privatezone_acr '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-acr'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.azurecr.io'
    vnetId: vnet.id

    dnsCreateNewZone: !privateDnsManagedByHub
    dnsExistingZoneSubscriptionId: privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: privateDnsManagedByHubResourceGroupName
  }
}

module privatezone_datalake_blob '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-blob'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.blob.${environment().suffixes.storage}'
    vnetId: vnet.id

    dnsCreateNewZone: !privateDnsManagedByHub
    dnsExistingZoneSubscriptionId: privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: privateDnsManagedByHubResourceGroupName
  }
}

module privatezone_datalake_dfs '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-dfs'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.dfs.${environment().suffixes.storage}'
    vnetId: vnet.id

    dnsCreateNewZone: !privateDnsManagedByHub
    dnsExistingZoneSubscriptionId: privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: privateDnsManagedByHubResourceGroupName
  }
}

module privatezone_datalake_file '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-file'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.file.${environment().suffixes.storage}'
    vnetId: vnet.id

    dnsCreateNewZone: !privateDnsManagedByHub
    dnsExistingZoneSubscriptionId: privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: privateDnsManagedByHubResourceGroupName
  }
}

module privatezone_azureml_api '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-azureml-api'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.api.azureml.ms'
    vnetId: vnet.id

    dnsCreateNewZone: !privateDnsManagedByHub
    dnsExistingZoneSubscriptionId: privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: privateDnsManagedByHubResourceGroupName
  }
}

module privatezone_azureml_notebook '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-azureml-notebook'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.notebooks.azure.net'
    vnetId: vnet.id

    dnsCreateNewZone: !privateDnsManagedByHub
    dnsExistingZoneSubscriptionId: privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: privateDnsManagedByHubResourceGroupName
  }
}

output vnetId string = vnet.id

output foundationalElementSubnetId string = '${vnet.id}/subnets/${subnetFoundationalElementsName}'
output presentationSubnetId string = '${vnet.id}/subnets/${subnetPresentationName}'
output applicationSubnetId string = '${vnet.id}/subnets/${subnetApplicationName}'
output dataSubnetId string = '${vnet.id}/subnets/${subnetDataName}'
output privateEndpointSubnetId string = '${vnet.id}/subnets/${subnetPrivateEndpointsName}'
output sqlMiSubnetId string = '${vnet.id}/subnets/${subnetSqlMIName}'
output aksSubnetId string = '${vnet.id}/subnets/${subnetAKSName}'

output databricksPublicSubnetName string = subnetDatabricksPublicName
output databricksPrivateSubnetName string = subnetDatabricksPrivateName

output dataLakeDfsPrivateDnsZoneId string = privatezone_datalake_dfs.outputs.privateDnsZoneId
output dataLakeBlobPrivateDnsZoneId string = privatezone_datalake_blob.outputs.privateDnsZoneId
output dataLakeFilePrivateDnsZoneId string = privatezone_datalake_file.outputs.privateDnsZoneId
output adfPrivateDnsZoneId string = privatezone_adf.outputs.privateDnsZoneId
output keyVaultPrivateDnsZoneId string = privatezone_keyvault.outputs.privateDnsZoneId
output acrPrivateDnsZoneId string = privatezone_acr.outputs.privateDnsZoneId
output sqlDBPrivateDnsZoneId string = privatezone_sqldb.outputs.privateDnsZoneId
output amlApiPrivateDnsZoneId string = privatezone_azureml_api.outputs.privateDnsZoneId
output amlNotebooksPrivateDnsZoneId string = privatezone_azureml_notebook.outputs.privateDnsZoneId
