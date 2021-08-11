// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

param azureRegion string = deployment().location

@description('Should SQL Database be deployed in environment')
param deploySQLDB bool

param securityContactEmail string

param tagClientOrganization string
param tagCostCenter string
param tagDataSensitivity string
param tagProjectContact string
param tagProjectName string
param tagTechnicalContact string

param rgAutomationName string
param rgNetworkWatcherName string
param rgVnetName string
param rgStorageName string
param rgComputeName string
param rgSecurityName string
param rgMonitorName string

param automationAccountName string

param vnetName string
param vnetAddressSpace string

param hubVnetId string

// Virtual Appliance IP
param egressVirtualApplianceIp string

// Hub IP Ranges
param hubRFC1918IPRange string
param hubCGNATIPRange string

// Internal Foundational Elements (OZ) Subnet
param subnetFoundationalElementsName string
param subnetFoundationalElementsPrefix string

// Presentation Zone (PAZ) Subnet
param subnetPresentationName string
param subnetPresentationPrefix string

// Application zone (RZ) Subnet
param subnetApplicationName string
param subnetApplicationPrefix string

// Data Zone (HRZ) Subnet
param subnetDataName string
param subnetDataPrefix string

// Databricks
param subnetDatabricksPublicName string
param subnetDatabricksPublicPrefix string

param subnetDatabricksPrivateName string
param subnetDatabricksPrivatePrefix string

// Private Endpoints
param subnetPrivateEndpointsName string
param subnetPrivateEndpointsPrefix string

// Web App Subnet
param subnetWebAppName string
param subnetWebAppPrefix string

param secretExpiryInDays int

@secure()
param synapseUsername string

@description('If SQL Database is selected to be deployed, enter username. Otherwise, you can enter blank')
@secure()
param sqldbUsername string

@description('When true, customer managed keys are used for Azure resources')
param useCMK bool

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
  location: azureRegion
  tags: tags
}

resource rgAutomation 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgAutomationName
  location: azureRegion
  tags: tags
}

resource rgVnet 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgVnetName
  location: azureRegion
  tags: tags
}

resource rgStorage 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgStorageName
  location: azureRegion
  tags: tags
}

resource rgCompute 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgComputeName
  location: azureRegion
  tags: tags
}

resource rgSecurity 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgSecurityName
  location: azureRegion
  tags: tags
}

resource rgMonitor 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgMonitorName
  location: azureRegion
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

module rgStorageDeploymentScriptPermissionCleanup '../../azresources/util/deploymentScript.bicep' = {
  dependsOn: [
    acr
    dataLake
    storageLogging
  ]

  scope: rgAutomation
  name: 'ds-rbac-${rgStorageName}-cleanup'
  params: {
    deploymentScript: format(azCliCommandDeploymentScriptPermissionCleanup, deploymentScriptIdentity.outputs.identityPrincipalId, rgStorage.id)
    deploymentScriptIdentityId: deploymentScriptIdentity.outputs.identityId
    deploymentScriptName: 'ds-rbac-${rgStorageName}-cleanup'
  }  
}

module rgComputeDeploymentScriptPermissionCleanup '../../azresources/util/deploymentScript.bicep' = {
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
    hubCGNATIPRange: hubCGNATIPRange

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

    deployPrivateEndpoint: true
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    privateZoneId: networking.outputs.keyVaultPrivateZoneId
  }
}

module storageLogging '../../azresources/storage/storage-generalpurpose.bicep' = {
  name: 'deploy-storage-for-logging'
  scope: rgStorage
  params: {
    tags: tags
    name: storageLoggingName

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    blobPrivateZoneId: networking.outputs.dataLakeBlobPrivateZoneId
    filePrivateZoneId: networking.outputs.dataLakeFilePrivateZoneId
    deployBlobPrivateZone: false
    deployFilePrivateZone: false
    
    defaultNetworkAcls: 'Deny'
    subnetIdForVnetRestriction: []

    useCMK: useCMK
    deploymentScriptIdentityId: useCMK ? deploymentScriptIdentity.outputs.identityId : ''
    keyVaultResourceGroupName: useCMK ? rgSecurity.name : ''
    keyVaultName: useCMK ? keyVault.outputs.akvName : ''
  }
}

module sqlDb '../../azresources/data/sqldb/main.bicep' = if (deploySQLDB == true) {
  name: 'deploy-sqldb'
  scope: rgStorage
  params: {
    tags: tags
    sqlServerName: sqlServerName
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    privateZoneId: networking.outputs.sqlDBPrivateZoneId
    sqldbUsername: sqldbUsername
    sqldbPassword: sqldbPassword
    saLoggingName: storageLogging.outputs.storageName
    storagePath: storageLogging.outputs.storagePath
    securityContactEmail: securityContactEmail

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

    deployBlobPrivateZone: true
    blobPrivateZoneId: networking.outputs.dataLakeBlobPrivateZoneId

    deployDfsPrivateZone: true
    dfsPrivateZoneId: networking.outputs.dataLakeDfsPrivateZoneId

    defaultNetworkAcls: 'Deny'
    subnetIdForVnetRestriction: []

    useCMK: useCMK
    deploymentScriptIdentityId: useCMK ? deploymentScriptIdentity.outputs.identityId : ''
    keyVaultResourceGroupName: useCMK ? rgSecurity.name : ''
    keyVaultName: useCMK ? keyVault.outputs.akvName : ''
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
    privateZoneId: networking.outputs.adfPrivateZoneId

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

    deployPrivateZone: true
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    privateZoneId: networking.outputs.acrPrivateZoneId

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
    blobPrivateZoneId: networking.outputs.dataLakeBlobPrivateZoneId
    filePrivateZoneId: networking.outputs.dataLakeFilePrivateZoneId
    deployBlobPrivateZone: true
    deployFilePrivateZone: true

    useCMK: useCMK
    deploymentScriptIdentityId: useCMK ? deploymentScriptIdentity.outputs.identityId : ''
    keyVaultResourceGroupName: useCMK ? rgSecurity.name : ''
    keyVaultName: useCMK ? keyVault.outputs.akvName : ''
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

    privateZoneAzureMLApiId: networking.outputs.amlApiPrivateZoneId
    privateZoneAzureMLNotebooksId: networking.outputs.amlNotebooksPrivateZoneId
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
    synapseName: synapseName
    tags: tags

    managedResourceGroupName: '${rgCompute.name}-${synapseName}-${uniqueString(rgCompute.id)}'

    adlsResourceGroupName: rgStorage.name
    adlsName: dataLake.outputs.storageName
    adlsFSName: 'synapsecontainer'

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    synapsePrivateZoneId: networking.outputs.synapsePrivateZoneId
    synapseDevPrivateZoneId: networking.outputs.synapseDevPrivateZoneId
    synapseSqlPrivateZoneId: networking.outputs.synapseSqlPrivateZoneId
    
    synapseUsername: synapseUsername 
    synapsePassword: synapsePassword
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
    privateZoneId: networking.outputs.fhirPrivateZoneId
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
    blobPrivateZoneId: networking.outputs.dataLakeBlobPrivateZoneId
    filePrivateZoneId: networking.outputs.dataLakeFilePrivateZoneId
    deployBlobPrivateZone: true
    deployFilePrivateZone: true

    useCMK: useCMK
    deploymentScriptIdentityId: useCMK ? deploymentScriptIdentity.outputs.identityId : ''
    keyVaultResourceGroupName: useCMK ? rgSecurity.name : ''
    keyVaultName: useCMK ? keyVault.outputs.akvName : ''
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
    privateZoneEventHubId : networking.outputs.eventhubPrivateZoneId
  }
}
