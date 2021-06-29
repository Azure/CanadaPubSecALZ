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

// Delegated Subnets
param subnetSQLMIName string
param subnetSQLMIPrefix string

param subnetDatabricksPublicName string
param subnetDatabricksPublicPrefix string

param subnetDatabricksPrivateName string
param subnetDatabricksPrivatePrefix string

// Priavte Endpoint Subnet
param subnetPrivateEndpointsName string
param subnetPrivateEndpointsPrefix string

// AKS Subnet
param subnetAKSName string
param subnetAKSPrefix string

// AKS version
param aksVersion string

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
@description('Should SQL Managed Instance be deployed in environment')
param deploySQLMI bool
@description('Should ADF Self Hosted Integration Runtime VM be deployed in environment')
param deploySelfhostIRVM bool


@description('If SQL Database is selected to be deployed, enter username. Otherwise, you can enter blank')
@secure()
param sqldbUsername string
@description('If SQL Managed Instance is selected to be deployed, enter username. Otherwise, you can enter blank')
@secure()
param sqlmiUsername string
@description('If ADF Self Hosted Integration Runtime VM is selected to be deployed, enter username. Otherwise, you can enter blank')
@secure()
param selfHostedVMUsername string

// Configure generic subscription
module genericSubscription '../lz-generic-subscription/main.bicep' = {
  name: 'genericSubscription'
  scope: subscription()
  params: {
    createBudget: createBudget
    budgetAmount: budgetAmount
    budgetName: budgetName
    budgetNotificationEmailAddress: budgetNotificationEmailAddress
    budgetStartDate: budgetStartDate
    budgetTimeGrain: budgetTimeGrain

    subscriptionOwnerGroupObjectIds: subscriptionOwnerGroupObjectIds
    subscriptionContributorGroupObjectIds: subscriptionContributorGroupObjectIds
    subscriptionReaderGroupObjectIds: subscriptionReaderGroupObjectIds
    
    securityContactEmail: securityContactEmail
    securityContactPhone: securityContactPhone

    tagISSO: tagISSO
    tagClientOrganization: tagClientOrganization
    tagCostCenter: tagCostCenter
    tagDataSensitivity: tagDataSensitivity
    tagProjectContact: tagProjectContact
    tagProjectName: tagProjectName
    tagTechnicalContact: tagTechnicalContact

    rgNetworkWatcherName: rgNetworkWatcherName
    rgAutomationName: rgAutomationName
    rgVnetName: rgVnetName

    automationAccountName: automationAccountName
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId

    egressVirtualApplianceIp: egressVirtualApplianceIp
    hubVnetId: hubVnetId
    hubCGNATIPRange: hubCGNATIPRange
    hubRFC1918IPRange: hubRFC1918IPRange

    deploySubnetsInExistingVnet: deploySubnetsInExistingVnet
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

// Overlay Machine Learning landing zone
module landingZone 'lz.bicep' = {
  dependsOn: [
    genericSubscription
  ]
  name: 'machinelearning-lz'
  scope: subscription()
  params: {
    tagClientOrganization: tagClientOrganization
    tagCostCenter: tagCostCenter
    tagDataSensitivity: tagDataSensitivity
    tagProjectContact: tagProjectContact
    tagProjectName: tagProjectName
    tagTechnicalContact: tagTechnicalContact
  
    securityContactEmail: securityContactEmail

    rgVnetName: rgVnetName
    rgComputeName: rgComputeName
    rgMonitorName: rgMonitorName
    rgSecurityName: rgSecurityName
    rgSelfHostedRuntimeName: rgSelfHostedRuntimeName
    rgStorageName: rgStorageName

    vnetId: genericSubscription.outputs.vnetId
    vnetName: vnetName

    deploySQLDB: deploySQLDB
    deploySQLMI: deploySQLMI
    deploySelfhostIRVM: deploySelfhostIRVM

    sqldbUsername: sqldbUsername
    sqlmiUsername: sqlmiUsername
    selfHostedVMUsername: selfHostedVMUsername

    subnetDatabricksPrivateName: subnetDatabricksPrivateName
    subnetDatabricksPrivatePrefix: subnetDatabricksPrivatePrefix

    subnetDatabricksPublicName: subnetDatabricksPublicName
    subnetDatabricksPublicPrefix: subnetDatabricksPublicPrefix

    subnetSQLMIName: subnetSQLMIName
    subnetSQLMIPrefix: subnetSQLMIPrefix

    subnetPrivateEndpointsName: subnetPrivateEndpointsName
    subnetPrivateEndpointsPrefix: subnetPrivateEndpointsPrefix

    subnetAKSName: subnetAKSName
    subnetAKSPrefix: subnetAKSPrefix

    aksVersion: aksVersion
    
    adfSelfHostedRuntimeSubnetId: '${genericSubscription.outputs.vnetId}/subnets/${subnetDataName}'

    secretExpiryInDays: secretExpiryInDays

    selfHostedRuntimeVmSize: selfHostedRuntimeVmSize
  }
}
