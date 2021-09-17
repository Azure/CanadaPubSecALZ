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

// Resource Groups
@description('Azure Network Watcher Resource Group Name.  Default: NetworkWatcherRG')
param rgNetworkWatcherName string = 'NetworkWatcherRG'

@description('Virtual Network Resource Group Name.')
param rgVnetName string

@description('Automation Account Resource Group Name.')
param rgAutomationName string

@description('Storage Resource Group Name.')
param rgStorageName string

@description('Compute Resource Group Name.')
param rgComputeName string

@description('Security Resource Group Name.')
param rgSecurityName string

@description('Monitoring Resource Group Name.')
param rgMonitorName string

// Automation
@description('Azure Automation Account name.')
param automationAccountName string

// VNET
@description('Virtual Network Name.')
param vnetName string

@description('Virtual Network Address Space.')
param vnetAddressSpace string

@description('Hub Virtual Network Resource Id.  It is required for configuring Virtual Network Peering & configuring route tables.')
param hubVnetId string

// Internal Foundational Elements (OZ) Subnet
@description('Foundational Element (OZ) Subnet Name')
param subnetFoundationalElementsName string

@description('Foundational Element (OZ) Subnet Address Prefix.')
param subnetFoundationalElementsPrefix string

// Presentation Zone (PAZ) Subnet
@description('Presentation Zone (PAZ) Subnet Name.')
param subnetPresentationName string

@description('Presentation Zone (PAZ) Subnet Address Prefix.')
param subnetPresentationPrefix string

// Application zone (RZ) Subnet
@description('Application (RZ) Subnet Name.')
param subnetApplicationName string

@description('Application (RZ) Subnet Address Prefix.')
param subnetApplicationPrefix string

// Data Zone (HRZ) Subnet
@description('Data Zone (HRZ) Subnet Name.')
param subnetDataName string

@description('Data Zone (HRZ) Subnet Address Prefix.')
param subnetDataPrefix string

// Delegated Subnets
@description('Delegated Databricks Public Subnet Name.')
param subnetDatabricksPublicName string

@description('Delegated Databricks Public Subnet Address Prefix.')
param subnetDatabricksPublicPrefix string

@description('Delegated Databricks Private Subnet Name.')
param subnetDatabricksPrivateName string

@description('Delegated Databricks Private Subnet Address Prefix.')
param subnetDatabricksPrivatePrefix string

// Priavte Endpoint Subnet
@description('Private Endpoints Subnet Name.  All private endpoints will be deployed to this subnet.')
param subnetPrivateEndpointsName string

@description('Private Endpoint Subnet Address Prefix.')
param subnetPrivateEndpointsPrefix string

// Web App Subnet
@description('Web App Subnet Name.')
param subnetWebAppName string

@description('Web App Subnet Address Prefix.')
param subnetWebAppPrefix string

// Virtual Appliance IP
@description('Egress Virtual Appliance IP.  It should be the IP address of the network virtual appliance.')
param egressVirtualApplianceIp string

// Hub IP Ranges
@description('Hub Virtual Network IP Address - RFC 1918')
param hubRFC1918IPRange string

@description('Hub Virtual Network IP Address - RFC 6598 (CGNAT)')
param hubRFC6598IPRange string

// Private DNS Zones
@description('Boolean flag to determine whether Private DNS Zones will be managed by Hub Network.')
param privateDnsManagedByHub bool = false

@description('Private DNS Zone Subscription Id.  Required when privateDnsManagedByHub=true')
param privateDnsManagedByHubSubscriptionId string = ''

@description('Private DNS Zone Resource Group Name.  Required when privateDnsManagedByHub=true')
param privateDnsManagedByHubResourceGroupName string = ''

// Azure Key Vault
@description('Azure Key Vault Secret Expiry in days.')
param secretExpiryInDays int

// Tags
@description('Resource Group scoped tag - Client Organization')
param tagClientOrganization string

@description('Resource Group scoped tag - Cost Center')
param tagCostCenter string

@description('Resource Group scoped tag - Data Sensitivity')
param tagDataSensitivity string

@description('Resource Group scoped tag - Project Contact')
param tagProjectContact string

@description('Resource Group scoped tag - Project Name')
param tagProjectName string

@description('Resource Group scoped tag - Technical Contact')
param tagTechnicalContact string

// ML landing zone parameters - start
@description('Boolean flag to determine whether SQL Database is deployed or not.')
param deploySQLDB bool

@description('Synapse Analytics Username.')
@secure()
param synapseUsername string

@description('SQL Database Username.')
@secure()
param sqldbUsername string

@description('Boolean flag to determine whether customer managed keys are used.')
param useCMK bool = false

var sqldbPassword = '${uniqueString(rgStorage.id)}*${toUpper(uniqueString(sqldbUsername))}'
var synapsePassword = '${uniqueString(rgCompute.id)}*${toUpper(uniqueString(synapseUsername))}'

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


var tags = {
  ClientOrganization: tagClientOrganization
  CostCenter: tagCostCenter
  DataSensitivity: tagDataSensitivity
  ProjectContact: tagProjectContact
  ProjectName: tagProjectName
  TechnicalContact: tagTechnicalContact
}

//resource group deployments
resource rgNetworkWatcher 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgNetworkWatcherName
  location: deployment().location
  tags: tags
}

resource rgAutomation 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgAutomationName
  location: deployment().location
  tags: tags
}

resource rgVnet 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgVnetName
  location: deployment().location
  tags: tags
}

resource rgStorage 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgStorageName
  location: deployment().location
  tags: tags
}

resource rgCompute 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgComputeName
  location: deployment().location
  tags: tags
}

resource rgSecurity 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgSecurityName
  location: deployment().location
  tags: tags
}

resource rgMonitor 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgMonitorName
  location: deployment().location
  tags: tags
}

// Automation
module automationAccount '../../azresources/automation/automation-account.bicep' = {
  name: 'deploy-automation-account'
  scope: rgAutomation
  params: {
    automationAccountName: automationAccountName
    tags: tags
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
  name: 'rbac-ds-${rgStorageName}'
  params: {
     // Owner - this role is cleaned up as part of this deployment
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
    resourceSPObjectIds: array(deploymentScriptIdentity.outputs.identityPrincipalId)
  }  
}

module rgComputeDeploymentScriptRBAC '../../azresources/iam/resourceGroup/role-assignment-to-sp.bicep' = {
  scope: rgCompute
  name: 'rbac-ds-${rgComputeName}'
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
    synapse
  ]

  scope: rgAutomation
  name: 'ds-rbac-${rgStorageName}-cleanup'
  params: {
    deploymentScript: format(azCliCommandDeploymentScriptPermissionCleanup, deploymentScriptIdentity.outputs.identityPrincipalId, rgStorage.id)
    deploymentScriptIdentityId: deploymentScriptIdentity.outputs.identityId
    deploymentScriptName: 'ds-rbac-${rgStorageName}-cleanup'
  }  
}

module rgComputeDeploymentScriptPermissionCleanup '../../azresources/util/deployment-script.bicep' = {
  dependsOn: [
    dataLakeMetaData
  ]

  scope: rgAutomation
  name: 'ds-rbac-${rgComputeName}-cleanup'
  params: {
    deploymentScript: format(azCliCommandDeploymentScriptPermissionCleanup, deploymentScriptIdentity.outputs.identityPrincipalId, rgCompute.id)
    deploymentScriptIdentityId: deploymentScriptIdentity.outputs.identityId
    deploymentScriptName: 'ds-rbac-${rgComputeName}-cleanup'
  }  
}

//virtual network deployment
module networking 'networking.bicep' = {
  name: 'deploy-networking'
  scope: rgVnet
  params: {
    vnetName: vnetName
    vnetAddressSpace: vnetAddressSpace

    hubVnetId: hubVnetId
    egressVirtualApplianceIp: egressVirtualApplianceIp
    hubRFC1918IPRange: hubRFC1918IPRange
    hubRFC6598IPRange: hubRFC6598IPRange

    subnetFoundationalElementsName: subnetFoundationalElementsName
    subnetFoundationalElementsPrefix: subnetFoundationalElementsPrefix

    subnetPresentationName: subnetPresentationName
    subnetPresentationPrefix: subnetPresentationPrefix

    subnetApplicationName: subnetApplicationName
    subnetApplicationPrefix: subnetApplicationPrefix

    subnetDataName: subnetDataName
    subnetDataPrefix: subnetDataPrefix
    
    subnetDatabricksPublicName: subnetDatabricksPublicName
    subnetDatabricksPublicPrefix: subnetDatabricksPublicPrefix

    subnetDatabricksPrivateName: subnetDatabricksPrivateName
    subnetDatabricksPrivatePrefix: subnetDatabricksPrivatePrefix
    
    subnetPrivateEndpointsName: subnetPrivateEndpointsName
    subnetPrivateEndpointsPrefix: subnetPrivateEndpointsPrefix

    subnetWebAppName: subnetWebAppName
    subnetWebAppPrefix: subnetWebAppPrefix

    privateDnsManagedByHub: privateDnsManagedByHub
    privateDnsManagedByHubSubscriptionId: privateDnsManagedByHubSubscriptionId
    privateDnsManagedByHubResourceGroupName: privateDnsManagedByHubResourceGroupName
  }
}

// Data and AI & related services deployment
module keyVault '../../azresources/security/key-vault.bicep' = {
  name: 'deploy-akv'
  scope: rgSecurity
  params: {
    name: akvName
    tags: tags

    enabledForDiskEncryption: true

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    privateZoneId: networking.outputs.keyVaultPrivateDnsZoneId
  }
}

module storageLogging '../../azresources/storage/storage-generalpurpose.bicep' = {
  name: 'deploy-storage-for-logging'
  scope: rgStorage
  params: {
    tags: tags
    name: storageLoggingName

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    blobPrivateZoneId: networking.outputs.dataLakeBlobPrivateDnsZoneId
    filePrivateZoneId: networking.outputs.dataLakeFilePrivateDnsZoneId
    
    defaultNetworkAcls: 'Deny'
    subnetIdForVnetAccess: []

    useCMK: useCMK
    deploymentScriptIdentityId: useCMK ? deploymentScriptIdentity.outputs.identityId : ''
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? keyVault.outputs.akvName : ''
  }
}

module sqlDb '../../azresources/data/sqldb/main.bicep' = if (deploySQLDB == true) {
  name: 'deploy-sqldb'
  scope: rgStorage
  params: {
    tags: tags
    sqlServerName: sqlServerName
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    privateZoneId: networking.outputs.sqlDBPrivateDnsZoneId
    sqldbUsername: sqldbUsername
    sqldbPassword: sqldbPassword
    sqlVulnerabilityLoggingStorageAccountName: storageLogging.outputs.storageName
    sqlVulnerabilityLoggingStoragePath: storageLogging.outputs.storagePath
    sqlVulnerabilitySecurityContactEmail: securityContactEmail

    useCMK: useCMK
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? keyVault.outputs.akvName : ''
  }
}

module dataLake '../../azresources/storage/storage-adlsgen2.bicep' = {
  name: 'deploy-datalake'
  scope: rgStorage
  params: {
    tags: tags
    name: datalakeStorageName

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId

    blobPrivateZoneId: networking.outputs.dataLakeBlobPrivateDnsZoneId
    dfsPrivateZoneId: networking.outputs.dataLakeDfsPrivateDnsZoneId

    defaultNetworkAcls: 'Deny'
    subnetIdForVnetAccess: []

    useCMK: useCMK
    deploymentScriptIdentityId: useCMK ? deploymentScriptIdentity.outputs.identityId : ''
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? keyVault.outputs.akvName : ''
  }
}

module egressLb '../../azresources/network/lb-egress.bicep' = {
  name: 'deploy-databricks-egressLb'
  scope: rgCompute
  params: {
    name: databricksEgressLbName
    tags: tags
  }
}

module databricks '../../azresources/analytics/databricks/main.bicep' = {
  name: 'deploy-databricks'
  scope: rgCompute
  params: {
    name: databricksName
    tags: tags
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
    tags: tags

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    datafactoryPrivateZoneId: networking.outputs.adfDataFactoryPrivateDnsZoneId
    portalPrivateZoneId: networking.outputs.adfPortalPrivateDnsZoneId
    
    useCMK: useCMK
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? keyVault.outputs.akvName : ''
  }
}

module acr '../../azresources/containers/acr/main.bicep' = {
  name: 'deploy-acr'
  scope: rgStorage
  params: {
    name: acrName
    tags: tags

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    privateZoneId: networking.outputs.acrPrivateDnsZoneId

    useCMK: useCMK
    deploymentScriptIdentityId: useCMK ? deploymentScriptIdentity.outputs.identityId : ''
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? keyVault.outputs.akvName : ''
  }
}

module appInsights '../../azresources/monitor/ai-web.bicep' = {
  name: 'deploy-appinsights-web'
  scope: rgMonitor
  params: {
    tags: tags
    name: aiName
  }
}

// azure machine learning uses a metadata data lake storage account

module dataLakeMetaData '../../azresources/storage/storage-generalpurpose.bicep' = {
  name: 'deploy-aml-metadata-storage'
  scope: rgCompute
  params: {
    tags: tags
    name: amlMetaStorageName

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    blobPrivateZoneId: networking.outputs.dataLakeBlobPrivateDnsZoneId
    filePrivateZoneId: networking.outputs.dataLakeFilePrivateDnsZoneId

    useCMK: useCMK
    deploymentScriptIdentityId: useCMK ? deploymentScriptIdentity.outputs.identityId : ''
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? keyVault.outputs.akvName : ''
  }
}

module aml '../../azresources/analytics/aml/main.bicep' = {
  name: 'deploy-aml'
  scope: rgCompute
  params: {
    name: amlName
    tags: tags
    containerRegistryId: acr.outputs.acrId
    storageAccountId: dataLakeMetaData.outputs.storageId
    appInsightsId: appInsights.outputs.aiId

    privateZoneAzureMLApiId: networking.outputs.amlApiPrivateDnsZoneId
    privateZoneAzureMLNotebooksId: networking.outputs.amlNotebooksPrivateDnsZoneId
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId

    useCMK: useCMK
    akvResourceGroupName: rgSecurity.name
    akvName: keyVault.outputs.akvName
  }
}

module synapse '../../azresources/analytics/synapse/main.bicep' = {
  name: 'deploy-synapse'
  scope: rgCompute
  params: {
    name: synapseName
    tags: tags

    managedResourceGroupName: '${rgCompute.name}-${synapseName}-${uniqueString(rgCompute.id)}'

    adlsResourceGroupName: rgStorage.name
    adlsName: dataLake.outputs.storageName
    adlsFSName: 'synapsecontainer'

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    synapsePrivateZoneId: networking.outputs.synapsePrivateDnsZoneId
    synapseDevPrivateZoneId: networking.outputs.synapseDevPrivateDnsZoneId
    synapseSqlPrivateZoneId: networking.outputs.synapseSqlPrivateDnsZoneId
    
    synapseUsername: synapseUsername 
    synapsePassword: synapsePassword

    sqlVulnerabilityLoggingStorageAccounResourceGroupName: rgStorage.name
    sqlVulnerabilityLoggingStorageAccountName: storageLogging.outputs.storageName
    sqlVulnerabilityLoggingStoragePath: storageLogging.outputs.storagePath
    sqlVulnerabilitySecurityContactEmail: securityContactEmail

    deploymentScriptIdentityId: deploymentScriptIdentity.outputs.identityId

    useCMK: useCMK
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? keyVault.outputs.akvName : ''
  }
}

module akvsynapseUsername '../../azresources/security/key-vault-secret.bicep' = {
  dependsOn: [
    keyVault
  ]
  name: 'add-akv-secret-synapseUsername'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'synapseUsername'
    secretValue: synapseUsername
    secretExpiryInDays: secretExpiryInDays
  }
}

module akvSqlDbUsername '../../azresources/security/key-vault-secret.bicep' = if (deploySQLDB == true) {
  dependsOn: [
    keyVault
  ]
  name: 'add-akv-secret-sqldbUsername'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'sqldbUsername'
    secretValue: sqldbUsername
    secretExpiryInDays: secretExpiryInDays
  }
}

module akvSqlDbPassword '../../azresources/security/key-vault-secret.bicep' = if (deploySQLDB == true) {
  dependsOn: [
    keyVault
  ]
  name: 'add-akv-secret-sqldbPassword'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'sqldbPassword'
    secretValue: sqldbPassword
    secretExpiryInDays: secretExpiryInDays
  }
}

module akvSqlDbConnection '../../azresources/security/key-vault-secret.bicep' = if (deploySQLDB == true) {
  dependsOn: [
    keyVault
  ]
  name: 'add-akv-secret-SqlDbConnectionString'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'SqlDbConnectionString'
    secretValue: 'Server=tcp:${deploySQLDB ? sqlDb.outputs.sqlDbFqdn : ''},1433;Initial Catalog=${sqlServerName};Persist Security Info=False;User ID=${sqldbUsername};Password=${sqldbPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
    secretExpiryInDays: secretExpiryInDays
  }
}

module akvsynapsePassword '../../azresources/security/key-vault-secret.bicep' = {
  dependsOn: [
    keyVault
  ]
  name: 'add-akv-secret-synapsePassword'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'synapsePassword'
    secretValue: synapsePassword
    secretExpiryInDays: secretExpiryInDays
  }
}

// Key Vault Secrets User - used for accessing secrets in ADF pipelines
module roleAssignADFToAKV '../../azresources/iam/resource/key-vault-role-assignment-to-sp.bicep' = {
  name: 'rbac-${adfName}-${akvName}'
  scope: rgSecurity
  params: {
    keyVaultName: keyVault.outputs.akvName
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
    tags: tags
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    privateZoneId: networking.outputs.fhirPrivateDnsZoneId
  }
}


// AzFunc
module functionStorage '../../azresources/storage/storage-generalpurpose.bicep' = {
  name: 'deploy-function-storage'
  scope: rgCompute
  params: {
    tags: tags
    name: azfuncStorageName

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    blobPrivateZoneId: networking.outputs.dataLakeBlobPrivateDnsZoneId
    filePrivateZoneId: networking.outputs.dataLakeFilePrivateDnsZoneId

    useCMK: useCMK
    deploymentScriptIdentityId: useCMK ? deploymentScriptIdentity.outputs.identityId : ''
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? keyVault.outputs.akvName : ''
  }
}

module functionAppServicePlan '../../azresources/compute/web/app-service-plan-linux.bicep' = {
  name: 'deploy-functions-plan'
  scope: rgCompute
  params: {
    name: azfunhpName
    skuName: 'S1'
    skuTier: 'Standard'

    tags: tags
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
    
    tags: tags
  }
}

// Streaming Analytics
module streamanalytics '../../azresources/analytics/stream-analytics/main.bicep' = {
  name: 'deploy-stream-analytics'
  scope: rgCompute
  params: {
    name: stranalyticsName
    tags: tags
  }
}

// Event Hub
module eventhub '../../azresources/integration/eventhub.bicep' = {
  name: 'deploy-eventhub'
  scope: rgCompute
  params: {
    name: eventhubName
    tags: tags
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    privateZoneEventHubId : networking.outputs.eventhubPrivateDnsZoneId
  }
}
