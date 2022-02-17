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
* Integration with Microsoft Defender for Cloud
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

/*

For accepted parameter values, see:

  * Documentation:              docs/archetypes/generic-subscriptions.md
  * JSON Schema Definition:     schemas/latest/landingzones/lz-generic-subscription.json
  * JSON Test Cases/Scenarios:  tests/schemas/lz-generic-subscription

*/

@description('Location for the deployment.')
param location string = deployment().location

// Service Health
@description('Service Health alerts')
param serviceHealthAlerts object = {}

// Log Analytics
@description('Log Analytics Resource Id to integrate Microsoft Defender for Cloud.')
param logAnalyticsWorkspaceResourceId string

// Microsoft Defender for Cloud
@description('Microsoft Defender for Cloud configuration.  It includes email and phone.')
param securityCenter object

// Subscription Role Assignments
@description('Array of role assignments at subscription scope.  The array will contain an object with comments, roleDefinitionId and array of securityGroupObjectIds.')
param subscriptionRoleAssignments array = []

// Subscription Budget
@description('Subscription budget configuration containing createBudget flag, name, amount, timeGrain and array of contactEmails')
param subscriptionBudget object

// Tags
@description('A set of key/value pairs of tags assigned to the subscription.')
param subscriptionTags object

// Example (JSON)
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
    subscriptionRoleAssignments: subscriptionRoleAssignments
    subscriptionBudget: subscriptionBudget
    subscriptionTags: subscriptionTags
    resourceTags: resourceTags

    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    securityCenter: securityCenter
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

// Create Azure backup RecoveryVault Resource Group
resource backupRgVault 'Microsoft.Resources/resourceGroups@2020-06-01' =if(backupRecoveryVault.enabled) {
  name: resourceGroups.backupRecoveryVault
  location: location
  tags: resourceTags
}

//create recovery vault for backup of vms
module backupVault '../../azresources/management/backup-recovery-vault.bicep'= if(backupRecoveryVault.enabled){
  name:'deploy-backup-recoveryvault'
  scope: backupRgVault
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
  }
}
