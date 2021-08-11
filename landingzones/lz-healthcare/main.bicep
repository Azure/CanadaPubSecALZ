// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

// Groups
param subscriptionOwnerGroupObjectIds array = []
param subscriptionContributorGroupObjectIds array = []
param subscriptionReaderGroupObjectIds array = []

// parameters for Azure Security Center
param logAnalyticsWorkspaceResourceId string
param securityContactEmail string
param securityContactPhone string

// Resource Groups
param rgNetworkWatcherName string = 'NetworkWatcherRG'
param rgVnetName string
param rgAutomationName string
param rgStorageName string
param rgComputeName string
param rgSecurityName string
param rgMonitorName string
param rgSelfHostedRuntimeName string

// Automation
param automationAccountName string

// VNET
param vnetName string
param vnetAddressSpace string

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

// Delegated Subnets
param subnetDatabricksPublicName string
param subnetDatabricksPublicPrefix string

param subnetDatabricksPrivateName string
param subnetDatabricksPrivatePrefix string

// Priavte Endpoint Subnet
param subnetPrivateEndpointsName string
param subnetPrivateEndpointsPrefix string

// Web App Subnet
param subnetWebAppName string
param subnetWebAppPrefix string

// Hub Virtual Network for virtual network peering
param hubVnetId string

// Virtual Appliance IP
param egressVirtualApplianceIp string

// Hub IP Ranges
param hubRFC1918IPRange string
param hubCGNATIPRange string

// parameters for Budget
param createBudget bool = true
param budgetName string
param budgetAmount int
param budgetNotificationEmailAddress string
param budgetStartDate string = utcNow('yyyy-MM-01')

// parameter for expiry of key vault secrets in days
param secretExpiryInDays int

// parameters for Tags
param tagISSO string
param tagClientOrganization string
param tagCostCenter string
param tagDataSensitivity string
param tagProjectContact string
param tagProjectName string
param tagTechnicalContact string

// parameters for vmsize
param selfHostedRuntimeVmSize string = 'Standard_D8s_v3'

@allowed([
  'Monthly'
  'Quarterly'
  'Annually'
])
param budgetTimeGrain string = 'Monthly'

// ML landing zone parameters - start
@description('Should SQL Database be deployed in environment')
param deploySQLDB bool

@description('Should ADF Self Hosted Integration Runtime VM be deployed in environment')
param deploySelfhostIRVM bool

@description('If ADF Self Hosted Integration Runtime VM is selected to be deployed, enter username. Otherwise, you can enter blank')
@secure()
param selfHostedVMUsername string

@secure()
param synapseUsername string

@description('If SQL Database is selected to be deployed, enter username. Otherwise, you can enter blank')
@secure()
param sqldbUsername string

@description('When true, customer managed keys are used for Azure resources')
param useCMK bool = false

// Scaffold subscription
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

// Overlay Machine Learning landing zone
module landingZone 'lz.bicep' = {
  name: 'deploy-healthcare-archetype'
  scope: subscription()
  params: {
    tagClientOrganization: tagClientOrganization
    tagCostCenter: tagCostCenter
    tagDataSensitivity: tagDataSensitivity
    tagProjectContact: tagProjectContact
    tagProjectName: tagProjectName
    tagTechnicalContact: tagTechnicalContact

    securityContactEmail: securityContactEmail
  
    rgAutomationName: rgAutomationName
    rgNetworkWatcherName: rgNetworkWatcherName
    rgVnetName: rgVnetName
    rgComputeName: rgComputeName
    rgMonitorName: rgMonitorName
    rgSecurityName: rgSecurityName
    rgSelfHostedRuntimeName: rgSelfHostedRuntimeName
    rgStorageName: rgStorageName

    automationAccountName: automationAccountName

    deploySQLDB: deploySQLDB
    sqldbUsername: sqldbUsername

    deploySelfhostIRVM: deploySelfhostIRVM
    selfHostedVMUsername: selfHostedVMUsername

    hubVnetId: hubVnetId
    egressVirtualApplianceIp: egressVirtualApplianceIp
    hubCGNATIPRange: hubCGNATIPRange
    hubRFC1918IPRange: hubRFC1918IPRange

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

    subnetDatabricksPrivateName: subnetDatabricksPrivateName
    subnetDatabricksPrivatePrefix: subnetDatabricksPrivatePrefix

    subnetDatabricksPublicName: subnetDatabricksPublicName
    subnetDatabricksPublicPrefix: subnetDatabricksPublicPrefix

    subnetPrivateEndpointsName: subnetPrivateEndpointsName
    subnetPrivateEndpointsPrefix: subnetPrivateEndpointsPrefix

    subnetWebAppName: subnetWebAppName
    subnetWebAppPrefix: subnetWebAppPrefix
  
    synapseUsername: synapseUsername

    secretExpiryInDays: secretExpiryInDays

    selfHostedRuntimeVmSize: selfHostedRuntimeVmSize

    useCMK: useCMK
  }
}
