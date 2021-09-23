// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

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
@description('Azure Network Watcher Resource Group Name.  Default: NetworkWatcherRG')
param rgNetworkWatcherName string = 'NetworkWatcherRG'

@description('Virtual Network Resource Group Name.')
param rgVnetName string

@description('Automation Account Resource Group Name.')
param rgAutomationName string

@description('Storage Resource Group Name.')
param rgStorageName string

@description('Compute Resource Group Name.')
param rgComputeName string

@description('Security Resource Group Name.')
param rgSecurityName string

@description('Monitoring Resource Group Name.')
param rgMonitorName string

// Automation
@description('Azure Automation Account name.')
param automationAccountName string

// VNET
@description('Virtual Network Name.')
param vnetName string

@description('Virtual Network Address Space.')
param vnetAddressSpace string

@description('Hub Virtual Network Resource Id.  It is required for configuring Virtual Network Peering & configuring route tables.')
param hubVnetId string

// Internal Foundational Elements (OZ) Subnet
@description('Foundational Element (OZ) Subnet Name')
param subnetFoundationalElementsName string

@description('Foundational Element (OZ) Subnet Address Prefix.')
param subnetFoundationalElementsPrefix string

// Presentation Zone (PAZ) Subnet
@description('Presentation Zone (PAZ) Subnet Name.')
param subnetPresentationName string

@description('Presentation Zone (PAZ) Subnet Address Prefix.')
param subnetPresentationPrefix string

// Application zone (RZ) Subnet
@description('Application (RZ) Subnet Name.')
param subnetApplicationName string

@description('Application (RZ) Subnet Address Prefix.')
param subnetApplicationPrefix string

// Data Zone (HRZ) Subnet
@description('Data Zone (HRZ) Subnet Name.')
param subnetDataName string

@description('Data Zone (HRZ) Subnet Address Prefix.')
param subnetDataPrefix string

// Delegated Subnets
@description('Delegated SQL MI Subnet Name.')
param subnetSQLMIName string

@description('Delegated SQL MI Subnet Address Prefix.')
param subnetSQLMIPrefix string

@description('Delegated Databricks Public Subnet Name.')
param subnetDatabricksPublicName string

@description('Delegated Databricks Public Subnet Address Prefix.')
param subnetDatabricksPublicPrefix string

@description('Delegated Databricks Private Subnet Name.')
param subnetDatabricksPrivateName string

@description('Delegated Databricks Private Subnet Address Prefix.')
param subnetDatabricksPrivatePrefix string

// Priavte Endpoint Subnet
@description('Private Endpoints Subnet Name.  All private endpoints will be deployed to this subnet.')
param subnetPrivateEndpointsName string

@description('Private Endpoint Subnet Address Prefix.')
param subnetPrivateEndpointsPrefix string

// AKS Subnet
@description('AKS Subnet Name.')
param subnetAKSName string

@description('AKS Subnet Address Prefix.')
param subnetAKSPrefix string

// Virtual Appliance IP
@description('Egress Virtual Appliance IP.  It should be the IP address of the network virtual appliance.')
param egressVirtualApplianceIp string

// Hub IP Ranges
@description('Hub Virtual Network IP Address - RFC 1918')
param hubRFC1918IPRange string

@description('Hub Virtual Network IP Address - RFC 6598 (CGNAT)')
param hubRFC6598IPRange string

// Private DNS Zones
@description('Boolean flag to determine whether Private DNS Zones will be managed by Hub Network.')
param privateDnsManagedByHub bool = false

@description('Private DNS Zone Subscription Id.  Required when privateDnsManagedByHub=true')
param privateDnsManagedByHubSubscriptionId string = ''

@description('Private DNS Zone Resource Group Name.  Required when privateDnsManagedByHub=true')
param privateDnsManagedByHubResourceGroupName string = ''

// AKS version
@description('AKS Version.')
param aksVersion string

// Azure Key Vault
@description('Azure Key Vault Secret Expiry in days.')
param secretExpiryInDays int

// ML landing zone parameters - start
@description('Boolean flag to determine whether SQL Database is deployed or not.')
param deploySQLDB bool
@description('Boolean flag to determine whether SQL Managed Instance is deployed or not.')
param deploySQLMI bool

@description('SQL Database Username.  Required if deploySQLDB=true')
@secure()
param sqldbUsername string

@description('SQL MI Username.  Required if deploySQLMI=true')
@secure()
param sqlmiUsername string

@description('Boolean flag to determine whether customer managed keys are used.  Default:  false')
param useCMK bool = false

@description('Boolean flag to enable High Business Impact Azure Machine Learning Workspace.  Default: false')
param enableHbiWorkspace bool = false

/*
  Scaffold the subscription which includes:
    * Azure Security Center - Enable Azure Defender (all available options)
    * Azure Security Center - Configure Log Analytics Workspace
    * Azure Security Center - Configure Security Alert Contact
    * Role Assignments to Security Groups
    * Service Health Alerts
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

// Deploy Landing Zone
module landingZone 'lz.bicep' = {
  name: 'deploy-machinelearning-archetype'
  scope: subscription()
  params: {
    resourceTags: resourceTags
  
    securityContactEmail: securityContactEmail

    rgAutomationName: rgAutomationName
    rgNetworkWatcherName: rgNetworkWatcherName
    rgVnetName: rgVnetName
    rgComputeName: rgComputeName
    rgMonitorName: rgMonitorName
    rgSecurityName: rgSecurityName
    rgStorageName: rgStorageName

    automationAccountName: automationAccountName

    deploySQLDB: deploySQLDB
    deploySQLMI: deploySQLMI

    sqldbUsername: sqldbUsername
    sqlmiUsername: sqlmiUsername

    hubVnetId: hubVnetId
    egressVirtualApplianceIp: egressVirtualApplianceIp
    hubRFC6598IPRange: hubRFC6598IPRange
    hubRFC1918IPRange: hubRFC1918IPRange

    vnetName: vnetName
    vnetAddressSpace: vnetAddressSpace

    subnetFoundationalElementsName: subnetFoundationalElementsName
    subnetFoundationalElementsPrefix: subnetFoundationalElementsPrefix

    subnetPresentationName: subnetPresentationName
    subnetPresentationPrefix: subnetPresentationPrefix

    subnetApplicationName: subnetApplicationName
    subnetApplicationPrefix: subnetApplicationPrefix

    subnetDataName: subnetDataName
    subnetDataPrefix: subnetDataPrefix

    subnetDatabricksPrivateName: subnetDatabricksPrivateName
    subnetDatabricksPrivatePrefix: subnetDatabricksPrivatePrefix

    subnetDatabricksPublicName: subnetDatabricksPublicName
    subnetDatabricksPublicPrefix: subnetDatabricksPublicPrefix

    subnetSQLMIName: subnetSQLMIName
    subnetSQLMIPrefix: subnetSQLMIPrefix

    subnetPrivateEndpointsName: subnetPrivateEndpointsName
    subnetPrivateEndpointsPrefix: subnetPrivateEndpointsPrefix

    subnetAKSName: subnetAKSName
    subnetAKSPrefix: subnetAKSPrefix

    privateDnsManagedByHub: privateDnsManagedByHub
    privateDnsManagedByHubSubscriptionId: privateDnsManagedByHub ? privateDnsManagedByHubSubscriptionId : ''
    privateDnsManagedByHubResourceGroupName: privateDnsManagedByHub ? privateDnsManagedByHubResourceGroupName : ''

    aksVersion: aksVersion
    
    secretExpiryInDays: secretExpiryInDays

    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId

    useCMK: useCMK

    enableHbiWorkspace: enableHbiWorkspace
  }
}
