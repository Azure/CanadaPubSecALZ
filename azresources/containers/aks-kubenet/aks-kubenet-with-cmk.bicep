// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param aksName string = 'aks'
param aksVersion string

param tags object = {}

param systemNodePoolEnableAutoScaling bool
param systemNodePoolMinNodeCount int
param systemNodePoolMaxNodeCount int
param systemNodePoolNodeSize string = 'Standard_DS2_v2'

param userNodePoolEnableAutoScaling bool
param userNodePoolMinNodeCount int
param userNodePoolMaxNodeCount int
param userNodePoolNodeSize string = 'Standard_DS2_v2'

param subnetID string
param dnsPrefix string = 'aksdns'
param nodeResourceGroupName string

param podCidr string = '11.0.0.0/16'
param serviceCidr string = '20.0.0.0/16'
param dnsServiceIP string = '20.0.0.10'
param dockerBridgeCidr string = '30.0.0.1/16'

param containerInsightsLogAnalyticsResourceId string = ''

@description('Enable encryption at host (double encryption)')
param enableEncryptionAtHost bool = true

param akvResourceGroupName string
param akvName string

resource akv 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  scope: resourceGroup(akvResourceGroupName)
  name: akvName
}

module akvKey '../../security/key-vault-key-rsa2048.bicep' = {
  name: 'add-cmk-${aksName}'
  scope: resourceGroup(akvResourceGroupName)
  params: {
      akvName: akvName
      keyName: 'cmk-aks-${aksName}'
  }
}

resource diskEncryptionSet 'Microsoft.Compute/diskEncryptionSets@2020-12-01' = {
  name: '${aksName}-disk-encryption-set'
  location: resourceGroup().location
  identity: {
      type: 'SystemAssigned'
  }

  properties: {
      rotationToLatestKeyVersionEnabled: true
      encryptionType: 'EncryptionAtRestWithPlatformAndCustomerKeys'
      activeKey: {
          keyUrl: akvKey.outputs.keyUriWithVersion
      }
  }
}

module diskEncryptionSetRoleAssignmentForCMK '../../iam/resource/key-vault-role-assignment-to-sp.bicep' = {
  name: 'rbac-${diskEncryptionSet.name}-key-vault'
  scope: resourceGroup(akvResourceGroupName)
  params: {
      keyVaultName: akv.name
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e147488a-f6f5-4113-8e2d-b22465e65bf6') // Key Vault Crypto Service Encryption User
      resourceSPObjectIds: array(diskEncryptionSet.identity.principalId)
  }
}

resource akskubenet 'Microsoft.ContainerService/managedClusters@2021-02-01' = {
  dependsOn: [
    diskEncryptionSetRoleAssignmentForCMK
  ]

  name: aksName
  location: resourceGroup().location
  tags: tags
  properties: {
    nodeResourceGroup: nodeResourceGroupName
    kubernetesVersion: aksVersion
    dnsPrefix: dnsPrefix
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'kubenet'
      podCidr: podCidr
      serviceCidr: serviceCidr
      dnsServiceIP: dnsServiceIP
      dockerBridgeCidr: dockerBridgeCidr
    }
    agentPoolProfiles: [
      {
        count: systemNodePoolMinNodeCount
        minCount: systemNodePoolMinNodeCount
        maxCount: systemNodePoolMaxNodeCount
        enableAutoScaling: systemNodePoolEnableAutoScaling
        vmSize: systemNodePoolNodeSize
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        type: 'VirtualMachineScaleSets'
        osType: 'Linux'
        vnetSubnetID: subnetID
        name: 'systempool'
        mode: 'System'
        enableEncryptionAtHost: enableEncryptionAtHost
      }
      {
        count: userNodePoolMinNodeCount
        minCount: userNodePoolMinNodeCount
        maxCount: userNodePoolMaxNodeCount
        enableAutoScaling: userNodePoolEnableAutoScaling
        vmSize: userNodePoolNodeSize
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        type: 'VirtualMachineScaleSets'
        osType: 'Linux'
        vnetSubnetID: subnetID
        name: 'agentpool'
        mode: 'User'
        enableEncryptionAtHost: enableEncryptionAtHost
      }
    ]
    apiServerAccessProfile: {
      enablePrivateCluster: true
    }
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    addonProfiles: {
      'omsagent': (!empty(containerInsightsLogAnalyticsResourceId)) ? {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: containerInsightsLogAnalyticsResourceId
        }
      } : {
          enabled: false
      }
    }
    diskEncryptionSetID: diskEncryptionSet.id
  }
  identity: {
    type: 'SystemAssigned'
  }
}
