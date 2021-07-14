// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------


param privateEndpointSubnetId string
param privateZoneId string
param name string = 'fhir${uniqueString(resourceGroup().id)}'
param tags object = {}
param version string = 'fhir-R4' // fhir version

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
}

resource fhir_pe_dns_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${fhir_pe.name}/default'
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
