// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

param azureRegion string = deployment().location

@description('Should ADF Self Hosted Integration Runtime VM be deployed in environment')
param deploySelfhostIRVM bool

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

param subnetPrivateEndpointsName string
param subnetPrivateEndpointsPrefix string

param adfSelfHostedRuntimeSubnetId string

param subnetSynapseName string
param subnetSynapsePrefix string

param secretExpiryInDays int


param adfIRVMNames array = [
  'SelfHostedVm1'
]

param selfHostedRuntimeVmSize string

@secure()
param synapseUsername string


@description('If ADF Self Hosted Integration Runtime VM is selected to be deployed, enter username. Otherwise, you can enter blank')
@secure()
param selfHostedVMUsername string

var synapsePassword = '${uniqueString(rgCompute.id)}*${toUpper(uniqueString(synapseUsername))}'
var selfHostedVMPassword = '${uniqueString(rgCompute.id)}*${toUpper(uniqueString(selfHostedVMUsername))}'

var databricksName = 'databricks'
var databricksEgressLbName = 'egressLb'
var datalakeStorageName = 'datalake${uniqueString(rgStorage.id)}'
var amlMetaStorageName = 'amlmeta${uniqueString(rgCompute.id)}'
var akvName = 'akv${uniqueString(rgSecurity.id)}'
var adfName = 'adf${uniqueString(rgCompute.id)}'
var amlName = 'aml${uniqueString(rgCompute.id)}'
var acrName = 'acr${uniqueString(rgStorage.id)}'
var aiName = 'ai${uniqueString(rgMonitor.id)}'
var synapseName = 'syn${uniqueString(rgMonitor.id)}'

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
    
    subnetDatabricksPublicName: subnetDatabricksPublicName
    subnetDatabricksPublicPrefix: subnetDatabricksPublicPrefix
    subnetDatabricksPrivateName: subnetDatabricksPrivateName
    subnetDatabricksPrivatePrefix: subnetDatabricksPrivatePrefix
    subnetPrivateEndpointsName: subnetPrivateEndpointsName
    subnetPrivateEndpointsPrefix: subnetPrivateEndpointsPrefix

    subnetSynapseName: subnetSynapseName
    subnetSynapsePrefix: subnetSynapsePrefix
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

module synapse '../../azresources/compute/synapse.bicep' = {
  name: 'synapse'
  scope: rgCompute
  params: {
    synapseName: synapseName
    computeSubnetId: networking.outputs.synapseSubnetId
    tags: tags
    managedResourceGroupName: 'synapse-rg-${rgCompute.name}-${uniqueString(rgCompute.id)}'
    synapseUsername: synapseUsername 
    synapsePassword: synapsePassword
  }
}

module akvsynapseUsername '../../azresources/security/key-vault-secret.bicep' = {
  dependsOn: [
    keyVault
  ]
  name: 'synapseUsername'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'synapseUsername'
    secretValue: synapseUsername
    secretExpiryInDays: secretExpiryInDays
  }
}

module akvsynapsePassword '../../azresources/security/key-vault-secret.bicep' = {
  dependsOn: [
    keyVault
  ]
  name: 'synapsePassword'
  scope: rgSecurity
  params: {
    akvName: akvName
    secretName: 'synapsePassword'
    secretValue: synapsePassword
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
