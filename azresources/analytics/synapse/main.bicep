// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param synapseName string
param tags object = {}

param adlsResourceGroupName string
param adlsName string
param adlsFSName string

param managedResourceGroupName string

param synapseUsername string
@secure()
param synapsePassword string

param privateEndpointSubnetId string
param synapsePrivateZoneId string
param synapseDevPrivateZoneId string
param synapseSqlPrivateZoneId string

param securityContactEmail string

param loggingStorageAccountResourceGroupName string
param loggingStorageAccountName string
param loggingStoragePath string

param deploymentScriptIdentityId string

@description('When true, customer managed key will be enabled')
param useCMK bool

param akvResourceGroupName string
param akvName string

module synapseWithoutCMK 'synapse-without-cmk.bicep' = if (!useCMK) {
  name: 'deploy-synapse-without-cmk'
  params: {
    synapseName: synapseName
    tags: tags 
    
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
    
    securityContactEmail: securityContactEmail 
    
    loggingStorageAccountResourceGroupName: loggingStorageAccountResourceGroupName 
    loggingStorageAccountName: loggingStorageAccountName
    loggingStoragePath: loggingStoragePath
    
    deploymentScriptIdentityId: deploymentScriptIdentityId
  }
}

module synapseWithCMK 'synapse-with-cmk.bicep' = if (useCMK) {
  name: 'deploy-synapse-with-cmk'
  params: {
    synapseName: synapseName
    tags: tags 
    
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
    
    securityContactEmail: securityContactEmail 
    
    loggingStorageAccountResourceGroupName: loggingStorageAccountResourceGroupName 
    loggingStorageAccountName: loggingStorageAccountName
    loggingStoragePath: loggingStoragePath
    
    deploymentScriptIdentityId: deploymentScriptIdentityId

    akvResourceGroupName: akvResourceGroupName
    akvName: akvName
  }
}
