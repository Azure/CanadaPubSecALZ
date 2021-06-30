// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

// Hub Virtual Network

// VNET
param vnetName string
param vnetAddressPrefixRFC1918 string         
param vnetAddressPrefixCGNAT string
param vnetAddressPrefixBastion string   

// External Facing (Internet/Ground)
param publicSubnetName string 
param publicSubnetAddressPrefix string       

// External Access Network
param eanSubnetName string    
param eanSubnetAddressPrefix string          

// Management Restricted Zone (connect Mgmt VNET)
param mrzIntSubnetName string  
param mrzIntSubnetAddressPrefix string       

// Internal Facing Prod  (Connect PROD VNET)
param prodIntSubnetName string  
param prodIntSubnetAddressPrefix string       

// Internal Facing Dev (Connect Dev VNET)
param devIntSubnetName string  
param devIntSubnetAddressPrefix string       

// High Availability (FW<=>FW heartbeat)
param haSubnetName string      
param haSubnetAddressPrefix string           

// Public Access Zone (i.e. Application Gateways)
param pazSubnetName string     
param pazSubnetAddressPrefix string  
param pazUdrId string

// Azure Bastion
param bastionSubnetAddressPrefix string      

// DDOS
param ddosStandardPlanId string

module nsgpublic '../../azresources/network/nsg/nsg-allowall.bicep' = {
  name: 'nsgpublic'
  params:{
    name: '${publicSubnetName}Nsg'
  }
}
module nsgean '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'nsgean'
  params:{
    name: '${eanSubnetName}Nsg'
  }
}
module nsgprd '../../azresources/network/nsg/nsg-allowall.bicep' = {
  name: 'nsgprd'
  params:{
    name: '${prodIntSubnetName}Nsg'
  }
}
module nsgdev '../../azresources/network/nsg/nsg-allowall.bicep' = {
  name: 'nsgdev'
  params:{
    name: '${devIntSubnetName}Nsg'
  }
}
module nsgha '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'nsgha'
  params:{
    name: '${haSubnetName}Nsg'
  }
}
module nsgmrz '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'nsgmrz'
  params:{
    name: '${mrzIntSubnetName}Nsg'
  }
}
module nsgpaz '../../azresources/network/nsg/nsg-appgwv2.bicep' = {
  name: 'nsgpaz'
  params:{
    name: '${pazSubnetName}Nsg'
  }
}
module nsgbastion '../../azresources/network/nsg/nsg-bastion.bicep' = {
  name: 'nsgbastion'
  params:{
    name: 'AzureBastionNsg'
  }
}

resource hubVnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  location: resourceGroup().location
  name: vnetName
  properties: {
    enableDdosProtection: !empty(ddosStandardPlanId)
    ddosProtectionPlan: (!empty(ddosStandardPlanId)) ? {
      id: ddosStandardPlanId
    } : null
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefixRFC1918
        vnetAddressPrefixCGNAT
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
    ]
  }
}

output hubVnetId  string = hubVnet.id
output PublicSubnetId string = '${hubVnet.id}/subnets/${publicSubnetName}'
output EANSubnetId    string = '${hubVnet.id}/subnets/${eanSubnetName}'
output PrdIntSubnetId string = '${hubVnet.id}/subnets/${prodIntSubnetName}'
output DevIntSubnetId string = '${hubVnet.id}/subnets/${devIntSubnetName}'
output MrzIntSubnetId string = '${hubVnet.id}/subnets/${mrzIntSubnetName}'
output HASubnetId     string = '${hubVnet.id}/subnets/${haSubnetName}'
output PAZSubnetId    string = '${hubVnet.id}/subnets/${pazSubnetName}'
output AzureBastionSubnetId string = '${hubVnet.id}/subnets/AzureBastionSubnet'
