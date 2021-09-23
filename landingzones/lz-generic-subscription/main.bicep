// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

/*

Generic Subscription Landing Zone archetype provides the basic Azure subscription configuration that includes:

* Service Health alerts (optional)
* Azure Automation Account
* Azure Virtual Network
* Role-based access control for Owner, Contributor, Reader & Application Owner (custom role) 
* Integration with Azure Cost Management for Subscription-scoped budget
* Integration with Azure Security Center
* Integration to Hub Virtual Network (optional)
* Support for Network Virtual Appliance (i.e. Fortinet, Azure Firewall) in the Hub Network (if integrated to hub network)
* Support for Azure Bastion in the Hub (if integrated to hub network)

This landing is typically used for:

* Lift & Shift Azure Migrations
* COTS (Commercial off-the-shelf) products
* General deployment where Application teams own and operate the application stack
* Evaluating/prototying new application designs

*/

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

// Subscription Role Assignments
// Example (JSON)
// -----------------------------
// [
//   {
//       "comments": "Built-in Contributor Role",
//       "roleDefinitionId": "b24988ac-6180-42a0-ab88-20f7382dd24c",
//       "securityGroupObjectIds": [
//           "38f33f7e-a471-4630-8ce9-c6653495a2ee"
//       ]
//   }
// ]

// Example (Bicep)
// -----------------------------
// [
//   {
//     'comments': 'Built-In Contributor Role'
//     'roleDefinitionId': 'b24988ac-6180-42a0-ab88-20f7382dd24c'
//     'securityGroupObjectIds': [
//       '38f33f7e-a471-4630-8ce9-c6653495a2ee'
//     ]
//   }
// ]
@description('Array of role assignments at subscription scope.  The array will contain an object with comments, roleDefinitionId and array of securityGroupObjectIds.')
param subscriptionRoleAssignments array = []

// Subscription Budget
// Example (JSON)
// ---------------------------
// "subscriptionBudget": {
//   "value": {
//       "createBudget": false,
//       "name": "MonthlySubscriptionBudget",
//       "amount": 1000,
//       "timeGrain": "Monthly",
//       "contactEmails": [ "alzcanadapubsec@microsoft.com" ]
//   }
// }

// Example (Bicep)
// ---------------------------
// {
//   createBudget: true
//   name: 'MonthlySubscriptionBudget'
//   amount: 1000
//   timeGrain: 'Monthly'
//   contactEmails: [
//     'alzcanadapubsec@microsoft.com'
//   ]
// }
@description('Subscription budget configuration containing createBudget flag, name, amount, timeGrain and array of contactEmails')
param subscriptionBudget object

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
// -----------------------------
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

// Azure Security Center
@description('Log Analytics Resource Id to integrate Azure Security Center.')
param logAnalyticsWorkspaceResourceId string

@description('Contact email address for Azure Security Center alerts.')
param securityContactEmail string

@description('Contact phone number for Azure Security Center alerts.')
param securityContactPhone string

// Resource Groups
// Example (JSON)
// -----------------------------
// "resourceGroups": {
//   "value": {
//       "automation": "rgAutomation",
//       "networking": "rgVnet",
//       "networkWatcher": "NetworkWatcherRG"
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   'automation': 'rgAutomation092021W3'
//   'networking': 'rgVnet092021W3'
//   'networkWatcher': 'NetworkWatcherRG'
// }
@description('Resource groups required for the achetype.  It includes automation, networking and networkWatcher.')
param resourceGroups object

// Networking
// Example (JSON)
// -----------------------------
// "hubNetwork": {
//   "value": {
//       "virtualNetworkId": "/subscriptions/ed7f4eed-9010-4227-b115-2a5e37728f27/resourceGroups/pubsec-hub-networking-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet",
//       "rfc1918IPRange": "10.18.0.0/22",
//       "rfc6598IPRange": "100.60.0.0/16",
//       "egressVirtualApplianceIp": "10.18.0.36"
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   'virtualNetworkId': '/subscriptions/ed7f4eed-9010-4227-b115-2a5e37728f27/resourceGroups/pubsec-hub-networking-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet'
//   'rfc1918IPRange': '10.18.0.0/22'
//   'rfc6598IPRange': '100.60.0.0/16'
//   'egressVirtualApplianceIp': '10.18.0.36'
// }
@description('Hub Network configuration that includes virtualNetworkId, rfc1918IPRange, rfc6598IPRange and egressVirtualApplianceIp.')
param hubNetwork object

// Example (JSON)
// -----------------------------
// "network": {
//   "value": {
//       "deployVnet": true,
//
//       "peerToHubVirtualNetwork": true,
//       "useRemoteGateway": false,
//
//       "name": "vnet",
//       "addressPrefixes": [
//           "10.2.0.0/16"
//       ],
//       "subnets": {
//           "oz": {
//               "comments": "Foundational Elements Zone (OZ)",
//               "name": "oz",
//               "addressPrefix": "10.2.1.0/25",
//               "nsg": {
//                   "enabled": true
//               },
//               "udr": {
//                   "enabled": true
//               }
//           },
//           "paz": {
//               "comments": "Presentation Zone (PAZ)",
//               "name": "paz",
//               "addressPrefix": "10.2.2.0/25",
//               "nsg": {
//                   "enabled": true
//               },
//               "udr": {
//                   "enabled": true
//               }
//           },
//           "rz": {
//               "comments": "Application Zone (RZ)",
//               "name": "rz",
//               "addressPrefix": "10.2.3.0/25",
//               "nsg": {
//                   "enabled": true
//               },
//               "udr": {
//                   "enabled": true
//               }
//           },
//           "hrz": {
//               "comments": "Data Zone (HRZ)",
//               "name": "hrz",
//               "addressPrefix": "10.2.4.0/25",
//               "nsg": {
//                   "enabled": true
//               },
//               "udr": {
//                   "enabled": true
//               }
//           },
//           "optional": [
//               {
//                   "comments": "App Service",
//                   "name": "appservice",
//                   "addressPrefix": "10.2.5.0/25",
//                   "nsg": {
//                       "enabled": false
//                   },
//                   "udr": {
//                       "enabled": false
//                   },
//                   "delegations": {
//                       "serviceName": "Microsoft.Web/serverFarms"
//                   }
//               }
//           ]
//       }
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   'deployVnet': true
//
//   'peerToHubVirtualNetwork': true
//   'useRemoteGateway': false
//
//   'name': 'vnet'
//   'addressPrefixes': [
//     '10.2.0.0/16'
//   ]
//   'subnets': {
//     'oz': {
//       'comments': 'Foundational Elements Zone (OZ)'
//       'name': 'oz'
//       'addressPrefix': '10.2.1.0/25'
//       'nsg': {
//         'enabled': true
//       }
//       'udr': {
//         'enabled': true
//       }
//     }
//     'paz': {
//       'comments': 'Presentation Zone (PAZ)'
//       'name': 'paz'
//       'addressPrefix': '10.2.2.0/25'
//       'nsg': {
//         'enabled': true
//       }
//       'udr': {
//         'enabled': true
//       }
//     }
//     'rz': {
//       'comments': 'Application Zone (RZ)'
//       'name': 'rz'
//       'addressPrefix': '10.2.3.0/25'
//       'nsg': {
//         'enabled': true
//       }
//       'udr': {
//         'enabled': true
//       }
//     }
//     'hrz': {
//       'comments': 'Data Zone (HRZ)'
//       'name': 'hrz'
//       'addressPrefix': '10.2.4.0/25'
//       'nsg': {
//         'enabled': true
//       }
//       'udr': {
//         'enabled': true
//       }
//     }
//     'optional': [
//       {
//         'comments': 'App Service'
//         'name': 'appservice'
//         'addressPrefix': '10.2.5.0/25'
//         'nsg': {
//           'enabled': false
//         }
//         'udr': {
//           'enabled': false
//         }
//         'delegations': {
//           'serviceName': 'Microsoft.Web/serverFarms'
//         }
//       }
//     ]
//   }
// }
@description('Network configuration for the spoke virtual network.  It includes name, address spaces, vnet peering and subnets.')
param network object

// Automation
@description('Azure Automation Account name.')
param automationAccountName string

/*
  Scaffold the subscription which includes:
    * Azure Security Center - Enable Azure Defender (all available options)
    * Azure Security Center - Configure Log Analytics Workspace
    * Azure Security Center - Configure Security Alert Contact
    * Service Health Alerts
    * Role Assignments to Security Groups
    * Subscription Budget
    * Subscription Tags
*/
module subScaffold '../scaffold-subscription.bicep' = {
  name: 'configure-subscription'
  scope: subscription()
  params: {
    serviceHealthAlerts: serviceHealthAlerts
    subscriptionRoleAssignments: subscriptionRoleAssignments
    subscriptionBudget: subscriptionBudget
    subscriptionTags: subscriptionTags
    resourceTags: resourceTags

    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    securityContactEmail: securityContactEmail
    securityContactPhone: securityContactPhone
  }
}

// Create Network Watcher Resource Group
resource rgNetworkWatcher 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroups.networkWatcher
  location: deployment().location
  tags: resourceTags
}

// Create Virtual Network Resource Group - only if Virtual Network is being deployed
resource rgVnet 'Microsoft.Resources/resourceGroups@2020-06-01' = if (network.deployVnet) {
  name: network.deployVnet ? resourceGroups.networking : 'placeholder'
  location: deployment().location
  tags: resourceTags
}

// Create Azure Automation Resource Group
resource rgAutomation 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroups.automation
  location: deployment().location
  tags: resourceTags
}

// Create automation account
module automationAccount '../../azresources/automation/automation-account.bicep' = {
  name: 'deploy-automation-account'
  scope: rgAutomation
  params: {
    automationAccountName: automationAccountName
    tags: resourceTags
  }
}

// Create & configure virtaual network - only if Virtual Network is being deployed
module vnet 'networking.bicep' = if (network.deployVnet) {
  name: 'deploy-networking'
  scope: resourceGroup(rgVnet.name)
  params: {
    hubNetwork: hubNetwork
    network: network
  }
}
