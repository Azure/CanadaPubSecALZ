// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string = 'adf${uniqueString(resourceGroup().id)}'
param tags object = {}

param privateEndpointSubnetId string
param datafactoryPrivateZoneId string
param portalPrivateZoneId string

@description('When true, customer managed key will be enabled')
param useCMK bool
@description('Required when useCMK=true')
param akvResourceGroupName string
@description('Required when useCMK=true')
param akvName string

module identity '../../iam/user-assigned-identity.bicep' = {
  name: 'deploy-create-user-assigned-identity'
  params: {
    name: '${name}-managed-identity'
  }
}

module adfWithoutCMK 'adf-without-cmk.bicep' = if (!useCMK) {
  name: 'deploy-adf-without-cmk'
  params: {
    name:name
    tags: tags

    privateEndpointSubnetId: privateEndpointSubnetId
    datafactoryPrivateZoneId: datafactoryPrivateZoneId
    portalPrivateZoneId: portalPrivateZoneId

    userAssignedIdentityId: identity.outputs.identityId
  }
}

module adfWithCMK 'adf-with-cmk.bicep' = if (useCMK) {
  name: 'deploy-adf-with-cmk'
  params: {
    name:name
    tags: tags

    privateEndpointSubnetId: privateEndpointSubnetId
    datafactoryPrivateZoneId: datafactoryPrivateZoneId
    portalPrivateZoneId: portalPrivateZoneId
    
    userAssignedIdentityId: identity.outputs.identityId
    userAssignedIdentityPrincipalId: identity.outputs.identityPrincipalId

    akvResourceGroupName: akvResourceGroupName
    akvName: akvName
  }
}

output identityPrincipalId string = identity.outputs.identityPrincipalId
