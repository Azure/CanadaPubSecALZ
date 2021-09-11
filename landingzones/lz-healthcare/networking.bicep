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

// Web App Subnet
param subnetWebAppName string
param subnetWebAppPrefix string

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

// Network security groups (NSGs): You can block outbound traffic with an NSG that's placed on your integration subnet.
// The inbound rules don't apply because you can't use VNet Integration to provide inbound access to your app.
// At the moment, there are no outbound rules to block outbound traffic
// See https://docs.microsoft.com/azure/app-service/web-sites-integrate-with-vnet#regional-vnet-integration
module nsgWebApp '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-webapp'
  params: {
    name: '${subnetWebAppName}Nsg'
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

// Route tables (UDRs): You can place a route table on the integration subnet to send outbound traffic where you want.
// At the moment, the route table is empty but rules can be added to force tunnel.
// See https://docs.microsoft.com/azure/app-service/web-sites-integrate-with-vnet#regional-vnet-integration
module udrWebApp '../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-web-app'
  params: {
    name: '${subnetWebAppName}Udr'
    routes: []
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
        name: subnetWebAppName
        properties: {
          addressPrefix: subnetWebAppPrefix
          networkSecurityGroup: {
            id: nsgWebApp.outputs.nsgId
          }
          routeTable: {
            id: udrWebApp.outputs.udrId
          }
          delegations: [
            {
              name: 'webapp'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
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

module privatezone_fhir '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-fhir'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.azurehealthcareapis.com'
    vnetId: vnet.id
    
    dnsCreateNewZone: !privateDnsManagedByHub
    dnsExistingZoneSubscriptionId: privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: privateDnsManagedByHubResourceGroupName
  }
}

module privatezone_eventhub '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-eventhub'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.servicebus.windows.net'
    vnetId: vnet.id
    
    dnsCreateNewZone: !privateDnsManagedByHub
    dnsExistingZoneSubscriptionId: privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: privateDnsManagedByHubResourceGroupName
  }
}

module privatezone_synapse '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-synapse'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.azuresynapse.net'
    vnetId: vnet.id
    
    dnsCreateNewZone: !privateDnsManagedByHub
    dnsExistingZoneSubscriptionId: privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: privateDnsManagedByHubResourceGroupName
  }
}

module privatezone_synapse_dev '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-synapse-dev'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.dev.azuresynapse.net'
    vnetId: vnet.id
    
    dnsCreateNewZone: !privateDnsManagedByHub
    dnsExistingZoneSubscriptionId: privateDnsManagedByHubSubscriptionId
    dnsExistingZoneResourceGroupName: privateDnsManagedByHubResourceGroupName
  }
}

module privatezone_synapse_sql '../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-synapse-sql'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.sql.azuresynapse.net'
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
output webAppSubnetId string = '${vnet.id}/subnets/${subnetWebAppName}'

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
output fhirPrivateDnsZoneId string = privatezone_fhir.outputs.privateDnsZoneId
output eventhubPrivateDnsZoneId string = privatezone_eventhub.outputs.privateDnsZoneId
output synapsePrivateDnsZoneId string = privatezone_synapse.outputs.privateDnsZoneId
output synapseDevPrivateDnsZoneId string = privatezone_synapse_dev.outputs.privateDnsZoneId
output synapseSqlPrivateDnsZoneId string = privatezone_synapse_sql.outputs.privateDnsZoneId
