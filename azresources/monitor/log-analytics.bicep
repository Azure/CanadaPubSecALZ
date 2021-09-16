// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param workspaceName string = 'workspace-${uniqueString(resourceGroup().id)}'
param automationAccountName string = 'automation-${uniqueString(resourceGroup().id)}'
param tags object = {}

var workspaceRetentionInDays = 730

module automationAccount '../automation/automation-account.bicep' = {
  name: 'automation-account'
  params: {
    automationAccountName: automationAccountName
    tags: tags
  }
}

resource workspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: workspaceName
  tags: tags
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'PerNode'
    }
    retentionInDays: workspaceRetentionInDays
  }
}

resource automationAccountLinkedToWorkspace 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = {
  name: '${workspace.name}/Automation'
  properties: {
    resourceId: automationAccount.outputs.automationAccountId
  }
}

// Add Workspace Solutions
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

resource workspaceSolutions 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for solution in solutions: {
  name: '${solution}(${workspace.name})'
  location: resourceGroup().location
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
