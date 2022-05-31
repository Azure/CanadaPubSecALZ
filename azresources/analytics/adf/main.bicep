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

@description('Azure Data Factory Name.')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

// Private Endpoints
@description('Private Endpoint Subnet Resource Id.')
param privateEndpointSubnetId string

@description('Private DNS Zone Resource Id for Data Factory.')
param datafactoryPrivateZoneId string

// Customer Managed Key
@description('Boolean flag that determines whether to enable Customer Managed Key.')
param useCMK bool

// Azure Key Vault
@description('Azure Key Vault Resource Group Name.  Required when useCMK=true.')
param akvResourceGroupName string

@description('Azure Key Vault Name.  Required when useCMK=true.')
param akvName string

// User Assigned Managed Identity
module identity '../../iam/user-assigned-identity.bicep' = {
  name: 'deploy-create-user-assigned-identity'
  params: {
    name: '${name}-managed-identity'
    location: location
  }
}

// Azure Data Factory without Customer Managed Key
module adfWithoutCMK 'adf-without-cmk.bicep' = if (!useCMK) {
  name: 'deploy-adf-without-cmk'
  params: {
    name:name
    tags: tags
    location: location

    privateEndpointSubnetId: privateEndpointSubnetId
    datafactoryPrivateZoneId: datafactoryPrivateZoneId

    userAssignedIdentityId: identity.outputs.identityId
  }
}

// Azure Data Factory with Customer Managed Key
module adfWithCMK 'adf-with-cmk.bicep' = if (useCMK) {
  name: 'deploy-adf-with-cmk'
  params: {
    name:name
    tags: tags
    location: location

    privateEndpointSubnetId: privateEndpointSubnetId
    datafactoryPrivateZoneId: datafactoryPrivateZoneId
    
    userAssignedIdentityId: identity.outputs.identityId
    userAssignedIdentityPrincipalId: identity.outputs.identityPrincipalId

    akvResourceGroupName: akvResourceGroupName
    akvName: akvName
  }
}

output identityPrincipalId string = identity.outputs.identityPrincipalId
