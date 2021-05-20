// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

// Owner Group
param subscriptionOwnerGroupObjectIds array = []
param subscriptionContributorGroupObjectIds array = []
param subscriptionReaderGroupObjectIds array = []

// parameters for Azure Security Center
param logAnalyticsWorkspaceResourceId string
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
    tags: {
      ISSO: tagISSO
    }
  }
}

// Configure Security Center
module securityCenter '../azresources/security-center/enable-asc.bicep' = {
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

// Role Assignments based on Security Groups
var ownerRoleDefinitionId = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
module group_roleAssignment_Owner '../azresources/iam/subscription/roleAssignmentToGroup.bicep' = if (!(empty(subscriptionOwnerGroupObjectIds))) {
  name: 'ownerAssignmentToGroup'
  scope: subscription()
  params: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', ownerRoleDefinitionId)
    subscriptionContributorGroupObjectIds: subscriptionOwnerGroupObjectIds
  }
}

var contributorRoleDefinitionId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
module group_roleAssignment_Contributor '../azresources/iam/subscription/roleAssignmentToGroup.bicep' = if (!(empty(subscriptionContributorGroupObjectIds))) {
  name: 'contributorAssignmentToGroup'
  scope: subscription()
  params: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionId)
    subscriptionContributorGroupObjectIds: subscriptionContributorGroupObjectIds
  }
}

var readerRoleDefinitionId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
module group_roleAssignment_Reader '../azresources/iam/subscription/roleAssignmentToGroup.bicep' = if (!(empty(subscriptionReaderGroupObjectIds))) {
  name: 'readerAssignmentToGroup'
  scope: subscription()
  params: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', readerRoleDefinitionId)
    subscriptionContributorGroupObjectIds: subscriptionReaderGroupObjectIds
  }
}
