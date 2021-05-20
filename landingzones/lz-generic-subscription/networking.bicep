// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

// VNET
param deploySubnetsInExistingVnet bool
param vnetName string
param vnetAddressSpace string

param hubVnetId string

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

// Virtual Appliance IP
param egressVirtualApplianceIp string

// Hub IP Ranges
param hubRFC1918IPRange string
param hubCGNATIPRange string

// Network Security Groups
resource nsgFoundationalElements 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: '${subnetFoundationalElementsName}Nsg'
  location: resourceGroup().location
  properties: {
    securityRules: []
  }
}

resource nsgPresentation 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: '${subnetPresentationName}Nsg'
  location: resourceGroup().location
  properties: {
    securityRules: []
  }
}

resource nsgApplication 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: '${subnetApplicationName}Nsg'
  location: resourceGroup().location
  properties: {
    securityRules: []
  }
}

resource nsgData 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: '${subnetDataName}Nsg'
  location: resourceGroup().location
  properties: {
    securityRules: []
  }
}

// Route Tables
resource udrFoundationalElements 'Microsoft.Network/routeTables@2020-06-01' = {
  name: '${subnetFoundationalElementsName}Udr'
  location: resourceGroup().location
  properties: {
    routes: [
      // Force Routes to Hub IPs (RFC1918 range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubRFC1918FWRoute'
        properties: {
          addressPrefix: hubRFC1918IPRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
      // Force Routes to Hub IPs (CGNAT range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubCGNATFWRoute'
        properties: {
          addressPrefix: hubCGNATIPRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
      {
        name: 'RouteToEgressFirewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
    ]
  }
}

resource udrPresentation 'Microsoft.Network/routeTables@2020-06-01' = {
  name: '${subnetPresentationName}Udr'
  location: resourceGroup().location
  properties: {
    routes: [
      // Force Routes to Hub IPs (RFC1918 range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubRFC1918FWRoute'
        properties: {
          addressPrefix: hubRFC1918IPRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
      // Force Routes to Hub IPs (CGNAT range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubCGNATFWRoute'
        properties: {
          addressPrefix: hubCGNATIPRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
      {
        name: 'RouteToEgressFirewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
    ]
  }
}

resource udrApplication 'Microsoft.Network/routeTables@2020-06-01' = {
  name: '${subnetApplicationName}Udr'
  location: resourceGroup().location
  properties: {
    routes: [
      // Force Routes to Hub IPs (RFC1918 range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubRFC1918FWRoute'
        properties: {
          addressPrefix: hubRFC1918IPRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
      // Force Routes to Hub IPs (CGNAT range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubCGNATFWRoute'
        properties: {
          addressPrefix: hubCGNATIPRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
      {
        name: 'RouteToEgressFirewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
    ]
  }
}

resource udrData 'Microsoft.Network/routeTables@2020-06-01' = {
  name: '${subnetDataName}Udr'
  location: resourceGroup().location
  properties: {
    routes: [
      // Force Routes to Hub IPs (RFC1918 range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubRFC1918FWRoute'
        properties: {
          addressPrefix: hubRFC1918IPRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
      // Force Routes to Hub IPs (CGNAT range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubCGNATFWRoute'
        properties: {
          addressPrefix: hubCGNATIPRange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
      {
        name: 'RouteToEgressFirewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: egressVirtualApplianceIp
        }
      }
    ]
  }
}

// Virtual Network
resource vnetNew 'Microsoft.Network/virtualNetworks@2020-06-01' = if (!deploySubnetsInExistingVnet) {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
  }
}

resource vnetExisting 'Microsoft.Network/virtualNetworks@2020-06-01' existing = if (deploySubnetsInExistingVnet) {
  name: vnetName
}

resource subnetFoundationalElements 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = {
  dependsOn: [
    vnetPeeringSpokeToHub
  ]
  name: '${!deploySubnetsInExistingVnet ? vnetNew.name : vnetExisting.name}/${subnetFoundationalElementsName}'
  properties: {
    addressPrefix: subnetFoundationalElementsPrefix
    routeTable: {
      id: udrFoundationalElements.id
    }
    networkSecurityGroup: {
      id: nsgFoundationalElements.id
    }
  }
}

resource subnetPresentation 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = {
  dependsOn: [
    vnetExisting
    vnetNew
    subnetFoundationalElements
  ]
  name: '${vnetName}/${subnetPresentationName}'
  properties: {
    addressPrefix: subnetPresentationPrefix
    routeTable: {
      id: udrPresentation.id
    }
    networkSecurityGroup: {
      id: nsgPresentation.id
    }
  }
}

resource subnetApplication 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = {
  dependsOn: [
    vnetExisting
    vnetNew
    subnetPresentation
  ]
  name: '${vnetName}/${subnetApplicationName}'
  properties: {
    addressPrefix: subnetApplicationPrefix
    routeTable: {
      id: udrApplication.id
    }
    networkSecurityGroup: {
      id: nsgApplication.id
    }
  }
}

resource subnetData 'Microsoft.Network/virtualNetworks/subnets@2020-07-01' = {
  dependsOn: [
    vnetExisting
    vnetNew
    subnetApplication
  ]
  name: '${vnetName}/${subnetDataName}'
  properties: {
    addressPrefix: subnetDataPrefix
    routeTable: {
      id: udrData.id
    }
    networkSecurityGroup: {
      id: nsgData.id
    }
  }
}

module vnetPeeringSpokeToHub '../../azresources/network/vnet-peering.bicep' = if (!empty(hubVnetId)) {
  dependsOn: [
    vnetExisting
    vnetNew
  ]
  name: 'spokeToHubPeer'
  scope: resourceGroup()
  params: {
    peeringName: '${vnetName}-SpokeToHub'
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    sourceVnetName: vnetName
    targetVnetId: hubVnetId
    //useRemoteGateways: true
  }
}

output vnetId string = deploySubnetsInExistingVnet ? vnetExisting.id : vnetNew.id
output foundationalElementSubnetId string = '${vnetName}/subnets/${subnetFoundationalElementsName}'
output presentationSubnetId string = '${vnetName}/subnets/${subnetPresentationName}'
output applicationSubnetId string = '${vnetName}/subnets/${subnetApplicationName}'
output dataSubnetId string = '${vnetName}/subnets/${subnetDataName}'
