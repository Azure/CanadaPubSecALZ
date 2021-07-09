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

param rgVnetName string
param rgStorageName string
param rgComputeName string
param rgSecurityName string
param rgMonitorName string
param rgSelfHostedRuntimeName string

param vnetId string
param vnetName string

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

param adfSelfHostedRuntimeSubnetId string

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

//resource group deployments
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

//virtual network deployment
module networking 'networking.bicep' = {
  name: 'networking'
  scope: resourceGroup(rgVnetName)
  params: {
    vnetId: vnetId
    vnetName: vnetName

    deploySQLDB: deploySQLDB
    deploySQLMI: deploySQLMI
    
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
  name: 'keyVault'
  scope: rgSecurity
  params: {
    name: akvName
    tags: tags
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    privateZoneId: networking.outputs.keyVaultPrivateZoneId
  }
}

module sqlMi '../../azresources/sql/sqlmi.bicep' = if (deploySQLMI == true) {
  name: 'sqlMi'
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
  }
}

module storageLogging '../../azresources/storage/storagev2.bicep' = {
  name: 'storageLogging'
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
    subnetIdForVnetRestriction: deploySQLMI ? array(networking.outputs.sqlMiSubnetId): []
  }
}

module sqlDb '../../azresources/sql/sqldb.bicep' = if (deploySQLDB == true) {
  name: 'sqldb'
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
  }
}

module dataLake '../../azresources/storage/adlsgen2.bicep' = {
  name: 'datalake'
  scope: rgStorage
  params: {
    tags: tags
    name: datalakeStorageName
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    blobPrivateZoneId: networking.outputs.dataLakeBlobPrivateZoneId
    dfsPrivateZoneId: networking.outputs.dataLakeDfsPrivateZoneId
  }
}

module egressLb '../../azresources/network/lb-egress.bicep' = {
  name: 'egressLb'
  scope: rgCompute
  params: {
    name: databricksEgressLbName
    tags: tags
  }
}

module databricks '../../azresources/compute/databricks.bicep' = {
  name: 'databricks'
  scope: rgCompute
  params: {
    name: databricksName
    tags: tags
    vnetId: vnetId
    pricingTier: 'premium'
    managedResourceGroupId: '${subscription().id}/resourceGroups/${rgCompute.name}-${databricksName}-${uniqueString(rgCompute.id)}'
    publicSubnetName: networking.outputs.databricksPublicSubnetName
    privateSubnetName: networking.outputs.databricksPrivateSubnetName
    loadbalancerId: egressLb.outputs.lbId
    loadBalancerBackendPoolName: egressLb.outputs.lbBackendPoolName
  }
}

module aks '../../azresources/compute/aks-kubenet.bicep' = {
  name: 'aks'
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
  }
}

module adf '../../azresources/compute/datafactory.bicep' = {
  name: 'adf'
  scope: rgCompute
  params: {
    tags: tags
    name: adfName
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    privateZoneId: networking.outputs.adfPrivateZoneId
  }
}

// vm provisioned as part for the integration runtime for ADF
module vm '../../azresources/compute/vm-win2019.bicep' = [for i in range(0, length(adfIRVMNames)): if (deploySelfhostIRVM == true) {
  name: adfIRVMNames[i]
  scope: rgSelfhosted
  params: {
    enableAcceleratedNetworking: false
    username: selfHostedVMUsername
    password: selfHostedVMPassword
    subnetId: adfSelfHostedRuntimeSubnetId
    vmName: adfIRVMNames[i]
    vmSize: selfHostedRuntimeVmSize
    availabilityZone: string((i % 3) + 1)
  }
}]

module acr '../../azresources/storage/acr.bicep' = {
  name: 'acr'
  scope: rgStorage
  params: {
    name: acrName
    tags: tags
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    privateZoneId: networking.outputs.acrPrivateZoneId
  }
}

module appInsights '../../azresources/monitor/ai-web.bicep' = {
  name: 'aiweb'
  scope: rgMonitor
  params: {
    tags: tags
    name: aiName
  }
}

// azure machine learning uses a metadata data lake storage account

module dataLakeMetaData '../../azresources/storage/storagev2.bicep' = {
  name: 'amlmeta'
  scope: rgCompute
  params: {
    tags: tags
    name: amlMetaStorageName
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    blobPrivateZoneId: networking.outputs.dataLakeBlobPrivateZoneId
    filePrivateZoneId: networking.outputs.dataLakeFilePrivateZoneId
    deployBlobPrivateZone: true
    deployFilePrivateZone: true
  }
}

module aml '../../azresources/compute/aml.bicep' = {
  name: 'aml'
  scope: rgCompute
  params: {
    name: amlName
    tags: tags
    keyVaultId: keyVault.outputs.akvId
    containerRegistryId: acr.outputs.acrId
    storageAccountId: dataLakeMetaData.outputs.storageId
    appInsightsId: appInsights.outputs.aiId
    privateZoneAzureMLApiId: networking.outputs.amlApiPrivateZoneId
    privateZoneAzureMLNotebooksId: networking.outputs.amlNotebooksPrivateZoneId
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
  }
}

// Adding secrets to key vault
module akvSqlDbUsername '../../azresources/security/key-vault-secret.bicep' = if (deploySQLDB == true) {
  dependsOn: [
    keyVault
  ]
  name: 'akvSqlDbUsername'
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
  name: 'akvSqlDbPassword'
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
  name: 'akvSqlDbConnection'
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
  name: 'akvSqlmiUsername'
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
  name: 'akvSqlmiPassword'
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
  name: 'akvSqlMiConnection'
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
  name: 'akvselfHostedVMUsername'
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
  name: 'akvselfHostedVMPassword'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'selfHostedVMPassword'
    secretValue: selfHostedVMPassword
    secretExpiryInDays: secretExpiryInDays
  }
}

// Creating role assignments
module roleAssignADFToAKV '../../azresources/iam/resource/roleAssignmentToSP.bicep' = {
  name: 'roleAssignADFToAKV'
  scope: rgSecurity
  params: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
    resourceSPObjectIds: array(adf.outputs.identityPrincipalId)
  }
}
