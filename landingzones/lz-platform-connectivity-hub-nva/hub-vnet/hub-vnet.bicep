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

// Hub Virtual Network

// VNET
@description('Virtual Network Name.')
param vnetName string

@description('Virtual Network Address Space (RFC 1918).')
param vnetAddressPrefixRFC1918 string

@description('Virtual Network Address Space (RFC 6598) - CGNAT.')
param vnetAddressPrefixRFC6598 string

@description('Virtual Network Address Space for Azure Bastion (RFC 1918).')
param vnetAddressPrefixBastion string

// External Facing (Internet/Ground)
@description('External Facing (Internet/Ground) Subnet Name.')
param publicSubnetName string

@description('External Facing (Internet/Ground) Subnet Address Prefix.')
param publicSubnetAddressPrefix string

// External Access Network
@description('Enternal Access Network Subnet Name.')
param eanSubnetName string

@description('Enternal Access Network Subnet Address Prefix.')
param eanSubnetAddressPrefix string

// Management Restricted Zone (connect Mgmt VNET)
@description('Management Restricted Zone Subnet Name.')
param mrzIntSubnetName string

@description('Management Restricted Zone Subnet Address Prefix.')
param mrzIntSubnetAddressPrefix string

// Internal Facing Prod  (Connect PROD VNET)
@description('Internal Facing Production Traffic Subnet Name.')
param prodIntSubnetName string

@description('Internal Facing Production Traffic Subnet Address Prefix.')
param prodIntSubnetAddressPrefix string

// Internal Facing Dev (Connect Dev VNET)
@description('Internal Facing Non-Production Traffic Subnet Name.')
param devIntSubnetName string

@description('Internal Facing Non-Production Traffic Subnet Address Prefix.')
param devIntSubnetAddressPrefix string

// High Availability (FW<=>FW heartbeat)
@description('High Availability (Firewall to Firewall heartbeat) Subnet Name.')
param haSubnetName string

@description('High Availability (Firewall to Firewall heartbeat) Subnet Address Prefix.')
param haSubnetAddressPrefix string

// Public Access Zone (i.e. Application Gateways)
@description('Public Access Zone (i.e. Application Gateway) Subnet Name.')
param pazSubnetName string

@description('Public Access Zone (i.e. Application Gateway) Subnet Address Prefix.')
param pazSubnetAddressPrefix string

@description('Public Access Zone (i.e. Application Gateway) User Defined Route Resource Id.')
param pazUdrId string

// Gateway Subnet
@description('Gateway Subnet Address Prefix.')
param gatewaySubnetAddressPrefix string

// Azure Bastion
@description('Azure Bastion Subnet Address Prefix.')
param bastionSubnetAddressPrefix string

// DDOS
@description('DDOS Standard Plan Resource Id - optional (blank value = DDOS Standard Plan will not be linked to virtual network).')
param ddosStandardPlanId string

module nsgpublic '../../../azresources/network/nsg/nsg-allowall.bicep' = {
  name: 'deploy-nsg-${publicSubnetName}'
  params: {
    name: '${publicSubnetName}Nsg'
    location: location
  }
}
module nsgean '../../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-${eanSubnetName}'
  params: {
    name: '${eanSubnetName}Nsg'
    location: location
  }
}
module nsgprd '../../../azresources/network/nsg/nsg-allowall.bicep' = {
  name: 'deploy-nsg-${prodIntSubnetName}'
  params: {
    name: '${prodIntSubnetName}Nsg'
    location: location
  }
}
module nsgdev '../../../azresources/network/nsg/nsg-allowall.bicep' = {
  name: 'deploy-nsg-${devIntSubnetName}'
  params: {
    name: '${devIntSubnetName}Nsg'
    location: location
  }
}
module nsgha '../../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-${haSubnetName}'
  params: {
    name: '${haSubnetName}Nsg'
    location: location
  }
}
module nsgmrz '../../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-${mrzIntSubnetName}'
  params: {
    name: '${mrzIntSubnetName}Nsg'
    location: location
  }
}
module nsgpaz '../../../azresources/network/nsg/nsg-appgwv2.bicep' = {
  name: 'deploy-nsg-${pazSubnetName}'
  params: {
    name: '${pazSubnetName}Nsg'
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

resource hubVnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  location: location
  name: vnetName
  properties: {
    enableDdosProtection: !empty(ddosStandardPlanId)
    ddosProtectionPlan: (!empty(ddosStandardPlanId)) ? {
      id: ddosStandardPlanId
    } : null
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefixRFC1918
        vnetAddressPrefixRFC6598
        vnetAddressPrefixBastion
      ]
    }
    subnets: [
      {
        name: publicSubnetName
        properties: {
          addressPrefix: publicSubnetAddressPrefix
          networkSecurityGroup: {
            id: nsgpublic.outputs.nsgId
          }
        }
      }
      {
        name: eanSubnetName
        properties: {
          addressPrefix: eanSubnetAddressPrefix
          networkSecurityGroup: {
            id: nsgean.outputs.nsgId
          }
        }
      }
      {
        name: prodIntSubnetName
        properties: {
          addressPrefix: prodIntSubnetAddressPrefix
          networkSecurityGroup: {
            id: nsgprd.outputs.nsgId
          }
        }
      }
      {
        name: devIntSubnetName
        properties: {
          addressPrefix: devIntSubnetAddressPrefix
          networkSecurityGroup: {
            id: nsgdev.outputs.nsgId
          }
        }
      }
      {
        name: mrzIntSubnetName
        properties: {
          addressPrefix: mrzIntSubnetAddressPrefix
          networkSecurityGroup: {
            id: nsgmrz.outputs.nsgId
          }
        }
      }
      {
        name: haSubnetName
        properties: {
          addressPrefix: haSubnetAddressPrefix
          networkSecurityGroup: {
            id: nsgha.outputs.nsgId
          }
        }
      }
      {
        name: pazSubnetName
        properties: {
          addressPrefix: pazSubnetAddressPrefix
          networkSecurityGroup: {
            id: nsgpaz.outputs.nsgId
          }
          routeTable: {
            id: pazUdrId
          }
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionSubnetAddressPrefix
          networkSecurityGroup: {
            id: nsgbastion.outputs.nsgId
          }
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: gatewaySubnetAddressPrefix
        }
      }
    ]
  }
}

output vnetName string = hubVnet.name
output vnetId string = hubVnet.id
output PublicSubnetId string = '${hubVnet.id}/subnets/${publicSubnetName}'
output EANSubnetId string = '${hubVnet.id}/subnets/${eanSubnetName}'
output PrdIntSubnetId string = '${hubVnet.id}/subnets/${prodIntSubnetName}'
output DevIntSubnetId string = '${hubVnet.id}/subnets/${devIntSubnetName}'
output MrzIntSubnetId string = '${hubVnet.id}/subnets/${mrzIntSubnetName}'
output HASubnetId string = '${hubVnet.id}/subnets/${haSubnetName}'
output PAZSubnetId string = '${hubVnet.id}/subnets/${pazSubnetName}'
output GatewaySubnetId string = '${hubVnet.id}/subnets/GatewaySubnet'
output AzureBastionSubnetId string = '${hubVnet.id}/subnets/AzureBastionSubnet'
