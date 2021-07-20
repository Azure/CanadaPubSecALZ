// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

// Management Restricted Zone Virtual Network

// VNET
param vnetName string 
param vnetAddressPrefix string     

// Management (Access Zone)
param mazSubnetName string
param mazSubnetAddressPrefix string      
param mazSubnetUdrId string 

// Infra Services (Restricted Zone)
param infSubnetName string 
param infSubnetAddressPrefix string   
param infSubnetUdrId string 

// Security Services (Restricted Zone)
param secSubnetName string  
param secSubnetAddressPrefix string
param secSubnetUdrId string 

// Logging Services (Restricted Zone)
param logSubnetName string  
param logSubnetAddressPrefix string
param logSubnetUdrId string 

// Core Management Interfaces
param mgmtSubnetName string 
param mgmtSubnetAddressPrefix string      
param mgmtSubnetUdrId string 

// DDOS
param ddosStandardPlanId string

module nsgmaz '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-${mazSubnetName}'
  params:{
    name: '${mazSubnetName}Nsg'
  }
}
module nsginf '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-${infSubnetName}'
  params:{
    name: '${infSubnetName}Nsg'
  }
}
module nsgsec '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-${secSubnetName}'
  params:{
    name: '${secSubnetName}Nsg'
  }
}
module nsglog '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-${logSubnetName}'
  params:{
    name: '${logSubnetName}Nsg'
  }
}
module nsgmgmt '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-${mgmtSubnetName}'
  params:{
    name: '${mgmtSubnetName}Nsg'
  }
}

resource mrzVnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  location: resourceGroup().location
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

output mrzVnetId string = mrzVnet.id

output MazSubnetId  string = '${mrzVnet.id}/subnets/${mazSubnetName}'
output InfSubnetId  string = '${mrzVnet.id}/subnets/${infSubnetName}'
output SecSubnetId  string = '${mrzVnet.id}/subnets/${secSubnetName}'
output LogSubnetId  string = '${mrzVnet.id}/subnets/${logSubnetName}'
output MgmtSubnetId string = '${mrzVnet.id}/subnets/${mgmtSubnetName}'
