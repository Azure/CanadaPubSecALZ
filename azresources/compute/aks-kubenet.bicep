// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param aksName string = 'aks'
param subnetID string
param aksVersion string
param vmNodeCount int = 1
param vmNodeSize string = 'Standard_DS2_v2'
param dnsPrefix string = 'aksdns'
param nodeResourceGroupName string
param tags object = {}

resource akskubenet 'Microsoft.ContainerService/managedClusters@2021-02-01' = {
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
      podCidr: '11.0.0.0/16'
      serviceCidr: '20.0.0.0/16'
      dnsServiceIP: '20.0.0.10'
      dockerBridgeCidr: '30.0.0.1/16'
    }
    agentPoolProfiles: [
      {
        count: vmNodeCount
        vmSize: vmNodeSize
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        type: 'VirtualMachineScaleSets'
        osType: 'Linux'
        vnetSubnetID: subnetID
        name: 'agentpool'
        mode: 'System'
      }
    ]
    apiServerAccessProfile: {
      enablePrivateCluster: true
    }
    servicePrincipalProfile: {
      clientId: 'msi'
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}
