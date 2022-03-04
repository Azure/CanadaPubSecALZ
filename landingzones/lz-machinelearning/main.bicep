// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

@description('Location for the deployment.')
param location string = deployment().location

/*

For accepted parameter values, see:

  * Documentation:              docs/archetypes/machinelearning.md
  * JSON Schema Definition:     schemas/latest/landingzones/lz-machinelearning.json
  * JSON Test Cases/Scenarios:  tests/schemas/lz-machinelearning

*/

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

// Azure Kubernetes Service
@description('Azure Kubernetes Service configuration.  Includes version.')
param aks object

// Azure App Service
@description('Azure App Service Linux Container configuration.')
param appServiceLinuxContainer object

// SQL Database
@description('SQL Database configuration.  Includes enabled flag and username.')
param sqldb object

// SQL Managed Instance
@description('SQL Managed Instance configuration.  Includes enabled flag and username.')
param sqlmi object

// Example (JSON)
@description('Azure Machine Learning configuration.  Includes enableHbiWorkspace.')
param aml object

// Networking
@description('Hub Network configuration that includes virtualNetworkId, rfc1918IPRange, rfc6598IPRange, egressVirtualApplianceIp, privateDnsManagedByHub flag, privateDnsManagedByHubSubscriptionId and privateDnsManagedByHubResourceGroupName.')
param hubNetwork object

// Example (JSON)
@description('Network configuration.  Includes peerToHubVirtualNetwork flag, useRemoteGateway flag, name, dnsServers, addressPrefixes and subnets (oz, paz, rz, hrz, privateEndpoints, sqlmi, databricksPublic, databricksPrivate, aks, appService) ')
param network object

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../config/telemetry.json'))
module telemetryCustomerUsageAttribution '../../azresources/telemetry/customer-usage-attribution-subscription.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.archetypes.machineLearning}'
}

/*
  Scaffold the subscription which includes:
    * Microsoft Defender for Cloud - Enable Azure Defender (all available options)
    * Microsoft Defender for Cloud - Configure Log Analytics Workspace
    * Microsoft Defender for Cloud - Configure Security Alert Contact
    * Role Assignments to Security Groups
    * Service Health Alerts
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
  name: 'deploy-machinelearning-archetype'
  scope: subscription()
  params: {
    location: location

    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId

    securityContactEmail: securityCenter.email

    resourceTags: resourceTags
    resourceGroups: resourceGroups

    useCMK: useCMK

    automation: automation
    keyVault: keyVault
    aks: aks
    appServiceLinuxContainer: appServiceLinuxContainer
    sqldb: sqldb
    sqlmi: sqlmi
    aml: aml

    hubNetwork: hubNetwork
    network: network
  }
}
