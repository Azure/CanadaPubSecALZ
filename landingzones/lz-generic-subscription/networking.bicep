// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

// VNET
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
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      {
        name: subnetFoundationalElementsName
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
      {
        name: subnetPresentationName
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
      {
        name: subnetApplicationName
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
      {
        name: subnetDataName
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
    ]
  }
}

module vnetPeeringSpokeToHub '../../azresources/network/vnet-peering.bicep' = if (!empty(hubVnetId)) {
  name: 'deploy-vnet-peering-spoke-to-hub'
  scope: resourceGroup()
  params: {
    peeringName: 'SpokeToHub-${vnet.name}'
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    sourceVnetName: vnet.name
    targetVnetId: hubVnetId
    //useRemoteGateways: true
  }
}

output vnetId string = vnet.id
output foundationalElementSubnetId string = '${vnet.id}/subnets/${subnetFoundationalElementsName}'
output presentationSubnetId string = '${vnet.id}/subnets/${subnetPresentationName}'
output applicationSubnetId string = '${vnet.id}/subnets/${subnetApplicationName}'
output dataSubnetId string = '${vnet.id}/subnets/${subnetDataName}'
