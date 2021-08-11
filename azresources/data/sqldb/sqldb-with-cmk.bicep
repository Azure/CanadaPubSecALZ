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

param akvResourceGroupName string
param akvName string

resource akv 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  scope: resourceGroup(akvResourceGroupName)
  name: akvName
}

module akvKey '../../security/key-vault-key-rsa2048.bicep' = {
  name: 'add-cmk-${sqlServerName}'
  scope: resourceGroup(akvResourceGroupName)
  params: {
    akvName: akvName
    keyName: 'cmk-sqldb-${sqlServerName}'
  }
}

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

  resource sqlserver_audit 'auditingSettings@2020-11-01-preview' = {
    name: 'default'
    properties: {
      isAzureMonitorTargetEnabled: true
      state: 'Enabled'
    }
  }
  
  resource sqlserver_devopsAudit 'devOpsAuditingSettings@2020-11-01-preview' = {
    name: 'default'
    properties: {
      isAzureMonitorTargetEnabled: true
      state: 'Enabled'
    }
  }

  resource sqlserver_securityAlertPolicies 'securityAlertPolicies@2020-11-01-preview' = {
    name: 'Default'
    properties: {
      state: 'Enabled'
      emailAccountAdmins: false
    }
  }
}

resource sqlserver_va 'Microsoft.Sql/servers/vulnerabilityAssessments@2020-11-01-preview' = {
  name: '${sqlServerName}/default'
  dependsOn: [
    sqlserver
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

module akvRoleAssignmentForCMK '../../iam/resource/key-vault-role-assignment-to-sp.bicep' = {
  name: 'rbac-${sqlServerName}-key-vault'
  scope: resourceGroup(akvResourceGroupName)
  params: {
    keyVaultName: akv.name
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e147488a-f6f5-4113-8e2d-b22465e65bf6') // Key Vault Crypto Service Encryption User
    resourceSPObjectIds: array(sqlserver.identity.principalId)
  }
}

module roleAssignSQLToSALogging '../../iam/resource/storage-role-assignment-to-sp.bicep' = {
  name: 'rbac-${sqlServerName}-logging-storage-account'
  params: {
    storageAccountName: saLoggingName
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    resourceSPObjectIds: array(sqlserver.identity.principalId)
  }
}

module enableTDE 'sqldb-with-cmk-enable-tde.bicep' = {
  dependsOn: [
    akvRoleAssignmentForCMK
  ]

  name: 'deploy-tde-with-cmk'
  params: {
    sqldbName: sqlserver.name

    akvName: akvName
    akvKeyName: akvKey.outputs.keyName
    akvKeyVersion: akvKey.outputs.keyVersion
    keyUriWithVersion: akvKey.outputs.keyUriWithVersion
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

  resource sqlserver_pe_dns_reg 'privateDnsZoneGroups@2020-06-01' = {
    name: 'default'
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
}

output sqlDbFqdn string = sqlserver.properties.fullyQualifiedDomainName
