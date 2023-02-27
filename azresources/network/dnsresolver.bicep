// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string
param location string = resourceGroup().location
param vnetId string

@description('Name of the private dns resolver outbound endpoint')
param inboundEndpointName string

@description('Name of the private dns resolver outbound endpoint')
param outboundEndpointName string

@description('name of the subnet that will be used for private resolver inbound endpoint')
param inboundSubnetName string

@description('name of the subnet that will be used for private resolver outbound endpoint')
param outboundSubnetName string

param vnetResourceGroupName string
param vnetName string

var subscriptionId = subscription().subscriptionId

var inboundSubnetId = resourceId(subscriptionId, vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, inboundSubnetName)
var outboundSubnetId = resourceId(subscriptionId, vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, outboundSubnetName)

resource resolver 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  name: name
  location: location
  properties: {
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource inEndPoint 'Microsoft.Network/dnsResolvers/inboundEndpoints@2022-07-01' = {
  parent: resolver
  name: inboundEndpointName
  location: location
  properties: {
    ipConfigurations: [
      {
        privateIpAllocationMethod: 'dynamic'
        subnet: {
          id: inboundSubnetId
        }
      }
    ]
  }
}


resource outEndpoint 'Microsoft.Network/dnsResolvers/outboundEndpoints@2022-07-01' = {
  parent: resolver
  name: outboundEndpointName
  location: location
  properties: {
    subnet: {
      id: outboundSubnetId
    }
  }
}

output inboundDnsIp string = inEndPoint.properties.ipConfigurations[0].privateIpAddress
output outboundEndpointId string = outEndpoint.id
