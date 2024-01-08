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

param SharedConnServicesNetwork object

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = [for subnet in SharedConnServicesNetwork.subnets.optional: if (subnet.nsg.enabled) {
  name: '${subnet.name}-Nsg'
  location: location
  properties: {
    securityRules: []
  }
}]

module nsgbastion '../../../azresources/network/nsg/nsg-bastion.bicep' = {
  name: 'deploy-nsg-AzureBastionNsg'
  params: {
    name: 'AzureBastion-Nsg'
    location: location
  }
}

module nsgempty '../../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-ManagementNsg'
  params: {
    name: 'Management-Nsg'
    location: location
  }
}

module nsgpanorama 'nsg-panorama.bicep' = {
  name: 'deploy-nsg-PanoramaNsg'
  params: {
    name: 'Panorama-Nsg'
    location: location
  }
}

var requiredSubnets = [
  {
    name: SharedConnServicesNetwork.subnets.AzureBastionSubnet.name
    properties: {
      addressPrefix: SharedConnServicesNetwork.subnets.AzureBastionSubnet.addressPrefix
      networkSecurityGroup: {
        id: nsgbastion.outputs.nsgId
      }
    }
  }
  {
    name: SharedConnServicesNetwork.subnets.ManagementSubnet.name
    properties: {
      addressPrefix: SharedConnServicesNetwork.subnets.ManagementSubnet.addressPrefix
      networkSecurityGroup: {
        id: nsgempty.outputs.nsgId
      }
    }
  }
  {
    name: SharedConnServicesNetwork.subnets.PanoramaSubnet.name
    properties: {
      addressPrefix: SharedConnServicesNetwork.subnets.PanoramaSubnet.addressPrefix
      networkSecurityGroup: {
        id: nsgpanorama.outputs.nsgId
      }
    }
  }
]

var optionalSubnets = [for (subnet, i) in SharedConnServicesNetwork.subnets.optional: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.addressPrefix
    networkSecurityGroup: (subnet.nsg.enabled) ? {
      id: nsg[i].id
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

resource SharedConnServicesVNET 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  location: location
  name: SharedConnServicesNetwork.name
  properties: {
    addressSpace: {
      addressPrefixes: SharedConnServicesNetwork.addressPrefixes
    }
    subnets: allSubnets
  }
}

output vnetName string = SharedConnServicesVNET.name
output vnetId string = SharedConnServicesVNET.id

output AzureBastionSubnetId string = '${SharedConnServicesVNET.id}/subnets/${SharedConnServicesNetwork.subnets.AzureBastionSubnet.name}'
output ManagementSubnetId string = '${SharedConnServicesVNET.id}/subnets/${SharedConnServicesNetwork.subnets.ManagementSubnet.name}'
output PanoramaSubnetId string = '${SharedConnServicesVNET.id}/subnets/${SharedConnServicesNetwork.subnets.PanoramaSubnet.name}'
