// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

@description('Management Group Id for assignable scope.')
param assignableMgId string

var scope = tenantResourceId('Microsoft.Management/managementGroups', assignableMgId)
var roleName = 'Custom - Log Analytics - Read Only for VM Insights'
var roleDescription = 'Read only access to Log Analytics for VM Insights.'

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../config/telemetry.json'))
module telemetryCustomerUsageAttribution '../azresources/telemetry/customer-usage-attribution-management-group.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.roles}'
}

resource roleDefn 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' = {
  name: guid(roleName)
  scope: managementGroup()
  properties: {
    roleName: roleName
    description: roleDescription
    permissions: [
      {
        actions: [
          'Microsoft.operationalinsights/workspaces/features/generateMap/read'
          'Microsoft.operationalinsights/workspaces/features/servergroups/members/read'
          'Microsoft.operationalinsights/workspaces/features/clientgroups/memebers/read'
          'Microsoft.operationalinsights/workspaces/features/machineGroups/read'
          'Microsoft.OperationalInsights/workspaces/query/VMBoundPort/read'
          'Microsoft.OperationalInsights/workspaces/query/VMComputer/read'
          'Microsoft.OperationalInsights/workspaces/query/VMConnection/read'
          'Microsoft.OperationalInsights/workspaces/query/VMProcess/read'
          'Microsoft.OperationalInsights/workspaces/query/InsightsMetrics/read'
        ]
        notActions: []
        dataActions: []
        notDataActions: []
      }
    ]
    assignableScopes: [
      scope
    ]
  }
}
