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

@description('Name of the Vault')
param vaultName string

@description('Key/Value pair of tags.')
param tags object = {}

@description('Enable Cross Region Restoration (Works if vault has not registered any backup instance)')
param enableCRR bool = true

@description('Change Vault Storage Type (Works if vault has not registered any backup instance)')
@allowed([
  'LocallyRedundant'
  'GeoRedundant'
])
param vaultStorageType string = 'GeoRedundant'

var skuName = 'RS0'
var skuTier = 'Standard'

resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2021-08-01' = {
  name: vaultName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {}
}

resource vaultName_vaultstorageconfig 'Microsoft.RecoveryServices/vaults/backupstorageconfig@2021-08-01' = {
  parent: recoveryServicesVault
  name: 'vaultstorageconfig'
  properties: {
    storageModelType: vaultStorageType
    crossRegionRestoreFlag: enableCRR
  }
}
