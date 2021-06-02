// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

// Groups
param subscriptionOwnerGroupObjectIds array = []
param subscriptionContributorGroupObjectIds array = []
param subscriptionReaderGroupObjectIds array = []

// Logging
param logAnalyticsResourceGroupName string
param logAnalyticsWorkspaceName string
param logAnalyticsAutomationAccountName string

// parameters for Azure Security Center
param securityContactEmail string
param securityContactPhone string

// parameters for Budget
param createBudget bool
param budgetName string
param budgetAmount int
param budgetNotificationEmailAddress string
param budgetStartDate string = utcNow('yyyy-MM-01')

// parameters for Tags
param tagISSO string
param tagClientOrganization string
param tagCostCenter string
param tagDataSensitivity string
param tagProjectContact string
param tagProjectName string
param tagTechnicalContact string

@allowed([
  'Monthly'
  'Quarterly'
  'Annually'  
])
param budgetTimeGrain string = 'Monthly'

var tags = {
  ClientOrganization: tagClientOrganization
  CostCenter: tagCostCenter
  DataSensitivity: tagDataSensitivity
  ProjectContact: tagProjectContact
  ProjectName: tagProjectName
  TechnicalContact: tagTechnicalContact
}

resource rgLogging 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: logAnalyticsResourceGroupName
  location: deployment().location
  tags: tags
}

module logAnalytics '../../azresources/monitor/logAnalytics.bicep' = {
  name: logAnalyticsWorkspaceName
  scope: rgLogging
  params: {
    workspaceName: logAnalyticsWorkspaceName
    automationAccountName: logAnalyticsAutomationAccountName
    tags: tags
  }
}

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
  }
}
