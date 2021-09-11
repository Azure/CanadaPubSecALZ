// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

// parameters for Tags
param tagISSO string
param tagClientOrganization string
param tagCostCenter string
param tagDataSensitivity string
param tagProjectContact string
param tagProjectName string
param tagTechnicalContact string

// parameters for Budget
param createBudget bool
param budgetName string
param budgetAmount int
param budgetNotificationEmailAddress string
param budgetStartDate string = utcNow('yyyy-MM-01')
@allowed([
  'Monthly'
  'Quarterly'
  'Annually'
])
param budgetTimeGrain string = 'Monthly'

// Groups
param subscriptionOwnerGroupObjectIds array = []
param subscriptionContributorGroupObjectIds array = []
param subscriptionReaderGroupObjectIds array = []

// parameters for Azure Security Center
param logAnalyticsWorkspaceResourceId string
param securityContactEmail string
param securityContactPhone string

// Network Watcher
param rgNetworkWatcherName string = 'NetworkWatcherRG'

// Private Dns Zones
param deployPrivateDnsZones bool
param rgPrivateDnsZonesName string

// DDOS Standard
param deployDdosStandard bool
param rgDdosName string
param ddosPlanName string

// Hub Virtual Network
param rgHubName string                          //= 'pubsecPrdHubPbRsg'
param hubVnetName string                        //= 'pubsecHubVnet'
param hubVnetAddressPrefixRFC1918 string        //= '10.18.0.0/22'
param hubVnetAddressPrefixCGNAT string          //= '100.60.0.0/16'
param hubVnetAddressPrefixBastion string        //= '192.168.0.0/16'

param hubEanSubnetName string                   //= 'EanSubnet'
param hubEanSubnetAddressPrefix string          //= '10.18.0.0/27'

param hubPublicSubnetName string                //= 'PublicSubnet'
param hubPublicSubnetAddressPrefix string       //= '100.60.0.0/24'

param hubPazSubnetName string                   //= 'PAZSubnet'
param hubPazSubnetAddressPrefix string          //= '100.60.1.0/24'

param hubDevIntSubnetName string                //= 'DevIntSubnet'
param hubDevIntSubnetAddressPrefix string       //= '10.18.0.64/27'

param hubSubnetProdIntName string               //= 'PrdIntSubnet'
param hubSubnetProdIntAddressPrefix string      //= '10.18.0.32/27'

param hubSubnetMrzIntName string                //= 'MrzSubnet'
param hubSubnetMrzIntAddressPrefix string       //= '10.18.0.96/27'

param hubSubnetHAName string                    //= 'HASubnet'
param hubSubnetHAAddressPrefix string           //= '10.18.0.128/28'

param hubSubnetGatewaySubnetPrefix string       //= '10.18.1.0/27'

param bastionName string                        //= 'pubsecHubBastion'
param hubSubnetBastionAddressPrefix string      //= '192.168.0.0/24'

// Firewall Virtual Appliances
param deployFirewallVMs bool = true
param useFortigateFW bool   = true

// Firewall Virtual Appliances - For Non-production Traffic
param fwDevILBName string                       //= 'pubsecDevFWs_ILB'
param fwDevVMSku string                         //= 'Standard_D8s_v4' //ensure it can have 4 nics
param fwDevVM1Name string                       //= 'pubsecDevFW1'
param fwDevVM2Name string                       //= 'pubsecDevFW2'
param fwDevILBExternalFacingIP string           //= '100.60.0.7'
param fwDevVM1ExternalFacingIP string           //= '100.60.0.8'
param fwDevVM2ExternalFacingIP string           //= '100.60.0.9'
param fwDevILBMrzIntIP string                   //= '10.18.0.103'
param fwDevVM1MrzIntIP string                   //= '10.18.0.104'
param fwDevVM2MrzIntIP string                   //= '10.18.0.105'
param fwDevILBDevIntIP string                   //= '10.18.0.68'
param fwDevVM1DevIntIP string                   //= '10.18.0.69'
param fwDevVM2DevIntIP string                   //= '10.18.0.70'
param fwDevVM1HAIP string                       //= '10.18.0.134'
param fwDevVM2HAIP string                       //= '10.18.0.135'
param fwDevVM1AvailabilityZone string = '2'
param fwDevVM2AvailabilityZone string = '3'

// Firewall Virtual Appliances - For Production Traffic
param fwProdILBName string                      //= 'pubsecProdFWs_ILB'
param fwProdVMSku string                        //= 'Standard_F8s_v2' //ensure it can have 4 nics
param fwProdVM1Name string                      //= 'pubsecProdFW1'
param fwProdVM2Name string                      //= 'pubsecProdFW2'
param fwProdILBExternalFacingIP string          //= '100.60.0.4'
param fwProdVM1ExternalFacingIP string          //= '100.60.0.5'
param fwProdVM2ExternalFacingIP string          //= '100.60.0.6'
param fwProdILBMrzIntIP string                  //= '10.18.0.100'
param fwProdVM1MrzIntIP string                  //= '10.18.0.101'
param fwProdVM2MrzIntIP string                  //= '10.18.0.102'
param fwProdILBPrdIntIP string                  //= '10.18.0.36'
param fwProdVM1PrdIntIP string                  //= '10.18.0.37'
param fwProdVM2PrdIntIP string                  //= '10.18.0.38'
param fwProdVM1HAIP string                      //= '10.18.0.132'
param fwProdVM2HAIP string                      //= '10.18.0.133'
param fwProdVM1AvailabilityZone string = '1'
param fwProdVM2AvailabilityZone string = '2'

// Management Restricted Zone Virtual Network
param rgMrzName string                          //= 'pubsecPrdMrzPbRsg'
param mrzVnetName string                        //= 'pubsecMrzVnet'
param mrzVnetAddressPrefixRFC1918 string        //= '10.18.4.0/22'

param mrzMazSubnetName string                   //= 'MazSubnet'
param mrzMazSubnetAddressPrefix string          //= '10.18.4.0/25'

param mrzInfSubnetName string                   //= 'InfSubnet'
param mrzInfSubnetAddressPrefix string          //= '10.18.4.128/25'

param mrzSecSubnetName string                   //= 'SecSubnet'
param mrzSecSubnetAddressPrefix string          //= '10.18.5.0/26'

param mrzLogSubnetName string                   //= 'LogSubnet'
param mrzLogSubnetAddressPrefix string          //= '10.18.5.64/26'

param mrzMgmtSubnetName string                  //= 'MgmtSubnet'
param mrzMgmtSubnetAddressPrefix string         //= '10.18.5.128/26'

// Public Zone
param rgPazName string                          //= 'pubsecPazPbRsg'

// Temporary VM Credentials
param fwUsername string

@secure()
param fwPassword string

var tags = {
  ClientOrganization: tagClientOrganization
  CostCenter: tagCostCenter
  DataSensitivity: tagDataSensitivity
  ProjectContact: tagProjectContact
  ProjectName: tagProjectName
  TechnicalContact: tagTechnicalContact
}

module subScaffold '../scaffold-subscription.bicep' = {
  name: 'configure-subscription'
  scope: subscription()
  params: {
    subscriptionOwnerGroupObjectIds: subscriptionOwnerGroupObjectIds
    subscriptionContributorGroupObjectIds: subscriptionContributorGroupObjectIds
    subscriptionReaderGroupObjectIds: subscriptionReaderGroupObjectIds
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    securityContactEmail: securityContactEmail
    securityContactPhone: securityContactPhone
    createBudget: createBudget
    budgetName: budgetName
    budgetAmount: budgetAmount
    budgetTimeGrain: budgetTimeGrain
    budgetStartDate: budgetStartDate
    budgetNotificationEmailAddress: budgetNotificationEmailAddress
    tagISSO: tagISSO
  }
}

resource rgNetworkWatcher 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgNetworkWatcherName
  location: deployment().location
  tags: tags
}

resource rgPrivateDnsZones 'Microsoft.Resources/resourceGroups@2020-06-01' = if (deployPrivateDnsZones) {
  name: rgPrivateDnsZonesName
  location: deployment().location
  tags: tags
}

resource rgDdos 'Microsoft.Resources/resourceGroups@2020-06-01' = if (deployDdosStandard) {
  name: rgDdosName
  location: deployment().location
  tags: tags
}

resource rgHubVnet 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgHubName
  location: deployment().location
  tags: tags
}

resource rgMrzVnet 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgMrzName
  location: deployment().location
  tags: tags
}

resource rgPaz 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgPazName
  location: deployment().location
  tags: tags
}

module rgDdosDeleteLock '../../azresources/util/delete-lock.bicep' = if (deployDdosStandard) {
  name: 'deploy-delete-lock-${rgDdosName}'
  scope: rgDdos
}

module rgHubDeleteLock '../../azresources/util/delete-lock.bicep' = {
  name: 'deploy-delete-lock-${rgHubName}'
  scope: rgHubVnet
}

module rgMrzDeleteLock '../../azresources/util/delete-lock.bicep' = {
  name: 'deploy-delete-lock-${rgMrzName}'
  scope: rgMrzVnet
}

module rgPazDeleteLock '../../azresources/util/delete-lock.bicep' = {
  name: 'deploy-delete-lock-${rgPazName}'
  scope: rgPaz
}

module ddosPlan '../../azresources/network/ddos-standard.bicep' = if (deployDdosStandard) {
  name: 'deploy-ddos-standard-plan'
  scope: rgDdos
  params: {
    ddosPlanName: ddosPlanName
  }
}

module udrPrdSpokes '../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-PrdSpokesUdr'
  scope: rgHubVnet
  params:{
    name: 'PrdSpokesUdr'
    routes: [
      {
        name: 'default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwProdILBPrdIntIP
        }
      }
      // Force Routes to Hub IPs (RFC1918 range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubRFC1918FWRoute'
        properties: {
          addressPrefix: hubVnetAddressPrefixRFC1918
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwProdILBPrdIntIP
        }
      }
      // Force Routes to Hub IPs (CGNAT range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubCGNATFWRoute'
        properties: {
          addressPrefix: hubVnetAddressPrefixCGNAT
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwProdILBPrdIntIP
        }
      }
      //no need to force MRZ routes, they are unknown to Spokes

      // if Bastion has an IP outside of the CIDR blocks Hub_IPRante and Hb_CGNATrange, no need to Override Bastion Routes via VirtualNetwork regular routes
      // even though this override below didn't work
      // {
      //   name: 'PrdSpokeUdrBastionVnetLocalRoute'
      //   properties: {
      //     addressPrefix: hubSubnetBastionAddressPrefix //shorter IP range, destination VnetLocal (avoid FW)    
      //     nextHopType:  'VnetLocal'
      //   }
      // }
    ]
  }
}

module udrMrzSpoke '../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-MrzSpokeUdr'
  scope: rgHubVnet
  params:{
    name: 'MrzSpokeUdr'
    routes: [
      {
        name: 'RouteToEgressFirewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwProdILBMrzIntIP
        }
      }
      //warning, setting hubVnetAddressPrefixRFC1918 breaks AzureBastion, see MrzSpokeUdrBastionFWRoute
      // Force Routes to Hub IPs (RFC1918 range) via FW despite knowing that route via peering
      {
        name: 'MrzSpokeUdrHubRFC1918FWRoute'
        properties: {
          addressPrefix: hubVnetAddressPrefixRFC1918       
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwProdILBMrzIntIP
        }
      }
      // Force Routes to Hub IPs (CGNAT range) via FW despite knowing that route via peering
      {
        name: 'MrzSpokeUdrHubCGNATFWRoute'
        properties: {
          addressPrefix: hubVnetAddressPrefixCGNAT
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwProdILBMrzIntIP
        }
      }
    ]
  }
}

module udrpaz '../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-PazSubnetUdr'
  scope: rgHubVnet
  params:{
    name: 'PazSubnetUdr'
    routes: [
      {
        name: 'PazSubnetUdrMrzFWRoute'
        properties: {
          addressPrefix: mrzVnetAddressPrefixRFC1918
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwProdILBExternalFacingIP
        }
      }
    ]
  }
}

module hubVnet './hub-vnet.bicep' = { 
  name: 'deploy-hub-vnet-${hubVnetName}'
  scope: rgHubVnet
  params: {
    vnetName: hubVnetName
    vnetAddressPrefixRFC1918: hubVnetAddressPrefixRFC1918
    vnetAddressPrefixCGNAT: hubVnetAddressPrefixCGNAT
    vnetAddressPrefixBastion: hubVnetAddressPrefixBastion

    publicSubnetName: hubPublicSubnetName
    publicSubnetAddressPrefix: hubPublicSubnetAddressPrefix

    mrzIntSubnetName: hubSubnetMrzIntName
    mrzIntSubnetAddressPrefix: hubSubnetMrzIntAddressPrefix

    prodIntSubnetName: hubSubnetProdIntName
    prodIntSubnetAddressPrefix: hubSubnetProdIntAddressPrefix

    devIntSubnetName: hubDevIntSubnetName
    devIntSubnetAddressPrefix: hubDevIntSubnetAddressPrefix

    haSubnetName: hubSubnetHAName
    haSubnetAddressPrefix: hubSubnetHAAddressPrefix

    pazSubnetName: hubPazSubnetName
    pazSubnetAddressPrefix: hubPazSubnetAddressPrefix
    pazUdrId: udrpaz.outputs.udrId 

    eanSubnetName: hubEanSubnetName
    eanSubnetAddressPrefix: hubEanSubnetAddressPrefix

    hubSubnetGatewaySubnetPrefix: hubSubnetGatewaySubnetPrefix

    bastionSubnetAddressPrefix: hubSubnetBastionAddressPrefix

    ddosStandardPlanId: deployDdosStandard ? ddosPlan.outputs.ddosPlanId : ''
  }
}

module mrzVnet './mrz-vnet.bicep' = {
  name: 'deploy-management-vnet-${mrzVnetName}'
  scope: rgMrzVnet
  params: {
    vnetName: mrzVnetName
    vnetAddressPrefix: mrzVnetAddressPrefixRFC1918

    mazSubnetName: mrzMazSubnetName
    mazSubnetAddressPrefix: mrzMazSubnetAddressPrefix
    mazSubnetUdrId: udrMrzSpoke.outputs.udrId 

    infSubnetName: mrzInfSubnetName
    infSubnetAddressPrefix: mrzInfSubnetAddressPrefix
    infSubnetUdrId: udrMrzSpoke.outputs.udrId 

    secSubnetName: mrzSecSubnetName
    secSubnetAddressPrefix: mrzSecSubnetAddressPrefix
    secSubnetUdrId: udrMrzSpoke.outputs.udrId 

    logSubnetName: mrzLogSubnetName
    logSubnetAddressPrefix: mrzLogSubnetAddressPrefix
    logSubnetUdrId: udrMrzSpoke.outputs.udrId 

    mgmtSubnetName: mrzMgmtSubnetName 
    mgmtSubnetAddressPrefix: mrzMgmtSubnetAddressPrefix
    mgmtSubnetUdrId: udrMrzSpoke.outputs.udrId

    ddosStandardPlanId: deployDdosStandard ? ddosPlan.outputs.ddosPlanId : ''
  }
}

module privatelinkDnsZones '../../azresources/network/private-dns-zone-privatelinks.bicep' = if (deployPrivateDnsZones) {
  name: 'deploy-privatelink-private-dns-zones'
  scope: rgPrivateDnsZones
  params: {
    vnetId: hubVnet.outputs.hubVnetId
    dnsCreateNewZone: true
  }
}

module vnetPeeringSpokeToHub '../../azresources/network/vnet-peering.bicep' = {
  dependsOn: [
    hubVnet
    mrzVnet
  ]
  name: 'deploy-vnet-peering-spoke-to-hub'
  scope: rgMrzVnet
  params: {
    peeringName: '${mrzVnetName}-to-${hubVnetName}'
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    sourceVnetName: mrzVnetName
    targetVnetId: hubVnet.outputs.hubVnetId
    useRemoteGateways: false //to be changed once we have ExpressRoute or VPN GWs 
  }
}

module vnetPeeringHubToSpoke '../../azresources/network/vnet-peering.bicep' = {
  dependsOn: [
    hubVnet
    mrzVnet
  ]
  name: 'deploy-vnet-peering-hub-to-spoke'
  scope: rgHubVnet
  params: {
    peeringName: '${hubVnetName}-to-${mrzVnetName}'
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    sourceVnetName: hubVnetName
    targetVnetId: mrzVnet.outputs.mrzVnetId
    useRemoteGateways: false
  }
}

module bastion '../../azresources/network/bastion.bicep' = {
  name: 'deploy-bastion'
  scope: rgHubVnet
  params: {
    bastionName: bastionName
    bastionSubnetId: hubVnet.outputs.AzureBastionSubnetId
  }
}

module ProdFW1_fortigate './fortinet-vm.bicep' = if (deployFirewallVMs && useFortigateFW) {
  name: 'deploy-nva-ProdFW1_fortigate'
  scope: rgHubVnet
  params: {
    availabilityZone: '1' //make it a parameter with a default value (in the params.json file)
    vmName: fwProdVM1Name
    vmSku: fwProdVMSku
    nic1PrivateIP: fwProdVM1ExternalFacingIP
    nic1SubnetId: hubVnet.outputs.PublicSubnetId 
    nic2PrivateIP: fwProdVM1MrzIntIP 
    nic2SubnetId: hubVnet.outputs.MrzIntSubnetId 
    nic3PrivateIP: fwProdVM1PrdIntIP
    nic3SubnetId: hubVnet.outputs.PrdIntSubnetId
    nic4PrivateIP: fwProdVM1HAIP
    nic4SubnetId: hubVnet.outputs.HASubnetId
    username: fwUsername
    password: fwPassword
  }
}

module ProdFW1_ubuntu './ubuntu-fw-vm.bicep' = if (deployFirewallVMs && !useFortigateFW) {
  name: 'deploy-nva-ProdFW1_ubuntu'
  scope: rgHubVnet
  params: {
    availabilityZone: fwProdVM1AvailabilityZone //make it a parameter with a default value (in the params.json file)
    vmName: fwProdVM1Name
    vmSku: fwProdVMSku
    nic1PrivateIP: fwProdVM1ExternalFacingIP
    nic1SubnetId: hubVnet.outputs.PublicSubnetId 
    nic2PrivateIP: fwProdVM1MrzIntIP 
    nic2SubnetId: hubVnet.outputs.MrzIntSubnetId 
    nic3PrivateIP: fwProdVM1PrdIntIP
    nic3SubnetId: hubVnet.outputs.PrdIntSubnetId
    nic4PrivateIP: fwProdVM1HAIP
    nic4SubnetId: hubVnet.outputs.HASubnetId
    username: fwUsername
    password: fwPassword
  }
}

module ProdFW2_fortigate './fortinet-vm.bicep' = if (deployFirewallVMs && useFortigateFW) {
  name: 'deploy-nva-ProdFW2_fortigate'
  scope: rgHubVnet
  params: {
    availabilityZone: fwProdVM2AvailabilityZone
    vmName: fwProdVM2Name
    vmSku: fwProdVMSku
    nic1PrivateIP: fwProdVM2ExternalFacingIP
    nic1SubnetId: hubVnet.outputs.PublicSubnetId
    nic2PrivateIP: fwProdVM2MrzIntIP
    nic2SubnetId: hubVnet.outputs.MrzIntSubnetId
    nic3PrivateIP: fwProdVM2PrdIntIP
    nic3SubnetId: hubVnet.outputs.PrdIntSubnetId
    nic4PrivateIP: fwProdVM2HAIP
    nic4SubnetId: hubVnet.outputs.HASubnetId
    username: fwUsername
    password: fwPassword 
  }
}

module ProdFW2_ubuntu './ubuntu-fw-vm.bicep' = if (deployFirewallVMs && !useFortigateFW) {
  name: 'deploy-nva-ProdFW2_ubuntu'
  scope: rgHubVnet
  params: {
    availabilityZone: '2'
    vmName: fwProdVM2Name
    vmSku: fwProdVMSku
    nic1PrivateIP: fwProdVM2ExternalFacingIP
    nic1SubnetId: hubVnet.outputs.PublicSubnetId
    nic2PrivateIP: fwProdVM2MrzIntIP
    nic2SubnetId: hubVnet.outputs.MrzIntSubnetId
    nic3PrivateIP: fwProdVM2PrdIntIP
    nic3SubnetId: hubVnet.outputs.PrdIntSubnetId
    nic4PrivateIP: fwProdVM2HAIP
    nic4SubnetId: hubVnet.outputs.HASubnetId
    username: fwUsername
    password: fwPassword
  }
}

module DevFW1 './fortinet-vm.bicep' = if (deployFirewallVMs && useFortigateFW) {
  name: 'deploy-nva-DevFW1_fortigate'
  scope: rgHubVnet
  params: {
    availabilityZone: fwDevVM1AvailabilityZone
    vmName: fwDevVM1Name
    vmSku: fwDevVMSku
    nic1PrivateIP: fwDevVM1ExternalFacingIP
    nic1SubnetId: hubVnet.outputs.PublicSubnetId
    nic2PrivateIP: fwDevVM1MrzIntIP
    nic2SubnetId: hubVnet.outputs.MrzIntSubnetId
    nic3PrivateIP: fwDevVM1DevIntIP
    nic3SubnetId: hubVnet.outputs.DevIntSubnetId
    nic4PrivateIP: fwDevVM1HAIP
    nic4SubnetId: hubVnet.outputs.HASubnetId
    username: fwUsername
    password: fwPassword
  }
}

module DevFW2 './fortinet-vm.bicep' = if (deployFirewallVMs && useFortigateFW) {
  name: 'deploy-nva-DevFW2_fortigate'
  scope: rgHubVnet
  params: {
    availabilityZone: fwDevVM2AvailabilityZone
    vmName: fwDevVM2Name
    vmSku: fwDevVMSku
    nic1PrivateIP: fwDevVM2ExternalFacingIP
    nic1SubnetId: hubVnet.outputs.PublicSubnetId
    nic2PrivateIP: fwDevVM2MrzIntIP
    nic2SubnetId: hubVnet.outputs.MrzIntSubnetId
    nic3PrivateIP: fwDevVM2DevIntIP
    nic3SubnetId: hubVnet.outputs.DevIntSubnetId
    nic4PrivateIP: fwDevVM2HAIP
    nic4SubnetId: hubVnet.outputs.HASubnetId
    username: fwUsername
    password: fwPassword
  }
}

module ProdFWs_ILB './lb-firewalls-hub.bicep' = {
  name: 'deploy-internal-loadblancer-ProdFWs_ILB'
  scope: rgHubVnet
  params: {
    name:           fwProdILBName
    backendVnetId: hubVnet.outputs.hubVnetId
    frontendIPExt:  fwProdILBExternalFacingIP
    backendIP1Ext:  fwProdVM1ExternalFacingIP
    backendIP2Ext:  fwProdVM2ExternalFacingIP 
    frontendSubnetIdExt: hubVnet.outputs.PublicSubnetId
    frontendIPMrz:  fwProdILBMrzIntIP
    backendIP1Mrz:  fwProdVM1MrzIntIP
    backendIP2Mrz:  fwProdVM2MrzIntIP 
    frontendSubnetIdMrz: hubVnet.outputs.MrzIntSubnetId
    frontendIPInt:  fwProdILBPrdIntIP
    backendIP1Int:  fwProdVM1PrdIntIP
    backendIP2Int:  fwProdVM2PrdIntIP
    frontendSubnetIdInt: hubVnet.outputs.PrdIntSubnetId
    lbProbeTcpPort: useFortigateFW ? 8008 : 22
    configureEmptyBackendPool: !deployFirewallVMs
  }
}

module DevFWs_ILB './lb-firewalls-hub.bicep' = {
  name: 'deploy-internal-loadblancer-DevFWs_ILB'
  scope: rgHubVnet
  params: {
    name:           fwDevILBName
    backendVnetId: hubVnet.outputs.hubVnetId
    frontendIPExt:  fwDevILBExternalFacingIP
    backendIP1Ext:  fwDevVM1ExternalFacingIP
    backendIP2Ext:  fwDevVM2ExternalFacingIP
    frontendSubnetIdExt: hubVnet.outputs.PublicSubnetId
    frontendIPMrz:  fwDevILBMrzIntIP
    backendIP1Mrz:  fwDevVM1MrzIntIP
    backendIP2Mrz:  fwDevVM2MrzIntIP 
    frontendSubnetIdMrz: hubVnet.outputs.MrzIntSubnetId
    frontendIPInt:  fwDevILBDevIntIP
    backendIP1Int:  fwDevVM1DevIntIP
    backendIP2Int:  fwDevVM2DevIntIP 
    frontendSubnetIdInt: hubVnet.outputs.DevIntSubnetId
    lbProbeTcpPort: useFortigateFW ? 8008 : 22
    configureEmptyBackendPool: !deployFirewallVMs
  }
}
