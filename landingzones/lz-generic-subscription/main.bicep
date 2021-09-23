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

* Service Health alerts (optional)
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
* COTS (Commercial off-the-shelf) products
* General deployment where Application teams own and operate the application stack
* Evaluating/prototying new application designs

*/

targetScope = 'subscription'

// Service Health
// Example (JSON)
// -----------------------------
// "serviceHealthAlerts": {
//   "value": {
//     "incidentTypes": [ "Incident", "Security", "Maintenance", "Information", "ActionRequired" ],
//     "regions": [ "Global", "Canada East", "Canada Central" ],
//     "receivers": {
//       "app": [ "email-1@company.com", "email-2@company.com" ],
//       "email": [ "email-1@company.com", "email-3@company.com", "email-4@company.com" ],
//       "sms": [ { "countryCode": "1", "phoneNumber": "1234567890" }, { "countryCode": "1",  "phoneNumber": "0987654321" } ],
//       "voice": [ { "countryCode": "1", "phoneNumber": "1234567890" } ]
//     }
//   }
// }
@description('Service Health alerts')
param serviceHealthAlerts object = {}

// Subscription Role Assignments
// Example (JSON)
// -----------------------------
// [
//   {
//       "comments": "Built-in Contributor Role",
//       "roleDefinitionId": "b24988ac-6180-42a0-ab88-20f7382dd24c",
//       "securityGroupObjectIds": [
//           "38f33f7e-a471-4630-8ce9-c6653495a2ee"
//       ]
//   }
// ]

// Example (Bicep)
// -----------------------------
// [
//   {
//     'comments': 'Built-In Contributor Role'
//     'roleDefinitionId': 'b24988ac-6180-42a0-ab88-20f7382dd24c'
//     'securityGroupObjectIds': [
//       '38f33f7e-a471-4630-8ce9-c6653495a2ee'
//     ]
//   }
// ]
@description('Array of role assignments at subscription scope.  The array will contain an object with comments, roleDefinitionId and array of securityGroupObjectIds.')
param subscriptionRoleAssignments array = []

// Subscription Budget
// Example (JSON)
// ---------------------------
// "subscriptionBudget": {
//   "value": {
//       "createBudget": false,
//       "name": "MonthlySubscriptionBudget",
//       "amount": 1000,
//       "timeGrain": "Monthly",
//       "contactEmails": [ "alzcanadapubsec@microsoft.com" ]
//   }
// }

// Example (Bicep)
// ---------------------------
// {
//   createBudget: true
//   name: 'MonthlySubscriptionBudget'
//   amount: 1000
//   timeGrain: 'Monthly'
//   contactEmails: [
//     'alzcanadapubsec@microsoft.com'
//   ]
// }
@description('Subscription budget configuration containing createBudget flag, name, amount, timeGrain and array of contactEmails')
param subscriptionBudget object

// Tags
// Example (JSON)
// -----------------------------
// "subscriptionTags": {
//   "value": {
//       "ISSO": "isso-tag"
//   }
// }

// Example (Bicep)
// ---------------------------
// {
//   'ISSO': 'isso-tag'
// }
@description('A set of key/value pairs of tags assigned to the subscription.')
param subscriptionTags object

// Example (JSON)
// -----------------------------
// "resourceTags": {
//   "value": {
//       "ClientOrganization": "client-organization-tag",
//       "CostCenter": "cost-center-tag",
//       "DataSensitivity": "data-sensitivity-tag",
//       "ProjectContact": "project-contact-tag",
//       "ProjectName": "project-name-tag",
//       "TechnicalContact": "technical-contact-tag"
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   'ClientOrganization': 'client-organization-tag'
//   'CostCenter': 'cost-center-tag'
//   'DataSensitivity': 'data-sensitivity-tag'
//   'ProjectContact': 'project-contact-tag'
//   'ProjectName': 'project-name-tag'
//   'TechnicalContact': 'technical-contact-tag'
// }
@description('A set of key/value pairs of tags assigned to the resource group and resources.')
param resourceTags object

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
@description('Azure Automation Account name.')
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
param hubRFC6598IPRange string

/*
  Scaffold the subscription which includes:
    * Azure Security Center - Enable Azure Defender (all available options)
    * Azure Security Center - Configure Log Analytics Workspace
    * Azure Security Center - Configure Security Alert Contact
    * Service Health Alerts
    * Role Assignments to Security Groups
    * Subscription Budget
    * Subscription Tags
*/
module subScaffold '../scaffold-subscription.bicep' = {
  name: 'configure-subscription'
  scope: subscription()
  params: {
    serviceHealthAlerts: serviceHealthAlerts
    subscriptionRoleAssignments: subscriptionRoleAssignments
    subscriptionBudget: subscriptionBudget
    subscriptionTags: subscriptionTags
    resourceTags: resourceTags

    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId   
    securityContactEmail: securityContactEmail
    securityContactPhone: securityContactPhone
  }
}

// Create Network Watcher Resource Group
resource rgNetworkWatcher 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgNetworkWatcherName
  location: deployment().location
  tags: resourceTags
}

// Create Virtual Network Resource Group - only if Virtual Network is being deployed
resource rgVnet 'Microsoft.Resources/resourceGroups@2020-06-01' = if (deployVnet) {
  name: deployVnet ? rgVnetName : 'placeholder'
  location: deployment().location
  tags: resourceTags
}

// Create Azure Automation Resource Group
resource rgAutomation 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgAutomationName
  location: deployment().location
  tags: resourceTags
}

// Create & configure virtaual network - only if Virtual Network is being deployed
module vnet 'networking.bicep' = if (deployVnet) {
  name: 'deploy-networking'
  scope: resourceGroup(rgVnet.name)
  params: {
    egressVirtualApplianceIp: egressVirtualApplianceIp
    hubRFC1918IPRange: hubRFC1918IPRange
    hubRFC6598IPRange: hubRFC6598IPRange
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
    tags: resourceTags
  }
}

// Outputs
output vnetId string = deployVnet ? vnet.outputs.vnetId : ''
output foundationalElementSubnetId string = deployVnet ? vnet.outputs.foundationalElementSubnetId : ''
output presentationSubnetId string = deployVnet ? vnet.outputs.presentationSubnetId : ''
output applicationSubnetId string = deployVnet ? vnet.outputs.applicationSubnetId : ''
output dataSubnetId string = deployVnet ? vnet.outputs.dataSubnetId : ''
