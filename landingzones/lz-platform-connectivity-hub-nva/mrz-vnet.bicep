// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param mrzName string 

param MRZ_IPrange string     
param Subnet_MAZ string       
param Subnet_INF string      
param Subnet_SEC string       
param Subnet_LOG string     
param Subnet_MGMT string      
param Subnet_MAZ_name string
param Subnet_INF_name string 
param Subnet_SEC_name string  
param Subnet_LOG_name string  
param Subnet_MGMT_name string 
param UDR string

module nsgmaz '../../azresources/network/nsg/nsg-allowall.bicep' = {
  name: 'nsgmaz'
  params:{
    name: '${Subnet_MAZ_name}Nsg'
  }
}
module nsginf '../../azresources/network/nsg/nsg-allowall.bicep' = {
  name: 'nsginf'
  params:{
    name: '${Subnet_INF_name}Nsg'
  }
}
module nsgsec '../../azresources/network/nsg/nsg-allowall.bicep' = {
  name: 'nsgsec'
  params:{
    name: '${Subnet_SEC_name}Nsg'
  }
}
module nsglog '../../azresources/network/nsg/nsg-allowall.bicep' = {
  name: 'nsglog'
  params:{
    name: '${Subnet_LOG_name}Nsg'
  }
}
module nsgmgmt '../../azresources/network/nsg/nsg-allowall.bicep' = {
  name: 'nsgmgmt'
  params:{
    name: '${Subnet_MGMT_name}Nsg'
  }
}

resource mrzVnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  location: resourceGroup().location
  name: mrzName
  properties: {
    addressSpace: {
      addressPrefixes: [
        MRZ_IPrange
      ]
    }
    subnets: [
      {
        name: Subnet_MAZ_name
        properties: {
          addressPrefix: Subnet_MAZ
          networkSecurityGroup: {
            id: nsgmaz.outputs.nsgId
          }
          routeTable: {
            id: UDR
          }
        }
      }
      {
        name: Subnet_INF_name
        properties: {
          addressPrefix: Subnet_INF
          networkSecurityGroup: {
            id: nsginf.outputs.nsgId
          }
          routeTable: {
            id: UDR
          }
        }
      }
      {
        name: Subnet_SEC_name
        properties: {
          addressPrefix: Subnet_SEC
          networkSecurityGroup: {
            id: nsgsec.outputs.nsgId
          }
          routeTable: {
            id: UDR
          }
        }
      }
      {
        name: Subnet_LOG_name
        properties: {
          addressPrefix: Subnet_LOG
          networkSecurityGroup: {
            id: nsglog.outputs.nsgId
          }
          routeTable: {
            id: UDR
          }
        }
      }
      {
        name: Subnet_MGMT_name
        properties: {
          addressPrefix: Subnet_MGMT
          networkSecurityGroup: {
            id: nsgmgmt.outputs.nsgId
          }
          routeTable: {
            id: UDR
          }
        }
      }
    ]
  }
}

output mrzVnetId string = mrzVnet.id

output MazSubnetId  string = '${mrzVnet.id}/subnets/${Subnet_MAZ_name}'
output InfSubnetId  string = '${mrzVnet.id}/subnets/${Subnet_INF_name}'
output SecSubnetId  string = '${mrzVnet.id}/subnets/${Subnet_SEC_name}'
output LogSubnetId  string = '${mrzVnet.id}/subnets/${Subnet_LOG_name}'
output MgmtSubnetId string = '${mrzVnet.id}/subnets/${Subnet_MGMT_name}'
