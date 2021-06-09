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

//TIP: we defined PARAMS here first, then we copy to subscription parameters with the help of a helper script 
//..\utils\bicep-vars-to-yaml.ps1 .\main.bicep "var-hubnetwork-"
//it outputs two results: one to be put in YAML file for AzDevOps, another to be appended to Azure CLI pipeline task

//Subnet vars
param Hub_IPrange string         //= '10.18.0.0/22'
param Hub_CGNATrange string      //= '100.60.0.0/16'
param Hub_BastionRange string    //= '192.168.0.0/16'
param Subnet_Public string       //= '100.60.0.0/24'
param Subnet_EAN string          //= '10.18.0.0/27'
param Subnet_MRZInt string       //= '10.18.0.96/27'
param Subnet_PrdInt string       //= '10.18.0.32/27'
param Subnet_DevInt string       //= '10.18.0.64/27'
param Subnet_HA string           //= '10.18.0.128/28'
param Subnet_PAZ string          //= '100.60.1.0/24'
param Subnet_Bastion string      //= '192.168.0.0/24'
param Subnet_Public_name string  //= 'PublicSubnet'
param Subnet_EAN_name string     //= 'EanSubnet'
param Subnet_MRZInt_name string  //= 'MrzSubnet'
param Subnet_PrdInt_name string  //= 'PrdIntSubnet'
param Subnet_DevInt_name string  //= 'DevIntSubnet'
param Subnet_HA_name string      //= 'HASubnet'
param Subnet_PAZ_name string     //= 'PAZSubnet'


//Fortinet vars
param FW_VM_sku_prod string //= 'Standard_F8s_v2' //ensure it can have 4 nics
param FW_VM_sku_dev string  //= 'Standard_D8s_v4' //ensure it can have 4 nics

param useFortigateFW bool   = true

param FW_VIP_ProdFWs_Public string     //= '100.60.0.4'
param FW_ProdFW1_Public string         //= '100.60.0.5'
param FW_ProdFW2_Public string         //= '100.60.0.6'
param FW_VIP_DevFWs_Public string      //= '100.60.0.7'
param FW_DevFW1_Public string          //= '100.60.0.8'
param FW_DevFW2_Public string          //= '100.60.0.9'

param FW_VIP_ProdFWs_MRZInt string  //= '10.18.0.100'
param FW_ProdFW1_MRZInt string      //= '10.18.0.101'
param FW_ProdFW2_MRZInt string      //= '10.18.0.102'
param FW_VIP_DevFWs_MRZInt string   //= '10.18.0.103'
param FW_DevFW1_MRZInt string       //= '10.18.0.104'
param FW_DevFW2_MRZInt string       //= '10.18.0.105'

param FW_VIP_ProdFWs_PrdInt string  //= '10.18.0.36'
param FW_ProdFW1_PrdInt string      //= '10.18.0.37'
param FW_ProdFW2_PrdInt string      //= '10.18.0.38'

param FW_VIP_DevFWs_DevInt string   //= '10.18.0.68'
param FW_DevFW1_DevInt string       //= '10.18.0.69'
param FW_DevFW2_DevInt string       //= '10.18.0.70'

param FW_ProdFW1_HA string          //= '10.18.0.132'
param FW_ProdFW2_HA string          //= '10.18.0.133'
param FW_DevFW1_HA string           //= '10.18.0.134'
param FW_DevFW2_HA string           //= '10.18.0.135'

//MRZ settings
param MRZ_IPrange string      //= '10.18.4.0/22'
param Subnet_MAZ string       //= '10.18.4.0/25'
param Subnet_INF string       //= '10.18.4.128/25'
param Subnet_SEC string       //= '10.18.5.0/26'
param Subnet_LOG string       //= '10.18.5.64/26'
param Subnet_MGMT string      //= '10.18.5.128/26'
param Subnet_MAZ_name string  //= 'MazSubnet'
param Subnet_INF_name string  //= 'InfSubnet'
param Subnet_SEC_name string  //= 'SecSubnet'
param Subnet_LOG_name string  //= 'LogSubnet'
param Subnet_MGMT_name string //= 'MgmtSubnet'
param RG_Hub_name string   //= 'JDCPPrdHubPbRsg'
param RG_Mrz_name string   //= 'JDCPPrdMrzPbRsg'
param RG_Paz_name string   //= 'JDCPPazPbRsg'
param VNET_Hub_name string //= 'JDCPHubVnet'
param VNET_Mrz_name string //= 'JDCPMrzVnet'
param Bastion_name string  //= 'JDCPHubBastion'
param PrdFWILB_name string //= 'JDCPProdFWs_ILB'
param DevFWILB_name string //= 'JDCPDevFWs_ILB'

param FW_ProdFW1_name string //= 'JDCPProdFW1'
param FW_ProdFW2_name string //= 'JDCPProdFW2'
param FW_DevFW1_name string //= 'JDCPDevFW1'
param FW_DevFW2_name string //= 'JDCPDevFW2'

param FW_ProdFW_username string //== 'localadmin'
param FW_ProdFW_temppassword string //= 'VeryGoodP@ssw0rd2021!'

param FW_ProdFW1_AZone string = '1'
param FW_ProdFW2_AZone string = '2'
param FW_DevFW1_AZone string = '2'
param FW_DevFW2_AZone string = '3'

var tags = {
  ClientOrganization: tagClientOrganization
  CostCenter: tagCostCenter
  DataSensitivity: tagDataSensitivity
  ProjectContact: tagProjectContact
  ProjectName: tagProjectName
  TechnicalContact: tagTechnicalContact
}

module subScaffold '../scaffold-subscription.bicep' = {
  name: 'subscription-scaffold'
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

resource rgHubVnetRG 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: RG_Hub_name
  location: deployment().location
  tags: tags
}
module rgHubDeleteLock '../../azresources/util/delete-lock.bicep' = {
  name: 'rgHubDeleteLock'
  scope: rgHubVnetRG
}

resource rgMrzVnetRG 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: RG_Mrz_name
  location: deployment().location
  tags: tags
}
module rgMrzDeleteLock '../../azresources/util/delete-lock.bicep' = {
  name: 'rgMrzDeleteLock'
  scope: rgMrzVnetRG
}
resource rgPazRG 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: RG_Paz_name
  location: deployment().location
  tags: tags
}
module rgPazDeleteLock '../../azresources/util/delete-lock.bicep' = {
  name: 'rgPazDeleteLock'
  scope: rgPazRG
}

module udrPrdSpokes '../../azresources/network/udr/udr-custom.bicep' = {
  name: 'PrdSpokesUdr'
  scope: rgHubVnetRG
  params:{
    name: 'PrdSpokesUdr'
    routes: [
      {
        name: 'default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: FW_VIP_ProdFWs_PrdInt
        }
      }
      // Force Routes to Hub IPs (RFC1918 range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubRFC1918FWRoute'
        properties: {
          addressPrefix: Hub_IPrange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: FW_VIP_ProdFWs_PrdInt
        }
      }
      // Force Routes to Hub IPs (CGNAT range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubCGNATFWRoute'
        properties: {
          addressPrefix: Hub_CGNATrange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: FW_VIP_ProdFWs_PrdInt
        }
      }
      //no need to force MRZ routes, they are unknown to Spokes

      // if Bastion has an IP outside of the CIDR blocks Hub_IPRante and Hb_CGNATrange, no need to Override Bastion Routes via VirtualNetwork regular routes
      // even though this override below didn't work
      // {
      //   name: 'PrdSpokeUdrBastionVnetLocalRoute'
      //   properties: {
      //     addressPrefix: Subnet_Bastion //shorter IP range, destination VnetLocal (avoid FW)    
      //     nextHopType:  'VnetLocal'
      //   }
      // }
    ]
  }
}
module udrMrzSpoke '../../azresources/network/udr/udr-custom.bicep' = {
  name: 'MrzSpokeUdr'
  scope: rgHubVnetRG
  params:{
    name: 'MrzSpokeUdr'
    routes: [
      {
        name: 'default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: FW_VIP_ProdFWs_MRZInt
        }
      }
      //warning, setting Hub_IPrange breaks AzureBastion, see MrzSpokeUdrBastionFWRoute
      // Force Routes to Hub IPs (RFC1918 range) via FW despite knowing that route via peering
      {
        name: 'MrzSpokeUdrHubRFC1918FWRoute'
        properties: {
          addressPrefix: Hub_IPrange       
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: FW_VIP_ProdFWs_MRZInt
        }
      }
      // Override Bastion Routes via VirtualNetwork regular routes
      {
        name: 'MrzSpokeUdrBastionVnetLocalRoute'
        properties: {
          addressPrefix: Subnet_Bastion //shorter IP range, destination VnetLocal (avoid FW)    
          nextHopType:  'VnetLocal'
        }
      }
      // Force Routes to Hub IPs (CGNAT range) via FW despite knowing that route via peering
      {
        name: 'MrzSpokeUdrHubCGNATFWRoute'
        properties: {
          addressPrefix: Hub_CGNATrange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: FW_VIP_ProdFWs_MRZInt
        }
      }
    ]
  }
}
module udrpaz '../../azresources/network/udr/udr-custom.bicep' = {
  name: 'PazSubnetUdr'
  scope: rgHubVnetRG
  params:{
    name: 'PazSubnetUdr'
    routes: [
      {
        name: 'PazSubnetUdrMrzFWRoute'
        properties: {
          addressPrefix: MRZ_IPrange
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: FW_VIP_ProdFWs_Public
        }
      }
    ]
  }
}


//cannot call Resources in this subscription-scope, need a module
module hubVnet './hub-vnet.bicep' = { 
  name: VNET_Hub_name
  scope: rgHubVnetRG
  params: {
    hubName: VNET_Hub_name
    Hub_IPrange: Hub_IPrange
    Hub_CGNATrange: Hub_CGNATrange
    Hub_BastionRange: Hub_BastionRange
    Subnet_Public: Subnet_Public
    Subnet_MRZInt: Subnet_MRZInt
    Subnet_PrdInt: Subnet_PrdInt
    Subnet_DevInt: Subnet_DevInt
    Subnet_HA: Subnet_HA
    Subnet_PAZ: Subnet_PAZ
    Subnet_EAN: Subnet_EAN
    Subnet_Bastion: Subnet_Bastion
    UDR_PAZ: udrpaz.outputs.udrId 
    Subnet_EAN_name: Subnet_EAN_name
    Subnet_PAZ_name: Subnet_PAZ_name
    Subnet_MRZInt_name: Subnet_MRZInt_name
    Subnet_PrdInt_name: Subnet_PrdInt_name
    Subnet_DevInt_name: Subnet_DevInt_name
    Subnet_HA_name: Subnet_HA_name
    Subnet_Public_name: Subnet_Public_name
  }
}




module mrzVnet './mrz-vnet.bicep' = {
  name: VNET_Mrz_name
  scope: rgMrzVnetRG
  params: {
    mrzName: VNET_Mrz_name
    MRZ_IPrange: MRZ_IPrange
    Subnet_MAZ: Subnet_MAZ
    Subnet_INF: Subnet_INF
    Subnet_SEC: Subnet_SEC
    Subnet_LOG: Subnet_LOG
    Subnet_MGMT: Subnet_MGMT
    UDR: udrMrzSpoke.outputs.udrId 
    Subnet_MAZ_name: Subnet_MAZ_name
    Subnet_INF_name: Subnet_INF_name
    Subnet_SEC_name: Subnet_SEC_name
    Subnet_LOG_name: Subnet_LOG_name
    Subnet_MGMT_name: Subnet_MGMT_name 
  }
}

module vnetPeeringSpokeToHub '../../azresources/network/vnet-peering.bicep' = {
  dependsOn: [
    hubVnet
    mrzVnet
  ]
  name: 'spokeToHubPeer'
  scope: rgMrzVnetRG
  params: {
    peeringName: '${VNET_Mrz_name}-to-${VNET_Hub_name}'
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    sourceVnetName: VNET_Mrz_name
    targetVnetId: hubVnet.outputs.hubVnetId
    useRemoteGateways: false //to be changed once we have ExpressRoute or VPN GWs 
  }
}
module vnetPeeringHubToSpoke '../../azresources/network/vnet-peering.bicep' = {
  dependsOn: [
    hubVnet
    mrzVnet
  ]
  name: 'hubToSpokePeer'
  scope: rgHubVnetRG
  params: {
    peeringName: '${VNET_Hub_name}-to-${VNET_Mrz_name}'
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    sourceVnetName: VNET_Hub_name
    targetVnetId: mrzVnet.outputs.mrzVnetId
    useRemoteGateways: false
  }
}

module bastion '../../azresources/compute/bastion.bicep' = {
  name: Bastion_name
  scope: rgHubVnetRG
  params: {
    bastionName: Bastion_name
    bastionSubnetId: hubVnet.outputs.AzureBastionSubnetId
  }
}

module ProdFW1_fortigate './fortinet-vm.bicep' = if (useFortigateFW) {
  name: 'ProdFW1_fortigate'
  scope: rgHubVnetRG
  params: {
    availabilityZone: '1' //make it a parameter with a default value (in the params.json file)
    VM_name: FW_ProdFW1_name
    VM_sku: FW_VM_sku_prod
    VM_nic1_ip: FW_ProdFW1_Public
    VM_nic1_subnetId: hubVnet.outputs.PublicSubnetId 
    VM_nic2_ip: FW_ProdFW1_MRZInt 
    VM_nic2_subnetId: hubVnet.outputs.MrzIntSubnetId 
    VM_nic3_ip: FW_ProdFW1_PrdInt
    VM_nic3_subnetId: hubVnet.outputs.PrdIntSubnetId
    VM_nic4_ip: FW_ProdFW1_HA
    VM_nic4_subnetId: hubVnet.outputs.HASubnetId
    username: FW_ProdFW_username
    password: FW_ProdFW_temppassword
  }
}

module ProdFW1_ubuntu './ubuntu-fw-vm.bicep' = if (!useFortigateFW) {
  name: 'ProdFW1_ubuntu'
  scope: rgHubVnetRG
  params: {
    availabilityZone: FW_ProdFW1_AZone //make it a parameter with a default value (in the params.json file)
    VM_name: FW_ProdFW1_name
    VM_sku: FW_VM_sku_prod
    VM_nic1_ip: FW_ProdFW1_Public
    VM_nic1_subnetId: hubVnet.outputs.PublicSubnetId 
    VM_nic2_ip: FW_ProdFW1_MRZInt 
    VM_nic2_subnetId: hubVnet.outputs.MrzIntSubnetId 
    VM_nic3_ip: FW_ProdFW1_PrdInt
    VM_nic3_subnetId: hubVnet.outputs.PrdIntSubnetId
    VM_nic4_ip: FW_ProdFW1_HA
    VM_nic4_subnetId: hubVnet.outputs.HASubnetId
    username: FW_ProdFW_username
    password: FW_ProdFW_temppassword
  }
}

module ProdFW2_fortigate './fortinet-vm.bicep' = if (useFortigateFW) {
  name: 'ProdFW2_fortigate'
  scope: rgHubVnetRG
  params: {
    availabilityZone: FW_ProdFW2_AZone
    VM_name: FW_ProdFW2_name
    VM_sku: FW_VM_sku_prod
    VM_nic1_ip: FW_ProdFW2_Public
    VM_nic1_subnetId: hubVnet.outputs.PublicSubnetId
    VM_nic2_ip: FW_ProdFW2_MRZInt
    VM_nic2_subnetId: hubVnet.outputs.MrzIntSubnetId
    VM_nic3_ip: FW_ProdFW2_PrdInt
    VM_nic3_subnetId: hubVnet.outputs.PrdIntSubnetId
    VM_nic4_ip: FW_ProdFW2_HA
    VM_nic4_subnetId: hubVnet.outputs.HASubnetId
    username: FW_ProdFW_username
    password: FW_ProdFW_temppassword 
  }
}

module ProdFW2_ubuntu './ubuntu-fw-vm.bicep' = if (!useFortigateFW) {
  name: 'ProdFW2_ubuntu'
  scope: rgHubVnetRG
  params: {
    availabilityZone: '2'
    VM_name: FW_ProdFW2_name
    VM_sku: FW_VM_sku_prod
    VM_nic1_ip: FW_ProdFW2_Public
    VM_nic1_subnetId: hubVnet.outputs.PublicSubnetId
    VM_nic2_ip: FW_ProdFW2_MRZInt
    VM_nic2_subnetId: hubVnet.outputs.MrzIntSubnetId
    VM_nic3_ip: FW_ProdFW2_PrdInt
    VM_nic3_subnetId: hubVnet.outputs.PrdIntSubnetId
    VM_nic4_ip: FW_ProdFW2_HA
    VM_nic4_subnetId: hubVnet.outputs.HASubnetId
    username: FW_ProdFW_username
    password: FW_ProdFW_temppassword
  }
}

module DevFW1 './fortinet-vm.bicep' = if (useFortigateFW) {
  name: 'DevFW1_fortigate'
  scope: rgHubVnetRG
  params: {
    availabilityZone: FW_DevFW1_AZone
    VM_name: FW_DevFW1_name
    VM_sku: FW_VM_sku_dev
    VM_nic1_ip: FW_DevFW1_Public
    VM_nic1_subnetId: hubVnet.outputs.PublicSubnetId
    VM_nic2_ip: FW_DevFW1_MRZInt
    VM_nic2_subnetId: hubVnet.outputs.MrzIntSubnetId
    VM_nic3_ip: FW_DevFW1_DevInt
    VM_nic3_subnetId: hubVnet.outputs.DevIntSubnetId
    VM_nic4_ip: FW_DevFW1_HA
    VM_nic4_subnetId: hubVnet.outputs.HASubnetId
    username: FW_ProdFW_username
    password: FW_ProdFW_temppassword
  }
}

module DevFW2 './fortinet-vm.bicep' = if (useFortigateFW) {
  name: 'DevFW2_fortigate'
  scope: rgHubVnetRG
  params: {
    availabilityZone: FW_DevFW2_AZone
    VM_name: FW_DevFW2_name
    VM_sku: FW_VM_sku_dev
    VM_nic1_ip: FW_DevFW2_Public
    VM_nic1_subnetId: hubVnet.outputs.PublicSubnetId
    VM_nic2_ip: FW_DevFW2_MRZInt
    VM_nic2_subnetId: hubVnet.outputs.MrzIntSubnetId
    VM_nic3_ip: FW_DevFW2_DevInt
    VM_nic3_subnetId: hubVnet.outputs.DevIntSubnetId
    VM_nic4_ip: FW_DevFW2_HA
    VM_nic4_subnetId: hubVnet.outputs.HASubnetId
    username: FW_ProdFW_username
    password: FW_ProdFW_temppassword
  }
}

module ProdFWs_ILB './lb-firewalls-hub.bicep' = {
  name: 'ProdFWs_ILB'
  scope: rgHubVnetRG
  params: {
    name:           PrdFWILB_name
    BackendVNet_ID: hubVnet.outputs.hubVnetId
    FrontendIP_ext:  FW_VIP_ProdFWs_Public
    BackendIP1_ext:  FW_ProdFW1_Public
    BackendIP2_ext:  FW_ProdFW2_Public 
    FrontendSubnetID_ext: hubVnet.outputs.PublicSubnetId
    FrontendIP_mrz:  FW_VIP_ProdFWs_MRZInt
    BackendIP1_mrz:  FW_ProdFW1_MRZInt
    BackendIP2_mrz:  FW_ProdFW2_MRZInt 
    FrontendSubnetID_mrz: hubVnet.outputs.MrzIntSubnetId
    FrontendIP_int:  FW_VIP_ProdFWs_PrdInt
    BackendIP1_int:  FW_ProdFW1_PrdInt
    BackendIP2_int:  FW_ProdFW2_PrdInt
    FrontendSubnetID_int: hubVnet.outputs.PrdIntSubnetId
    LB_Probe_tcp_port: useFortigateFW? 8008 : 22
  }
}

module DevFWs_ILB './lb-firewalls-hub.bicep' = {
  name: 'DevFWs_ILB'
  scope: rgHubVnetRG
  params: {
    name:           DevFWILB_name
    BackendVNet_ID: hubVnet.outputs.hubVnetId
    FrontendIP_ext:  FW_VIP_DevFWs_Public
    BackendIP1_ext:  FW_DevFW1_Public
    BackendIP2_ext:  FW_DevFW2_Public
    FrontendSubnetID_ext: hubVnet.outputs.PublicSubnetId
    FrontendIP_mrz:  FW_VIP_DevFWs_MRZInt
    BackendIP1_mrz:  FW_DevFW1_MRZInt
    BackendIP2_mrz:  FW_DevFW2_MRZInt 
    FrontendSubnetID_mrz: hubVnet.outputs.MrzIntSubnetId
    FrontendIP_int:  FW_VIP_DevFWs_DevInt
    BackendIP1_int:  FW_DevFW1_DevInt
    BackendIP2_int:  FW_DevFW2_DevInt 
    FrontendSubnetID_int: hubVnet.outputs.DevIntSubnetId
    LB_Probe_tcp_port: useFortigateFW? 8008 : 22
  }
}

output rgHubVnetRG string = rgHubVnetRG.name
output rgMrzVnetRG string = rgMrzVnetRG.name
