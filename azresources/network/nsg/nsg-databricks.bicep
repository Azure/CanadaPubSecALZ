// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Network Security Group Name for Public Subnet.')
param namePublic string

@description('Network Security Group Name for Private Subnet.')
param namePrivate string

resource nsgPublic 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: namePublic
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-inbound'
        properties: {
            description: 'Required for worker nodes communication within a cluster.'
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'VirtualNetwork'
            access: 'Allow'
            priority: 100
            direction: 'Inbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-databricks-webapp'
        properties: {
            description: 'Required for workers communication with Databricks Webapp.'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'AzureDatabricks'
            access: 'Allow'
            priority: 100
            direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-sql'
        properties: {
            description: 'Required for workers communication with Azure SQL services.'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '3306'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'Sql'
            access: 'Allow'
            priority: 101
            direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-storage'
        properties: {
            description: 'Required for workers communication with Azure Storage services.'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'Storage'
            access: 'Allow'
            priority: 102
            direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-outbound'
        properties: {
            description: 'Required for worker nodes communication within a cluster.'
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'VirtualNetwork'
            access: 'Allow'
            priority: 103
            direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-eventhub'
        properties: {
            description: 'Required for worker communication with Azure Eventhub services.'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '9093'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'EventHub'
            access: 'Allow'
            priority: 104
            direction: 'Outbound'
        }
      }
    ]
  }
}

resource nsgPrivate 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: namePrivate
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-inbound'
        properties: {
            description: 'Required for worker nodes communication within a cluster.'
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'VirtualNetwork'
            access: 'Allow'
            priority: 100
            direction: 'Inbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-databricks-webapp'
        properties: {
            description: 'Required for workers communication with Databricks Webapp.'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'AzureDatabricks'
            access: 'Allow'
            priority: 100
            direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-sql'
        properties: {
            description: 'Required for workers communication with Azure SQL services.'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '3306'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'Sql'
            access: 'Allow'
            priority: 101
            direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-storage'
        properties: {
            description: 'Required for workers communication with Azure Storage services.'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '443'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'Storage'
            access: 'Allow'
            priority: 102
            direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-outbound'
        properties: {
            description: 'Required for worker nodes communication within a cluster.'
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'VirtualNetwork'
            access: 'Allow'
            priority: 103
            direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-eventhub'
        properties: {
            description: 'Required for worker communication with Azure Eventhub services.'
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '9093'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'EventHub'
            access: 'Allow'
            priority: 104
            direction: 'Outbound'
        }
      }
    ]
  }
}

// Outputs
output publicNsgId string = nsgPublic.id
output privateNsgId string = nsgPrivate.id
