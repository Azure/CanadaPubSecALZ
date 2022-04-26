// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Location for the deployment.')
param location string = resourceGroup().location

@description('Hub Virtual network configuration.  See docs/archetypes/hubnetwork-nva.md for configuration settings.')
param hubNetwork object

// Common Route Table
@description('Route Table Resource Id for optional subnets in Hub Virtual Network')
param hubUdrId string

// Public Access Zone (i.e. Application Gateways)
@description('Public Access Zone (i.e. Application Gateway) User Defined Route Resource Id.')
param pazUdrId string

// DDOS
@description('DDOS Standard Plan Resource Id - optional (blank value = DDOS Standard Plan will not be linked to virtual network).')
param ddosStandardPlanId string

module nsgpublic '../../../azresources/network/nsg/nsg-allowall.bicep' = {
  name: 'deploy-nsg-${hubNetwork.subnets.public.name}'
  params: {
    name: '${hubNetwork.subnets.public.name}Nsg'
    location: location
  }
}

module nsgean '../../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-${hubNetwork.subnets.externalAccessNetwork.name}'
  params: {
    name: '${hubNetwork.subnets.externalAccessNetwork.name}Nsg'
    location: location
  }
}

module nsgprd '../../../azresources/network/nsg/nsg-allowall.bicep' = {
  name: 'deploy-nsg-${hubNetwork.subnets.productionInternal.name}'
  params: {
    name: '${hubNetwork.subnets.productionInternal.name}Nsg'
    location: location
  }
}

module nsgdev '../../../azresources/network/nsg/nsg-allowall.bicep' = {
  name: 'deploy-nsg-${hubNetwork.subnets.nonProductionInternal.name}'
  params: {
    name: '${hubNetwork.subnets.nonProductionInternal.name}Nsg'
    location: location
  }
}

module nsgha '../../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-${hubNetwork.subnets.highAvailability.name}'
  params: {
    name: '${hubNetwork.subnets.highAvailability.name}Nsg'
    location: location
  }
}

module nsgmrz '../../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-${hubNetwork.subnets.managementRestrictedZoneInternal.name}'
  params: {
    name: '${hubNetwork.subnets.managementRestrictedZoneInternal.name}Nsg'
    location: location
  }
}

module nsgpaz '../../../azresources/network/nsg/nsg-appgwv2.bicep' = {
  name: 'deploy-nsg-${hubNetwork.subnets.publicAccessZone.name}'
  params: {
    name: '${hubNetwork.subnets.publicAccessZone.name}Nsg'
    location: location
  }
}

module nsgbastion '../../../azresources/network/nsg/nsg-bastion.bicep' = {
  name: 'deploy-nsg-AzureBastionNsg'
  params: {
    name: 'AzureBastionNsg'
    location: location
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = [for subnet in hubNetwork.subnets.optional: if (subnet.nsg.enabled) {
  name: '${subnet.name}Nsg'
  location: location
  properties: {
    securityRules: []
  }
}]

var requiredSubnets = [
  {
    name: hubNetwork.subnets.public.name
    properties: {
      addressPrefix: hubNetwork.subnets.public.addressPrefix
      networkSecurityGroup: {
        id: nsgpublic.outputs.nsgId
      }
    }
  }
  {
    name: hubNetwork.subnets.externalAccessNetwork.name
    properties: {
      addressPrefix: hubNetwork.subnets.externalAccessNetwork.addressPrefix
      networkSecurityGroup: {
        id: nsgean.outputs.nsgId
      }
    }
  }
  {
    name: hubNetwork.subnets.productionInternal.name
    properties: {
      addressPrefix: hubNetwork.subnets.productionInternal.addressPrefix
      networkSecurityGroup: {
        id: nsgprd.outputs.nsgId
      }
    }
  }
  {
    name: hubNetwork.subnets.nonProductionInternal.name
    properties: {
      addressPrefix: hubNetwork.subnets.nonProductionInternal.addressPrefix
      networkSecurityGroup: {
        id: nsgdev.outputs.nsgId
      }
    }
  }
  {
    name: hubNetwork.subnets.managementRestrictedZoneInternal.name
    properties: {
      addressPrefix: hubNetwork.subnets.managementRestrictedZoneInternal.addressPrefix
      networkSecurityGroup: {
        id: nsgmrz.outputs.nsgId
      }
    }
  }
  {
    name: hubNetwork.subnets.highAvailability.name
    properties: {
      addressPrefix: hubNetwork.subnets.highAvailability.addressPrefix
      networkSecurityGroup: {
        id: nsgha.outputs.nsgId
      }
    }
  }
  {
    name: hubNetwork.subnets.publicAccessZone.name
    properties: {
      addressPrefix: hubNetwork.subnets.publicAccessZone.addressPrefix
      networkSecurityGroup: {
        id: nsgpaz.outputs.nsgId
      }
      routeTable: {
        id: pazUdrId
      }
    }
  }
  {
    name: hubNetwork.subnets.bastion.name
    properties: {
      addressPrefix: hubNetwork.subnets.bastion.addressPrefix
      networkSecurityGroup: {
        id: nsgbastion.outputs.nsgId
      }
    }
  }
  {
    name: hubNetwork.subnets.gateway.name
    properties: {
      addressPrefix: hubNetwork.subnets.gateway.addressPrefix
    }
  }
]

var optionalSubnets = [for (subnet, i) in hubNetwork.subnets.optional: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.addressPrefix
    networkSecurityGroup: (subnet.nsg.enabled) ? {
      id: nsg[i].id
    } : null
    routeTable: (subnet.udr.enabled) ? {
      id: hubUdrId
    } : null
    delegations: contains(subnet, 'delegations') ? [
      {
        name: replace(subnet.delegations.serviceName, '/', '.')
        properties: {
          serviceName: subnet.delegations.serviceName
        }
      }
    ] : null
  }
}]

var allSubnets = union(requiredSubnets, optionalSubnets)

resource hubVnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  location: location
  name: hubNetwork.name
  properties: {
    enableDdosProtection: !empty(ddosStandardPlanId)
    ddosProtectionPlan: (!empty(ddosStandardPlanId)) ? {
      id: ddosStandardPlanId
    } : null
    addressSpace: {
      addressPrefixes: union(hubNetwork.addressPrefixes, array(hubNetwork.addressPrefixBastion))
    }
    subnets: allSubnets
  }
}

output vnetName string = hubVnet.name
output vnetId string = hubVnet.id

output AzureBastionSubnetId string = '${hubVnet.id}/subnets/${hubNetwork.subnets.bastion.name}'
output GatewaySubnetId string = '${hubVnet.id}/subnets/${hubNetwork.subnets.gateway.name}'

output NonProdIntSubnetId string = '${hubVnet.id}/subnets/${hubNetwork.subnets.nonProductionInternal.name}'
output ProdIntSubnetId string = '${hubVnet.id}/subnets/${hubNetwork.subnets.productionInternal.name}'
output MrzIntSubnetId string = '${hubVnet.id}/subnets/${hubNetwork.subnets.managementRestrictedZoneInternal.name}'
output HASubnetId string = '${hubVnet.id}/subnets/${hubNetwork.subnets.highAvailability.name}'

output EANSubnetId string = '${hubVnet.id}/subnets/${hubNetwork.subnets.externalAccessNetwork.name}'
output PublicSubnetId string = '${hubVnet.id}/subnets/${hubNetwork.subnets.public.name}'
output PublicAccessZoneSubnetId string = '${hubVnet.id}/subnets/${hubNetwork.subnets.publicAccessZone.name}'
