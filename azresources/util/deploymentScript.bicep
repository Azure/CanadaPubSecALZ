// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param deploymentScriptName string
param deploymentScript string
param deploymentScriptIdentityId string

param azCliVersion string = '2.26.0'
param forceUpdateTag string = utcNow()

@description('Script timeout in ISO 8601 format.  Default is 1 hour.')
param timeout string = 'PT1H'

@description('Script retention in ISO 8601 format.  Default is 1 hour.')
param retentionInterval string = 'PT1H'

resource ds 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: deploymentScriptName
  location: resourceGroup().location
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
