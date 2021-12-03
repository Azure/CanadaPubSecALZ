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

@description('User Assigned Managed Identity Resource Id.')
param userAssignedIdentityId string

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

// Host Encryption
@description('Enable encryption at host (double encryption).  Default: true')
param enableEncryptionAtHost bool = true


var networkProfile =  {
  networkPlugin: networkPlugin
  podCidr: podCidr
  serviceCidr: serviceCidr
  dnsServiceIP: dnsServiceIP
  dockerBridgeCidr: dockerBridgeCidr
  networkPolicy: networkPolicy
  outboundType: 'userDefinedRouting'
}

resource aks 'Microsoft.ContainerService/managedClusters@2021-07-01' = {
  name: name
  location: resourceGroup().location
  tags: tags
  properties: {
    nodeResourceGroup: nodeResourceGroupName
    kubernetesVersion: version
    dnsPrefix: dnsPrefix
    enableRBAC: true
    networkProfile: networkProfile
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
        vnetSubnetID: subnetId
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
        vnetSubnetID: subnetId
        name: 'agentpool'
        mode: 'User'
        enableEncryptionAtHost: enableEncryptionAtHost
      }
    ]
    apiServerAccessProfile: {
      enablePrivateCluster: true
      enablePrivateClusterPublicFQDN: false
      privateDNSZone: privateDNSZoneId
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
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
}
