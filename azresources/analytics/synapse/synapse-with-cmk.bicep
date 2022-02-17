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

// Azure Key Vault
@description('Azure Key Vault Resource Group Name.  Required when useCMK=true.')
param akvResourceGroupName string

@description('Azure Key Vault Name.  Required when useCMK=true.')
param akvName string

resource akv 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  scope: resourceGroup(akvResourceGroupName)
  name: akvName
}

module akvKey '../../security/key-vault-key-rsa2048.bicep' = {
  name: 'add-cmk-${name}'
  scope: resourceGroup(akvResourceGroupName)
  params: {
    akvName: akvName
    keyName: 'cmk-synapse-${name}'
  }
}

resource adls 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  scope: resourceGroup(adlsResourceGroupName)
  name: adlsName
}

module dataLakeSynapseFS '../../storage/storage-adlsgen2-fs.bicep' = {
  name: 'deploy-datalake-fs-for-synapse'
  scope: resourceGroup(adlsResourceGroupName)
  params: {
    adlsName: adlsName
    fsName: adlsFSName
  }
}

resource synapsePrivateLinkHub 'Microsoft.Synapse/privateLinkHubs@2021-03-01' = {
  name: '${toLower(name)}plhub'
  tags: tags
  location: location
}

resource synapse 'Microsoft.Synapse/workspaces@2021-03-01' = {
  dependsOn: [
    dataLakeSynapseFS
  ]

  name: name
  tags: tags
  location: location
  properties: {
    sqlAdministratorLoginPassword: synapsePassword
    managedResourceGroupName: managedResourceGroupName
    sqlAdministratorLogin: synapseUsername

    managedVirtualNetwork: 'default'
    managedVirtualNetworkSettings: {
      preventDataExfiltration: true
    }

    publicNetworkAccess: 'Disabled'

    encryption: {
      cmk: {
        key : {
          name: 'cmk-synapse-${name}'
          keyVaultUrl: akvKey.outputs.keyUri
        }
      }
    }
    
    defaultDataLakeStorage: {
      accountUrl: adls.properties.primaryEndpoints.dfs
      filesystem: adlsFSName
    }
  }
  identity: {
    type: 'SystemAssigned'
  }

  // Assign the workspace's system-assigned managed identity CONTROL permissions to SQL pools for pipeline integration
  resource synapse_msi_sql_control_settings 'managedIdentitySqlControlSettings@2021-05-01' = {
    name: 'default'
    properties: {
      grantSqlControlToManagedIdentity: {
        desiredState: 'Enabled'
      }
    }
  }
}

module roleAssignSynapseToSALogging '../../iam/resource/storage-role-assignment-to-sp.bicep' = {
  name: 'rbac-${synapse.name}-logging-storage-account'
  scope: resourceGroup(sqlVulnerabilityLoggingStorageAccounResourceGroupName)
  params: {
    storageAccountName: sqlVulnerabilityLoggingStorageAccountName
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    resourceSPObjectIds: array(synapse.identity.principalId)
  }
}

resource synapse_workspace_web_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: location
  name: '${synapse.name}-web-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${synapse.name}-web-endpoint'
        properties: {
          privateLinkServiceId: synapsePrivateLinkHub.id
          groupIds: [
            'web'
          ]
        }
      }
    ]
  }

  resource synapse_workspace_web_reg 'privateDnsZoneGroups@2020-06-01' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-synapse-workspace-web'
          properties: {
            privateDnsZoneId: synapsePrivateZoneId
          }
        }
      ]
    }
  }
}

resource synapse_workspace_dev_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: location
  name: '${synapse.name}-workspace-dev-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${synapse.name}-workspace-dev-endpoint'
        properties: {
          privateLinkServiceId: synapse.id
          groupIds: [
            'dev'
          ]
        }
      }
    ]
  }

  resource synapse_workspace_dev_reg 'privateDnsZoneGroups@2020-06-01' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-synapse-workspace-dev'
          properties: {
            privateDnsZoneId: synapseDevPrivateZoneId
          }
        }
      ]
    }
  }
}

resource synapse_workspace_sql_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: location
  name: '${synapse.name}-workspace-sql-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${synapse.name}-workspace-sql-endpoint'
        properties: {
          privateLinkServiceId: synapse.id
          groupIds: [
            'sql'
          ]
        }
      }
    ]
  }

  resource synapse_workspace_sql_reg 'privateDnsZoneGroups@2020-06-01' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-synapse-workspace-sql'
          properties: {
            privateDnsZoneId: synapseSqlPrivateZoneId
          }
        }
      ]
    }
  }
}

resource synapse_workspace_sql_on_demand_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: location
  name: '${synapse.name}-workspace-sql-ondemand-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${synapse.name}-workspace-sql-ondemand-endpoint'
        properties: {
          privateLinkServiceId: synapse.id
          groupIds: [
            'sqlondemand'
          ]
        }
      }
    ]
  }

  resource synapse_workspace_sql_on_demand_reg 'privateDnsZoneGroups@2020-06-01' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-synapse-workspace-sql-ondemand'
          properties: {
            privateDnsZoneId: synapseSqlPrivateZoneId
          }
        }
      ]
    }
  }
}

// Grant Synapse access to ADLS Gen2 as Storage Blob Data Contributor
module roleAssignSynapseToADLSGen2 '../../iam/resource/storage-role-assignment-to-sp.bicep' = {
  name: 'rbac-${synapse.name}-${adls.name}'
  scope: resourceGroup(adlsResourceGroupName)
  params: {
    storageAccountName: adlsName
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor
    resourceSPObjectIds: array(synapse.identity.principalId)
  }
}

// Grant access from Azure resource instances
var azCliCommand = '''
  az extension add -n storage-preview

  az storage account network-rule add \
  --resource-id {0} \
  --tenant-id {1} \
  -g {2} \
  --account-name {3}
'''

module addResourceAccess '../../util/deployment-script.bicep' = {
  name: 'grant-resource-instance-access-${adlsName}'
  params: {
    deploymentScript: format(azCliCommand, synapse.id, subscription().tenantId, adlsResourceGroupName, adlsName)
    deploymentScriptName: 'grant-access-${synapse.name}-${adlsName}'
    deploymentScriptIdentityId: deploymentScriptIdentityId
    location: location
  }
}

module akvRoleAssignmentForCMK '../../iam/resource/key-vault-role-assignment-to-sp.bicep' = {
  name: 'rbac-${synapse.name}-key-vault'
  scope: resourceGroup(akvResourceGroupName)
  params: {
    keyVaultName: akv.name
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e147488a-f6f5-4113-8e2d-b22465e65bf6') // Key Vault Crypto Service Encryption User
    resourceSPObjectIds: array(synapse.identity.principalId)
  }
}


resource cmkActivation 'Microsoft.Synapse/workspaces/keys@2021-06-01-preview' = {
  dependsOn: [
    akvRoleAssignmentForCMK
  ]
  name: '${name}/cmk-synapse-${name}'
  properties: {
    isActiveCMK: true
    keyVaultUrl: akvKey.outputs.keyUri
  }
}

module wait '../../util/wait.bicep' = {
  dependsOn: [
    cmkActivation
  ]
  name: 'wait-for-cmk-activation'
  params: {
    loopCounter: 120
    waitNamePrefix: 'wait-for-cmk-activation'
  }
}

resource synapse_audit 'Microsoft.Synapse/workspaces/auditingSettings@2021-05-01' = {
  dependsOn: [
    cmkActivation
    wait
  ]
  name: '${name}/default'
  properties: {
    isAzureMonitorTargetEnabled: true
    state: 'Enabled'
  }
}

resource synapse_securityAlertPolicies 'Microsoft.Synapse/workspaces/securityAlertPolicies@2021-05-01' = {
  dependsOn: [
    cmkActivation
    wait
  ]
  name: '${name}/Default'
  properties: {
    state: 'Enabled'
    emailAccountAdmins: false
  }
}

resource synapse_va 'Microsoft.Synapse/workspaces/vulnerabilityAssessments@2021-05-01' = {
  dependsOn: [
    cmkActivation
    wait
    synapse_audit
    synapse_securityAlertPolicies
    roleAssignSynapseToSALogging
  ]
  name: '${name}/default'
  properties: {
    storageContainerPath: '${sqlVulnerabilityLoggingStoragePath}vulnerability-assessment'
    recurringScans: {
      isEnabled: true
      emailSubscriptionAdmins: true
      emails: [
        sqlVulnerabilitySecurityContactEmail
      ]
    }
  }
}
