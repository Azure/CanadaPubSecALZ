// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
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

param subnetId string
param dnsPrefix string = 'aksdns'
param nodeResourceGroupName string

param podCidr string = '11.0.0.0/16'
param serviceCidr string = '20.0.0.0/16'
param dnsServiceIP string = '20.0.0.10'
param dockerBridgeCidr string = '30.0.0.1/16'

param privateDNSZoneId string

param containerInsightsLogAnalyticsResourceId string = ''

@description('When true, customer managed key will be enabled')
param useCMK bool
@description('Required when useCMK=true')
param akvResourceGroupName string
@description('Required when useCMK=true')
param akvName string

@description('Enable encryption at host (double encryption)')
param enableEncryptionAtHost bool = true

// Example:  /subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/virtualNetworks/<virtual-network-name>/subnets/aks
var subnetIdSplit = split(subnetId, '/')
var virtualNetworkResourceGroup = subnetIdSplit[4]
var virtualNetworkName = subnetIdSplit[8]

// Example: /subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/privateDnsZones/privatelink.canadacentral.azmk8s.io
var privateDnsZoneIdSplit = split(privateDNSZoneId, '/')
var privateDnsZoneSubscriptionId = privateDnsZoneIdSplit[2]
var privateZoneDnsResourceGroupName = privateDnsZoneIdSplit[4]
var privateZoneResourceName = last(privateDnsZoneIdSplit)

module identity '../../iam/user-assigned-identity.bicep' = {
  name: 'deploy-aks-identity'
  params: {
    name: '${aksName}-managed-identity'
  }
}

// assign permissions to identity per https://docs.microsoft.com/en-us/azure/aks/private-clusters#configure-private-dns-zone
module rbacPrivateDnsZoneContributor '../../iam/resource/private-dns-zone-role-assignment-to-sp.bicep' = {
  name: 'rbac-private-dns-zone-contributor-${aksName}'
  scope: resourceGroup(privateDnsZoneSubscriptionId, privateZoneDnsResourceGroupName)
  params: {
    zoneName: privateZoneResourceName
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b12aa53e-6015-4669-85d0-8515ebb3ae7f') // Private DNS Zone Contributor
    resourceSPObjectIds: array(identity.outputs.identityPrincipalId)
  }
}

module rbacNetworkContributor '../../iam/resource/virtual-network-role-assignment-to-sp.bicep' = {
  name: 'rbac-network-contributor-${aksName}'
  scope: resourceGroup(virtualNetworkResourceGroup)
  params: {
    vnetName: virtualNetworkName
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7') // Network Contributor
    resourceSPObjectIds: array(identity.outputs.identityPrincipalId)
  }
}

module aksWithoutCMK 'aks-kubenet-without-cmk.bicep' = if (!useCMK) {
  dependsOn: [
    rbacPrivateDnsZoneContributor
    rbacNetworkContributor
  ]

  name: 'deploy-aks-without-cmk'
  params: {
    aksName: aksName
    aksVersion: aksVersion

    userAssignedIdentityId: identity.outputs.identityId

    dnsPrefix: dnsPrefix

    nodeResourceGroupName: nodeResourceGroupName

    tags: tags

    subnetId: subnetId

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

    privateDNSZoneId: privateDNSZoneId

    containerInsightsLogAnalyticsResourceId: containerInsightsLogAnalyticsResourceId

    enableEncryptionAtHost: enableEncryptionAtHost
  }
}

module aksWithCMK 'aks-kubenet-with-cmk.bicep' = if (useCMK) {
  dependsOn: [
    rbacPrivateDnsZoneContributor
    rbacNetworkContributor
  ]

  name: 'deploy-aks-with-cmk'
  params: {
    aksName: aksName
    aksVersion: aksVersion

    userAssignedIdentityId: identity.outputs.identityId

    dnsPrefix: dnsPrefix

    nodeResourceGroupName: nodeResourceGroupName

    tags: tags

    subnetId: subnetId

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

    privateDNSZoneId: privateDNSZoneId

    containerInsightsLogAnalyticsResourceId: containerInsightsLogAnalyticsResourceId

    enableEncryptionAtHost: enableEncryptionAtHost

    akvResourceGroupName: akvResourceGroupName
    akvName: akvName
  }
}
