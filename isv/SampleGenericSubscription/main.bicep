// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

// Resource Groups
param rgVnetName string = 'networkingRG'

// VNET
param vnetName string = 'vnet'
param vnetAddressSpace string = '10.0.0.0/16'

// Presentation Zone (PAZ) Subnet
param subnetPresentationName string = 'paz'
param subnetPresentationPrefix string = '10.0.1.0/24'

// Internal Foundational Elements (OZ) Subnet
param subnetFoundationalElementsName string = 'oz'
param subnetFoundationalElementsPrefix string = '10.0.2.0/24'

// Application zone (RZ) Subnet
param subnetApplicationName string = 'rz'
param subnetApplicationPrefix string = '10.0.3.0/24'

// Data Zone (HRZ) Subnet
param subnetDataName string = 'hrz'
param subnetDataPrefix string = '10.0.4.0/24'

// Resource Groups
resource rgVnet 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgVnetName
  location: deployment().location
}

// Virtual Network
module vnet 'networking.bicep' = {
  name: 'vnet'
  scope: resourceGroup(rgVnet.name)
  params: {
    vnetName: vnetName
    vnetAddressSpace: vnetAddressSpace
    subnetFoundationalElementsName: subnetFoundationalElementsName
    subnetFoundationalElementsPrefix: subnetFoundationalElementsPrefix
    subnetPresentationName: subnetPresentationName
    subnetPresentationPrefix: subnetPresentationPrefix
    subnetApplicationName: subnetApplicationName
    subnetApplicationPrefix: subnetApplicationPrefix
    subnetDataName: subnetDataName
    subnetDataPrefix: subnetDataPrefix
  }
}

// Outputs
output vnetId string = vnet.outputs.vnetId
output foundationalElementSubnetId string = vnet.outputs.foundationalElementSubnetId
output presentationSubnetId string = vnet.outputs.presentationSubnetId
output applicationSubnetId string = vnet.outputs.applicationSubnetId
output dataSubnetId string = vnet.outputs.dataSubnetId
