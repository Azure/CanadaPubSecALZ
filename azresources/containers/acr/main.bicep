// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string = 'acr${uniqueString(resourceGroup().id)}'
param tags object = {}

param deployPrivateZone bool
param privateEndpointSubnetId string
param privateZoneId string

@description('When true, customer managed key will be enabled')
param useCMK bool
@description('Required when useCMK=true')
param akvResourceGroupName string
@description('Required when useCMK=true')
param akvName string
@description('Required when useCMK=true')
param deploymentScriptIdentityId string

module acrIdentity '../../iam/userAssignedIdentity.bicep' = {
  name: '${name}-managed-identity'
  params: {
    name: '${name}-managed-identity'
  }
}

module acrWithCMK 'acr-with-cmk.bicep' = if (useCMK) {
  name: 'deploy-acr-with-cmk'
  params: {
    name: name
    tags: tags

    userAssignedIdentityId: acrIdentity.outputs.identityId
    userAssignedIdentityPrincipalId: acrIdentity.outputs.identityPrincipalId
    userAssignedIdentityClientId: acrIdentity.outputs.identityClientId

    deployPrivateZone: deployPrivateZone
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

    userAssignedIdentityId: acrIdentity.outputs.identityId

    deployPrivateZone: deployPrivateZone
    privateEndpointSubnetId: privateEndpointSubnetId
    privateZoneId: privateZoneId    
  }
}

output acrId string = useCMK ? acrWithCMK.outputs.acrId : acrWithoutCMK.outputs.acrId
