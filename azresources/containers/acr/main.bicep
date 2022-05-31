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

@description('Azure Container Registry Name.')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

// Networking
@description('Private Endpoint Subnet Resource Id.')
param privateEndpointSubnetId string

@description('Private DNS Zone Resource Id.')
param privateZoneId string

// Customer Managed Key
@description('Boolean flag that determines whether to enable Customer Managed Key.')
param useCMK bool

// Azure Key Vault
@description('Azure Key Vault Resource Group Name.  Required when useCMK=true.')
param akvResourceGroupName string

@description('Azure Key Vault Name.  Required when useCMK=true.')
param akvName string

@description('Deployment Script Identity Id.  Required when useCMK=true.')
param deploymentScriptIdentityId string

module acrIdentity '../../iam/user-assigned-identity.bicep' = {
  name: '${name}-managed-identity'
  params: {
    name: '${name}-managed-identity'
    location: location
  }
}

module acrWithCMK 'acr-with-cmk.bicep' = if (useCMK) {
  name: 'deploy-acr-with-cmk'
  params: {
    name: name
    tags: tags
    location: location

    userAssignedIdentityId: acrIdentity.outputs.identityId
    userAssignedIdentityPrincipalId: acrIdentity.outputs.identityPrincipalId
    userAssignedIdentityClientId: acrIdentity.outputs.identityClientId

    privateEndpointSubnetId: privateEndpointSubnetId
    privateZoneId: privateZoneId    

    deploymentScriptIdentityId: deploymentScriptIdentityId
    akvResourceGroupName: akvResourceGroupName
    akvName: akvName
  } 
}

module acrWithoutCMK 'acr-without-cmk.bicep' = if (!useCMK) {
  name: 'deploy-acr-without-cmk'
  params: {
    name: name
    tags: tags
    location: location

    userAssignedIdentityId: acrIdentity.outputs.identityId

    privateEndpointSubnetId: privateEndpointSubnetId
    privateZoneId: privateZoneId    
  }
}

// Outputs
output acrId string = useCMK ? acrWithCMK.outputs.acrId : acrWithoutCMK.outputs.acrId
