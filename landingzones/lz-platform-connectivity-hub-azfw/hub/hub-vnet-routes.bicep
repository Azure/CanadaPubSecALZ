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

@description('Hub Route Table Name')
param hubUdrName string

@description('Public Access Zone Route Table Name')
param publicAccessZoneUdrName string

@description('Management Restricted Zone Virtual Network Route Table Name')
param managementRestrictedZoneUdrName string

@description('IP address prefixes used for configuring routes')
param addressPrefixes array

@description('Azure Firewall Private IP address')
param azureFirwallPrivateIp string

var defaultRoutes = [
  {
    name: 'Hub-AzureFirewall-Default-Route'
    properties: {
      nextHopType: 'VirtualAppliance'
      addressPrefix: '0.0.0.0/0'
      nextHopIpAddress: azureFirwallPrivateIp
    }
  }
]

var routesFromAddressPrefixes = [for addressPrefix in addressPrefixes: {
    name: 'Hub-AzureFirewall-${replace(replace(addressPrefix, '.', '-'), '/', '-')}'
    properties: {
      nextHopType: 'VirtualAppliance'
      addressPrefix: addressPrefix
      nextHopIpAddress: azureFirwallPrivateIp
    }
}]

var routes = union(defaultRoutes, routesFromAddressPrefixes)

module hubUdr '../../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-${hubUdrName}'
  params: {
    name: hubUdrName
    routes: routes
    location: location
  }
}

module publicAccessZoneUdr '../../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-${publicAccessZoneUdrName}'
  params: {
    name: publicAccessZoneUdrName
    routes: routes
    location: location
  }
}

module managementRestrictedZoneUdr '../../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-${managementRestrictedZoneUdrName}'
  params: {
    name: managementRestrictedZoneUdrName
    routes: routes
    location: location
  }
}
