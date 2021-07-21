// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string = 'acr${uniqueString(resourceGroup().id)}'
param tags object = {}

param userAssignedIdentityId string
param userAssignedIdentityPrincipalId string
param userAssignedIdentityClientId string

param quarantinePolicy string = 'disabled'
param trustPolicyType string = 'Notary'
@allowed([
  'disabled'
])
param trustPolicyStatus string = 'disabled'
param retentionPolicyDays int = 30
param retentionPolicyStatus string = 'enabled'

param deployPrivateZone bool
param privateEndpointSubnetId string
param privateZoneId string

param akvResourceGroupName string
param akvName string
param deploymentScriptIdentityId string

@description('Key Vault will be created with this name during the deployment, then deleted once ACR key is rotated.')
param tempKeyVaultName string = 'tmpkv${uniqueString(utcNow())}'

/*
  Create a temporary key vault and key to setup CMK.  These will be deleted at the end of deployment using deployment script.
  See: https://docs.microsoft.com/en-us/azure/container-registry/container-registry-customer-managed-keys#advanced-scenario-key-vault-firewall  
*/
module tempAkv '../../security/key-vault.bicep' = {
  name: 'deploy-keyvault-temp'
  params: {
    name: tempKeyVaultName
    softDeleteRetentionInDays: 7
  }
}

module tempAkvKey '../../security/key-vault-key-rsa2048.bicep' = {
  name: 'add-temp-cmk-akv-${name}'
  params: {
    akvName: tempAkv.outputs.akvName
    keyName: 'cmk-acr'
  }
}

module tempAkvRoleAssignmentForCMK '../../iam/resource/key-vault-role-assignment-to-sp.bicep' = {
  name: 'rbac-add-temp-${name}-${tempKeyVaultName}'
  params: {
    keyVaultName: tempAkv.outputs.akvName
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e147488a-f6f5-4113-8e2d-b22465e65bf6') // Key Vault Crypto Service Encryption User
    resourceSPObjectIds: array(userAssignedIdentityPrincipalId)
  }
}

/* Configure ACR & Use Temp AKV */
resource acr 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  dependsOn: [
    tempAkvRoleAssignmentForCMK
  ]

  name: name
  tags: tags
  location: resourceGroup().location
  sku: {
    name: 'Premium'
  }
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  properties: {
    adminUserEnabled: true
    
    networkRuleSet: {
      defaultAction: 'Deny'
    }

    policies: {
      quarantinePolicy: {
        status: quarantinePolicy
      }
      trustPolicy: {
        type: trustPolicyType
        status: trustPolicyStatus
      }
      retentionPolicy: {
        days: retentionPolicyDays
        status: retentionPolicyStatus
      }
    }
    
    encryption: {
      status: 'enabled'
      keyVaultProperties: {
        identity: userAssignedIdentityClientId
        keyIdentifier: tempAkvKey.outputs.keyUri 
      }
    }

    dataEndpointEnabled: false
    publicNetworkAccess: 'Disabled'
  }
}

resource acr_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = if (deployPrivateZone) {
  location: resourceGroup().location
  name: '${acr.name}-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${acr.name}-endpoint'
        properties: {
          privateLinkServiceId: acr.id
          groupIds: [
            'registry'
          ]
        }
      }
    ]
  }
}

resource acr_pe_dns_reg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = if (deployPrivateZone) {
  name: '${acr_pe.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-azurecr-io'
        properties: {
          privateDnsZoneId: privateZoneId
        }
      }
    ]
  }
}

// rotate from temporary key-vault to permanent key-vault & system-managed identity
resource akv 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  scope: resourceGroup(akvResourceGroupName)
  name: akvName  
}

module akvRoleAssignmentForCMK '../../iam/resource/key-vault-role-assignment-to-sp.bicep' = {
  name: 'rbac-${acr.name}-key-vault'
  scope: resourceGroup(akvResourceGroupName)
  params: {
    keyVaultName: akv.name
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e147488a-f6f5-4113-8e2d-b22465e65bf6') // Key Vault Crypto Service Encryption User
    resourceSPObjectIds: array(acr.identity.principalId)
  }
}

module akvKey '../../security/key-vault-key-rsa2048.bicep' = {
  name: 'add-cmk-${acr.name}'
  scope: resourceGroup(akvResourceGroupName)
  params: {
    akvName: akvName
    keyName: 'cmk-acr-${acr.name}'
  }
}

var cliCmkRotateCommand = '''
  az acr encryption rotate-key \
    -g {0} \
    -n {1} \
    --key-encryption-key {2} \
    --identity '[system]' --debug
'''
   
module rotateCmk '../../util/deploymentScript.bicep' = { 
  dependsOn: [
    akvRoleAssignmentForCMK
  ]

  name: 'rotate-cmk-acr-${acr.name}'
  params: {
    deploymentScript: format(cliCmkRotateCommand, resourceGroup().name, name, akvKey.outputs.keyUri)
    deploymentScriptName: 'rotate-cmk-acr-${acr.name}-ds'
    deploymentScriptIdentityId: deploymentScriptIdentityId
  }
}

var cliCmkCleanUpCommand = '''
  az keyvault delete -g {0} -n {1}
'''
   
module cleanupCmk '../../util/deploymentScript.bicep' = { 
  dependsOn: [
    rotateCmk
  ]
  
  name: 'cleanup-cmk-${tempKeyVaultName}'
  params: {
    deploymentScript: format(cliCmkCleanUpCommand, resourceGroup().name, tempAkv.outputs.akvName)
    deploymentScriptName: 'cleanup-cmk-${tempKeyVaultName}-ds'
    deploymentScriptIdentityId: deploymentScriptIdentityId
  }
}

output acrId string = acr.id
