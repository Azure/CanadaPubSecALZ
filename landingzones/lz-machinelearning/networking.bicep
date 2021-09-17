// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

// VNET
@description('Virtual Network Name.')
param vnetName string

@description('Virtual Network Address Space.')
param vnetAddressSpace string

@description('Hub Virtual Network Resource Id.  It is required for configuring Virtual Network Peering & configuring route tables.')
param hubVnetId string

// Internal Foundational Elements (OZ) Subnet
@description('Foundational Element (OZ) Subnet Name')
param subnetFoundationalElementsName string

@description('Foundational Element (OZ) Subnet Address Prefix.')
param subnetFoundationalElementsPrefix string

// Presentation Zone (PAZ) Subnet
@description('Presentation Zone (PAZ) Subnet Name.')
param subnetPresentationName string

@description('Presentation Zone (PAZ) Subnet Address Prefix.')
param subnetPresentationPrefix string

// Application zone (RZ) Subnet
@description('Application (RZ) Subnet Name.')
param subnetApplicationName string

@description('Application (RZ) Subnet Address Prefix.')
param subnetApplicationPrefix string

// Data Zone (HRZ) Subnet
@description('Data Zone (HRZ) Subnet Name.')
param subnetDataName string

@description('Data Zone (HRZ) Subnet Address Prefix.')
param subnetDataPrefix string

// Delegated Subnets
@description('Delegated SQL MI Subnet Name.')
param subnetSQLMIName string

@description('Delegated SQL MI Subnet Address Prefix.')
param subnetSQLMIPrefix string

@description('Delegated Databricks Public Subnet Name.')
param subnetDatabricksPublicName string

@description('Delegated Databricks Public Subnet Address Prefix.')
param subnetDatabricksPublicPrefix string

@description('Delegated Databricks Private Subnet Name.')
param subnetDatabricksPrivateName string

@description('Delegated Databricks Private Subnet Address Prefix.')
param subnetDatabricksPrivatePrefix string

// Priavte Endpoint Subnet
@description('Private Endpoints Subnet Name.  All private endpoints will be deployed to this subnet.')
param subnetPrivateEndpointsName string

@description('Private Endpoint Subnet Address Prefix.')
param subnetPrivateEndpointsPrefix string

// AKS Subnet
@description('AKS Subnet Name.')
param subnetAKSName string

@description('AKS Subnet Address Prefix.')
param subnetAKSPrefix string

// Virtual Appliance IP
@description('Egress Virtual Appliance IP.  It should be the IP address of the network virtual appliance.')
param egressVirtualApplianceIp string

// Hub IP Ranges
@description('Hub Virtual Network IP Address - RFC 1918')
param hubRFC1918IPRange string

@description('Hub Virtual Network IP Address - RFC 6598 (CGNAT)')
param hubRFC6598IPRange string

// Private DNS Zones
@description('Boolean flag to determine whether Private DNS Zones will be managed by Hub Network.')
param privateDnsManagedByHub bool = false

@description('Private DNS Zone Subscription Id.  Required when privateDnsManagedByHub=true')
param privateDnsManagedByHubSubscriptionId string = ''

@description('Private DNS Zone Resource Group Name.  Required when privateDnsManagedByHub=true')
param privateDnsManagedByHubResourceGroupName string = ''

var integrateToHubVirtualNetwork = !empty(hubVnetId)
var hubVnetIdSplit = split(hubVnetId, '/')

var routesToHub = [
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
    name: 'PrdSpokesUdrHubRFC6598FWRoute'
    properties: {
      addressPrefix: hubRFC6598IPRange
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

// Network Security Groups
resource nsgFoundationalElements 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: '${subnetFoundationalElementsName}Nsg'
  location: resourceGroup().location
  properties: {
    securityRules: []
  }
}

resource nsgPresentation 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: '${subnetPresentationName}Nsg'
  location: resourceGroup().location
  properties: {
    securityRules: []
  }
}

resource nsgApplication 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: '${subnetApplicationName}Nsg'
  location: resourceGroup().location
  properties: {
    securityRules: []
  }
}

resource nsgData 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
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
    name: '${subnetSQLMIName}Nsg'
  }
}

// Route Tables
resource udrFoundationalElements 'Microsoft.Network/routeTables@2021-02-01' = {
  name: '${subnetFoundationalElementsName}Udr'
  location: resourceGroup().location
  properties: {
    routes: integrateToHubVirtualNetwork ? routesToHub : null
  }
}

resource udrPresentation 'Microsoft.Network/routeTables@2021-02-01' = {
  name: '${subnetPresentationName}Udr'
  location: resourceGroup().location
  properties: {
    routes: integrateToHubVirtualNetwork ? routesToHub : null
  }
}

resource udrApplication 'Microsoft.Network/routeTables@2021-02-01' = {
  name: '${subnetApplicationName}Udr'
  location: resourceGroup().location
  properties: {
    routes: integrateToHubVirtualNetwork ? routesToHub : null
  }
}

resource udrData 'Microsoft.Network/routeTables@2021-02-01' = {
  name: '${subnetDataName}Udr'
  location: resourceGroup().location
  properties: {
    routes: integrateToHubVirtualNetwork ? routesToHub : null
  }
}

module udrSqlMi '../../azresources/network/udr/udr-sqlmi.bicep' = {
  name: 'deploy-route-table-sqlmi'
  params: {
    name: '${subnetSQLMIName}Udr'
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
resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
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
        name: subnetSQLMIName
        properties: {
          addressPrefix: subnetSQLMIPrefix
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
    peeringName: 'Hub-${vnet.name}-to-${last(hubVnetIdSplit)}'
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    sourceVnetName: vnet.name
    targetVnetId: hubVnetId
    //useRemoteGateways: true
  }
}

// For Hub to Spoke vnet peering, we must rescope the deployment to the subscription id & resource group of where the Hub VNET is located.
module vnetPeeringHubToSpoke '../../azresources/network/vnet-peering.bicep' = if (integrateToHubVirtualNetwork) {
  name: 'deploy-vnet-peering-${subscription().subscriptionId}'
  // vnet id = /subscriptions/<<SUBSCRIPTION ID>>/resourceGroups/<<RESOURCE GROUP>>/providers/Microsoft.Network/virtualNetworks/<<VNET NAME>>
  scope: resourceGroup(integrateToHubVirtualNetwork ? hubVnetIdSplit[2] : '', integrateToHubVirtualNetwork ? hubVnetIdSplit[4] : '')
  params: {
    peeringName: 'Spoke-${last(hubVnetIdSplit)}-to-${vnet.name}-${uniqueString(vnet.id)}'
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    sourceVnetName: last(hubVnetIdSplit)
    targetVnetId: vnet.id
    useRemoteGateways: false
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

module privatezone_adf_datafactory '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-adf-datafactory'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.datafactory.azure.net'
    vnetId: vnet.id

    dnsCreateNewZone: !privateDnsManagedByHub
    dnsExistingZoneSubscriptionId: privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: privateDnsManagedByHubResourceGroupName
  }
}

module privatezone_adf_portal '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-adf-portal'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.adf.azure.com'
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

module privatezone_aks '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-aks'
  scope: resourceGroup()
  params: {
    zone: toLower('privatelink.${resourceGroup().location}.azmk8s.io')
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
output sqlMiSubnetId string = '${vnet.id}/subnets/${subnetSQLMIName}'
output aksSubnetId string = '${vnet.id}/subnets/${subnetAKSName}'

output databricksPublicSubnetName string = subnetDatabricksPublicName
output databricksPrivateSubnetName string = subnetDatabricksPrivateName

output dataLakeDfsPrivateDnsZoneId string = privatezone_datalake_dfs.outputs.privateDnsZoneId
output dataLakeBlobPrivateDnsZoneId string = privatezone_datalake_blob.outputs.privateDnsZoneId
output dataLakeFilePrivateDnsZoneId string = privatezone_datalake_file.outputs.privateDnsZoneId
output adfDataFactoryPrivateDnsZoneId string = privatezone_adf_datafactory.outputs.privateDnsZoneId
output adfPortalPrivateDnsZoneId string = privatezone_adf_portal.outputs.privateDnsZoneId
output keyVaultPrivateDnsZoneId string = privatezone_keyvault.outputs.privateDnsZoneId
output acrPrivateDnsZoneId string = privatezone_acr.outputs.privateDnsZoneId
output sqlDBPrivateDnsZoneId string = privatezone_sqldb.outputs.privateDnsZoneId
output amlApiPrivateDnsZoneId string = privatezone_azureml_api.outputs.privateDnsZoneId
output amlNotebooksPrivateDnsZoneId string = privatezone_azureml_notebook.outputs.privateDnsZoneId
output aksPrivateDnsZoneId string = privatezone_aks.outputs.privateDnsZoneId
