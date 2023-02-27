// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------


/*

Identity Landing Zone to support ESLZ topology.  This architeype will provide:

* Azure Automation Account
* Azure Virtual Network
* Azure Key Vault
* Role-based access control for Owner, Contributor & Reader
* Integration with Azure Cost Management for Subscription-scoped budget
* Integration with Microsoft Defender for Cloud
* Azure Private DNS Resolver & Conditional Forwarder Zone (optional).
* Enables DDOS Standard (optional)
* Enables Azure Private DNS Zones (optional).

*/

targetScope = 'subscription'

@description('Location for the deployment.')
param location string = deployment().location

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
//     },
//     "actionGroupName": "ALZ action group",
//     "actionGroupShortName": "alz-alert",
//     "alertRuleName": "ALZ alert rule",
//     "alertRuleDescription": "Alert rule for Azure Landing Zone"
//   }
// }
@description('Service Health alerts')
param serviceHealthAlerts object = {}

// Log Analytics
@description('Log Analytics Resource Id to integrate Microsoft Defender for Cloud.')
param logAnalyticsWorkspaceResourceId string

// Microsoft Defender for Cloud
// Example (JSON)
// -----------------------------
// "securityCenter": {
//   "value": {
//       "email": "alzcanadapubsec@microsoft.com",
//       "phone": "5555555555"
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   email: 'alzcanadapubsec@microsoft.com'
//   phone: '5555555555'
// }
@description('Microsoft Defender for Cloud configuration.  It includes email and phone.')
param securityCenter object

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
//     comments: 'Built-In Contributor Role'
//     roleDefinitionId: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
//     securityGroupObjectIds: [
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
//   ISSO: 'isso-tag'
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
//   ClientOrganization: 'client-organization-tag'
//   CostCenter: 'cost-center-tag'
//   DataSensitivity: 'data-sensitivity-tag'
//   ProjectContact: 'project-contact-tag'
//   ProjectName: 'project-name-tag'
//   TechnicalContact: 'technical-contact-tag'
// }
@description('A set of key/value pairs of tags assigned to the resource group and resources.')
param resourceTags object

// Resource Groups
@description('Resource groups required for the achetype.  It includes automation, networking and networkWatcher.')
param resourceGroups object

// RecoveryVault
@description('Azure recovery vault configuration containing enabled flag, and name')
param backupRecoveryVault object

// Azure Automation Account
@description('Azure Automation Account configuration.  Includes name.')
param automation object

// Networking
@description('Hub Network configuration that includes virtualNetworkId, rfc1918IPRange, rfc6598IPRange and egressVirtualApplianceIp.')
param hubNetwork object

@description('Network configuration for the spoke virtual network.  It includes name, dnsServers, address spaces, vnet peering and subnets.')
param network object

// Private Dns Zones
@description('Private DNS Zones configuration.  See docs/archetypes/hubnetwork-azfw.md for configuration settings.')
param privateDnsZones object

// Private DNS Resolver
@description('Private DNS Resolver configuration for Inbound connections.')
param privateDnsResolver object

// Private DNS Resolver Ruleset
@description('Private DNS Resolver Default Ruleset Configuration')
param privateDnsResolverRuleset object


// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../config/telemetry.json'))
module telemetryCustomerUsageAttribution '../../azresources/telemetry/customer-usage-attribution-subscription.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.archetypes.genericSubscription}'
}

/*
  Scaffold the subscription which includes:
    * Microsoft Defender for Cloud - Enable Azure Defender (all available options)
    * Microsoft Defender for Cloud - Configure Log Analytics Workspace
    * Microsoft Defender for Cloud - Configure Security Alert Contact
    * Service Health Alerts
    * Role Assignments to Security Groups
    * Subscription Budget
    * Subscription Tags
*/
module subScaffold '../scaffold-subscription.bicep' = {
  name: 'configure-subscription'
  scope: subscription()
  params: {
    location: location

    serviceHealthAlerts: serviceHealthAlerts

    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    securityCenter: securityCenter

    subscriptionBudget: subscriptionBudget

    subscriptionTags: subscriptionTags
    resourceTags: resourceTags

    subscriptionRoleAssignments: subscriptionRoleAssignments
  }
}

// Create Network Watcher Resource Group
resource rgNetworkWatcher 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroups.networkWatcher
  location: location
  tags: resourceTags
}

// Create Virtual Network Resource Group - only if Virtual Network is being deployed
resource rgVnet 'Microsoft.Resources/resourceGroups@2020-06-01' = if (network.deployVnet) {
  name: network.deployVnet ? resourceGroups.networking : 'placeholder'
  location: location
  tags: resourceTags
}

// Create Azure Automation Resource Group
resource rgAutomation 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroups.automation
  location: location
  tags: resourceTags
}

// Create Azure backup RecoveryVault Resource Group
resource rgBackupVault 'Microsoft.Resources/resourceGroups@2020-06-01' =if (backupRecoveryVault.enabled) {
  name: resourceGroups.backupRecoveryVault
  location: location
  tags: resourceTags
}

// Create Private DNS Zones Resource Group
resource rgPrivateDnsZones 'Microsoft.Resources/resourceGroups@2020-06-01' =if (privateDnsZones.enabled) {
  name: resourceGroups.privateDnsZones
  location: location
  tags: resourceTags
}

// Create automation account
module automationAccount '../../azresources/automation/automation-account.bicep' = {
  name: 'deploy-automation-account'
  scope: rgAutomation
  params: {
    automationAccountName: automation.name
    tags: resourceTags
    location: location
  }
}

//create recovery vault for backup of vms
module backupVault '../../azresources/management/backup-recovery-vault.bicep'= if(backupRecoveryVault.enabled){
  name:'deploy-backup-recoveryvault'
  scope: rgBackupVault
  params:{
    vaultName: backupRecoveryVault.name
    tags: resourceTags
    location: location
  }
}

// Create & configure virtaual network - only if Virtual Network is being deployed
module vnet 'networking.bicep' = if (network.deployVnet) {
  name: 'deploy-networking'
  scope: resourceGroup(rgVnet.name)
  params: {
    hubNetwork: hubNetwork
    network: network
    location: location
    deployDNSResolver: privateDnsResolver
  }
}

module dnsResolver 'dnsResolver.bicep' = if (privateDnsResolver.enabled) {
  name: 'deploy-dns-resolver'
  scope: subscription()
  params: {
    privateDnsResolver: privateDnsResolver
    location: location
    rgVnet: rgVnet.name
    vnetId: vnet.outputs.vnetId
    vnetName: vnet.outputs.vnetName
    network: network
    resourceTags: resourceTags
    privateDnsResolverRuleset: privateDnsResolverRuleset
    dnsResolverRG: resourceGroups.dnsResolver
  }
}

// Private DNS Zones
module privatelinkDnsZones '../../azresources/network/private-dns-zone-privatelinks.bicep' = if (privateDnsZones.enabled) {
  name: 'deploy-privatelink-private-dns-zones'
  scope: resourceGroup(resourceGroups.privateDnsZones)
  params: {
    vnetId: vnet.outputs.vnetId
    dnsCreateNewZone: true
    dnsLinkToVirtualNetwork: true

    // Not required since the private dns zones will be created and linked to hub virtual network.
    dnsExistingZoneSubscriptionId: ''
    dnsExistingZoneResourceGroupName: ''
  }
}
