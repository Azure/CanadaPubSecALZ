// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

/*

Generic Subscription Landing Zone archetype provides the basic Azure subscription configuration that includes:

* Azure Automation Account
* Azure Virtual Network
* Role-based access control for Owner, Contributor, Reader & Application Owner (custom role) 
* Integration with Azure Cost Management for Subscription-scoped budget
* Integration with Azure Security Center
* Integration to Hub Virtual Network (optional)
* Support for Network Virtual Appliance (i.e. Fortinet, Azure Firewall) in the Hub Network (if integrated to hub network)
* Support for Azure Bastion in the Hub (if integrated to hub network)

This landing is typically used for:

* Lift & Shift Azure Migrations
* General deployment where Application teams own and operate the application stack
* Evaluating/prototying new application designs

*/

targetScope = 'subscription'

// Groups
@description('An array of Security Group object ids that should be granted Owner built-in role.  Default: []')
param subscriptionOwnerGroupObjectIds array = []

@description('An array of Security Group object ids that should be granted Contributor built-in role.  Default: []')
param subscriptionContributorGroupObjectIds array = []

@description('An array of Security Group object ids that should be granted Reader built-in role.  Default: []')
param subscriptionReaderGroupObjectIds array = []

@description('An array of Security Group object ids that should be granted Application Owner custom role.  Default: []')
param subscriptionAppOwnerGroupObjectIds array = []

@description('Reference to Application Owner custom role definition id.  Default: empty string')
param lzAppOwnerRoleDefinitionId string = ''

// Azure Security Center
@description('Log Analytics Resource Id to integrate Azure Security Center.')
param logAnalyticsWorkspaceResourceId string

@description('Contact email address for Azure Security Center alerts.')
param securityContactEmail string

@description('Contact phone number for Azure Security Center alerts.')
param securityContactPhone string

// Resource Groups
@description('Virtual Network Resource Group Name.')
param rgVnetName string

@description('Azure Automation Account Resource Group Name.')
param rgAutomationName string

@description('Azure Network Watcher Resource Group Name.  Default: NetworkWatcherRG')
param rgNetworkWatcherName string = 'NetworkWatcherRG'

// Automation
@description('Azure Automation Account name')
param automationAccountName string

// VNET
@description('Defines whether to deploy a virtual network in the subscription or not.  Default:  true')
param deployVnet bool = true

@description('Virtual Network Name.')
param vnetName string

@description('Virtual Network Address Space.')
param vnetAddressSpace string

@description('Hub Virtual Network Resource Id.  It is required for configuring Virtual Network Peering & configuring route tables.')
param hubVnetId string

// Internal Foundational Elements (OZ) Subnet
@description('Foundational Element (OZ) Subnet Name')
param subnetFoundationalElementsName string

@description('Foundational Element (OZ) Subnet Address Prefix.')
param subnetFoundationalElementsPrefix string

// Presentation Zone (PAZ) Subnet
@description('Presentation Zone (PAZ) Subnet Name.')
param subnetPresentationName string

@description('Presentation Zone (PAZ) Subnet Address Prefix.')
param subnetPresentationPrefix string

// Application zone (RZ) Subnet
@description('Application (RZ) Subnet Name.')
param subnetApplicationName string

@description('Application (RZ) Subnet Address Prefix.')
param subnetApplicationPrefix string

// Data Zone (HRZ) Subnet
@description('Data Zone (HRZ) Subnet Name.')
param subnetDataName string

@description('Data Zone (HRZ) Subnet Address Prefix.')
param subnetDataPrefix string

// Virtual Appliance IP
@description('Virtual Appliance IP address to force tunnel traffic.  This IP address is used when hubVnetId is provided.')
param egressVirtualApplianceIp string

// Hub IP Ranges
@description('Virtual Network address space for RFC 1918.')
param hubRFC1918IPRange string

@description('Virtual Network address space for RFC 6598 (CG NAT).')
param hubCGNATIPRange string

// Budget
@description('Boolean flag to determine whether to create subscription budget.  Default: true')
param createBudget bool = true

@description('Subscription budget name.')
param budgetName string

@description('Subscription budget amount.')
param budgetAmount int

@description('Subscription budget email notification address.')
param budgetNotificationEmailAddress string

@description('Subscription budget start date.  New budget can not be created with the same name and different start date.  You must delete the old budget before recreating or disable budget creation through createBudget flag.  Default:  1st day of current month')
param budgetStartDate string = utcNow('yyyy-MM-01')

@description('Budget Time Window.  Options are Monthly, Quarterly or Annually.  Default: Monthly')
@allowed([
  'Monthly'
  'Quarterly'
  'Annually'
])
param budgetTimeGrain string = 'Monthly'

// Tags
@description('Subscription scoped tag - ISSO')
param tagISSO string

@description('Resource Group scoped tag - Client Organization')
param tagClientOrganization string

@description('Resource Group scoped tag - Cost Center')
param tagCostCenter string

@description('Resource Group scoped tag - Data Sensitivity')
param tagDataSensitivity string

@description('Resource Group scoped tag - Project Contact')
param tagProjectContact string

@description('Resource Group scoped tag - Project Name')
param tagProjectName string

@description('Resource Group scoped tag - Technical Contact')
param tagTechnicalContact string

var tags = {
  ClientOrganization: tagClientOrganization
  CostCenter: tagCostCenter
  DataSensitivity: tagDataSensitivity
  ProjectContact: tagProjectContact
  ProjectName: tagProjectName
  TechnicalContact: tagTechnicalContact
}

/*
  Scaffold the subscription which includes:
    * Azure Security Center - Enable Azure Defender (all available options)
    * Azure Security Center - Configure Log Analytics Workspace
    * Azure Security Center - Configure Security Alert Contact
    * Role Assignments to Security Groups
    * Subscription Budget
    * Subscription Tag:  ISSO
*/
module subScaffold '../scaffold-subscription.bicep' = {
  name: 'configure-subscription'
  scope: subscription()
  params: {
    lzAppOwnerRoleDefinitionId: lzAppOwnerRoleDefinitionId
    subscriptionAppOwnerGroupObjectIds: subscriptionAppOwnerGroupObjectIds
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

// Create Network Watcher Resource Group
resource rgNetworkWatcher 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgNetworkWatcherName
  location: deployment().location
  tags: tags
}

// Create Virtual Network Resource Group - only if Virtual Network is being deployed
resource rgVnet 'Microsoft.Resources/resourceGroups@2020-06-01' = if (deployVnet) {
  name: deployVnet ? rgVnetName : 'placeholder'
  location: deployment().location
  tags: tags
}

// Create Azure Automation Resource Group
resource rgAutomation 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgAutomationName
  location: deployment().location
  tags: tags
}

// Create & configure virtaual network - only if Virtual Network is being deployed
module vnet 'networking.bicep' = if (deployVnet) {
  name: 'deploy-networking'
  scope: resourceGroup(rgVnet.name)
  params: {
    egressVirtualApplianceIp: egressVirtualApplianceIp
    hubRFC1918IPRange: hubRFC1918IPRange
    hubCGNATIPRange: hubCGNATIPRange
    hubVnetId: hubVnetId

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

// Create automation account
module automationAccount '../../azresources/automation/automation-account.bicep' = {
  name: 'deploy-automation-account'
  scope: rgAutomation
  params: {
    automationAccountName: automationAccountName
    tags: tags
  }
}

// Outputs
output vnetId string = deployVnet ? vnet.outputs.vnetId : ''
output foundationalElementSubnetId string = deployVnet ? vnet.outputs.foundationalElementSubnetId : ''
output presentationSubnetId string = deployVnet ? vnet.outputs.presentationSubnetId : ''
output applicationSubnetId string = deployVnet ? vnet.outputs.applicationSubnetId : ''
output dataSubnetId string = deployVnet ? vnet.outputs.dataSubnetId : ''
