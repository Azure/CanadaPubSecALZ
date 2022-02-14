// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Location for the deployment.')
param location string = resourceGroup().location

@description('Log Analytics Workspace Name.')
param workspaceName string

@description('Automation Account Name.')
param automationAccountName string

@description('Key/Value pair of tags.')
param tags object = {}

@description('Log Analytics Workspace Data Retention in days.')
param workspaceRetentionInDays int

// Log Analytics Workspace Solutions
var solutions = [
  'AgentHealthAssessment'
  'AntiMalware'
  'AzureActivity'
  'ChangeTracking'
  'Security'
  'SecurityInsights'
  'ServiceMap'
  'SQLAssessment'
  'Updates'
  'VMInsights'
]

// Create Automation Account
module automationAccount '../automation/automation-account.bicep' = {
  name: 'automation-account'
  params: {
    automationAccountName: automationAccountName
    tags: tags
    location: location
  }
}

// Create Log Analytics Workspace
resource workspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: workspaceName
  tags: tags
  location: location
  properties: {
    sku: {
      name: 'PerNode'
    }
    retentionInDays: workspaceRetentionInDays
  }
}

// Link Log Analytics Workspace to Automation Account
resource automationAccountLinkedToWorkspace 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = {
  name: '${workspace.name}/Automation'
  tags: tags
  properties: {
    resourceId: automationAccount.outputs.automationAccountId
  }
}

// Add Log Analytics Workspace Solutions
resource workspaceSolutions 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for solution in solutions: {
  name: '${solution}(${workspace.name})'
  tags: tags
  location: location
  properties: {
    workspaceResourceId: workspace.id
  }
  plan: {
    name: '${solution}(${workspace.name})'
    product: 'OMSGallery/${solution}'
    publisher: 'Microsoft'
    promotionCode: ''
  }
}]

output workspaceResourceId string = workspace.id
