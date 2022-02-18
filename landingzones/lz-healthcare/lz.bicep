// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

@description('Location for the deployment.')
param location string = deployment().location

/*

For accepted parameter values, see:

  * Documentation:              docs/archetypes/healthcare.md
  * JSON Schema Definition:     schemas/latest/landingzones/lz-healthcare.json
  * JSON Test Cases/Scenarios:  tests/schemas/lz-healthcare

*/

// Security Contact Email Address
@description('Contact email address for security alerts.')
param securityContactEmail string

// Tags
@description('A set of key/value pairs of tags assigned to the resource group and resources.')
param resourceTags object

// Resource Groups
@description('Resource groups required for the achetype.  It includes automation, compute, monitor, networking, networkWatcher, security and storage.')
param resourceGroups object

@description('Boolean flag to determine whether customer managed keys are used.  Default:  false')
param useCMK bool = false

// Azure Automation Account
@description('Azure Automation Account configuration.  Includes name.')
param automation object

// Azure Key Vault
@description('Azure Key Vault configuraiton.  Includes secretExpiryInDays.')
param keyVault object

// SQL Database
@description('SQL Database configuration.  Includes enabled flag and username.')
param sqldb object

// Synapse
@description('Synapse Analytics configuration.  Includes username.')
param synapse object

// Networking
@description('Hub Network configuration that includes virtualNetworkId, rfc1918IPRange, rfc6598IPRange, egressVirtualApplianceIp, privateDnsManagedByHub flag, privateDnsManagedByHubSubscriptionId and privateDnsManagedByHubResourceGroupName.')
param hubNetwork object

@description('Network configuration.  Includes peerToHubVirtualNetwork flag, useRemoteGateway flag, name, dnsServers, addressPrefixes and subnets (oz, paz, rz, hrz, privateEndpoints, databricksPublic, databricksPrivate, web) ')
param network object

var sqldbPassword = sqldb.enabled && !sqldb.aadAuthenticationOnly  ? '${uniqueString(rgStorage.id)}*${toUpper(uniqueString(sqldb.sqlAuthenticationUsername))}' : ''
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
  location: location
  tags: resourceTags
}

resource rgAutomation 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroups.automation
  location: location
  tags: resourceTags
}

resource rgVnet 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroups.networking
  location: location
  tags: resourceTags
}

resource rgStorage 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroups.storage
  location: location
  tags: resourceTags
}

resource rgCompute 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroups.compute
  location: location
  tags: resourceTags
}

resource rgSecurity 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroups.security
  location: location
  tags: resourceTags
}

resource rgMonitor 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroups.monitor
  location: location
  tags: resourceTags
}

// Automation
module automationAccount '../../azresources/automation/automation-account.bicep' = {
  name: 'deploy-automation-account'
  scope: rgAutomation
  params: {
    automationAccountName: automation.name
    tags: resourceTags
    location: location    
  }
}

// Prepare for CMK deployments
module deploymentScriptIdentity '../../azresources/iam/user-assigned-identity.bicep' = {
  name: 'deploy-ds-managed-identity'
  scope: rgAutomation
  params: {
    name: 'deployment-scripts'
    location: location
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
    location: location
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
    location: location
  }  
}

//virtual network deployment
module networking 'networking.bicep' = {
  name: 'deploy-networking'
  scope: rgVnet
  params: {
    hubNetwork: hubNetwork
    network: network
    location: location
  }
}

// Data and AI & related services deployment
module akv '../../azresources/security/key-vault.bicep' = {
  name: 'deploy-akv'
  scope: rgSecurity
  params: {
    name: akvName
    tags: resourceTags
    location: location

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
    location: location

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
    location: location

    tags: resourceTags
    sqlServerName: sqlServerName
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    privateZoneId: networking.outputs.sqlDBPrivateDnsZoneId
    aadAuthenticationOnly:sqldb.aadAuthenticationOnly
    aadLoginName: contains(sqldb,'aadLoginName') ? sqldb.aadLoginName : ''
    aadLoginObjectID: contains(sqldb,'aadLoginObjectID')? sqldb.aadLoginObjectID : ''
    aadLoginType: contains(sqldb,'aadLoginType') ? sqldb.aadLoginType : 'Group'
    sqlAuthenticationUsername: contains(sqldb,'sqlAuthenticationUsername')? sqldb.sqlAuthenticationUsername : ''
    sqlAuthenticationPassword: sqldbPassword
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
    location: location

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
    location: location
  }
}

module databricks '../../azresources/analytics/databricks/main.bicep' = {
  name: 'deploy-databricks'
  scope: rgCompute
  params: {
    location: location

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
    location: location

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
    location: location

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
    location: location
  }
}

// azure machine learning uses a metadata data lake storage account

module dataLakeMetaData '../../azresources/storage/storage-generalpurpose.bicep' = {
  name: 'deploy-aml-metadata-storage'
  scope: rgCompute
  params: {
    tags: resourceTags
    name: amlMetaStorageName
    location: location

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
    location: location

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
    location: location

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
    secretValue: sqldb.sqlAuthenticationUsername
    secretExpiryInDays: keyVault.secretExpiryInDays
  }
}

module akvSqlDbPassword '../../azresources/security/key-vault-secret.bicep' = if (sqldb.enabled && sqldb.aadAuthenticationOnly==false) {
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
    location: location

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
    location: location

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
    location: location
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

    location: location
  }
}

// Streaming Analytics
module streamanalytics '../../azresources/analytics/stream-analytics/main.bicep' = {
  name: 'deploy-stream-analytics'
  scope: rgCompute
  params: {
    name: stranalyticsName
    tags: resourceTags
    location: location
  }
}

// Event Hub
module eventhub '../../azresources/integration/eventhub.bicep' = {
  name: 'deploy-eventhub'
  scope: rgCompute
  params: {
    name: eventhubName
    tags: resourceTags
    location: location
    
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    privateZoneEventHubId : networking.outputs.eventhubPrivateDnsZoneId
  }
}
