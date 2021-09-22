// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

/*

Platform Logging archetype provides infrastructure for centrally managed Log Analytics Workspace & Sentinel that includes:

* Azure Automation Account
* Log Analytics Workspace
* Log Analytics Workspace Solutions
  * AgentHealthAssessment
  * AntiMalware
  * AzureActivity
  * ChangeTracking
  * Security
  * SecurityInsights (Azure Sentinel)
  * ServiceMap
  * SQLAssessment
  * Updates
  * VMInsights
* Role-based access control for Owner, Contributor & Reader 
* Integration between Azure Automation Account & Log Analytics Workspace
* Integration with Azure Cost Management for Subscription-scoped budget
* Integration with Azure Security Center

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

// Subscription Budget
// Example (JSON)
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
// ---------------------------
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

// Groups
@description('An array of Security Group object ids that should be granted Owner built-in role.  Default: []')
param subscriptionOwnerGroupObjectIds array = []

@description('An array of Security Group object ids that should be granted Contributor built-in role.  Default: []')
param subscriptionContributorGroupObjectIds array = []

@description('An array of Security Group object ids that should be granted Reader built-in role.  Default: []')
param subscriptionReaderGroupObjectIds array = []

// Logging
@description('Log Analytics Resource Group name.')
param logAnalyticsResourceGroupName string

@description('Log Analytics Workspace name.')
param logAnalyticsWorkspaceName string

@description('Automation account name.')
param logAnalyticsAutomationAccountName string

// Azure Security Center
@description('Contact email address for Azure Security Center alerts.')
param securityContactEmail string

@description('Contact phone number for Azure Security Center alerts.')
param securityContactPhone string

// Create Log Analytics Workspace Resource Group
resource rgLogging 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: logAnalyticsResourceGroupName
  location: deployment().location
  tags: resourceTags
}

// Create Log Analytics Workspace
module logAnalytics '../../azresources/monitor/log-analytics.bicep' = {
  name: logAnalyticsWorkspaceName
  scope: rgLogging
  params: {
    workspaceName: logAnalyticsWorkspaceName
    automationAccountName: logAnalyticsAutomationAccountName
    tags: resourceTags
  }
}

/*
  Scaffold the subscription which includes:
    * Azure Security Center - Enable Azure Defender (all available options)
    * Azure Security Center - Configure Log Analytics Workspace (using the Log Analytics Workspace created in this deployment)
    * Azure Security Center - Configure Security Alert Contact
    * Role Assignments to Security Groups
    * Service Health Alerts
    * Subscription Budget
    * Subscription Tags
*/
module subScaffold '../scaffold-subscription.bicep' = {
  name: 'subscription-scaffold'
  scope: subscription()
  params: {
    subscriptionOwnerGroupObjectIds: subscriptionOwnerGroupObjectIds
    subscriptionContributorGroupObjectIds: subscriptionContributorGroupObjectIds
    subscriptionReaderGroupObjectIds: subscriptionReaderGroupObjectIds
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.workspaceResourceId
    securityContactEmail: securityContactEmail
    securityContactPhone: securityContactPhone

    serviceHealthAlerts: serviceHealthAlerts
    subscriptionBudget: subscriptionBudget    
    subscriptionTags: subscriptionTags
    resourceTags: resourceTags
  }
}
