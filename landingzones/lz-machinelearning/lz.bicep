// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

// Log Analytics
@description('Log Analytics Resource Id to integrate Azure Security Center.')
param logAnalyticsWorkspaceResourceId string

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
//     "automation": "azmlAutomation",
//     "compute": "azmlCompute",
//     "monitor": "azmlMonitor",
//     "networking": "azmlNetworking",
//     "networkWatcher": "NetworkWatcherRG",
//     "security": "azmlSecurity",
//     "storage": "azmlStorage"
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   automation: 'azmlAutomation'
//   compute: 'azmlCompute'
//   monitor: 'azmlMonitor'
//   networking: 'azmlNetworking'
//   networkWatcher: 'NetworkWatcherRG'
//   security: 'azmlSecurity'
//   storage: 'azmlStorage'
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
//     "name": "azmlautomation"
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   name: 'azmlautomation'
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

// Azure Kubernetes Service
// Example (JSON)
//-----------------------------
// "aks": {
//   "value": {
//     "version": "1.21.2"
//   }
// }

// Example (Bicep)
//-----------------------------
// {
//   version: '1.21.2'
// }
@description('Azure Kubernetes Service configuration.  Includes version.')
param aks object

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

// SQL Managed Instance
// -----------------------------
// Example (JSON)
// "sqlmi": {
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
@description('SQL Managed Instance configuration.  Includes enabled flag and username.')
param sqlmi object

// Example (JSON)
// -----------------------------
// "aml": {
//   "value": {
//     "enableHbiWorkspace": false
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   enableHbiWorkspace: false
// }
@description('Azure Machine Learning configuration.  Includes enableHbiWorkspace.')
param aml object

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
//     "dnsServers": [
//       "10.18.1.4"
//     ],
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
//       "sqlmi": {
//         "comments": "SQL Managed Instances Delegated Subnet",
//         "name": "sqlmi",
//         "addressPrefix": "10.2.6.0/25"
//       },
//       "databricksPublic": {
//         "comments": "Databricks Public Delegated Subnet",
//         "name": "databrickspublic",
//         "addressPrefix": "10.2.7.0/25"
//       },
//       "databricksPrivate": {
//         "comments": "Databricks Private Delegated Subnet",
//         "name": "databricksprivate",
//         "addressPrefix": "10.2.8.0/25"
//       },
//       "aks": {
//         "comments": "AKS Subnet",
//         "name": "aks",
//         "addressPrefix": "10.2.9.0/25"
//       }
//     }
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   peerToHubVirtualNetwork: true
//   useRemoteGateway: false
//   name: 'vnet'
//   dnsServers: [
//     '10.18.1.4'
//   ]
//   addressPrefixes: [
//     '10.2.0.0/16'
//   ]
//   subnets: {
//     oz: {
//       comments: 'Foundational Elements Zone (OZ)'
//       name: 'oz'
//       addressPrefix: '10.2.1.0/25'
//     }
//     paz: {
//       comments: 'Presentation Zone (PAZ)'
//       name: 'paz'
//       addressPrefix: '10.2.2.0/25'
//     }
//     rz: {
//       comments: 'Application Zone (RZ)'
//       name: 'rz'
//       addressPrefix: '10.2.3.0/25'
//     }
//     hrz: {
//       comments: 'Data Zone (HRZ)'
//       name: 'hrz'
//       addressPrefix: '10.2.4.0/25'
//     }
//     privateEndpoints: {
//       comments: 'Private Endpoints Subnet'
//       name: 'privateendpoints'
//       addressPrefix: '10.2.5.0/25'
//     }
//     sqlmi: {
//       comments: 'SQL Managed Instances Delegated Subnet'
//       name: 'sqlmi'
//       addressPrefix: '10.2.6.0/25'
//     }
//     databricksPublic: {
//       comments: 'Databricks Public Delegated Subnet'
//       name: 'databrickspublic'
//       addressPrefix: '10.2.7.0/25'
//     }
//     databricksPrivate: {
//       comments: 'Databricks Private Delegated Subnet'
//       name: 'databricksprivate'
//       addressPrefix: '10.2.8.0/25'
//     }
//     aks: {
//       comments: 'AKS Subnet'
//       name: 'aks'
//       addressPrefix: '10.2.9.0/25'
//     }
//   }
// }
@description('Network configuration.  Includes peerToHubVirtualNetwork flag, useRemoteGateway flag, name, dnsServers, addressPrefixes and subnets (oz, paz, rz, hrz, privateEndpoints, sqlmi, databricksPublic, databricksPrivate, aks) ')
param network object

var sqldbPassword = sqldb.enabled ? '${uniqueString(rgStorage.id)}*${toUpper(uniqueString(sqldb.username))}' : ''
var sqlmiPassword = sqlmi.enabled ? '${uniqueString(rgStorage.id)}*${toUpper(uniqueString(sqlmi.username))}' : ''

var databricksName = 'databricks'
var databricksEgressLbName = 'egressLb'
var datalakeStorageName = 'datalake${uniqueString(rgStorage.id)}'
var amlMetaStorageName = 'amlmeta${uniqueString(rgCompute.id)}'
var akvName = 'akv${uniqueString(rgSecurity.id)}'
var sqlServerName = 'sqlserver${uniqueString(rgStorage.id)}'
var adfName = 'adf${uniqueString(rgCompute.id)}'
var aksName = 'aks${uniqueString(rgCompute.id)}'
var sqlMiName = 'sqlmi${uniqueString(rgStorage.id)}'
var amlName = 'aml${uniqueString(rgCompute.id)}'
var acrName = 'acr${uniqueString(rgStorage.id)}'
var aiName = 'ai${uniqueString(rgMonitor.id)}'
var storageLoggingName = 'salogging${uniqueString(rgStorage.id)}'

var useDeploymentScripts = useCMK

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
module deploymentScriptIdentity '../../azresources/iam/user-assigned-identity.bicep' = if (useDeploymentScripts) {
  name: 'deploy-ds-managed-identity'
  scope: rgAutomation
  params: {
    name: 'deployment-scripts'
  }
}

module rgStorageDeploymentScriptRBAC '../../azresources/iam/resourceGroup/role-assignment-to-sp.bicep' = if (useDeploymentScripts) {
  scope: rgStorage
  name: 'rbac-ds-${resourceGroups.storage}'
  params: {
     // Owner - this role is cleaned up as part of this deployment
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
    resourceSPObjectIds: useDeploymentScripts ? array(deploymentScriptIdentity.outputs.identityPrincipalId) : []
  }  
}

module rgComputeDeploymentScriptRBAC '../../azresources/iam/resourceGroup/role-assignment-to-sp.bicep' = if (useDeploymentScripts) {
  scope: rgCompute
  name: 'rbac-ds-${resourceGroups.compute}'
  params: {
     // Owner - this role is cleaned up as part of this deployment
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
    resourceSPObjectIds: useDeploymentScripts ? array(deploymentScriptIdentity.outputs.identityPrincipalId) : []
  }  
}

// Clean up the role assignments
var azCliCommandDeploymentScriptPermissionCleanup = '''
  az role assignment delete --assignee {0} --scope {1}
'''

module rgStorageDeploymentScriptPermissionCleanup '../../azresources/util/deployment-script.bicep' = if (useDeploymentScripts) {
  dependsOn: [
    acr
    dataLake
    storageLogging
  ]

  scope: rgAutomation
  name: 'ds-rbac-${resourceGroups.storage}-cleanup'
  params: {
    deploymentScript: format(azCliCommandDeploymentScriptPermissionCleanup, useDeploymentScripts ? deploymentScriptIdentity.outputs.identityPrincipalId : '', rgStorage.id)
    deploymentScriptIdentityId: useDeploymentScripts ? deploymentScriptIdentity.outputs.identityId : ''
    deploymentScriptName: 'ds-rbac-${resourceGroups.storage}-cleanup'
  }  
}

module rgComputeDeploymentScriptPermissionCleanup '../../azresources/util/deployment-script.bicep' = if (useDeploymentScripts) {
  dependsOn: [
    dataLakeMetaData
  ]

  scope: rgAutomation
  name: 'ds-rbac-${resourceGroups.compute}-cleanup'
  params: {
    deploymentScript: format(azCliCommandDeploymentScriptPermissionCleanup, useDeploymentScripts ? deploymentScriptIdentity.outputs.identityPrincipalId : '', rgCompute.id)
    deploymentScriptIdentityId: useDeploymentScripts ? deploymentScriptIdentity.outputs.identityId : ''
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

module sqlMi '../../azresources/data/sqlmi/main.bicep' = if (sqlmi.enabled) {
  name: 'deploy-sqlmi'
  scope: rgStorage
  params: {
    tags: resourceTags
    
    sqlServerName: sqlMiName
    
    subnetId: networking.outputs.sqlMiSubnetId
    
    sqlmiUsername: sqlmi.username
    sqlmiPassword: sqlmiPassword

    sqlVulnerabilityLoggingStorageAccountName: storageLogging.outputs.storageName
    sqlVulnerabilityLoggingStoragePath: storageLogging.outputs.storagePath
    sqlVulnerabilitySecurityContactEmail: securityContactEmail

    useCMK: useCMK
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? akv.outputs.akvName : ''
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
    subnetIdForVnetAccess: array(networking.outputs.sqlMiSubnetId)

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

module aksKubnet '../../azresources/containers/aks-kubenet/main.bicep' = {
  name: 'deploy-aksKubnet'
  scope: rgCompute
  params: {
    tags: resourceTags

    name: aksName
    version: aks.version

    systemNodePoolEnableAutoScaling: true
    systemNodePoolMinNodeCount: 1
    systemNodePoolMaxNodeCount: 3
    systemNodePoolNodeSize: 'Standard_DS2_v2'

    userNodePoolEnableAutoScaling: true
    userNodePoolMinNodeCount: 1
    userNodePoolMaxNodeCount: 3
    userNodePoolNodeSize: 'Standard_DS2_v2'
    
    dnsPrefix: toLower(aksName)
    subnetId: networking.outputs.aksSubnetId
    nodeResourceGroupName: '${rgCompute.name}-${aksName}-${uniqueString(rgCompute.id)}'

    privateDNSZoneId: networking.outputs.aksPrivateDnsZoneId
    
    containerInsightsLogAnalyticsResourceId: logAnalyticsWorkspaceResourceId

    useCMK: useCMK
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? akv.outputs.akvName : ''
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

module machineLearning '../../azresources/analytics/aml/main.bicep' = {
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
    enableHbiWorkspace: aml.enableHbiWorkspace

    useCMK: useCMK
    akvResourceGroupName: rgSecurity.name
    akvName: akv.outputs.akvName
  }
}

// Adding secrets to key vault
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

module akvSqlmiUsername '../../azresources/security/key-vault-secret.bicep' = if (sqlmi.enabled) {
  dependsOn: [
    akv
  ]
  name: 'add-akv-secret-sqlmiUsername'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'sqlmiUsername'
    secretValue: sqlmi.username
    secretExpiryInDays: keyVault.secretExpiryInDays
  }
}

module akvSqlmiPassword '../../azresources/security/key-vault-secret.bicep' = if (sqlmi.enabled) {
  dependsOn: [
    akv
  ]
  name: 'add-akv-secret-sqlmiPassword'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'sqlmiPassword'
    secretValue: sqlmiPassword
    secretExpiryInDays: keyVault.secretExpiryInDays
  }
}

module akvSqlMiConnection '../../azresources/security/key-vault-secret.bicep' = if (sqlmi.enabled) {
  dependsOn: [
    akv
  ]
  name: 'add-akv-secret-SqlMiConnectionString'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'SqlMiConnectionString'
    secretValue: 'Server=tcp:${sqlmi.enabled ? sqlMi.outputs.sqlMiFqdn : ''},1433;Initial Catalog=${sqlMiName};Persist Security Info=False;User ID=${sqlmi.username};Password=${sqlmiPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
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
