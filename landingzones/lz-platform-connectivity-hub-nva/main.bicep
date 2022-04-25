// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Location for the deployment.')
param location string = deployment().location

/*

Hub Networking with Fortigate Virtual Network Appliance archetype infrastructure to support Hub & Spoke network topology.  This archetype will provide:

* Azure Automation Account
* Azure Virtual Network (Hub)
* Azure Virtual Network (Management Restricted Zone) - used for management resources such as IaaS based Logging, Patch Management, etc.
* Two pairs of pay-as-you-go Fortigate Firewalls (one pair for development workload and another for production workload) - customer must configure the fortigate firewalls.
* Enables DDOS Standard (optional)
* Enables Azure Private DNS Zones (optional)
* Role-based access control for Owner, Contributor & Reader
* Integration with Azure Cost Management for Subscription-scoped budget
* Integration with Microsoft Defender for Cloud

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
//     },
//     "actionGroupName": "ALZ action group",
//     "actionGroupShortName": "alz-alert",
//     "alertRuleName": "ALZ alert rule",
//     "alertRuleDescription": "Alert rule for Azure Landing Zone"
//   }
// }
@description('Service Health alerts')
param serviceHealthAlerts object = {}

// Log Analytics
@description('Log Analytics Resource Id to integrate Microsoft Defender for Cloud.')
param logAnalyticsWorkspaceResourceId string

// Microsoft Defender for Cloud
// Example (JSON)
// -----------------------------
// "securityCenter": {
//   "value": {
//       "email": "alzcanadapubsec@microsoft.com",
//       "phone": "5555555555"
//   }
// }

// Example (Bicep)
// -----------------------------
// {
//   email: 'alzcanadapubsec@microsoft.com'
//   phone: '5555555555'
// }
@description('Microsoft Defender for Cloud configuration.  It includes email and phone.')
param securityCenter object

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

// Hub
@description('Hub configuration.  See docs/archetypes/hubnetwork-nva.md for configuration settings.')
param hub object

// Network Watcher
@description('Network Watcher configuration.  See docs/archetypes/hubnetwork-nva.md for configuration settings.')
param networkWatcher object

// Private Dns Zones
@description('Private DNS Zones configuration.  See docs/archetypes/hubnetwork-nva.md for configuration settings.')
param privateDnsZones object

// DDOS Standard
@description('DDOS Standard configuration.  See docs/archetypes/hubnetwork-nva.md for configuration settings.')
param ddosStandard object

// Public Access Zone
@description('Public Access Zone configuration.  See docs/archetypes/hubnetwork-nva.md for configuration settings.')
param publicAccessZone object

// Management Restricted Zone
@description('Management Restricted Zone configuration.  See docs/archetypes/hubnetwork-nva.md for configuration settings.')
param managementRestrictedZone object

// Temporary VM Credentials
@description('Temporary username for firewall virtual machines.')
@secure()
param fwUsername string

@description('Temporary password for firewall virtual machines.')
@secure()
param fwPassword string

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../config/telemetry.json'))
module telemetryCustomerUsageAttribution '../../azresources/telemetry/customer-usage-attribution-subscription.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.networking.nvaFortinet}'
}

/*
  Scaffold the subscription which includes:
    * Microsoft Defender for Cloud - Enable Azure Defender (all available options)
    * Microsoft Defender for Cloud - Configure Log Analytics Workspace
    * Microsoft Defender for Cloud - Configure Security Alert Contact
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

    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    securityCenter: securityCenter
  }
}

// Create Network Watcher Resource Group
resource rgNetworkWatcher 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: networkWatcher.resourceGroupName
  location: location
  tags: resourceTags
}

// Create Private DNS Zone Resource Group - optional
resource rgPrivateDnsZones 'Microsoft.Resources/resourceGroups@2020-06-01' = if (privateDnsZones.enabled) {
  name: privateDnsZones.resourceGroupName
  location: location
  tags: resourceTags
}

// Create Azure DDOS Standard Resource Group - optional
resource rgDdos 'Microsoft.Resources/resourceGroups@2020-06-01' = if (ddosStandard.enabled) {
  name: ddosStandard.resourceGroupName
  location: location
  tags: resourceTags
}

// Create Hub Virtual Network Resource Group
resource rgHubVnet 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: hub.resourceGroupName
  location: location
  tags: resourceTags
}

// Enable delete locks
module rgDdosDeleteLock '../../azresources/util/delete-lock.bicep' = if (ddosStandard.enabled) {
  name: 'deploy-delete-lock-${ddosStandard.resourceGroupName}'
  scope: rgDdos
}

module rgHubDeleteLock '../../azresources/util/delete-lock.bicep' = {
  name: 'deploy-delete-lock-${hub.resourceGroupName}'
  scope: rgHubVnet
}

// DDOS Standard - optional
module ddosPlan '../../azresources/network/ddos-standard.bicep' = if (ddosStandard.enabled) {
  name: 'deploy-ddos-standard-plan'
  scope: rgDdos
  params: {
    name: ddosStandard.planName
    location: location
  }
}

// Route Tables
var defaultRoutes = [
  {
    name: 'Hub-NVA-Default-Route'
    properties: {
      nextHopType: 'VirtualAppliance'
      addressPrefix: '0.0.0.0/0'
      nextHopIpAddress: hub.nvafirewall.production.internalLoadBalancer.internalIp
    }
  }
]

var routesFromAddressPrefixes = [for addressPrefix in hub.network.addressPrefixes: {
    name: 'Hub-NVA-${replace(replace(addressPrefix, '.', '-'), '/', '-')}'
    properties: {
      nextHopType: 'VirtualAppliance'
      addressPrefix: addressPrefix
      nextHopIpAddress: hub.nvafirewall.production.internalLoadBalancer.internalIp
    }
}]

var routes = union(defaultRoutes, routesFromAddressPrefixes)

module udrPrdSpokes '../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-PrdSpokesUdr'
  scope: rgHubVnet
  params: {
    location: location
    name: 'PrdSpokesUdr'
    routes: routes
  }
}

module managementRestrictedZoneUdr '../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-MrzSpokeUdr'
  scope: rgHubVnet
  params: {
    location: location
    name: 'MrzSpokeUdr'
    routes: routes
  }
}

module udrPaz '../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-PazSubnetUdr'
  scope: rgHubVnet
  params: {
    location: location
    name: 'PazSubnetUdr'
    routes: [for addressPrefix in managementRestrictedZone.network.addressPrefixes: {
      name: 'PazSubnetUdrMrzFWRoute-${replace(replace(addressPrefix, '.', '-'), '/', '-')}'
      properties: {
        addressPrefix: addressPrefix
        nextHopType: 'VirtualAppliance'
        nextHopIpAddress: hub.nvafirewall.production.internalLoadBalancer.externalIp
      }
    }]
  }
}

// Hub Virtual Network
module hubVnet 'hub/hub-vnet.bicep' = {
  name: 'deploy-hub-vnet-${hub.network.name}'
  scope: rgHubVnet
  params: {
    location: location

    hubNetwork: hub.network
    pazUdrId: udrPaz.outputs.udrId

    ddosStandardPlanId: ddosStandard.enabled ? ddosPlan.outputs.ddosPlanId : ''
  }
}

// Private DNS Zones - optional
module privatelinkDnsZones '../../azresources/network/private-dns-zone-privatelinks.bicep' = if (privateDnsZones.enabled) {
  name: 'deploy-privatelink-private-dns-zones'
  scope: rgPrivateDnsZones
  params: {
    vnetId: hubVnet.outputs.vnetId
    dnsCreateNewZone: true
    dnsLinkToVirtualNetwork: true

    // Not required since the private dns zones will be created and linked to hub virtual network.
    dnsExistingZoneSubscriptionId: ''
    dnsExistingZoneResourceGroupName: ''
  }
}

// Azure Bastion
module bastion '../../azresources/network/bastion.bicep' = if (hub.bastion.enabled) {
  name: 'deploy-bastion'
  scope: rgHubVnet
  params: {
    location: location
    name: hub.bastion.name
    sku: hub.bastion.sku
    scaleUnits: hub.bastion.scaleUnits
    subnetId: hubVnet.outputs.AzureBastionSubnetId
  }
}

// Non production traffic - NVAs
module nonProductionNVA 'nva/nva-vm.bicep' = [for (virtualMachine, virtualMachines) in hub.nvafirewall.nonProduction.virtualMachines: {
  name: 'deploy-nva-nonprod-${virtualMachine.name}'
  scope: rgHubVnet
  params: {
    location: location

    vmImageOffer: hub.nvaFirewall.image.offer
    vmImagePublisher: hub.nvaFirewall.image.publisher
    vmImageSku: hub.nvaFirewall.image.sku
    vmImageVersion: hub.nvaFirewall.image.version
    vmImagePlanName: hub.nvaFirewall.image.plan

    vmName: virtualMachine.name
    vmSku: virtualMachine.vmSku
    availabilityZone: virtualMachine.availabilityZone

    nic1PrivateIP: virtualMachine.externalIp
    nic1SubnetId: hubVnet.outputs.PublicSubnetId

    nic2PrivateIP: virtualMachine.mrzInternalIp
    nic2SubnetId: hubVnet.outputs.MrzIntSubnetId

    nic3PrivateIP: virtualMachine.internalIp
    nic3SubnetId: hubVnet.outputs.NonProdIntSubnetId

    nic4PrivateIP: virtualMachine.highAvailabilityIp
    nic4SubnetId: hubVnet.outputs.HASubnetId

    username: fwUsername
    password: fwPassword
  }
}]

// Non-Production traffic - Internal Load Balancer
module nonProductionNVA_ILB 'hub/lb-firewalls-hub.bicep' = {
  name: 'deploy-internal-loadblancer-nonprod-ilb'
  scope: rgHubVnet
  params: {
    location: location

    name: hub.nvafirewall.nonProduction.internalLoadBalancer.name

    backendVnetId: hubVnet.outputs.vnetId

    frontendSubnetIdInt: hubVnet.outputs.NonProdIntSubnetId
    frontendSubnetIdExt: hubVnet.outputs.PublicSubnetId

    frontendIPInt: hub.nvafirewall.nonProduction.internalLoadBalancer.internalIp
    frontendIPExt: hub.nvafirewall.nonProduction.internalLoadBalancer.externalIp
   
    lbProbeTcpName: hub.nvafirewall.nonProduction.internalLoadBalancer.tcpProbe.name
    lbProbeTcpPort: hub.nvafirewall.nonProduction.internalLoadBalancer.tcpProbe.port
    lbProbeTcpIntervalInSeconds: hub.nvafirewall.nonProduction.internalLoadBalancer.tcpProbe.intervalInSeconds
    lbProbeTcpNumberOfProbes: hub.nvafirewall.nonProduction.internalLoadBalancer.tcpProbe.numberOfProbes

    configureEmptyBackendPool: !hub.nvafirewall.nonProduction.deployVirtualMachines || length(hub.nvafirewall.nonProduction.virtualMachines) == 0
    backendPoolVirtualMachines: hub.nvafirewall.nonProduction.virtualMachines
  }
}

// Production traffic - NVAs
module productionNVA 'nva/nva-vm.bicep' = [for (virtualMachine, virtualMachines) in hub.nvafirewall.production.virtualMachines: {
  name: 'deploy-nva-prod-${virtualMachine.name}'
  scope: rgHubVnet
  params: {
    location: location

    vmImageOffer: hub.nvaFirewall.image.offer
    vmImagePublisher: hub.nvaFirewall.image.publisher
    vmImageSku: hub.nvaFirewall.image.sku
    vmImageVersion: hub.nvaFirewall.image.version
    vmImagePlanName: hub.nvaFirewall.image.plan

    vmName: virtualMachine.name
    vmSku: virtualMachine.vmSku
    availabilityZone: virtualMachine.availabilityZone

    nic1PrivateIP: virtualMachine.externalIp
    nic1SubnetId: hubVnet.outputs.PublicSubnetId

    nic2PrivateIP: virtualMachine.mrzInternalIp
    nic2SubnetId: hubVnet.outputs.MrzIntSubnetId

    nic3PrivateIP: virtualMachine.internalIp
    nic3SubnetId: hubVnet.outputs.ProdIntSubnetId

    nic4PrivateIP: virtualMachine.highAvailabilityIp
    nic4SubnetId: hubVnet.outputs.HASubnetId

    username: fwUsername
    password: fwPassword
  }
}]

// Production traffic - Internal Load Balancer
module productionNVA_ILB 'hub/lb-firewalls-hub.bicep' = {
  name: 'deploy-internal-loadblancer-prod-ilb'
  scope: rgHubVnet
  params: {
    location: location

    name: hub.nvafirewall.production.internalLoadBalancer.name

    backendVnetId: hubVnet.outputs.vnetId

    frontendSubnetIdInt: hubVnet.outputs.ProdIntSubnetId
    frontendSubnetIdExt: hubVnet.outputs.PublicSubnetId

    frontendIPInt: hub.nvafirewall.production.internalLoadBalancer.internalIp
    frontendIPExt: hub.nvafirewall.production.internalLoadBalancer.externalIp
   
    lbProbeTcpName: hub.nvafirewall.production.internalLoadBalancer.tcpProbe.name
    lbProbeTcpPort: hub.nvafirewall.production.internalLoadBalancer.tcpProbe.port
    lbProbeTcpIntervalInSeconds: hub.nvafirewall.production.internalLoadBalancer.tcpProbe.intervalInSeconds
    lbProbeTcpNumberOfProbes: hub.nvafirewall.production.internalLoadBalancer.tcpProbe.numberOfProbes

    configureEmptyBackendPool: !hub.nvafirewall.production.deployVirtualMachines || length(hub.nvafirewall.production.virtualMachines) == 0
    backendPoolVirtualMachines: hub.nvafirewall.production.virtualMachines
  }
}

// Management Restricted Zone
module mrz 'mrz/mrz.bicep' = if (managementRestrictedZone.enabled) {
  name: 'deploy-management-restricted-zone'
  scope: subscription()
  params: {
    location: location
    resourceTags: resourceTags
    
    ddosStandardPlanId: ddosStandard.enabled ? ddosPlan.outputs.ddosPlanId : ''

    hubResourceGroup: rgHubVnet.name
    hubVnetName: hubVnet.outputs.vnetName
    hubVnetId: hubVnet.outputs.vnetId

    managementRestrictedZone: managementRestrictedZone
    managementRestrictedZoneUdrId: managementRestrictedZoneUdr.outputs.udrId
  }
}

// Public Access Zone
module paz 'paz/paz.bicep' = if (publicAccessZone.enabled) {
  name: 'deploy-public-access-zone'
  scope: subscription()
  params: {
    location: location
    resourceTags: resourceTags

    publicAccessZone: publicAccessZone
  }
}
