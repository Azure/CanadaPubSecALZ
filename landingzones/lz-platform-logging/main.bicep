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

// Budget
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

// Create Log Analytics Workspace Resource Group
resource rgLogging 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: logAnalyticsResourceGroupName
  location: deployment().location
  tags: tags
}

// Create Log Analytics Workspace
module logAnalytics '../../azresources/monitor/log-analytics.bicep' = {
  name: logAnalyticsWorkspaceName
  scope: rgLogging
  params: {
    workspaceName: logAnalyticsWorkspaceName
    automationAccountName: logAnalyticsAutomationAccountName
    tags: tags
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
    * Subscription Tag:  ISSO
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
    createBudget: createBudget
    budgetName: budgetName
    budgetAmount: budgetAmount
    budgetTimeGrain: budgetTimeGrain
    budgetStartDate: budgetStartDate
    budgetNotificationEmailAddress: budgetNotificationEmailAddress
    tagISSO: tagISSO
    tagClientOrganization: tagClientOrganization
    tagCostCenter: tagCostCenter
    tagDataSensitivity: tagDataSensitivity
    tagProjectContact: tagProjectContact
    tagProjectName: tagProjectName
    tagTechnicalContact: tagTechnicalContact
  }
}
