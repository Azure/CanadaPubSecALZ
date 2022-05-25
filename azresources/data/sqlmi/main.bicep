// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('SQL Managed Instance Name.')
param sqlServerName string

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

// Customer Managed Key
@description('Boolean flag that determines whether to enable Customer Managed Key.')
param useCMK bool

// Azure Key Vault
@description('Azure Key Vault Resource Group Name.  Required when useCMK=true.')
param akvResourceGroupName string

@description('Azure Key Vault Name.  Required when useCMK=true.')
param akvName string

// SQL Managed Instance without Customer Managed Key
module sqlmiWithoutCMK 'sqlmi-without-cmk.bicep' = if (!useCMK) {
  name: 'deploy-sqlmi-without-cmk'
  params: {
    name: sqlServerName
    tags: tags

    skuName: skuName

    vCores: vCores
    storageSizeInGB: storageSizeInGB

    subnetId: subnetId

    sqlVulnerabilityLoggingStorageAccountName: sqlVulnerabilityLoggingStorageAccountName
    sqlVulnerabilityLoggingStoragePath: sqlVulnerabilityLoggingStoragePath
    sqlVulnerabilitySecurityContactEmail: sqlVulnerabilitySecurityContactEmail

    sqlmiUsername: sqlmiUsername
    sqlmiPassword: sqlmiPassword
  }
}

// SQL Managed Instance with Customer Managed Key
module sqlmiWithCMK 'sqlmi-with-cmk.bicep' = if (useCMK) {
  name: 'deploy-sqlmi-with-cmk'
  params: {
    name: sqlServerName
    tags: tags

    skuName: skuName

    vCores: vCores
    storageSizeInGB: storageSizeInGB

    subnetId: subnetId

    sqlVulnerabilityLoggingStorageAccountName: sqlVulnerabilityLoggingStorageAccountName
    sqlVulnerabilityLoggingStoragePath: sqlVulnerabilityLoggingStoragePath
    sqlVulnerabilitySecurityContactEmail: sqlVulnerabilitySecurityContactEmail

    sqlmiUsername: sqlmiUsername
    sqlmiPassword: sqlmiPassword

    akvResourceGroupName: akvResourceGroupName
    akvName: akvName
  }
}

// Outputs
output sqlMiFqdn string = useCMK ? sqlmiWithCMK.outputs.sqlMiFqdn : sqlmiWithoutCMK.outputs.sqlMiFqdn
