// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

@description('Log Analytics Workspace Resource Id.')
param logAnalyticsWorkspaceResourceId string

@description('Security Contact Email Address.')
param securityContactEmail string

@description('Security Contact Phone.')
param securityContactPhone string

// Enable Security Contacts
resource ascSecurityContacts 'Microsoft.Security/securityContacts@2017-08-01-preview' = {
  name: 'default1'
  properties: {
    email: securityContactEmail
    phone: securityContactPhone
    alertNotifications: 'On'
    alertsToAdmins: 'On'
  }
}

// Enable Log Analytics Workspace
resource ascWorkspaceSettings 'Microsoft.Security/workspaceSettings@2017-08-01-preview' = {
  name: 'default'
  properties: {
    scope: subscription().id
    workspaceId: logAnalyticsWorkspaceResourceId
  }
}

resource ascAutoProvision 'Microsoft.Security/autoProvisioningSettings@2017-08-01-preview' = {
  name: 'default'
  properties: {
    autoProvision: 'On'
  }
}

// Enable Azure Defender
var azureDefenderServices = [
  'Arm'
  'AppServices'
  'Containers'
  'CosmosDbs'
  'Dns'
  'KeyVaults'
  'OpenSourceRelationalDatabases'
  'SqlServers'
  'SqlServerVirtualMachines'
  'StorageAccounts'
  'VirtualMachines'
]

resource ascDefender 'Microsoft.Security/pricings@2018-06-01' = [for service in azureDefenderServices: {
  name: service
  properties: {
    pricingTier: 'Standard'
  }
}]

