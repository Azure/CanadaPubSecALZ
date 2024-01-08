// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

@description('Location for the deployment.')
param location string = deployment().location

/*

This is a platform archetype to support deployment of Azure VWAN with Virtual HUBs.  
This archetype will provide:

* Feature1
* Feature2
* Feature2 (optional)

*/

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
//     },
//     "actionGroupName": "ALZ action group",
//     "actionGroupShortName": "alz-alert",
//     "alertRuleName": "ALZ alert rule",
//     "alertRuleDescription": "Alert rule for Azure Landing Zone"
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
//     comments: 'Built-In Contributor Role'
//     roleDefinitionId: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
//     securityGroupObjectIds: [
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
//   ISSO: 'isso-tag'
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
//   ClientOrganization: 'client-organization-tag'
//   CostCenter: 'cost-center-tag'
//   DataSensitivity: 'data-sensitivity-tag'
//   ProjectContact: 'project-contact-tag'
//   ProjectName: 'project-name-tag'
//   TechnicalContact: 'technical-contact-tag'
// }
@description('A set of key/value pairs of tags assigned to the resource group and resources.')
param resourceTags object

// central VWAN resource
@description('Reserved for description')
param VWAN object

// Virtual HUB resources
@description('Reserved for description')
param VirtualWanHUBs array

/*
  Scaffold the subscription which includes:
    * Role Assignments to Security Groups
    * Service Health Alerts
    * Subscription Budget
    * Subscription Tags
*/
module subScaffold '../scaffold-subscription.bicep' = {
  name: 'configure-subscription'
  scope: subscription()
  params: {
    location: location
    serviceHealthAlerts: serviceHealthAlerts
    subscriptionRoleAssignments: subscriptionRoleAssignments
    subscriptionBudget: subscriptionBudget
    subscriptionTags: subscriptionTags
    resourceTags: resourceTags
  }
}

// Create VWAN Resource Group
resource rgVWAN 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: VWAN.resourceGroupName
  location: location
  tags: resourceTags
}

// Create VWAN resource
module resVWAN 'vwan/vwan.bicep' = {
  name: 'deploy-vwan-${VWAN.name}'
  scope:  rgVWAN
  params:{
    name: VWAN.name
    location: rgVWAN.location
    tags:resourceTags
  }
}

//Create Virtual HUB resources
module resVHUB 'vwan/vhubs.bicep' = [for hub in VirtualWanHUBs: if (hub.DeployVWANHUB) {
  scope: rgVWAN
  name: 'deploy-vhub-${hub.VirtualWanHUBName}'
  params: {
    VirtualWanHUBName: hub.VirtualWanHUBName
    location: hub.HubLocation
    tags: resourceTags
    VWANId: resVWAN.outputs.resourceId
    VirtualHubAddressPrefix: hub.VirtualHubAddressPrefix
    HubRoutingPreference: hub.HubRoutingPreference
    VirtualRouterAutoScaleConfiguration: hub.VirtualRouterAutoScaleConfiguration
  }
}]

// Get built-in route tableIds
module builtInRouteTables 'vwan/defaultRouteTable.bicep' = [for (hub, i) in VirtualWanHUBs: if (hub.DeployVWANHUB) {
  scope: rgVWAN
  name: 'defaultRouteTable-${hub.HubLocation}-Ids'
  params: {
    hubName: hub.DeployVWANHUB ? resVHUB[i].outputs.resourceName : null
  }
}]

//Create ExpressRoute Gateways inside of the Virtual HUBs
module resERGateway 'vwan/ergw.bicep' = [for (hub, i) in VirtualWanHUBs: if ((hub.DeployVWANHUB) && (hub.ExpressRouteConfig.ExpressRouteGatewayEnabled)) {
  name: 'deploy-vhub-${hub.VirtualWanHUBName}-ergw'
  scope: rgVWAN
  params: {
    name: '${hub.VirtualWanHUBName}-ergw'
    tags: resourceTags
    vHUBId: hub.DeployVWANHUB ? resVHUB[i].outputs.resourceId : null
    location: hub.HubLocation
    scaleUnits: hub.ExpressRouteConfig.ExpressRouteGatewayScaleUnits
  }
}]

param SharedConnServicesNetwork object

// Create Shared Connectivity Services Resource Group for VNET
resource rgVNET 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: SharedConnServicesNetwork.resourceGroupName
  tags: resourceTags
  location: location
}

// Create & configure virtaual network - only if Virtual Network is being deployed
module vnet 'sharedservices/networking.bicep' = {
  name: 'deploy-networking'
  scope: resourceGroup(rgVNET.name)
  params: {
    SharedConnServicesNetwork: SharedConnServicesNetwork.network
    location: location
  }
}

//Connect Shared Connectivity Services VNET with First HUB
module vNetConn 'vwan/hubVirtualNetworkConnections.bicep' = {
  scope: rgVWAN
  name: 'deploy-vhub-connection'
  params: {
    vHubName: resVHUB[0].outputs.resourceName
    vHubConnName: '${vnet.outputs.vnetName}-to-${resVHUB[0].outputs.resourceName}'
    remoteVirtualNetworkId: vnet.outputs.vnetId
  }
}

// Create Bastion Resource Group
resource rgBastion 'Microsoft.Resources/resourceGroups@2020-06-01' = if (SharedConnServicesNetwork.bastion.enabled) {
  name: SharedConnServicesNetwork.bastion.resourceGroupName
  location: location
  tags: resourceTags
}

// Azure Bastion
module bastion '../../azresources/network/bastion.bicep' = if (SharedConnServicesNetwork.bastion.enabled) {
  name: 'deploy-bastion'
  scope: rgBastion
  params: {
    location: location
    name: SharedConnServicesNetwork.bastion.name
    sku: SharedConnServicesNetwork.bastion.sku
    scaleUnits: SharedConnServicesNetwork.bastion.scaleUnits
    subnetId: vnet.outputs.AzureBastionSubnetId
  }
}

// Create Bastion Resource Group
resource rgJumpbox 'Microsoft.Resources/resourceGroups@2020-06-01' = if (SharedConnServicesNetwork.jumpbox.enabled) {
  name: SharedConnServicesNetwork.jumpbox.resourceGroupName
  location: location
  tags: resourceTags
}

// Temporary VM Credentials
@description('Temporary username for firewall virtual machines.')
@secure()
param fwUsername string

@description('Temporary password for firewall virtual machines.')
@secure()
param fwPassword string

module jumpbox 'sharedservices/management-vm.bicep' = if (SharedConnServicesNetwork.jumpbox.enabled) {
  scope: rgJumpbox
  name: 'deploy-jumpbox'
  params: {
    location: location
    password: fwPassword
    subnetId: vnet.outputs.ManagementSubnetId
    username: fwUsername
    vmName: SharedConnServicesNetwork.jumpbox.name
    vmSize: SharedConnServicesNetwork.jumpbox.VMSize
  }
}

// Create Panorama Resource Group
resource rgPanorama 'Microsoft.Resources/resourceGroups@2020-06-01' = if (SharedConnServicesNetwork.panoramaA.enabled) {
  name: SharedConnServicesNetwork.panoramaA.resourceGroupName
  location: location
  tags: resourceTags
}

module availSet 'sharedservices/availset.bicep' = if (SharedConnServicesNetwork.panoramaA.enabled) {
  scope: rgPanorama
  name: 'deploy-panorama-avail'
  params: {
    name: 'panorama-avail'
    location: location
  }
}

module PanoramaA 'sharedservices/panorama-vm.bicep' = if (SharedConnServicesNetwork.panoramaA.enabled) {
  scope: rgPanorama
  name: 'deploy-panoramaA-VM'
  params: {
    location: rgPanorama.location
    availID: availSet.outputs.availID
    password: fwPassword
    subnetId: vnet.outputs.PanoramaSubnetId
    username: fwUsername
    vmName: SharedConnServicesNetwork.panoramaA.vmName
    vmSize: SharedConnServicesNetwork.panoramaA.vmSize
    privateIPAddress: SharedConnServicesNetwork.panoramaA.privateIPAddress
  }
}


module PanoramaB 'sharedservices/panorama-vm.bicep' = if (SharedConnServicesNetwork.panoramaB.enabled) {
  scope: rgPanorama
  name: 'deploy-panoramaB-VM'
  params: {
    location: rgPanorama.location
    availID: availSet.outputs.availID
    password: fwPassword
    subnetId: vnet.outputs.PanoramaSubnetId
    username: fwUsername
    vmName: SharedConnServicesNetwork.panoramaB.vmName
    vmSize: SharedConnServicesNetwork.panoramaB.vmSize
    privateIPAddress: SharedConnServicesNetwork.panoramaB.privateIPAddress
  }
}

