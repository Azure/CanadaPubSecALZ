// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

param azureRegion string = deployment().location

// Groups
param subscriptionOwnerGroupObjectIds array = []
param subscriptionContributorGroupObjectIds array = []
param subscriptionReaderGroupObjectIds array = []

// parameters for Azure Security Center
param logAnalyticsWorkspaceResourceId string
param securityContactEmail string
param securityContactPhone string

// Resource Groups
param rgVnetName string
param rgAutomationName string

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

// parameters for Tags
param tagISSO string
param tagClientOrganization string
param tagCostCenter string
param tagDataSensitivity string
param tagProjectContact string
param tagProjectName string
param tagTechnicalContact string

@allowed([
  'Monthly'
  'Quarterly'
  'Annually'
])
param budgetTimeGrain string = 'Monthly'

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

// Resource Groups
resource rgVnet 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgVnetName
  location: azureRegion
  tags: tags
}

resource rgAutomation 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgAutomationName
  location: azureRegion
  tags: tags
}

// Virtual Network
module vnet 'networking.bicep' = {
  name: 'vnet'
  scope: resourceGroup(rgVnet.name)
  params: {
    egressVirtualApplianceIp: egressVirtualApplianceIp
    hubRFC1918IPRange: hubRFC1918IPRange
    hubCGNATIPRange: hubCGNATIPRange
    hubVnetId: hubVnetId
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

// Automation
module automationAccount '../../azresources/automation/automationAccount.bicep' = {
  name: 'automation-account'
  scope: rgAutomation
  params: {
    automationAccountName: automationAccountName
    tags: tags
  }
}

// Outputs
output vnetId string = vnet.outputs.vnetId
output foundationalElementSubnetId string = vnet.outputs.foundationalElementSubnetId
output presentationSubnetId string = vnet.outputs.presentationSubnetId
output applicationSubnetId string = vnet.outputs.applicationSubnetId
output dataSubnetId string = vnet.outputs.dataSubnetId
