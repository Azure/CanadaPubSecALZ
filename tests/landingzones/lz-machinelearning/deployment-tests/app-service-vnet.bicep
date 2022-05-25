// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------



module nsgAppService '../../../../azresources/network/nsg/nsg-empty.bicep' = {
  name: 'deploy-nsg-app-service-integration'
  params: {
    name: 'appServiceNsg'
  }
}

module udrAppService '../../../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-app-service-integration'
  params: {
    name: 'appServiceUdr'
    routes: []
  }
}


// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: 'testasvnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'pe'
        properties: {
          addressPrefix: '10.1.8.0/25'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'appService'
        properties: {
          addressPrefix: '10.1.9.0/25'
          networkSecurityGroup: {
            id: nsgAppService.outputs.nsgId
          }
          routeTable: {
            id: udrAppService.outputs.udrId
          }
          delegations: [
            {
              name: 'app-service-delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
    ]
  }
}

module privatezone_datalake_blob '../../../../azresources/network/private-dns-zone.bicep' = {
  name: 'datalake_blob_private_zone'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.blob.${environment().suffixes.storage}'
    vnetId: vnet.id

    dnsCreateNewZone: true
    dnsLinkToVirtualNetwork: true
    dnsExistingZoneSubscriptionId: ''
    dnsExistingZoneResourceGroupName: ''
    registrationEnabled: false
  }
}

module privatezone_datalake_file '../../../../azresources/network/private-dns-zone.bicep' = {
  name: 'deploy-privatezone-file'
  scope: resourceGroup()
  params: {
    zone: 'privatelink.file.${environment().suffixes.storage}'
    vnetId: vnet.id

    dnsCreateNewZone: true
    dnsLinkToVirtualNetwork: true
    dnsExistingZoneSubscriptionId: ''
    dnsExistingZoneResourceGroupName: ''
    registrationEnabled: false
  }
}

output privateEndpointSubnetId string = '${vnet.id}/subnets/pe'
output appServiceSubnetId string = '${vnet.id}/subnets/appService'
output dataLakeBlobPrivateDnsZoneId string = privatezone_datalake_blob.outputs.privateDnsZoneId
output dataLakeFilePrivateDnsZoneId string = privatezone_datalake_file.outputs.privateDnsZoneId
