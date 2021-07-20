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

@description('When true, customer managed key will be enabled')
param useCMK bool
@description('Required when useCMK=true')
param akvResourceGroupName string
@description('Required when useCMK=true')
param akvName string

@description('Enable encryption at host (double encryption)')
param enableEncryptionAtHost bool = true

module aksWithoutCMK 'aks-kubenet-without-cmk.bicep' = if (!useCMK) {
  name: 'deploy-aks-without-cmk'
  params: {
    aksName: aksName
    aksVersion: aksVersion

    dnsPrefix: dnsPrefix

    nodeResourceGroupName: nodeResourceGroupName

    tags: tags

    subnetID: subnetID

    systemNodePoolMinNodeCount: systemNodePoolMinNodeCount
    systemNodePoolMaxNodeCount: systemNodePoolMaxNodeCount
    systemNodePoolEnableAutoScaling: systemNodePoolEnableAutoScaling
    systemNodePoolNodeSize: systemNodePoolNodeSize

    userNodePoolMaxNodeCount: userNodePoolMaxNodeCount
    userNodePoolEnableAutoScaling: userNodePoolEnableAutoScaling
    userNodePoolMinNodeCount: userNodePoolMinNodeCount
    userNodePoolNodeSize: userNodePoolNodeSize

    podCidr: podCidr
    serviceCidr: serviceCidr
    dnsServiceIP: dnsServiceIP
    dockerBridgeCidr: dockerBridgeCidr

    containerInsightsLogAnalyticsResourceId: containerInsightsLogAnalyticsResourceId

    enableEncryptionAtHost: enableEncryptionAtHost
  }
}

module aksWithCMK 'aks-kubenet-with-cmk.bicep' = if (useCMK) {
  name: 'deploy-aks-with-cmk'
  params: {
    aksName: aksName
    aksVersion: aksVersion

    dnsPrefix: dnsPrefix

    nodeResourceGroupName: nodeResourceGroupName

    tags: tags

    subnetID: subnetID

    systemNodePoolMinNodeCount: systemNodePoolMinNodeCount
    systemNodePoolMaxNodeCount: systemNodePoolMaxNodeCount
    systemNodePoolEnableAutoScaling: systemNodePoolEnableAutoScaling
    systemNodePoolNodeSize: systemNodePoolNodeSize

    userNodePoolMaxNodeCount: userNodePoolMaxNodeCount
    userNodePoolEnableAutoScaling: userNodePoolEnableAutoScaling
    userNodePoolMinNodeCount: userNodePoolMinNodeCount
    userNodePoolNodeSize: userNodePoolNodeSize

    podCidr: podCidr
    serviceCidr: serviceCidr
    dnsServiceIP: dnsServiceIP
    dockerBridgeCidr: dockerBridgeCidr

    containerInsightsLogAnalyticsResourceId: containerInsightsLogAnalyticsResourceId

    enableEncryptionAtHost: enableEncryptionAtHost

    akvResourceGroupName: akvResourceGroupName
    akvName: akvName
  }
}
