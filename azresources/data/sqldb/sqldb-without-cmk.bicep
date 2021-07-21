// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param sqlServerName string = 'sqlserver${uniqueString(resourceGroup().id)}'

param privateEndpointSubnetId string
param privateZoneId string

param securityContactEmail string

param saLoggingName string
param storagePath string

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

module roleAssignSQLToSALogging '../../iam/resource/storage-role-assignment-to-sp.bicep' = {
  name: 'rbac-${sqlServerName}-key-vault'
  params: {
    storageAccountName: saLoggingName
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    resourceSPObjectIds: array(sqlserver.identity.principalId)
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
    roleAssignSQLToSALogging
  ]
  properties: {
    storageContainerPath: '${storagePath}vulnerability-assessment'
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

output sqlDbFqdn string = sqlserver.properties.fullyQualifiedDomainName
