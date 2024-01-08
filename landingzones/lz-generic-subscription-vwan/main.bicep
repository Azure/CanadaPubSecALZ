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

@description('All configs are in one object')
param SubscriptionConfig object

// Telemetry - Azure customer usage attribution
// Reference:  https://learn.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
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
    location: SubscriptionConfig.location
    serviceHealthAlerts: SubscriptionConfig.serviceHealthAlerts
    subscriptionRoleAssignments: SubscriptionConfig.subscriptionRoleAssignments
    subscriptionBudget: SubscriptionConfig.subscriptionBudget
    subscriptionTags: SubscriptionConfig.subscriptionTags
    resourceTags: SubscriptionConfig.resourceTags
  }
}

// Create Network Watcher Resource Group
// resource rgNetworkWatcher 'Microsoft.Resources/resourceGroups@2020-06-01' = {
//   name: resourceGroups.networkWatcher
//   location: location
//   tags: resourceTags
// }

// Create Azure Automation Resource Group
resource rgAutomation 'Microsoft.Resources/resourceGroups@2020-06-01' = if (SubscriptionConfig.automationAccount.enabled) {
  name: SubscriptionConfig.automationAccount.resourceGroupName
  location: SubscriptionConfig.location
  tags: SubscriptionConfig.resourceTags
}

// Create automation account
module automationAccount '../../azresources/automation/automation-account.bicep' = if (SubscriptionConfig.automationAccount.enabled) {
  name: 'deploy-automation-account'
  scope: rgAutomation
  params: {
    automationAccountName: SubscriptionConfig.automationAccount.name
    tags: SubscriptionConfig.resourceTags
    location: SubscriptionConfig.location
  }
}

// Create Azure backup RecoveryVault Resource Group
resource rgBackupVault 'Microsoft.Resources/resourceGroups@2020-06-01' =if (SubscriptionConfig.backupRecoveryVault.enabled) {
  name: SubscriptionConfig.backupRecoveryVault.resourceGroupName
  location: SubscriptionConfig.location
  tags: SubscriptionConfig.resourceTags
}

//create recovery vault for backup of vms
module backupVault '../../azresources/management/backup-recovery-vault.bicep'= if(SubscriptionConfig.backupRecoveryVault.enabled) {
  name:'deploy-backup-recoveryvault'
  scope: rgBackupVault
  params:{
    vaultName: SubscriptionConfig.backupRecoveryVault.name
    tags: SubscriptionConfig.resourceTags
    location: SubscriptionConfig.location
  }
}

// Create Virtual Network Resource Group - only if Virtual Network is being deployed
resource rgVnet 'Microsoft.Resources/resourceGroups@2020-06-01' = if (SubscriptionConfig.network.deployVnet) {
  name: SubscriptionConfig.network.resourceGroupName
  location: SubscriptionConfig.location
  tags: SubscriptionConfig.resourceTags
}

// Create & configure virtaual network - only if Virtual Network is being deployed
module vnet 'networking.bicep' = if (SubscriptionConfig.network.deployVnet) {
  name: 'deploy-networking'
  scope: rgVnet
  params: {
    network: SubscriptionConfig.network
    location: SubscriptionConfig.location
  }
}

output vnetID string = SubscriptionConfig.network.deployVnet ? vnet.outputs.vnetId : ''
output vnetName string = SubscriptionConfig.network.deployVnet ? vnet.outputs.vnetName : ''
