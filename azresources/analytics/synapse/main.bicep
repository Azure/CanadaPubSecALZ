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

@description('Synapse Analytics name.')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

@description('Synapse Analytics Managed Resource Group Name.')
param managedResourceGroupName string

// ADLS Gen 2
@description('Azure Data Lake Store Gen2 Resource Group Name.')
param adlsResourceGroupName string

@description('Azure Data Lake Store Gen2 Name.')
param adlsName string

@description('Azure Data Lake Store File System Name.')
param adlsFSName string

// Credentials
@description('Synapse Analytics Username.')
@secure()
param synapseUsername string

@description('Synapse Analytics Password.')
@secure()
param synapsePassword string

// Networking
@description('Private Endpoint Subnet Resource Id.')
param privateEndpointSubnetId string

@description('Private DNS Zone Resource Id.')
param synapsePrivateZoneId string

@description('Private DNS Zone Resource Id for Dev.')
param synapseDevPrivateZoneId string

@description('Private DNS Zone Resource Id for Sql.')
param synapseSqlPrivateZoneId string

// SQL Vulnerability Scanning
@description('SQL Vulnerability Scanning - Security Contact email address for alerts.')
param sqlVulnerabilitySecurityContactEmail string

@description('SQL Vulnerability Scanning - Storage Account Resource Group.')
param sqlVulnerabilityLoggingStorageAccounResourceGroupName string

@description('SQL Vulnerability Scanning - Storage Account Name.')
param sqlVulnerabilityLoggingStorageAccountName string

@description('SQL Vulnerability Scanning - Storage Account Path to store the vulnerability scan results.')
param sqlVulnerabilityLoggingStoragePath string

// Deployment Script Identity
@description('Deployment Script Identity Resource Id.  This identity is used to execute Azure CLI as part of the deployment.')
param deploymentScriptIdentityId string

// Customer Managed Key
@description('Boolean flag that determines whether to enable Customer Managed Key.')
param useCMK bool

// Azure Key Vault
@description('Azure Key Vault Resource Group Name.  Required when useCMK=true.')
param akvResourceGroupName string

@description('Azure Key Vault Name.  Required when useCMK=true.')
param akvName string

// Synapse Analytics without Customer Managed Key
module synapseWithoutCMK 'synapse-without-cmk.bicep' = if (!useCMK) {
  name: 'deploy-synapse-without-cmk'
  params: {
    name: name
    tags: tags 
    location: location
    
    adlsResourceGroupName: adlsResourceGroupName 
    adlsName: adlsName 
    adlsFSName: adlsFSName 
    
    managedResourceGroupName: managedResourceGroupName 
    
    synapseUsername: synapseUsername 
    synapsePassword: synapsePassword 
    
    privateEndpointSubnetId: privateEndpointSubnetId 
    synapsePrivateZoneId: synapsePrivateZoneId 
    synapseDevPrivateZoneId: synapseDevPrivateZoneId
    synapseSqlPrivateZoneId: synapseSqlPrivateZoneId 
    
    sqlVulnerabilitySecurityContactEmail: sqlVulnerabilitySecurityContactEmail 
    
    sqlVulnerabilityLoggingStorageAccounResourceGroupName: sqlVulnerabilityLoggingStorageAccounResourceGroupName 
    sqlVulnerabilityLoggingStorageAccountName: sqlVulnerabilityLoggingStorageAccountName
    sqlVulnerabilityLoggingStoragePath: sqlVulnerabilityLoggingStoragePath
    
    deploymentScriptIdentityId: deploymentScriptIdentityId
  }
}

// Synapse Analytics with Customer Managed Key
module synapseWithCMK 'synapse-with-cmk.bicep' = if (useCMK) {
  name: 'deploy-synapse-with-cmk'
  params: {
    name: name
    tags: tags 
    location: location
    
    adlsResourceGroupName: adlsResourceGroupName 
    adlsName: adlsName 
    adlsFSName: adlsFSName 
    
    managedResourceGroupName: managedResourceGroupName 
    
    synapseUsername: synapseUsername 
    synapsePassword: synapsePassword 
    
    privateEndpointSubnetId: privateEndpointSubnetId 
    synapsePrivateZoneId: synapsePrivateZoneId 
    synapseDevPrivateZoneId: synapseDevPrivateZoneId
    synapseSqlPrivateZoneId: synapseSqlPrivateZoneId 
    
    sqlVulnerabilitySecurityContactEmail: sqlVulnerabilitySecurityContactEmail 
    
    sqlVulnerabilityLoggingStorageAccounResourceGroupName: sqlVulnerabilityLoggingStorageAccounResourceGroupName 
    sqlVulnerabilityLoggingStorageAccountName: sqlVulnerabilityLoggingStorageAccountName
    sqlVulnerabilityLoggingStoragePath: sqlVulnerabilityLoggingStoragePath
    
    deploymentScriptIdentityId: deploymentScriptIdentityId

    akvResourceGroupName: akvResourceGroupName
    akvName: akvName
  }
}
