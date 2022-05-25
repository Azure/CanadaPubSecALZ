// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Azure Kubernetes Service Name.')
param name string

@description('Azure Kubernetes Service UDR Name.')
param udrName string

@description('Azure Kubernetes Service Version.')
param version string

@description('Azure Kubernetes Service Network Plugin; Kubenet (kubenet) | Azure CNI (azure) .')
param networkPlugin string

@description('Azure Kubernetes Service Network Policy; for Kubenet: calico | For Azure CNI: azure or calico .')
param networkPolicy string 

@description('Key/Value pair of tags.')
param tags object = {}

@description('AKS Managed Resource Group Name.')
param nodeResourceGroupName string

// System Node Pool
@description('System Node Pool - Boolean to enable auto scaling.')
param systemNodePoolEnableAutoScaling bool

@description('System Node Pool - Minimum Node Count.')
param systemNodePoolMinNodeCount int

@description('System Node Pool - Maximum Node Count.')
param systemNodePoolMaxNodeCount int

@description('System Node Pool - Node SKU.')
param systemNodePoolNodeSize string

// User Node Pool
@description('User Node Pool - Boolean to enable auto scaling.')
param userNodePoolEnableAutoScaling bool

@description('User Node Pool - Minimum Node Count.')
param userNodePoolMinNodeCount int

@description('User Node Pool - Maximum Node Count.')
param userNodePoolMaxNodeCount int

@description('User Node Pool - Node SKU.')
param userNodePoolNodeSize string

// Networking
@description('Subnet Resource Id.')
param subnetId string

@description('DNS Prefix.')
param dnsPrefix string

@description('Private DNS Zone Resource Id.')
param privateDNSZoneId string

// Kubernetes Networking 
@description('Pod CIDR.')
param podCidr string 

@description('Service CIDR.')
param serviceCidr string

@description('DNS Service IP.')
param dnsServiceIP string

@description('Docker Bridge CIDR.')
param dockerBridgeCidr string 

// Container Insights
@description('Log Analytics Workspace Resource Id.  Default: blank')
param containerInsightsLogAnalyticsResourceId string = ''

// Customer Managed Key
@description('Boolean flag that determines whether to enable Customer Managed Key.')
param useCMK bool

// Azure Key Vault
@description('Azure Key Vault Resource Group Name.  Required when useCMK=true.')
param akvResourceGroupName string

@description('Azure Key Vault Name.  Required when useCMK=true.')
param akvName string

// Host Encryption
@description('Enable encryption at host (double encryption).  Default: true')
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
    name: '${name}-managed-identity'
  }
}

// assign permissions to identity per https://docs.microsoft.com/en-us/azure/aks/private-clusters#configure-private-dns-zone
module rbacPrivateDnsZoneContributor '../../iam/resource/private-dns-zone-role-assignment-to-sp.bicep' = {
  name: 'rbac-private-dns-zone-contributor-${name}'
  scope: resourceGroup(privateDnsZoneSubscriptionId, privateZoneDnsResourceGroupName)
  params: {
    zoneName: privateZoneResourceName
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b12aa53e-6015-4669-85d0-8515ebb3ae7f') // Private DNS Zone Contributor
    resourceSPObjectIds: array(identity.outputs.identityPrincipalId)
  }
}

module rbacNetworkContributor '../../iam/resource/virtual-network-role-assignment-to-sp.bicep' = {
  name: 'rbac-network-contributor-${name}'
  scope: resourceGroup(virtualNetworkResourceGroup)
  params: {
    vnetName: virtualNetworkName
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7') // Network Contributor
    resourceSPObjectIds: array(identity.outputs.identityPrincipalId)
  }
}

module rbacUdrContributor '../../iam/resource/route-table-role-assignment-to-sp.bicep' = {
  name: 'rbac-udr-contributor-${name}'
  scope: resourceGroup(virtualNetworkResourceGroup)
  params: {
    udrName: udrName
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7') // Network Contributor
    resourceSPObjectIds: array(identity.outputs.identityPrincipalId)
  }
}

module aksWithoutCMK 'aks-without-cmk.bicep' = if (!useCMK) {
  dependsOn: [
    rbacPrivateDnsZoneContributor
    rbacNetworkContributor
  ]

  name: 'deploy-aks-without-cmk'
  params: {
    name: name
    version: version

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

    networkPlugin: networkPlugin
    networkPolicy: networkPolicy

    privateDNSZoneId: privateDNSZoneId

    containerInsightsLogAnalyticsResourceId: containerInsightsLogAnalyticsResourceId

    enableEncryptionAtHost: enableEncryptionAtHost
  }
}

module aksWithCMK 'aks-with-cmk.bicep' = if (useCMK) {
  dependsOn: [
    rbacPrivateDnsZoneContributor
    rbacNetworkContributor
  ]

  name: 'deploy-aks-with-cmk'
  params: {
    name: name
    version: version

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

    networkPlugin: networkPlugin
    networkPolicy: networkPolicy
    
    privateDNSZoneId: privateDNSZoneId

    containerInsightsLogAnalyticsResourceId: containerInsightsLogAnalyticsResourceId

    enableEncryptionAtHost: enableEncryptionAtHost

    akvResourceGroupName: akvResourceGroupName
    akvName: akvName
  }
}
