// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('FHIR Name.')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

@description('FHIR API Version.  Default:  fhir-R4')
param version string = 'fhir-R4' // fhir version

// Networking
@description('Private Endpoint Subnet Resource Id.')
param privateEndpointSubnetId string

@description('Private Zone Resource Id.')
param privateZoneId string

resource fhir 'Microsoft.HealthcareApis/services@2021-01-11' = {
  location: resourceGroup().location
  name: name
  tags: tags
  kind: version
  properties: {
    authenticationConfiguration: {
      audience: 'https://${name}.azurehealthcareapis.com'
      authority: uri(environment().authentication.loginEndpoint, subscription().tenantId)
    }
  }
}

resource fhir_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: resourceGroup().location
  name: '${fhir.name}-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${fhir.name}-endpoint'
        properties: {
          privateLinkServiceId: fhir.id
          groupIds: [
            'fhir'
          ]
        }
      }
    ]
  }

  resource fhir_pe_dns_reg 'privateDnsZoneGroups@2020-06-01' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-api-fhir-ms'
          properties: {
            privateDnsZoneId: privateZoneId
          }
        }
      ]
    }
  }
}
