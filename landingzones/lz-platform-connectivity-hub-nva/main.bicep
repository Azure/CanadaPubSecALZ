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

// Network Watcher
@description('Azure Network Watcher Resource Group Name.  Default: NetworkWatcherRG')
param rgNetworkWatcherName string = 'NetworkWatcherRG'

// Private Dns Zones
@description('Boolean flag to determine whether Private DNS Zones will be centrally managed in the Hub.')
param deployPrivateDnsZones bool

@description('Private DNS Zone Resource Group Name.')
param rgPrivateDnsZonesName string

// DDOS Standard
@description('Boolean flag to determine whether to deploy Azure DDOS Standard.')
param deployDdosStandard bool

@description('Azure DDOS Standard Resource Group.')
param rgDdosName string

@description('Azure DDOS Standard Plan Name.')
param ddosPlanName string

// Hub Virtual Network
@description('Hub Virtual Network Resource Group Name.')
param rgHubName string //= 'pubsecPrdHubPbRsg'

@description('Hub Virtual Network Name.')
param hubVnetName string //= 'pubsecHubVnet'

@description('Hub Virtual Network address space for RFC 1918.')
param hubVnetAddressPrefixRFC1918 string //= '10.18.0.0/22'

@description('Hub Virtual Network address space for RFC 6598 (CGNAT).')
param hubVnetAddressPrefixRFC6598 string //= '100.60.0.0/16'

@description('Hub Virtual Network address space for Azure Bastion (must be RFC 1918).')
param hubVnetAddressPrefixBastion string //= '192.168.0.0/16'

@description('Hub - Enternal Access Network Subnet Name.')
param hubEanSubnetName string //= 'EanSubnet'

@description('Hub - Enternal Access Network Subnet Address Prefix (based on RFC 1918).')
param hubEanSubnetAddressPrefix string //= '10.18.0.0/27'

@description('Hub - Public Subnet Name.')
param hubPublicSubnetName string //= 'PublicSubnet

@description('Hub - Public Subnet Address Prefix (based on RFC 6598).')
param hubPublicSubnetAddressPrefix string //= '100.60.0.0/24'

@description('Hub - Public Access Zone Subnet Name.')
param hubPazSubnetName string //= 'PAZSubnet'

@description('Hub - Public Access Zone Subnet Name (based on RFC 6598).')
param hubPazSubnetAddressPrefix string //= '100.60.1.0/24'

@description('Hub - Non-Production Internal Subnet Name.')
param hubDevIntSubnetName string //= 'DevIntSubnet'

@description('Hub - Non-Production Internal Subnet Address Prefix (based on RFC 1918).')
param hubDevIntSubnetAddressPrefix string //= '10.18.0.64/27'

@description('Hub - Production Internal Subnet Name.')
param hubProdIntSubnetName string //= 'PrdIntSubnet'

@description('Hub - Production Internal Subnet Address Prefix (based on RFC 1918).')
param hubProdIntSubnetAddressPrefix string //= '10.18.0.32/27'

@description('Hub - Management Resctricted Zone Subnet Name.')
param hubMrzIntSubnetName string //= 'MrzSubnet'

@description('Hub - Management Resctricted Zone Subnet Address Prefix (based on RFC 1918).')
param hubMrzIntSubnetAddressPrefix string //= '10.18.0.96/27'

@description('Hub - Firewall High Availability Subnet Name.')
param hubHASubnetName string //= 'HASubnet'

@description('Hub - Firewall High Availability Subnet Address Prefix (based on RFC 1918).')
param hubHASubnetAddressPrefix string //= '10.18.0.128/28'

@description('Hub - Virtual Network Gateway Subnet Address Prefix (based on RFC 1918).')
param hubGatewaySubnetPrefix string //= '10.18.1.0/27'

@description('Hub - Azure Bastion Name.')
param bastionName string //= 'pubsecHubBastion'

@description('Hub - Azure Bastion SKU.')
@allowed([
  'Basic'
  'Standard'
])
param bastionSku string

@description('Azure Bastion Scale Units (2 to 50).  Required for Standard SKU.  Set to any number in min/max for Basic SKU as it is ignored.')
@minValue(2)
@maxValue(50)
param bastionScaleUnits int

@description('Hub - Azure Bastion Address Prefix (based on RFC 1918 and must be placed in the Azure Bastion Address Space).')
param hubBastionSubnetAddressPrefix string //= '192.168.0.0/24'

// Firewall Virtual Appliances
@description('Boolean flag to determine whether virtual machines will be deployed, either Ubuntu (for internal testing) or Fortinet (for workloads).  Default: true')
param deployFirewallVMs bool = true

@description('Boolean flag to determine whether Fortinet firewalls will be deployed.  Default: true')
param useFortigateFW bool = true

// Firewall Virtual Appliances - For Non-production Traffic
@description('Non-production NVA - Internal Load Balancer Name.')
param fwDevILBName string //= 'pubsecDevFWs_ILB'

@description('Non-production NVA - VM SKU.')
param fwDevVMSku string //= 'Standard_D8s_v4' //ensure it can have 4 nics

@description('Non-production NVA - VM #1 Name.')
param fwDevVM1Name string //= 'pubsecDevFW1'

@description('Non-production NVA - VM #2 Name.')
param fwDevVM2Name string //= 'pubsecDevFW2'

@description('Non-production NVA - Internal Load Balancer External Facing IP (based on RFC 6598).')
param fwDevILBExternalFacingIP string //= '100.60.0.7'

@description('Non-production NVA - VM #1 External Facing IP (based on RFC 6598).')
param fwDevVM1ExternalFacingIP string //= '100.60.0.8'

@description('Non-production NVA - VM #2 External Facing IP (based on RFC 6598).')
param fwDevVM2ExternalFacingIP string //= '100.60.0.9'

@description('Non-production NVA - VM #1 Management Restricted Zone IP (based on RFC 1918).')
param fwDevVM1MrzIntIP string //= '10.18.0.104'

@description('Non-production NVA - VM #2 Management Restricted Zone IP (based on RFC 1918).')
param fwDevVM2MrzIntIP string //= '10.18.0.105'

@description('Non-production NVA - Internal Load Balancer IP (based on RFC 1918).')
param fwDevILBDevIntIP string //= '10.18.0.68'

@description('Non-production NVA - VM #1 IP (based on RFC 1918).')
param fwDevVM1DevIntIP string //= '10.18.0.69'

@description('Non-production NVA - VM #2 IP (based on RFC 1918).')
param fwDevVM2DevIntIP string //= '10.18.0.70'

@description('Non-production NVA - VM #1 High Availability IP (based on RFC 1918).')
param fwDevVM1HAIP string //= '10.18.0.134'

@description('Non-production NVA - VM #2 High Availability IP (based on RFC 1918).')
param fwDevVM2HAIP string //= '10.18.0.135'

@description('Non-production NVA - VM #1 Availability Zone. Default: 2')
param fwDevVM1AvailabilityZone string = '2'

@description('Non-production NVA - VM #2 Availability Zone. Default: 3')
param fwDevVM2AvailabilityZone string = '3'

// Firewall Virtual Appliances - For Production Traffic
@description('Production NVA - Internal Load Balancer Name.')
param fwProdILBName string //= 'pubsecProdFWs_ILB'

@description('Production NVA - VM SKU.')
param fwProdVMSku string //= 'Standard_F8s_v2' //ensure it can have 4 nics

@description('Production NVA - VM #1 Name.')
param fwProdVM1Name string //= 'pubsecProdFW1'

@description('Production NVA - VM #2 Name.')
param fwProdVM2Name string //= 'pubsecProdFW2'

@description('Production NVA - Internal Load Balancer External Facing IP (based on RFC 6598).')
param fwProdILBExternalFacingIP string //= '100.60.0.4'

@description('Production NVA - VM #1 External Facing IP (based on RFC 6598).')
param fwProdVM1ExternalFacingIP string //= '100.60.0.5'

@description('Production NVA - VM #2 External Facing IP (based on RFC 6598).')
param fwProdVM2ExternalFacingIP string //= '100.60.0.6'

@description('Production NVA - VM #1 Management Restricted Zone IP (based on RFC 1918).')
param fwProdVM1MrzIntIP string //= '10.18.0.101'

@description('Production NVA - VM #2 Management Restricted Zone IP (based on RFC 1918).')
param fwProdVM2MrzIntIP string //= '10.18.0.102'

@description('Production NVA - Internal Load Balancer IP (based on RFC 1918).')
param fwProdILBPrdIntIP string //= '10.18.0.36'

@description('Production NVA - VM #1 IP (based on RFC 1918).')
param fwProdVM1PrdIntIP string //= '10.18.0.37'

@description('Production NVA - VM #2 IP (based on RFC 1918).')
param fwProdVM2PrdIntIP string //= '10.18.0.38'

@description('Production NVA - VM #1 High Availability IP (based on RFC 1918).')
param fwProdVM1HAIP string //= '10.18.0.132'

@description('Production NVA - VM #2 High Availability IP (based on RFC 1918).')
param fwProdVM2HAIP string //= '10.18.0.133'

@description('Production NVA - VM #1 Availability Zone.  Default: 1')
param fwProdVM1AvailabilityZone string = '1'

@description('Production NVA - VM #2 Availability Zone.  Default: 2')
param fwProdVM2AvailabilityZone string = '2'

// Management Restricted Zone Virtual Network
@description('Management Restricted Zone - Resource Group Name.')
param rgMrzName string //= 'pubsecPrdMrzPbRsg'

@description('Management Restricted Zone - Virtual Network Name.')
param mrzVnetName string //= 'pubsecMrzVnet'

@description('Management Restricted Zone - Virtual Network Address Space.')
param mrzVnetAddressPrefixRFC1918 string //= '10.18.4.0/22'

@description('Management Restricted Zone - Management (Access Zone) Subnet Name.')
param mrzMazSubnetName string //= 'MazSubnet'

@description('Management Restricted Zone - Management (Access Zone) Subnet Address Prefix.')
param mrzMazSubnetAddressPrefix string //= '10.18.4.0/25'

@description('Management Restricted Zone - Infrastructure Services (Restricted Zone) Subnet Name.')
param mrzInfSubnetName string //= 'InfSubnet'

@description('Management Restricted Zone - Infrastructure Services (Restricted Zone) Subnet Address Prefix.')
param mrzInfSubnetAddressPrefix string //= '10.18.4.128/25'

@description('Management Restricted Zone - Security Services (Restricted Zone) Subnet Name.')
param mrzSecSubnetName string //= 'SecSubnet'

@description('Management Restricted Zone - Security Services (Restricted Zone) Subnet Address Prefix.')
param mrzSecSubnetAddressPrefix string //= '10.18.5.0/26'

@description('Management Restricted Zone - Logging Services (Restricted Zone) Subnet Name.')
param mrzLogSubnetName string //= 'LogSubnet'

@description('Management Restricted Zone - Loggin Services (Restricted Zone) Subnet Address Prefix.')
param mrzLogSubnetAddressPrefix string //= '10.18.5.64/26'

@description('Management Restricted Zone - Core Management Interfaces (Restricted Zone) Subnet Name.')
param mrzMgmtSubnetName string //= 'MgmtSubnet'

@description('Management Restricted Zone - Core Management Interfaces (Restricted Zone) Subnet Address Prefix.')
param mrzMgmtSubnetAddressPrefix string //= '10.18.5.128/26'

// Public Access Zone
@description('Public Access Zone Resource Group Name.')
param rgPazName string //= 'pubsecPazPbRsg'

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
  name: rgNetworkWatcherName
  location: location
  tags: resourceTags
}

// Create Private DNS Zone Resource Group - optional
resource rgPrivateDnsZones 'Microsoft.Resources/resourceGroups@2020-06-01' = if (deployPrivateDnsZones) {
  name: rgPrivateDnsZonesName
  location: location
  tags: resourceTags
}

// Create Azure DDOS Standard Resource Group - optional
resource rgDdos 'Microsoft.Resources/resourceGroups@2020-06-01' = if (deployDdosStandard) {
  name: rgDdosName
  location: location
  tags: resourceTags
}

// Create Hub Virtual Network Resource Group
resource rgHubVnet 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgHubName
  location: location
  tags: resourceTags
}

// Create Managemend Restricted Virtual Network Resource Group
resource rgMrzVnet 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgMrzName
  location: location
  tags: resourceTags
}

// Create Public Access Zone Resource Group
resource rgPaz 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgPazName
  location: location
  tags: resourceTags
}

// Enable delete locks
module rgDdosDeleteLock '../../azresources/util/delete-lock.bicep' = if (deployDdosStandard) {
  name: 'deploy-delete-lock-${rgDdosName}'
  scope: rgDdos
}

module rgHubDeleteLock '../../azresources/util/delete-lock.bicep' = {
  name: 'deploy-delete-lock-${rgHubName}'
  scope: rgHubVnet
}

module rgMrzDeleteLock '../../azresources/util/delete-lock.bicep' = {
  name: 'deploy-delete-lock-${rgMrzName}'
  scope: rgMrzVnet
}

module rgPazDeleteLock '../../azresources/util/delete-lock.bicep' = {
  name: 'deploy-delete-lock-${rgPazName}'
  scope: rgPaz
}

// DDOS Standard - optional
module ddosPlan '../../azresources/network/ddos-standard.bicep' = if (deployDdosStandard) {
  name: 'deploy-ddos-standard-plan'
  scope: rgDdos
  params: {
    name: ddosPlanName
    location: location
  }
}

// Route Tables
module udrPrdSpokes '../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-PrdSpokesUdr'
  scope: rgHubVnet
  params: {
    location: location
    name: 'PrdSpokesUdr'
    routes: [
      {
        name: 'default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwProdILBPrdIntIP
        }
      }
      // Force Routes to Hub IPs (RFC1918 range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubRFC1918FWRoute'
        properties: {
          addressPrefix: hubVnetAddressPrefixRFC1918
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwProdILBPrdIntIP
        }
      }
      // Force Routes to Hub IPs (CGNAT range) via FW despite knowing that route via peering
      {
        name: 'PrdSpokesUdrHubRFC6598FWRoute'
        properties: {
          addressPrefix: hubVnetAddressPrefixRFC6598
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwProdILBPrdIntIP
        }
      }
    ]
  }
}

module udrMrzSpoke '../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-MrzSpokeUdr'
  scope: rgHubVnet
  params: {
    location: location
    name: 'MrzSpokeUdr'
    routes: [
      {
        name: 'RouteToEgressFirewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwProdILBPrdIntIP
        }
      }
      // Force Routes to Hub IPs (RFC1918 range) via FW despite knowing that route via peering
      {
        name: 'MrzSpokeUdrHubRFC1918FWRoute'
        properties: {
          addressPrefix: hubVnetAddressPrefixRFC1918
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwProdILBPrdIntIP
        }
      }
      // Force Routes to Hub IPs (CGNAT range) via FW despite knowing that route via peering
      {
        name: 'MrzSpokeUdrHubRFC6598FWRoute'
        properties: {
          addressPrefix: hubVnetAddressPrefixRFC6598
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwProdILBPrdIntIP
        }
      }
    ]
  }
}

module udrPaz '../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-PazSubnetUdr'
  scope: rgHubVnet
  params: {
    location: location
    name: 'PazSubnetUdr'
    routes: [
      {
        name: 'PazSubnetUdrMrzFWRoute'
        properties: {
          addressPrefix: mrzVnetAddressPrefixRFC1918
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwProdILBExternalFacingIP
        }
      }
    ]
  }
}

// Hub Virtual Network
module hubVnet 'hub-vnet/hub-vnet.bicep' = {
  name: 'deploy-hub-vnet-${hubVnetName}'
  scope: rgHubVnet
  params: {
    location: location

    vnetName: hubVnetName
    vnetAddressPrefixRFC1918: hubVnetAddressPrefixRFC1918
    vnetAddressPrefixRFC6598: hubVnetAddressPrefixRFC6598
    vnetAddressPrefixBastion: hubVnetAddressPrefixBastion

    publicSubnetName: hubPublicSubnetName
    publicSubnetAddressPrefix: hubPublicSubnetAddressPrefix

    mrzIntSubnetName: hubMrzIntSubnetName
    mrzIntSubnetAddressPrefix: hubMrzIntSubnetAddressPrefix

    prodIntSubnetName: hubProdIntSubnetName
    prodIntSubnetAddressPrefix: hubProdIntSubnetAddressPrefix

    devIntSubnetName: hubDevIntSubnetName
    devIntSubnetAddressPrefix: hubDevIntSubnetAddressPrefix

    haSubnetName: hubHASubnetName
    haSubnetAddressPrefix: hubHASubnetAddressPrefix

    pazSubnetName: hubPazSubnetName
    pazSubnetAddressPrefix: hubPazSubnetAddressPrefix
    pazUdrId: udrPaz.outputs.udrId

    eanSubnetName: hubEanSubnetName
    eanSubnetAddressPrefix: hubEanSubnetAddressPrefix

    gatewaySubnetAddressPrefix: hubGatewaySubnetPrefix

    bastionSubnetAddressPrefix: hubBastionSubnetAddressPrefix

    ddosStandardPlanId: deployDdosStandard ? ddosPlan.outputs.ddosPlanId : ''
  }
}

// Management Restricted Virtual Network
module mrzVnet 'mrz-vnet/mrz-vnet.bicep' = {
  name: 'deploy-management-vnet-${mrzVnetName}'
  scope: rgMrzVnet
  params: {
    location: location
    
    vnetName: mrzVnetName
    vnetAddressPrefix: mrzVnetAddressPrefixRFC1918

    mazSubnetName: mrzMazSubnetName
    mazSubnetAddressPrefix: mrzMazSubnetAddressPrefix
    mazSubnetUdrId: udrMrzSpoke.outputs.udrId

    infSubnetName: mrzInfSubnetName
    infSubnetAddressPrefix: mrzInfSubnetAddressPrefix
    infSubnetUdrId: udrMrzSpoke.outputs.udrId

    secSubnetName: mrzSecSubnetName
    secSubnetAddressPrefix: mrzSecSubnetAddressPrefix
    secSubnetUdrId: udrMrzSpoke.outputs.udrId

    logSubnetName: mrzLogSubnetName
    logSubnetAddressPrefix: mrzLogSubnetAddressPrefix
    logSubnetUdrId: udrMrzSpoke.outputs.udrId

    mgmtSubnetName: mrzMgmtSubnetName
    mgmtSubnetAddressPrefix: mrzMgmtSubnetAddressPrefix
    mgmtSubnetUdrId: udrMrzSpoke.outputs.udrId

    ddosStandardPlanId: deployDdosStandard ? ddosPlan.outputs.ddosPlanId : ''
  }
}

// Private DNS Zones - optional
module privatelinkDnsZones '../../azresources/network/private-dns-zone-privatelinks.bicep' = if (deployPrivateDnsZones) {
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

// Virtual Network Peering - Management Restricted Zone to Hub
module vnetPeeringSpokeToHub '../../azresources/network/vnet-peering.bicep' = {
  name: 'deploy-vnet-peering-spoke-to-hub'
  scope: rgMrzVnet
  params: {
    peeringName: '${mrzVnet.outputs.vnetName}-to-${hubVnet.outputs.vnetName}'
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    sourceVnetName: mrzVnet.outputs.vnetName
    targetVnetId: hubVnet.outputs.vnetId
    useRemoteGateways: false //to be changed once we have ExpressRoute or VPN GWs 
  }
}

// Virtual Network Peering - Hub to Management Restricted Zone
module vnetPeeringHubToSpoke '../../azresources/network/vnet-peering.bicep' = {
  name: 'deploy-vnet-peering-hub-to-spoke'
  scope: rgHubVnet
  params: {
    peeringName: '${hubVnet.outputs.vnetName}-to-${mrzVnet.outputs.vnetName}'
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    sourceVnetName: hubVnet.outputs.vnetName
    targetVnetId: mrzVnet.outputs.vnetId
    useRemoteGateways: false
  }
}

// Azure Bastion
module bastion '../../azresources/network/bastion.bicep' = {
  name: 'deploy-bastion'
  scope: rgHubVnet
  params: {
    location: location
    name: bastionName
    sku: bastionSku
    scaleUnits: bastionScaleUnits
    subnetId: hubVnet.outputs.AzureBastionSubnetId
  }
}

// Production traffic - Fortinet Firewall VM
module ProdFW1_fortigate 'nva/fortinet-vm.bicep' = if (deployFirewallVMs && useFortigateFW) {
  name: 'deploy-nva-ProdFW1_fortigate'
  scope: rgHubVnet
  params: {
    location: location

    availabilityZone: '1' //make it a parameter with a default value (in the params.json file)
    vmName: fwProdVM1Name
    vmSku: fwProdVMSku
    nic1PrivateIP: fwProdVM1ExternalFacingIP
    nic1SubnetId: hubVnet.outputs.PublicSubnetId
    nic2PrivateIP: fwProdVM1MrzIntIP
    nic2SubnetId: hubVnet.outputs.MrzIntSubnetId
    nic3PrivateIP: fwProdVM1PrdIntIP
    nic3SubnetId: hubVnet.outputs.PrdIntSubnetId
    nic4PrivateIP: fwProdVM1HAIP
    nic4SubnetId: hubVnet.outputs.HASubnetId
    username: fwUsername
    password: fwPassword
  }
}

// Production traffic - Ubuntu Firewall VM
module ProdFW1_ubuntu 'nva/ubuntu-fw-vm.bicep' = if (deployFirewallVMs && !useFortigateFW) {
  name: 'deploy-nva-ProdFW1_ubuntu'
  scope: rgHubVnet
  params: {
    location: location

    availabilityZone: fwProdVM1AvailabilityZone //make it a parameter with a default value (in the params.json file)
    vmName: fwProdVM1Name
    vmSku: fwProdVMSku
    nic1PrivateIP: fwProdVM1ExternalFacingIP
    nic1SubnetId: hubVnet.outputs.PublicSubnetId
    nic2PrivateIP: fwProdVM1MrzIntIP
    nic2SubnetId: hubVnet.outputs.MrzIntSubnetId
    nic3PrivateIP: fwProdVM1PrdIntIP
    nic3SubnetId: hubVnet.outputs.PrdIntSubnetId
    nic4PrivateIP: fwProdVM1HAIP
    nic4SubnetId: hubVnet.outputs.HASubnetId
    username: fwUsername
    password: fwPassword
  }
}

// Production traffic - Fortinet Firewall VM
module ProdFW2_fortigate 'nva/fortinet-vm.bicep' = if (deployFirewallVMs && useFortigateFW) {
  name: 'deploy-nva-ProdFW2_fortigate'
  scope: rgHubVnet
  params: {
    location: location

    availabilityZone: fwProdVM2AvailabilityZone
    vmName: fwProdVM2Name
    vmSku: fwProdVMSku
    nic1PrivateIP: fwProdVM2ExternalFacingIP
    nic1SubnetId: hubVnet.outputs.PublicSubnetId
    nic2PrivateIP: fwProdVM2MrzIntIP
    nic2SubnetId: hubVnet.outputs.MrzIntSubnetId
    nic3PrivateIP: fwProdVM2PrdIntIP
    nic3SubnetId: hubVnet.outputs.PrdIntSubnetId
    nic4PrivateIP: fwProdVM2HAIP
    nic4SubnetId: hubVnet.outputs.HASubnetId
    username: fwUsername
    password: fwPassword
  }
}

// Production traffic - Ubuntu Firewall VM
module ProdFW2_ubuntu 'nva/ubuntu-fw-vm.bicep' = if (deployFirewallVMs && !useFortigateFW) {
  name: 'deploy-nva-ProdFW2_ubuntu'
  scope: rgHubVnet
  params: {
    location: location

    availabilityZone: '2'
    vmName: fwProdVM2Name
    vmSku: fwProdVMSku
    nic1PrivateIP: fwProdVM2ExternalFacingIP
    nic1SubnetId: hubVnet.outputs.PublicSubnetId
    nic2PrivateIP: fwProdVM2MrzIntIP
    nic2SubnetId: hubVnet.outputs.MrzIntSubnetId
    nic3PrivateIP: fwProdVM2PrdIntIP
    nic3SubnetId: hubVnet.outputs.PrdIntSubnetId
    nic4PrivateIP: fwProdVM2HAIP
    nic4SubnetId: hubVnet.outputs.HASubnetId
    username: fwUsername
    password: fwPassword
  }
}

// Non-Production traffic - Fortinet Firewall VM
module DevFW1 'nva/fortinet-vm.bicep' = if (deployFirewallVMs && useFortigateFW) {
  name: 'deploy-nva-DevFW1_fortigate'
  scope: rgHubVnet
  params: {
    location: location

    availabilityZone: fwDevVM1AvailabilityZone
    vmName: fwDevVM1Name
    vmSku: fwDevVMSku
    nic1PrivateIP: fwDevVM1ExternalFacingIP
    nic1SubnetId: hubVnet.outputs.PublicSubnetId
    nic2PrivateIP: fwDevVM1MrzIntIP
    nic2SubnetId: hubVnet.outputs.MrzIntSubnetId
    nic3PrivateIP: fwDevVM1DevIntIP
    nic3SubnetId: hubVnet.outputs.DevIntSubnetId
    nic4PrivateIP: fwDevVM1HAIP
    nic4SubnetId: hubVnet.outputs.HASubnetId
    username: fwUsername
    password: fwPassword
  }
}

// Non-Production traffic - Fortinet Firewall VM
module DevFW2 'nva/fortinet-vm.bicep' = if (deployFirewallVMs && useFortigateFW) {
  name: 'deploy-nva-DevFW2_fortigate'
  scope: rgHubVnet
  params: {
    location: location

    availabilityZone: fwDevVM2AvailabilityZone
    vmName: fwDevVM2Name
    vmSku: fwDevVMSku
    nic1PrivateIP: fwDevVM2ExternalFacingIP
    nic1SubnetId: hubVnet.outputs.PublicSubnetId
    nic2PrivateIP: fwDevVM2MrzIntIP
    nic2SubnetId: hubVnet.outputs.MrzIntSubnetId
    nic3PrivateIP: fwDevVM2DevIntIP
    nic3SubnetId: hubVnet.outputs.DevIntSubnetId
    nic4PrivateIP: fwDevVM2HAIP
    nic4SubnetId: hubVnet.outputs.HASubnetId
    username: fwUsername
    password: fwPassword
  }
}

// Production traffic - Internal Load Balancer
module ProdFWs_ILB 'hub-vnet/lb-firewalls-hub.bicep' = {
  name: 'deploy-internal-loadblancer-ProdFWs_ILB'
  scope: rgHubVnet
  params: {
    location: location

    name: fwProdILBName
    backendVnetId: hubVnet.outputs.vnetId
    frontendIPExt: fwProdILBExternalFacingIP
    backendIP1Ext: fwProdVM1ExternalFacingIP
    backendIP2Ext: fwProdVM2ExternalFacingIP
    frontendSubnetIdExt: hubVnet.outputs.PublicSubnetId
    frontendIPInt: fwProdILBPrdIntIP
    backendIP1Int: fwProdVM1PrdIntIP
    backendIP2Int: fwProdVM2PrdIntIP
    frontendSubnetIdInt: hubVnet.outputs.PrdIntSubnetId
    lbProbeTcpPort: useFortigateFW ? 8008 : 22
    configureEmptyBackendPool: !deployFirewallVMs
  }
}

// Non-Production traffic - Internal Load Balancer
module DevFWs_ILB 'hub-vnet/lb-firewalls-hub.bicep' = {
  name: 'deploy-internal-loadblancer-DevFWs_ILB'
  scope: rgHubVnet
  params: {
    location: location

    name: fwDevILBName
    backendVnetId: hubVnet.outputs.vnetId
    frontendIPExt: fwDevILBExternalFacingIP
    backendIP1Ext: fwDevVM1ExternalFacingIP
    backendIP2Ext: fwDevVM2ExternalFacingIP
    frontendSubnetIdExt: hubVnet.outputs.PublicSubnetId
    frontendIPInt: fwDevILBDevIntIP
    backendIP1Int: fwDevVM1DevIntIP
    backendIP2Int: fwDevVM2DevIntIP
    frontendSubnetIdInt: hubVnet.outputs.DevIntSubnetId
    lbProbeTcpPort: useFortigateFW ? 8008 : 22
    configureEmptyBackendPool: !deployFirewallVMs
  }
}
