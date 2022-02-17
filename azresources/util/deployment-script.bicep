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

@description('Deployment Script Name.')
param deploymentScriptName string

@description('Deployment Script')
param deploymentScript string

@description('Identity for the deployment script to execute in Azure Container Instance.')
param deploymentScriptIdentityId string

@description('Azure CLI Version.  Default: 2.32.0')
param azCliVersion string = '2.32.0'

@description('Force Update Tag.  Default:  utcNow()')
param forceUpdateTag string = utcNow()

@description('Script timeout in ISO 8601 format.  Default is 1 hour.')
param timeout string = 'PT1H'

@description('Script retention in ISO 8601 format.  Default is 1 hour.')
param retentionInterval string = 'PT1H'

resource ds 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: deploymentScriptName
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${deploymentScriptIdentityId}': {}
    }
  }
  properties: {
    forceUpdateTag: forceUpdateTag
    azCliVersion: azCliVersion
    retentionInterval: retentionInterval
    timeout: timeout
    cleanupPreference: 'OnExpiration'
    scriptContent: deploymentScript
  }
}
