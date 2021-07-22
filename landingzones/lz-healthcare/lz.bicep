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

param subnetPrivateEndpointsName string
param subnetPrivateEndpointsPrefix string

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

@description('When true, customer managed keys are used for Azure resources')
param useCMK bool

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
var fhirName = 'fhir${uniqueString(rgCompute.id)}'

var tags = {
  ClientOrganization: tagClientOrganization
  CostCenter: tagCostCenter
  DataSensitivity: tagDataSensitivity
  ProjectContact: tagProjectContact
  ProjectName: tagProjectName
  TechnicalContact: tagTechnicalContact
}

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
        
    subnetSynapseName: subnetSynapseName
    subnetSynapsePrefix: subnetSynapsePrefix
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
    subnetIdForVnetRestriction: array(networking.outputs.privateEndpointSubnetId)

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
    keyVaultId: keyVault.outputs.akvId
    containerRegistryId: acr.outputs.acrId
    storageAccountId: dataLakeMetaData.outputs.storageId
    appInsightsId: appInsights.outputs.aiId
    privateZoneAzureMLApiId: networking.outputs.amlApiPrivateZoneId
    privateZoneAzureMLNotebooksId: networking.outputs.amlNotebooksPrivateZoneId
    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
  }
}

module synapse '../../azresources/analytics/synapse/main.bicep' = {
  name: 'deploy-synapse'
  scope: rgCompute
  params: {
    synapseName: synapseName
    tags: tags

    computeSubnetId: networking.outputs.synapseSubnetId
    managedResourceGroupName: '${rgCompute.name}-${synapseName}-${uniqueString(rgCompute.id)}'

    deploymentScriptIdentityId: deploymentScriptIdentity.outputs.identityId
    adlsResourceGroupName: rgStorage.name
    adlsName: dataLake.outputs.storageName
    adlsFSName: 'synapsecontainer'
    
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
