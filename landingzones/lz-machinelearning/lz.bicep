// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

param azureRegion string = deployment().location

@description('Should SQL Database be deployed in environment')
param deploySQLDB bool
@description('Should SQL Managed Instance be deployed in environment')
param deploySQLMI bool
@description('Should ADF Self Hosted Integration Runtime VM be deployed in environment')
param deploySelfhostIRVM bool

param securityContactEmail string

param tagClientOrganization string
param tagCostCenter string
param tagDataSensitivity string
param tagProjectContact string
param tagProjectName string
param tagTechnicalContact string

param rgExistingAutomationName string
param rgVnetName string
param rgStorageName string
param rgComputeName string
param rgSecurityName string
param rgMonitorName string
param rgSelfHostedRuntimeName string

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

param subnetDatabricksPublicName string
param subnetDatabricksPublicPrefix string

param subnetDatabricksPrivateName string
param subnetDatabricksPrivatePrefix string

param subnetSQLMIName string
param subnetSQLMIPrefix string

param subnetPrivateEndpointsName string
param subnetPrivateEndpointsPrefix string

param subnetAKSName string
param subnetAKSPrefix string

param secretExpiryInDays int

param aksVersion string

param adfIRVMNames array = [
  'SelfHostedVm1'
]

param selfHostedRuntimeVmSize string

param logAnalyticsWorkspaceResourceId string = ''

@description('If SQL Database is selected to be deployed, enter username. Otherwise, you can enter blank')
@secure()
param sqldbUsername string
@description('If SQL Managed Instance is selected to be deployed, enter username. Otherwise, you can enter blank')
@secure()
param sqlmiUsername string
@description('If ADF Self Hosted Integration Runtime VM is selected to be deployed, enter username. Otherwise, you can enter blank')
@secure()
param selfHostedVMUsername string

@description('When true, customer managed keys are used for Azure resources')
param useCMK bool

@description('When true, Azure ML workspace has high business impact workspace enabled')
param enableHbiWorkspace bool

var sqldbPassword = '${uniqueString(rgStorage.id)}*${toUpper(uniqueString(sqldbUsername))}'
var sqlmiPassword = '${uniqueString(rgStorage.id)}*${toUpper(uniqueString(sqlmiUsername))}'
var selfHostedVMPassword = '${uniqueString(rgCompute.id)}*${toUpper(uniqueString(selfHostedVMUsername))}'

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

var tags = {
  ClientOrganization: tagClientOrganization
  CostCenter: tagCostCenter
  DataSensitivity: tagDataSensitivity
  ProjectContact: tagProjectContact
  ProjectName: tagProjectName
  TechnicalContact: tagTechnicalContact
}

var useDeploymentScripts = useCMK

//resource group deployments
resource rgAutomation 'Microsoft.Resources/resourceGroups@2020-06-01' existing = {
  name: rgExistingAutomationName
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

resource rgSelfhosted 'Microsoft.Resources/resourceGroups@2020-06-01' = if (deploySelfhostIRVM == true) {
  name: rgSelfHostedRuntimeName
  location: azureRegion
  tags: tags
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
  name: 'rbac-ds-${rgStorageName}'
  params: {
     // Owner - this role is cleaned up as part of this deployment
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
    resourceSPObjectIds: useDeploymentScripts ? array(deploymentScriptIdentity.outputs.identityPrincipalId) : []
  }  
}

module rgComputeDeploymentScriptRBAC '../../azresources/iam/resourceGroup/role-assignment-to-sp.bicep' = if (useDeploymentScripts) {
  scope: rgCompute
  name: 'rbac-ds-${rgComputeName}'
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

module rgStorageDeploymentScriptPermissionCleanup '../../azresources/util/deploymentScript.bicep' = if (useDeploymentScripts) {
  dependsOn: [
    acr
    dataLake
    storageLogging
  ]

  scope: rgAutomation
  name: 'ds-rbac-${rgStorageName}-cleanup'
  params: {
    deploymentScript: format(azCliCommandDeploymentScriptPermissionCleanup, useDeploymentScripts ? deploymentScriptIdentity.outputs.identityPrincipalId : '', rgStorage.id)
    deploymentScriptIdentityId: useDeploymentScripts ? deploymentScriptIdentity.outputs.identityId : ''
    deploymentScriptName: 'ds-rbac-${rgStorageName}-cleanup'
  }  
}

module rgComputeDeploymentScriptPermissionCleanup '../../azresources/util/deploymentScript.bicep' = if (useDeploymentScripts) {
  dependsOn: [
    dataLakeMetaData
  ]

  scope: rgAutomation
  name: 'ds-rbac-${rgComputeName}-cleanup'
  params: {
    deploymentScript: format(azCliCommandDeploymentScriptPermissionCleanup, useDeploymentScripts ? deploymentScriptIdentity.outputs.identityPrincipalId : '', rgCompute.id)
    deploymentScriptIdentityId: useDeploymentScripts ? deploymentScriptIdentity.outputs.identityId : ''
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
    
    subnetSqlMIName: subnetSQLMIName
    subnetSqlMIPrefix: subnetSQLMIPrefix
   
    subnetPrivateEndpointsName: subnetPrivateEndpointsName
    subnetPrivateEndpointsPrefix: subnetPrivateEndpointsPrefix
    
    subnetAKSName: subnetAKSName
    subnetAKSPrefix: subnetAKSPrefix
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

module sqlMi '../../azresources/data/sqlmi/main.bicep' = if (deploySQLMI == true) {
  name: 'deploy-sqlmi'
  scope: rgStorage
  params: {
    tags: tags
    
    name: sqlMiName
    
    subnetId: networking.outputs.sqlMiSubnetId
    
    sqlmiUsername: sqlmiUsername
    sqlmiPassword: sqlmiPassword

    saLoggingName: storageLogging.outputs.storageName
    storagePath: storageLogging.outputs.storagePath
    
    securityContactEmail: securityContactEmail

    useCMK: useCMK
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? keyVault.outputs.akvName : ''
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
    subnetIdForVnetRestriction: array(networking.outputs.sqlMiSubnetId)

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

module aks '../../azresources/containers/aks-kubenet/main.bicep' = {
  name: 'deploy-aks'
  scope: rgCompute
  params: {
    tags: tags

    aksName: aksName
    aksVersion: aksVersion

    systemNodePoolEnableAutoScaling: true
    systemNodePoolMinNodeCount: 1
    systemNodePoolMaxNodeCount: 3
    systemNodePoolNodeSize: 'Standard_DS2_v2'

    userNodePoolEnableAutoScaling: true
    userNodePoolMinNodeCount: 1
    userNodePoolMaxNodeCount: 3
    userNodePoolNodeSize: 'Standard_DS2_v2'
    
    subnetID: networking.outputs.aksSubnetId
    nodeResourceGroupName: '${rgCompute.name}-${aksName}-${uniqueString(rgCompute.id)}'
    
    containerInsightsLogAnalyticsResourceId: logAnalyticsWorkspaceResourceId

    useCMK: useCMK
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? keyVault.outputs.akvName : ''
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

// vm provisioned as part for the integration runtime for ADF
module vm '../../azresources/compute/vm-win2019/main.bicep' = [for (vmName, i) in adfIRVMNames: if (deploySelfhostIRVM == true) {
  name: 'deploy-ir-${vmName}'
  scope: rgSelfhosted
  params: {
    vmName: vmName
    vmSize: selfHostedRuntimeVmSize

    availabilityZone: string((i % 3) + 1)

    subnetId: networking.outputs.dataSubnetId
    enableAcceleratedNetworking: false

    username: selfHostedVMUsername
    password: selfHostedVMPassword
    
    useCMK: useCMK
    akvResourceGroupName: useCMK ? rgSecurity.name : ''
    akvName: useCMK ? keyVault.outputs.akvName : ''
  }
}]

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
    enableHbiWorkspace: enableHbiWorkspace

    useCMK: useCMK
    akvResourceGroupName: rgSecurity.name
    akvName: keyVault.outputs.akvName
  }
}

// Adding secrets to key vault
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

module akvSqlmiUsername '../../azresources/security/key-vault-secret.bicep' = if (deploySQLMI == true) {
  dependsOn: [
    keyVault
  ]
  name: 'add-akv-secret-sqlmiUsername'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'sqlmiUsername'
    secretValue: sqlmiUsername
    secretExpiryInDays: secretExpiryInDays
  }
}

module akvSqlmiPassword '../../azresources/security/key-vault-secret.bicep' = if (deploySQLMI == true) {
  dependsOn: [
    keyVault
  ]
  name: 'add-akv-secret-sqlmiPassword'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'sqlmiPassword'
    secretValue: sqlmiPassword
    secretExpiryInDays: secretExpiryInDays
  }
}

module akvSqlMiConnection '../../azresources/security/key-vault-secret.bicep' = if (deploySQLMI == true) {
  dependsOn: [
    keyVault
  ]
  name: 'add-akv-secret-SqlMiConnectionString'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'SqlMiConnectionString'
    secretValue: 'Server=tcp:${deploySQLMI ? sqlMi.outputs.sqlMiFqdn : ''},1433;Initial Catalog=${sqlMiName};Persist Security Info=False;User ID=${sqlmiUsername};Password=${sqlmiPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
    secretExpiryInDays: secretExpiryInDays
  }
}

module akvselfHostedVMUsername '../../azresources/security/key-vault-secret.bicep' = if (deploySelfhostIRVM == true) {
  dependsOn: [
    keyVault
  ]
  name: 'add-akv-secret-selfHostedVMUsername'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'selfHostedVMUsername'
    secretValue: selfHostedVMUsername
    secretExpiryInDays: secretExpiryInDays
  }
}

module akvselfHostedVMPassword '../../azresources/security/key-vault-secret.bicep' = if (deploySelfhostIRVM == true) {
  dependsOn: [
    keyVault
  ]
  name: 'add-akv-secret-selfHostedVMPassword'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'selfHostedVMPassword'
    secretValue: selfHostedVMPassword
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
