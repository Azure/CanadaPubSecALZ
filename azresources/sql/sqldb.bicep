// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param privateEndpointSubnetId string
param privateZoneId string
param sqlServerName string = 'sqlserver${uniqueString(resourceGroup().id)}'
param storagePath string
param securityContactEmail string
param saLoggingID string

param tags object = {}

@secure()
param sqldbUsername string

@secure()
param sqldbPassword string

resource sqlserver 'Microsoft.Sql/servers@2019-06-01-preview' = {
  tags: tags
  location: resourceGroup().location
  name: sqlServerName
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: sqldbUsername
    administratorLoginPassword: sqldbPassword
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
  }
}

resource sqlserver_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: resourceGroup().location
  name: '${sqlserver.name}-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${sqlserver.name}-endpoint'
        properties: {
          privateLinkServiceId: sqlserver.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

resource sqlserver_pe_dns_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${sqlserver_pe.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink_database_windows_net'
        properties: {
          privateDnsZoneId: privateZoneId
        }
      }
    ]
  }
}
resource sqlserver_sap 'Microsoft.Sql/servers/securityAlertPolicies@2020-11-01-preview' = {
  name: '${sqlServerName}/default'
  dependsOn: [
    sqlserver
  ]
  properties: {
    state: 'Enabled'
    emailAccountAdmins: false
  }
}
resource sqlserver_va 'Microsoft.Sql/servers/vulnerabilityAssessments@2020-11-01-preview' = {
  name: '${sqlServerName}/default'
  dependsOn: [
    sqlserver
    sqlserver_sap
  ]
  properties: {
    storageContainerPath: '${storagePath}vulnerability-assessment'
    storageAccountAccessKey: listKeys(saLoggingID, '2019-06-01').keys[0].value
    recurringScans: {
      isEnabled: true
      emailSubscriptionAdmins: true
      emails: [
        securityContactEmail
      ]
    }
  }
}

resource sqlserveraudit 'Microsoft.Sql/servers/auditingSettings@2020-11-01-preview' = {
  name: '${sqlServerName}/Default'
  dependsOn: [
    sqlserver
  ]
  properties: {
    isAzureMonitorTargetEnabled: true
    state: 'Enabled'
  }
}

resource sqlserverdevopsaudit 'Microsoft.Sql/servers/devOpsAuditingSettings@2020-11-01-preview' = {
  name: '${sqlServerName}/Default'
  dependsOn: [
    sqlserver
  ]
  properties: {
    isAzureMonitorTargetEnabled: true
    state: 'Enabled'
  }
}

output sqlSPId string = reference(sqlserver.id,'2020-11-01-preview', 'Full').identity.principalId
output sqlDbFqdn string = sqlserver.properties.fullyQualifiedDomainName
