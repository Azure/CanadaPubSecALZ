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
//   'email': 'alzcanadapubsec@microsoft.com'
//   'phone': '5555555555'
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

// Configure Tags
resource setTagISSO 'Microsoft.Resources/tags@2020-10-01' = {
  name: 'default'
  scope: subscription()
  properties: {
    tags: subscriptionTags
  }
}

// Configure Microsoft Defender for Cloud
module asc '../azresources/security-center/asc.bicep' = {
  name: 'configure-security-center'
  scope: subscription()
  params: {
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    securityContactEmail: securityCenter.email
    securityContactPhone: securityCenter.phone
  }
}

// Configure Budget
module budget '../azresources/cost/budget-subscription.bicep' = if (!empty(subscriptionBudget) && subscriptionBudget.createBudget) {
  name: 'configure-budget'
  scope: subscription()
  params: {
    budgetName: subscriptionBudget.name
    budgetAmount: subscriptionBudget.amount
    timeGrain: subscriptionBudget.timeGrain
    contactEmails: subscriptionBudget.contactEmails
  }
}

// Create Service Health resource group for managing alerts and action groups
resource rgServiceHealth 'Microsoft.Resources/resourceGroups@2021-04-01' = if (!empty(serviceHealthAlerts)) {
  name: (!empty(serviceHealthAlerts)) ? serviceHealthAlerts.resourceGroupName : 'rgServiceHealth'
  location: location
  tags: resourceTags
}

// Create Service Health alerts
module serviceHealth '../azresources/service-health/service-health.bicep' = if (!empty(serviceHealthAlerts)) {
  name: 'deploy-service-health'
  scope: rgServiceHealth
  params: {
    incidentTypes: (!empty(serviceHealthAlerts)) ? serviceHealthAlerts.incidentTypes : []
    regions: (!empty(serviceHealthAlerts)) ? serviceHealthAlerts.regions : []
    receivers: (!empty(serviceHealthAlerts)) ? serviceHealthAlerts.receivers : {}
    actionGroupName: (!empty(serviceHealthAlerts)) ? serviceHealthAlerts.actionGroupName : ''
    actionGroupShortName: (!empty(serviceHealthAlerts)) ? serviceHealthAlerts.actionGroupShortName : ''
    alertRuleName: (!empty(serviceHealthAlerts)) ? serviceHealthAlerts.alertRuleName : ''
    alertRuleDescription: (!empty(serviceHealthAlerts)) ? serviceHealthAlerts.alertRuleDescription : ''
  }
}

// Role Assignments based on Security Groups
module assignSubscriptionRBAC '../azresources/iam/subscription/role-assignment-to-group.bicep' = [for roleAssignment in subscriptionRoleAssignments: {
  name: 'rbac-${roleAssignment.roleDefinitionId}'
  scope: subscription()
  params: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionId)
    groupObjectIds: roleAssignment.securityGroupObjectIds
  }
}]
