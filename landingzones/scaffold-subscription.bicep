// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

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

// RBAC assignments
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

// Subscription Budget
@description('Boolean flag to determine whether to create subscription budget.  Default: true')
param createBudget bool

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

// Configure Tags
resource setTagISSO 'Microsoft.Resources/tags@2020-10-01' = {
  name: 'default'
  scope: subscription()
  properties: {
    tags: subscriptionTags
  }
}

// Configure Security Center
module securityCenter '../azresources/security-center/asc.bicep' = {
  name: 'configure-security-center'
  scope: subscription()
  params: {
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    securityContactEmail: securityContactEmail
    securityContactPhone: securityContactPhone
  }
}

// Configure Budget
module budget '../azresources/cost/budget-subscription.bicep' = if (createBudget) {
  name: 'configure-budget'
  scope: subscription()
  params: {
    budgetAmount: budgetAmount
    budgetName: budgetName
    startDate: budgetStartDate
    timeGrain: budgetTimeGrain
    notificationEmailAddress: budgetNotificationEmailAddress
  }
}

// Create Service Health resource group for managing alerts and action groups
resource rgServiceHealth 'Microsoft.Resources/resourceGroups@2021-04-01' = if (!empty(serviceHealthAlerts)) {
  name: (!empty(serviceHealthAlerts)) ? serviceHealthAlerts.resourceGroupName : 'rgServiceHealth'
  location: deployment().location
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
  }
}

// Role Assignments based on Security Groups
var ownerRoleDefinitionId = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
module group_roleAssignment_Owner '../azresources/iam/subscription/role-assignment-to-group.bicep' = if (!(empty(subscriptionOwnerGroupObjectIds))) {
  name: 'rbac-assign-owner-to-sg'
  scope: subscription()
  params: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', ownerRoleDefinitionId)
    groupObjectIds: subscriptionOwnerGroupObjectIds
  }
}

var contributorRoleDefinitionId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
module group_roleAssignment_Contributor '../azresources/iam/subscription/role-assignment-to-group.bicep' = if (!(empty(subscriptionContributorGroupObjectIds))) {
  name: 'rbac-assign-contributor-to-sg'
  scope: subscription()
  params: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionId)
    groupObjectIds: subscriptionContributorGroupObjectIds
  }
}

var readerRoleDefinitionId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
module group_roleAssignment_Reader '../azresources/iam/subscription/role-assignment-to-group.bicep' = if (!(empty(subscriptionReaderGroupObjectIds))) {
  name: 'rbac-assign-reader-to-sg'
  scope: subscription()
  params: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', readerRoleDefinitionId)
    groupObjectIds: subscriptionReaderGroupObjectIds
  }
}

module group_roleAssignment_LZAppOwner '../azresources/iam/subscription/role-assignment-to-group.bicep' = if (!(empty(subscriptionAppOwnerGroupObjectIds)) && (!(empty(lzAppOwnerRoleDefinitionId)))) {
  name: 'rbac-assign-lzappowner-to-sg'
  scope: subscription()
  params: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', lzAppOwnerRoleDefinitionId)
    groupObjectIds: subscriptionAppOwnerGroupObjectIds
  }
}
