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

// Management Restricted Zone Virtual Network

// VNET
@description('Virtual Network Name.')
param vnetName string

@description('Virtual Network Address Space.')
param vnetAddressPrefix string

// Management (Access Zone)
@description('Management (Access Zone) Subnet Name.')
param mazSubnetName string

@description('Management (Access Zone) Subnet Address Prefix.')
param mazSubnetAddressPrefix string

@description('Management (Access Zone) User Defined Route Resource Id.')
param mazSubnetUdrId string

// Infra Services (Restricted Zone)
@description('Infrastructure Services (Restricted Zone) Subnet Name.')
param infSubnetName string

@description('Infrastructure Services (Restricted Zone) Subnet Address Prefix.')
param infSubnetAddressPrefix string

@description('Infrastructure Services (Restricted Zone) User Defined Route Resource Id.')
param infSubnetUdrId string

// Security Services (Restricted Zone)
@description('Security Services (Restricted Zone) Subnet Name.')
param secSubnetName string
@description('Security Services (Restricted Zone) Subnet Address Prefis.')
param secSubnetAddressPrefix string

@description('Security Services (Restricted Zone) User Defined Route Resource Id.')
param secSubnetUdrId string

// Logging Services (Restricted Zone)
@description('Logging Services (Restricted Zone) Subnet Name.')
param logSubnetName string

@description('Logging Services (Restricted Zone) Subnet Address Prefix.')
param logSubnetAddressPrefix string

@description('Logging Services (Restricted Zone) User Defined Route Resource Id.')
param logSubnetUdrId string

// Core Management Interfaces
@description('Core Management Interfaces (Restricted Zone) Subnet Name.')
param mgmtSubnetName string

@description('Core Management Interfaces (Restricted Zone) Subnet Address Prefix.')
param mgmtSubnetAddressPrefix string

@description('Core Management Interfaces (Restricted Zone) User Defined Route Table Resource Id.')
param mgmtSubnetUdrId string

// DDOS
@description('DDOS Standard Plan Resource Id - optional (blank value = DDOS Standard Plan will not be linked to virtual network).')
param ddosStandardPlanId string

module nsgmaz '../../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-${mazSubnetName}'
  params: {
    name: '${mazSubnetName}Nsg'
    location: location
  }
}

module nsginf '../../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-${infSubnetName}'
  params: {
    name: '${infSubnetName}Nsg'
    location: location
  }
}

module nsgsec '../../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-${secSubnetName}'
  params: {
    name: '${secSubnetName}Nsg'
    location: location
  }
}

module nsglog '../../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-${logSubnetName}'
  params: {
    name: '${logSubnetName}Nsg'
    location: location
  }
}

module nsgmgmt '../../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-${mgmtSubnetName}'
  params: {
    name: '${mgmtSubnetName}Nsg'
    location: location
  }
}

resource mrzVnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  location: location
  name: vnetName
  properties: {
    enableDdosProtection: !empty(ddosStandardPlanId)
    ddosProtectionPlan: (!empty(ddosStandardPlanId)) ? {
      id: ddosStandardPlanId
    } : null
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: mazSubnetName
        properties: {
          addressPrefix: mazSubnetAddressPrefix
          networkSecurityGroup: {
            id: nsgmaz.outputs.nsgId
          }
          routeTable: {
            id: mazSubnetUdrId
          }
        }
      }
      {
        name: infSubnetName
        properties: {
          addressPrefix: infSubnetAddressPrefix
          networkSecurityGroup: {
            id: nsginf.outputs.nsgId
          }
          routeTable: {
            id: infSubnetUdrId
          }
        }
      }
      {
        name: secSubnetName
        properties: {
          addressPrefix: secSubnetAddressPrefix
          networkSecurityGroup: {
            id: nsgsec.outputs.nsgId
          }
          routeTable: {
            id: secSubnetUdrId
          }
        }
      }
      {
        name: logSubnetName
        properties: {
          addressPrefix: logSubnetAddressPrefix
          networkSecurityGroup: {
            id: nsglog.outputs.nsgId
          }
          routeTable: {
            id: logSubnetUdrId
          }
        }
      }
      {
        name: mgmtSubnetName
        properties: {
          addressPrefix: mgmtSubnetAddressPrefix
          networkSecurityGroup: {
            id: nsgmgmt.outputs.nsgId
          }
          routeTable: {
            id: mgmtSubnetUdrId
          }
        }
      }
    ]
  }
}

// Outputs
output vnetName string = mrzVnet.name
output vnetId string = mrzVnet.id

output MazSubnetId string = '${mrzVnet.id}/subnets/${mazSubnetName}'
output InfSubnetId string = '${mrzVnet.id}/subnets/${infSubnetName}'
output SecSubnetId string = '${mrzVnet.id}/subnets/${secSubnetName}'
output LogSubnetId string = '${mrzVnet.id}/subnets/${logSubnetName}'
output MgmtSubnetId string = '${mrzVnet.id}/subnets/${mgmtSubnetName}'
