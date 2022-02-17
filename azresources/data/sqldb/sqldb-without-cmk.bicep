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

@description('SQL Database Logical Server Name.')
param sqlServerName string

@description('Key/Value pair of tags.')
param tags object = {}

// Networking
@description('Private Endpoint Subnet Resource Id.')
param privateEndpointSubnetId string

@description('Private DNS Zone Resource Id.')
param privateZoneId string

// SQL Vulnerability Scanning
@description('SQL Vulnerability Scanning - Security Contact email address for alerts.')
param sqlVulnerabilitySecurityContactEmail string

@description('SQL Vulnerability Scanning - Storage Account Name.')
param sqlVulnerabilityLoggingStorageAccountName string

@description('SQL Vulnerability Scanning - Storage Account Path to store the vulnerability scan results.')
param sqlVulnerabilityLoggingStoragePath string

// Credentials
@description('SQL Database Username.')
@secure()
param sqlAuthenticationUsername string

@description('SQL Database Password.')
@secure()
param sqlAuthenticationPassword string

@description('Azure AD principal to be the admin for details about it the object details, refer to the parameter file')
param aadAdministrator object

resource sqlserver 'Microsoft.Sql/servers@2021-02-01-preview' = {
  tags: tags
  location: location
  name: sqlServerName
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: aadAdministrator.azureADOnlyAuthentication? json('null') : sqlAuthenticationUsername 
    administratorLoginPassword: aadAdministrator.azureADOnlyAuthentication? json('null') : sqlAuthenticationPassword
    administrators: empty(aadAdministrator.sid)? json('null') : aadAdministrator
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
    storageContainerPath: '${sqlVulnerabilityLoggingStoragePath}vulnerability-assessment'
    recurringScans: {
      isEnabled: true
      emailSubscriptionAdmins: true
      emails: [
        sqlVulnerabilitySecurityContactEmail
      ]
    }
  }
}

module roleAssignSQLToSALogging '../../iam/resource/storage-role-assignment-to-sp.bicep' = {
  name: 'rbac-${sqlServerName}-logging-storage-account'
  params: {
    storageAccountName: sqlVulnerabilityLoggingStorageAccountName
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    resourceSPObjectIds: array(sqlserver.identity.principalId)
  }
}

resource sqlserver_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: location
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

// Outputs
output sqlDbFqdn string = sqlserver.properties.fullyQualifiedDomainName
