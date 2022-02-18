// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

/*

For accepted parameter values, see:

  * Documentation:              docs/archetypes/healthcare.md
  * JSON Schema Definition:     schemas/latest/landingzones/lz-healthcare.json
  * JSON Test Cases/Scenarios:  tests/schemas/lz-healthcare

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

@description('A set of key/value pairs of tags assigned to the resource group and resources.')
param resourceTags object

// Resource Groups
@description('Resource groups required for the achetype.  It includes automation, compute, monitor, networking, networkWatcher, security and storage.')
param resourceGroups object

@description('Boolean flag to determine whether customer managed keys are used.  Default:  false')
param useCMK bool = false

// Azure Automation Account
@description('Azure Automation Account configuration.  Includes name.')
param automation object

// Azure Key Vault
@description('Azure Key Vault configuraiton.  Includes secretExpiryInDays.')
param keyVault object

// SQL Database
@description('SQL Database configuration.  Includes enabled flag and username.')
param sqldb object

// Synapse
@description('Synapse Analytics configuration.  Includes username.')
param synapse object

// Networking
@description('Hub Network configuration that includes virtualNetworkId, rfc1918IPRange, rfc6598IPRange, egressVirtualApplianceIp, privateDnsManagedByHub flag, privateDnsManagedByHubSubscriptionId and privateDnsManagedByHubResourceGroupName.')
param hubNetwork object

@description('Network configuration.  Includes peerToHubVirtualNetwork flag, useRemoteGateway flag, name, dnsServers, addressPrefixes and subnets (oz, paz, rz, hrz, privateEndpoints, databricksPublic, databricksPrivate, web) ')
param network object

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../config/telemetry.json'))
module telemetryCustomerUsageAttribution '../../azresources/telemetry/customer-usage-attribution-subscription.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.archetypes.healthcare}'
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

// Deploy Landing Zone
module landingZone 'lz.bicep' = {
  name: 'deploy-healthcare-archetype'
  scope: subscription()
  params: {
    location: location
    
    securityContactEmail: securityCenter.email

    resourceTags: resourceTags
    resourceGroups: resourceGroups

    useCMK: useCMK

    automation: automation
    keyVault: keyVault
    sqldb: sqldb
    synapse: synapse

    hubNetwork: hubNetwork
    network: network
  }
}
