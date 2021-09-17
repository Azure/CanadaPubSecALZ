// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('SQL Database Logic Server Name.')
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
param sqldbUsername string

@description('SQL Database Password.')
@secure()
param sqldbPassword string

// Customer Managed Key
@description('Boolean flag that determines whether to enable Customer Managed Key.')
param useCMK bool

// Azure Key Vault
@description('Azure Key Vault Resource Group Name.  Required when useCMK=true.')
param akvResourceGroupName string

@description('Azure Key Vault Name.  Required when useCMK=true.')
param akvName string

// SQL Server without Customer Managed Key
module sqldbWithoutCMK 'sqldb-without-cmk.bicep' = if (!useCMK) {
  name: 'deploy-sqldb-without-cmk'
  params: {
    sqlServerName: sqlServerName

    privateEndpointSubnetId: privateEndpointSubnetId
    privateZoneId: privateZoneId
    
    sqlVulnerabilitySecurityContactEmail: sqlVulnerabilitySecurityContactEmail

    sqlVulnerabilityLoggingStorageAccountName: sqlVulnerabilityLoggingStorageAccountName
    sqlVulnerabilityLoggingStoragePath: sqlVulnerabilityLoggingStoragePath

    sqldbUsername: sqldbUsername
    sqldbPassword: sqldbPassword

    tags: tags
  }
}

// SQL Server with Customer Managed Key
module sqldbWithCMK 'sqldb-with-cmk.bicep' = if (useCMK) {
  name: 'deploy-sqldb-with-cmk'
  params: {
    sqlServerName: sqlServerName

    privateEndpointSubnetId: privateEndpointSubnetId
    privateZoneId: privateZoneId
    
    sqlVulnerabilitySecurityContactEmail: sqlVulnerabilitySecurityContactEmail

    sqlVulnerabilityLoggingStorageAccountName: sqlVulnerabilityLoggingStorageAccountName
    sqlVulnerabilityLoggingStoragePath: sqlVulnerabilityLoggingStoragePath

    sqldbUsername: sqldbUsername
    sqldbPassword: sqldbPassword

    tags: tags

    akvResourceGroupName: akvResourceGroupName
    akvName: akvName
  }
}

// Outputs
output sqlDbFqdn string = useCMK ? sqldbWithCMK.outputs.sqlDbFqdn : sqldbWithoutCMK.outputs.sqlDbFqdn
