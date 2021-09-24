// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

// Security Contact Email Address
@description('Contact email address for security alerts.')
param securityContactEmail string

// Tags
// Example (JSON)
// -----------------------------
// "resourceTags": {
//   "value": {
//       "ClientOrganization": "client-organization-tag",
//       "CostCenter": "cost-center-tag",
//       "DataSensitivity": "data-sensitivity-tag",
//       "ProjectContact": "project-contact-tag",
//       "ProjectName": "project-name-tag",
//       "TechnicalContact": "technical-contact-tag"
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   ClientOrganization: 'client-organization-tag'
//   CostCenter: 'cost-center-tag'
//   DataSensitivity: 'data-sensitivity-tag'
//   ProjectContact: 'project-contact-tag'
//   ProjectName: 'project-name-tag'
//   TechnicalContact: 'technical-contact-tag'
// }
@description('A set of key/value pairs of tags assigned to the resource group and resources.')
param resourceTags object

// Resource Groups
// Example (JSON)
// -----------------------------
// "resourceGroups": {
//   "value": {
//     "automation": "healthAutomation",
//     "compute": "healthCompute",
//     "monitor": "healthMonitor",
//     "networking": "healthNetworking",
//     "networkWatcher": "NetworkWatcherRG",
//     "security": "healthSecurity",
//     "storage": "healthStorage"
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   automation: 'healthAutomation'
//   compute: 'healthCompute'
//   monitor: 'healthMonitor'
//   networking: 'healthNetworking'
//   networkWatcher: 'NetworkWatcherRG'
//   security: 'healthSecurity'
//   storage: 'healthStorage'
// }
@description('Resource groups required for the achetype.  It includes automation, compute, monitor, networking, networkWatcher, security and storage.')
param resourceGroups object

@description('Boolean flag to determine whether customer managed keys are used.  Default:  false')
param useCMK bool = false

// Azure Automation Account
// Example (JSON)
// -----------------------------
// "automation": {
//   "value": {
//     "name": "healthAutomation"
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   name: 'healthAutomation'
// }
@description('Azure Automation Account configuration.  Includes name.')
param automation object

// Azure Key Vault
// Example (JSON)
//-----------------------------
// "keyVault": {
//   "value": {
//     "secretExpiryInDays": 3650
//   }
// }

// Example (Bicep)
//-----------------------------
// {
//   secretExpiryInDays: 3650
// }
@description('Azure Key Vault configuraiton.  Includes secretExpiryInDays.')
param keyVault object

// SQL Database
// -----------------------------
// Example (JSON)
// "sqldb": {
//   "value": {
//     "enabled": true,
//     "username": "azadmin"
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   enabled: true
//   username: 'azadmin'
// }
@description('SQL Database configuration.  Includes enabled flag and username.')
param sqldb object

// Synapse
// -----------------------------
// Example (JSON)
// "synapse": {
//   "value": {
//     "username": "azadmin"
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   username: 'azadmin'
// }
@description('Synapse Analytics configuration.  Includes username.')
param synapse object

// Networking
// Example (JSON)
// -----------------------------
// "hubNetwork": {
//   "value": {
//       "virtualNetworkId": "/subscriptions/ed7f4eed-9010-4227-b115-2a5e37728f27/resourceGroups/pubsec-hub-networking-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet",
//       "rfc1918IPRange": "10.18.0.0/22",
//       "rfc6598IPRange": "100.60.0.0/16",
//       "egressVirtualApplianceIp": "10.18.0.36",
//       "privateDnsManagedByHub": true,
//       "privateDnsManagedByHubSubscriptionId": "ed7f4eed-9010-4227-b115-2a5e37728f27",
//       "privateDnsManagedByHubResourceGroupName": "pubsec-dns-rg"
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   virtualNetworkId: '/subscriptions/ed7f4eed-9010-4227-b115-2a5e37728f27/resourceGroups/pubsec-hub-networking-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet'
//   rfc1918IPRange: '10.18.0.0/22'
//   rfc6598IPRange: '100.60.0.0/16'
//   egressVirtualApplianceIp: '10.18.0.36'
//   privateDnsManagedByHub: true,
//   privateDnsManagedByHubSubscriptionId: 'ed7f4eed-9010-4227-b115-2a5e37728f27',
//   privateDnsManagedByHubResourceGroupName: 'pubsec-dns-rg'
// }
@description('Hub Network configuration that includes virtualNetworkId, rfc1918IPRange, rfc6598IPRange, egressVirtualApplianceIp, privateDnsManagedByHub flag, privateDnsManagedByHubSubscriptionId and privateDnsManagedByHubResourceGroupName.')
param hubNetwork object

// Example (JSON)
// -----------------------------
// "network": {
//   "value": {
//     "peerToHubVirtualNetwork": true,
//     "useRemoteGateway": false,
//     "name": "vnet",
//     "addressPrefixes": [
//       "10.2.0.0/16"
//     ],
//     "subnets": {
//       "oz": {
//         "comments": "Foundational Elements Zone (OZ)",
//         "name": "oz",
//         "addressPrefix": "10.2.1.0/25"
//       },
//       "paz": {
//         "comments": "Presentation Zone (PAZ)",
//         "name": "paz",
//         "addressPrefix": "10.2.2.0/25"
//       },
//       "rz": {
//         "comments": "Application Zone (RZ)",
//         "name": "rz",
//         "addressPrefix": "10.2.3.0/25"
//       },
//       "hrz": {
//         "comments": "Data Zone (HRZ)",
//         "name": "hrz",
//         "addressPrefix": "10.2.4.0/25"
//       },
//       "privateEndpoints": {
//         "comments": "Private Endpoints Subnet",
//         "name": "privateendpoints",
//         "addressPrefix": "10.2.5.0/25"
//       },
//       "databricksPublic": {
//         "comments": "Databricks Public Delegated Subnet",
//         "name": "databrickspublic",
//         "addressPrefix": "10.2.6.0/25"
//       },
//       "databricksPrivate": {
//         "comments": "Databricks Private Delegated Subnet",
//         "name": "databricksprivate",
//         "addressPrefix": "10.2.7.0/25"
//       },
//       "web": {
//         "comments": "Azure Web App Delegated Subnet",
//         "name": "webapp",
//         "addressPrefix": "10.2.8.0/25"
//       }
//     }
//   }

// Example (Bicep)
// -----------------------------
// {
//   peerToHubVirtualNetwork: true
//   useRemoteGateway: false
//   name: 'vnet'
//   addressPrefixes: [
//     '10.5.0.0/16'
//   ]
//   subnets: {
//     oz: {
//       comments: 'Foundational Elements Zone (OZ)'
//       name: 'oz'
//       addressPrefix: '10.5.1.0/25'
//     }
//     paz: {
//       comments: 'Presentation Zone (PAZ)'
//       name: 'paz'
//       addressPrefix: '10.5.2.0/25'
//     }
//     rz: {
//       comments: 'Application Zone (RZ)'
//       name: 'rz'
//       addressPrefix: '10.5.3.0/25'
//     }
//     hrz: {
//       comments: 'Data Zone (HRZ)'
//       name: 'hrz'
//       addressPrefix: '10.5.4.0/25'
//     }
//     databricksPublic: {
//       comments: 'Databricks Public Delegated Subnet'
//       name: 'databrickspublic'
//       addressPrefix: '10.5.5.0/25'
//     }
//     databricksPrivate: {
//       comments: 'Databricks Private Delegated Subnet'
//       name: 'databricksprivate'
//       addressPrefix: '10.5.6.0/25'
//     }
//     privateEndpoints: {
//       comments: 'Private Endpoints Subnet'
//       name: 'privateendpoints'
//       addressPrefix: '10.5.7.0/25'
//     }
//     web: {
//       comments: 'Azure Web App Delegated Subnet'
//       name: 'webapp'
//       addressPrefix: '10.5.8.0/25'
//     }
//   }
// }
@description('Network configuration.  Includes peerToHubVirtualNetwork flag, useRemoteGateway flag, name, addressPrefixes and subnets (oz, paz, rz, hrz, privateEndpoints, databricksPublic, databricksPrivate, web) ')
param network object

var sqldbPassword = '${uniqueString(rgStorage.id)}*${toUpper(uniqueString(sqldb.username))}'
var synapsePassword = '${uniqueString(rgCompute.id)}*${toUpper(uniqueString(synapse.username))}'

var databricksName = 'databricks'
var databricksEgressLbName = 'egressLb'
var datalakeStorageName = 'datalake${uniqueString(rgStorage.id)}'
var amlMetaStorageName = 'amlmeta${uniqueString(rgCompute.id)}'
var akvName = 'akv${uniqueString(rgSecurity.id)}'
var sqlServerName = 'sqlserver${uniqueString(rgStorage.id)}'
var adfName = 'adf${uniqueString(rgCompute.id)}'
var amlName = 'aml${uniqueString(rgCompute.id)}'
var acrName = 'acr${uniqueString(rgStorage.id)}'
var aiName = 'ai${uniqueString(rgMonitor.id)}'
var storageLoggingName = 'salogging${uniqueString(rgStorage.id)}'
var synapseName = 'syn${uniqueString(rgMonitor.id)}'
var fhirName = 'fhir${uniqueString(rgCompute.id)}'
var azfuncStorageName = 'azfuncstg${uniqueString(rgCompute.id)}'
var azfuncName = 'azfunc${uniqueString(rgCompute.id)}'
var azfunhpName = 'azfunchp${uniqueString(rgCompute.id)}'
var stranalyticsName = 'strana${uniqueString(rgCompute.id)}'
var eventhubName = 'eventhub${uniqueString(rgCompute.id)}'

//resource group deployments
resource rgNetworkWatcher 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroups.networkWatcher
  location: deployment().location
  tags: resourceTags
}

resource rgAutomation 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroups.automation
  location: deployment().location
  tags: resourceTags
}

resource rgVnet 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroups.networking
  location: deployment().location
  tags: resourceTags
}

resource rgStorage 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroups.storage
  location: deployment().location
  tags: resourceTags
}

resource rgCompute 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroups.compute
  location: deployment().location
  tags: resourceTags
}

resource rgSecurity 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroups.security
  location: deployment().location
  tags: resourceTags
}

resource rgMonitor 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroups.monitor
  location: deployment().location
  tags: resourceTags
}

// Automation
module automationAccount '../../azresources/automation/automation-account.bicep' = {
  name: 'deploy-automation-account'
  scope: rgAutomation
  params: {
    automationAccountName: automation.name
    tags: resourceTags
  }
}

// Prepare for CMK deployments
module deploymentScriptIdentity '../../azresources/iam/user-assigned-identity.bicep' = {
  name: 'deploy-ds-managed-identity'
  scope: rgAutomation
  params: {
    name: 'deployment-scripts'
  }
}

module rgStorageDeploymentScriptRBAC '../../azresources/iam/resourceGroup/role-assignment-to-sp.bicep' = {
  scope: rgStorage
  name: 'rbac-ds-${resourceGroups.storage}'
  params: {
     // Owner - this role is cleaned up as part of this deployment
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
    resourceSPObjectIds: array(deploymentScriptIdentity.outputs.identityPrincipalId)
  }  
}

module rgComputeDeploymentScriptRBAC '../../azresources/iam/resourceGroup/role-assignment-to-sp.bicep' = {
  scope: rgCompute
  name: 'rbac-ds-${resourceGroups.compute}'
  params: {
     // Owner - this role is cleaned up as part of this deployment
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
    resourceSPObjectIds: array(deploymentScriptIdentity.outputs.identityPrincipalId)
  }  
}

// Clean up the role assignments
var azCliCommandDeploymentScriptPermissionCleanup = '''
  az role assignment delete --assignee {0} --scope {1}
'''

module rgStorageDeploymentScriptPermissionCleanup '../../azresources/util/deployment-script.bicep' = {
  dependsOn: [
    acr
    dataLake
    storageLogging
    synapseAnalytics
  ]

  scope: rgAutomation
  name: 'ds-rbac-${resourceGroups.storage}-cleanup'
  params: {
    deploymentScript: format(azCliCommandDeploymentScriptPermissionCleanup, deploymentScriptIdentity.outputs.identityPrincipalId, rgStorage.id)
    deploymentScriptIdentityId: deploymentScriptIdentity.outputs.identityId
    deploymentScriptName: 'ds-rbac-${resourceGroups.storage}-cleanup'
  }  
}

module rgComputeDeploymentScriptPermissionCleanup '../../azresources/util/deployment-script.bicep' = {
  dependsOn: [
    dataLakeMetaData
  ]

  scope: rgAutomation
  name: 'ds-rbac-${resourceGroups.compute}-cleanup'
  params: {
    deploymentScript: format(azCliCommandDeploymentScriptPermissionCleanup, deploymentScriptIdentity.outputs.identityPrincipalId, rgCompute.id)
    deploymentScriptIdentityId: deploymentScriptIdentity.outputs.identityId
    deploymentScriptName: 'ds-rbac-${resourceGroups.compute}-cleanup'
  }  
}

//virtual network deployment
module networking 'networking.bicep' = {
  name: 'deploy-networking'
  scope: rgVnet
  params: {
    hubNetwork: hubNetwork
    network: network
  }
}

// Data and AI & related services deployment
module akv '../../azresources/security/key-vault.bicep' = {
  name: 'deploy-akv'
  scope: rgSecurity
  params: {
    name: akvName
    tags: resourceTags

    enabledForDiskEncryption: true

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    privateZoneId: networking.outputs.keyVaultPrivateDnsZoneId
  }
}

module storageLogging '../../azresources/storage/storage-generalpurpose.bicep' = {
  name: 'deploy-storage-for-logging'
  scope: rgStorage
  params: {
    tags: resourceTags
    name: storageLoggingName

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    blobPrivateZoneId: networking.outputs.dataLakeBlobPrivateDnsZoneId
    filePrivateZoneId: networking.outputs.dataLakeFilePrivateDnsZoneId
    
    defaultNetworkAcls: 'Deny'
    subnetIdForVnetAccess: []

    useCMK: useCMK
    deploymentScriptIdentityId: useCMK ? deploymentScriptIdentity.outputs.identityId : ''
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? akv.outputs.akvName : ''
  }
}

module sqlDb '../../azresources/data/sqldb/main.bicep' = if (sqldb.enabled) {
  name: 'deploy-sqldb'
  scope: rgStorage
  params: {
    tags: resourceTags
    sqlServerName: sqlServerName
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    privateZoneId: networking.outputs.sqlDBPrivateDnsZoneId
    sqldbUsername: sqldb.username
    sqldbPassword: sqldbPassword
    sqlVulnerabilityLoggingStorageAccountName: storageLogging.outputs.storageName
    sqlVulnerabilityLoggingStoragePath: storageLogging.outputs.storagePath
    sqlVulnerabilitySecurityContactEmail: securityContactEmail

    useCMK: useCMK
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? akv.outputs.akvName : ''
  }
}

module dataLake '../../azresources/storage/storage-adlsgen2.bicep' = {
  name: 'deploy-datalake'
  scope: rgStorage
  params: {
    tags: resourceTags
    name: datalakeStorageName

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId

    blobPrivateZoneId: networking.outputs.dataLakeBlobPrivateDnsZoneId
    dfsPrivateZoneId: networking.outputs.dataLakeDfsPrivateDnsZoneId

    defaultNetworkAcls: 'Deny'
    subnetIdForVnetAccess: []

    useCMK: useCMK
    deploymentScriptIdentityId: useCMK ? deploymentScriptIdentity.outputs.identityId : ''
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? akv.outputs.akvName : ''
  }
}

module egressLb '../../azresources/network/lb-egress.bicep' = {
  name: 'deploy-databricks-egressLb'
  scope: rgCompute
  params: {
    name: databricksEgressLbName
    tags: resourceTags
  }
}

module databricks '../../azresources/analytics/databricks/main.bicep' = {
  name: 'deploy-databricks'
  scope: rgCompute
  params: {
    name: databricksName
    tags: resourceTags
    vnetId: networking.outputs.vnetId
    pricingTier: 'premium'
    managedResourceGroupId: '${subscription().id}/resourceGroups/${rgCompute.name}-${databricksName}-${uniqueString(rgCompute.id)}'
    publicSubnetName: networking.outputs.databricksPublicSubnetName
    privateSubnetName: networking.outputs.databricksPrivateSubnetName
    loadbalancerId: egressLb.outputs.lbId
    loadBalancerBackendPoolName: egressLb.outputs.lbBackendPoolName
  }
}

module adf '../../azresources/analytics/adf/main.bicep' = {
  name: 'deploy-adf'
  scope: rgCompute
  params: {
    name: adfName
    tags: resourceTags

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    datafactoryPrivateZoneId: networking.outputs.adfDataFactoryPrivateDnsZoneId
    portalPrivateZoneId: networking.outputs.adfPortalPrivateDnsZoneId
    
    useCMK: useCMK
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? akv.outputs.akvName : ''
  }
}

module acr '../../azresources/containers/acr/main.bicep' = {
  name: 'deploy-acr'
  scope: rgStorage
  params: {
    name: acrName
    tags: resourceTags

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    privateZoneId: networking.outputs.acrPrivateDnsZoneId

    useCMK: useCMK
    deploymentScriptIdentityId: useCMK ? deploymentScriptIdentity.outputs.identityId : ''
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? akv.outputs.akvName : ''
  }
}

module appInsights '../../azresources/monitor/ai-web.bicep' = {
  name: 'deploy-appinsights-web'
  scope: rgMonitor
  params: {
    tags: resourceTags
    name: aiName
  }
}

// azure machine learning uses a metadata data lake storage account

module dataLakeMetaData '../../azresources/storage/storage-generalpurpose.bicep' = {
  name: 'deploy-aml-metadata-storage'
  scope: rgCompute
  params: {
    tags: resourceTags
    name: amlMetaStorageName

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    blobPrivateZoneId: networking.outputs.dataLakeBlobPrivateDnsZoneId
    filePrivateZoneId: networking.outputs.dataLakeFilePrivateDnsZoneId

    useCMK: useCMK
    deploymentScriptIdentityId: useCMK ? deploymentScriptIdentity.outputs.identityId : ''
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? akv.outputs.akvName : ''
  }
}

module aml '../../azresources/analytics/aml/main.bicep' = {
  name: 'deploy-aml'
  scope: rgCompute
  params: {
    name: amlName
    tags: resourceTags
    containerRegistryId: acr.outputs.acrId
    storageAccountId: dataLakeMetaData.outputs.storageId
    appInsightsId: appInsights.outputs.aiId

    privateZoneAzureMLApiId: networking.outputs.amlApiPrivateDnsZoneId
    privateZoneAzureMLNotebooksId: networking.outputs.amlNotebooksPrivateDnsZoneId
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId

    useCMK: useCMK
    akvResourceGroupName: rgSecurity.name
    akvName: akv.outputs.akvName
  }
}

module synapseAnalytics '../../azresources/analytics/synapse/main.bicep' = {
  name: 'deploy-synapse'
  scope: rgCompute
  params: {
    name: synapseName
    tags: resourceTags

    managedResourceGroupName: '${rgCompute.name}-${synapseName}-${uniqueString(rgCompute.id)}'

    adlsResourceGroupName: rgStorage.name
    adlsName: dataLake.outputs.storageName
    adlsFSName: 'synapsecontainer'

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    synapsePrivateZoneId: networking.outputs.synapsePrivateDnsZoneId
    synapseDevPrivateZoneId: networking.outputs.synapseDevPrivateDnsZoneId
    synapseSqlPrivateZoneId: networking.outputs.synapseSqlPrivateDnsZoneId
    
    synapseUsername: synapse.username 
    synapsePassword: synapsePassword

    sqlVulnerabilityLoggingStorageAccounResourceGroupName: rgStorage.name
    sqlVulnerabilityLoggingStorageAccountName: storageLogging.outputs.storageName
    sqlVulnerabilityLoggingStoragePath: storageLogging.outputs.storagePath
    sqlVulnerabilitySecurityContactEmail: securityContactEmail

    deploymentScriptIdentityId: deploymentScriptIdentity.outputs.identityId

    useCMK: useCMK
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? akv.outputs.akvName : ''
  }
}

module akvsynapseUsername '../../azresources/security/key-vault-secret.bicep' = {
  dependsOn: [
    akv
  ]
  name: 'add-akv-secret-synapseUsername'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'synapseUsername'
    secretValue: synapse.username
    secretExpiryInDays: keyVault.secretExpiryInDays
  }
}

module akvSqlDbUsername '../../azresources/security/key-vault-secret.bicep' = if (sqldb.enabled) {
  dependsOn: [
    akv
  ]
  name: 'add-akv-secret-sqldbUsername'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'sqldbUsername'
    secretValue: sqldb.username
    secretExpiryInDays: keyVault.secretExpiryInDays
  }
}

module akvSqlDbPassword '../../azresources/security/key-vault-secret.bicep' = if (sqldb.enabled) {
  dependsOn: [
    akv
  ]
  name: 'add-akv-secret-sqldbPassword'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'sqldbPassword'
    secretValue: sqldbPassword
    secretExpiryInDays: keyVault.secretExpiryInDays
  }
}

module akvSqlDbConnection '../../azresources/security/key-vault-secret.bicep' = if (sqldb.enabled) {
  dependsOn: [
    akv
  ]
  name: 'add-akv-secret-SqlDbConnectionString'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'SqlDbConnectionString'
    secretValue: 'Server=tcp:${sqldb.enabled ? sqlDb.outputs.sqlDbFqdn : ''},1433;Initial Catalog=${sqlServerName};Persist Security Info=False;User ID=${sqldb.username};Password=${sqldbPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
    secretExpiryInDays: keyVault.secretExpiryInDays
  }
}

module akvsynapsePassword '../../azresources/security/key-vault-secret.bicep' = {
  dependsOn: [
    akv
  ]
  name: 'add-akv-secret-synapsePassword'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'synapsePassword'
    secretValue: synapsePassword
    secretExpiryInDays: keyVault.secretExpiryInDays
  }
}

// Key Vault Secrets User - used for accessing secrets in ADF pipelines
module roleAssignADFToAKV '../../azresources/iam/resource/key-vault-role-assignment-to-sp.bicep' = {
  name: 'rbac-${adfName}-${akvName}'
  scope: rgSecurity
  params: {
    keyVaultName: akv.outputs.akvName
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
    resourceSPObjectIds: array(adf.outputs.identityPrincipalId)
  }
}

// FHIR
module fhir '../../azresources/compute/fhir.bicep' = {
  name: 'deploy-fhir'
  scope: rgCompute
  params: {
    name: fhirName
    tags: resourceTags
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    privateZoneId: networking.outputs.fhirPrivateDnsZoneId
  }
}


// AzFunc
module functionStorage '../../azresources/storage/storage-generalpurpose.bicep' = {
  name: 'deploy-function-storage'
  scope: rgCompute
  params: {
    tags: resourceTags
    name: azfuncStorageName

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    blobPrivateZoneId: networking.outputs.dataLakeBlobPrivateDnsZoneId
    filePrivateZoneId: networking.outputs.dataLakeFilePrivateDnsZoneId

    useCMK: useCMK
    deploymentScriptIdentityId: useCMK ? deploymentScriptIdentity.outputs.identityId : ''
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? akv.outputs.akvName : ''
  }
}

module functionAppServicePlan '../../azresources/compute/web/app-service-plan-linux.bicep' = {
  name: 'deploy-functions-plan'
  scope: rgCompute
  params: {
    name: azfunhpName
    skuName: 'S1'
    skuTier: 'Standard'

    tags: resourceTags
  }
}

module functionApp '../../azresources/compute/web/functions-python-linux.bicep' = {
  name: 'deploy-azure-function'
  scope: rgCompute
  params: {
    name: azfuncName
    appServicePlanId: functionAppServicePlan.outputs.planId
    
    aiIKey: appInsights.outputs.aiIKey

    storageName: functionStorage.outputs.storageName
    storageId: functionStorage.outputs.storageId
    
    vnetIntegrationSubnetId: networking.outputs.webAppSubnetId
    
    tags: resourceTags
  }
}

// Streaming Analytics
module streamanalytics '../../azresources/analytics/stream-analytics/main.bicep' = {
  name: 'deploy-stream-analytics'
  scope: rgCompute
  params: {
    name: stranalyticsName
    tags: resourceTags
  }
}

// Event Hub
module eventhub '../../azresources/integration/eventhub.bicep' = {
  name: 'deploy-eventhub'
  scope: rgCompute
  params: {
    name: eventhubName
    tags: resourceTags
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    privateZoneEventHubId : networking.outputs.eventhubPrivateDnsZoneId
  }
}
