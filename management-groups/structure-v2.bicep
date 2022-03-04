// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

@description('Top Level Management Group Name')
param topLevelManagementGroupName string

@description('Parent Management Group ID')
param parentManagementGroupId string

@description('Child Management Group ID')
param childManagementGroupId string

@description('Child Management Group Name')
param childManagementGroupName string

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../config/telemetry.json'))
module telemetryCustomerUsageAttribution '../azresources/telemetry/customer-usage-attribution-management-group.bicep' = if (telemetry.customerUsageAttribution.enabled && (childManagementGroupName == topLevelManagementGroupName)) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.managementGroups}'
}

// Management Group
resource managementGroup 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: childManagementGroupId
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: tenantResourceId('Microsoft.Management/managementGroups', parentManagementGroupId)
      }
    }
    displayName: childManagementGroupName
  }
}
