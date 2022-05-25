// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('SQL Managed Instance Name.')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

@description('SQL Managed Instance SKU.  Default: GP_Gen5')
param skuName string = 'GP_Gen5'

@description('Number of vCores.  Defalut: 4')
param vCores int = 4

@description('Data Storage Size in GB.  Default: 32')
param storageSizeInGB int = 32

// Networking
@description('Subnet Resource Id.')
param subnetId string

// SQL Vulnerability Scanning
@description('SQL Vulnerability Scanning - Security Contact email address for alerts.')
param sqlVulnerabilitySecurityContactEmail string

@description('SQL Vulnerability Scanning - Storage Account Name.')
param sqlVulnerabilityLoggingStorageAccountName string

@description('SQL Vulnerability Scanning - Storage Account Path to store the vulnerability scan results.')
param sqlVulnerabilityLoggingStoragePath string

// Credentials
@description('SQL MI Username')
@secure()
param sqlmiUsername string

@description('SQL MI Password')
@secure()
param sqlmiPassword string

resource sqlmi 'Microsoft.Sql/managedInstances@2020-11-01-preview' = {
  name: name
  location: resourceGroup().location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: skuName
  }
  properties: {
    administratorLogin: sqlmiUsername
    administratorLoginPassword: sqlmiPassword
    subnetId: subnetId
    licenseType: 'LicenseIncluded'
    vCores: vCores
    storageSizeInGB: storageSizeInGB
  }

  resource sqlmi_securityAlertPolicies 'securityAlertPolicies@2020-11-01-preview' = {
    name: 'Default'
    properties: {
      state: 'Enabled'
      emailAccountAdmins: false
    }
  }
}

resource sqlmi_va 'Microsoft.Sql/managedInstances/vulnerabilityAssessments@2020-11-01-preview' = {
  name: '${name}/default'
  dependsOn: [
    sqlmi
    roleAssignSQLMIToSALogging
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

module roleAssignSQLMIToSALogging '../../iam/resource/storage-role-assignment-to-sp.bicep' = {
  name: 'rbac-${name}-logging-storage-account'
  params: {
    storageAccountName: sqlVulnerabilityLoggingStorageAccountName
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    resourceSPObjectIds: array(sqlmi.identity.principalId)
  }
}

// Outputs
output sqlMiFqdn string = sqlmi.properties.fullyQualifiedDomainName
