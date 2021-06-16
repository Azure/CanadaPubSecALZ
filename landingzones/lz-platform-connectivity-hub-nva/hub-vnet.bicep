// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param hubName string

param Hub_IPrange string         
param Hub_CGNATrange string
param Hub_BastionRange string      
param Subnet_Public string       
param Subnet_EAN string          
param Subnet_MRZInt string       
param Subnet_PrdInt string       
param Subnet_DevInt string       
param Subnet_HA string           
param Subnet_PAZ string         
param Subnet_Bastion string      
param Subnet_Public_name string 
param Subnet_EAN_name string    
param Subnet_MRZInt_name string  
param Subnet_PrdInt_name string  
param Subnet_DevInt_name string  
param Subnet_HA_name string      
param Subnet_PAZ_name string     
param UDR_PAZ string

module nsgpublic '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'nsgpublic'
  params:{
    name: '${Subnet_Public_name}Nsg'
  }
}
module nsgean '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'nsgean'
  params:{
    name: '${Subnet_EAN_name}Nsg'
  }
}
module nsgprd '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'nsgprd'
  params:{
    name: '${Subnet_PrdInt_name}Nsg'
  }
}
module nsgdev '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'nsgdev'
  params:{
    name: '${Subnet_DevInt_name}Nsg'
  }
}
module nsgha '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'nsgha'
  params:{
    name: '${Subnet_HA_name}Nsg'
  }
}
module nsgmrz '../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'nsgmrz'
  params:{
    name: '${Subnet_MRZInt_name}Nsg'
  }
}
module nsgpaz '../../azresources/network/nsg/nsg-appgwv2.bicep' = {
  name: 'nsgpaz'
  params:{
    name: '${Subnet_PAZ_name}Nsg'
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
  name: hubName
  properties: {
    addressSpace: {
      addressPrefixes: [
        Hub_IPrange
        Hub_CGNATrange
        Hub_BastionRange
      ]
    }
    subnets: [
      {
        name: Subnet_Public_name
        properties: {
          addressPrefix: Subnet_Public
          networkSecurityGroup: {
            id: nsgpublic.outputs.nsgId
          }
        }
      }
      {
        name: Subnet_EAN_name
        properties: {
          addressPrefix: Subnet_EAN
          networkSecurityGroup: {
            id: nsgean.outputs.nsgId
          }
        }
      }
      {
        name: Subnet_PrdInt_name
        properties: {
          addressPrefix: Subnet_PrdInt
          networkSecurityGroup: {
            id: nsgprd.outputs.nsgId
          }
        }
      }
      {
        name: Subnet_DevInt_name
        properties: {
          addressPrefix: Subnet_DevInt
          networkSecurityGroup: {
            id: nsgdev.outputs.nsgId
          }
        }
      }
      {
        name: Subnet_MRZInt_name
        properties: {
          addressPrefix: Subnet_MRZInt
          networkSecurityGroup: {
            id: nsgmrz.outputs.nsgId
          }
        }
      }
      {
        name: Subnet_HA_name
        properties: {
          addressPrefix: Subnet_HA
          networkSecurityGroup: {
            id: nsgha.outputs.nsgId
          }
        }
      }
      {
        name: Subnet_PAZ_name
        properties: {
          addressPrefix: Subnet_PAZ
          networkSecurityGroup: {
            id: nsgpaz.outputs.nsgId
          }
          routeTable: {
            id: UDR_PAZ
          }
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
         addressPrefix: Subnet_Bastion
         networkSecurityGroup: {
          id: nsgbastion.outputs.nsgId
          }
        }
      }
    ]
  }
}

output hubVnetId  string = hubVnet.id
output PublicSubnetId string = '${hubVnet.id}/subnets/${Subnet_Public_name}'
output EANSubnetId    string = '${hubVnet.id}/subnets/${Subnet_EAN_name}'
output PrdIntSubnetId string = '${hubVnet.id}/subnets/${Subnet_PrdInt_name}'
output DevIntSubnetId string = '${hubVnet.id}/subnets/${Subnet_DevInt_name}'
output MrzIntSubnetId string = '${hubVnet.id}/subnets/${Subnet_MRZInt_name}'
output HASubnetId     string = '${hubVnet.id}/subnets/${Subnet_HA_name}'
output PAZSubnetId    string = '${hubVnet.id}/subnets/${Subnet_PAZ_name}'
output AzureBastionSubnetId string = '${hubVnet.id}/subnets/AzureBastionSubnet'
