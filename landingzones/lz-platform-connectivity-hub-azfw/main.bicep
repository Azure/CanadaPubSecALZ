// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------
targetScope = 'subscription'

@description('Location for the deployment.')
param location string = deployment().location

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
param privateDnsZones object

// DDOS Standard
param ddosStandard object

// Bastion
param bastion object

// Azure Firewall
@description('Azure Firewall Name')
param azureFirewallName string //= 'azfw' 

@description('Azure Firewall Availability Zones.  Empty array = zonal, an array 1,2,3 is zone-redundant.')
param azureFirewallZones array //= ['1' '2' '3']

@description('Azure Firewall is deployed in Forced Tunneling mode where a route table must be added as the next hop.')
param azureFirewallForcedTunnelingEnabled bool

@description('Next Hop for AzureFirewallSubnet when Azure Firewall is deployed in forced tunneling mode.')
param azureFirewallForcedTunnelingNextHop string

@description('Azure Firewall Policy Resource Id.')
param azureFirewallExistingPolicyId string //= ARM Resource Id

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

@description('Hub - Public Access Zone Subnet Name.')
param hubPazSubnetName string //= 'PAZSubnet'

@description('Hub - Public Access Zone Subnet Name (based on RFC 6598).')
param hubPazSubnetAddressPrefix string //= '100.60.1.0/24'

@description('Hub - Virtual Network Gateway Subnet Address Prefix (based on RFC 1918).')
param hubGatewaySubnetAddressPrefix string //= '10.18.1.0/27'

@description('Hub - Azure Firewall Subnet Address Prefix.')
param hubAzureFirewallSubnetAddressPrefix string //= '10.18.2.0/24'

@description('Hub - Azure Firewall Management Subnet Address Prefix.')
param hubAzureFirewallManagementSubnetAddressPrefix string //= '10.18.3.0/26'

@description('Azure Bastion Subnet Address Prefix.')
param hubBastionSubnetAddressPrefix string //= '10.18.4.0/24'

// Management Restricted Zone Virtual Network
param managementRestrictedZone object

// Public Access Zone
param publicAccessZone object

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../config/telemetry.json'))
module telemetryCustomerUsageAttribution '../../azresources/telemetry/customer-usage-attribution-subscription.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.networking.azureFirewall}'
}

module subScaffold '../scaffold-subscription.bicep' = {
  name: 'configure-subscription'
  scope: subscription()
  params: {
    location: location

    serviceHealthAlerts: serviceHealthAlerts

    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    securityCenter: securityCenter

    subscriptionBudget: subscriptionBudget

    subscriptionTags: subscriptionTags
    resourceTags: resourceTags

    subscriptionRoleAssignments: subscriptionRoleAssignments
  }
}

// Create Network Watcher Resource Group
resource rgNetworkWatcher 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgNetworkWatcherName
  location: location
  tags: resourceTags
}

// Create Private DNS Zone Resource Group - optional
resource rgPrivateDnsZones 'Microsoft.Resources/resourceGroups@2020-06-01' = if (privateDnsZones.enabled) {
  name: privateDnsZones.resourceGroup
  location: location
  tags: resourceTags
}

// Create Azure DDOS Standard Resource Group - optional
resource rgDdos 'Microsoft.Resources/resourceGroups@2020-06-01' = if (ddosStandard.enabled) {
  name: ddosStandard.resourceGroup
  location: location
  tags: resourceTags
}

// Create Hub Virtual Network Resource Group
resource rgHubVnet 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgHubName
  location: location
  tags: resourceTags
}

// Enable delete locks
module rgDdosDeleteLock '../../azresources/util/delete-lock.bicep' = if (ddosStandard.enabled) {
  name: 'deploy-delete-lock-${ddosStandard.resourceGroup}'
  scope: rgDdos
}

module rgHubDeleteLock '../../azresources/util/delete-lock.bicep' = {
  name: 'deploy-delete-lock-${rgHubName}'
  scope: rgHubVnet
}

// Azure DDOS Standard - optional
module ddosPlan '../../azresources/network/ddos-standard.bicep' = if (ddosStandard.enabled) {
  name: 'deploy-ddos-standard-plan'
  scope: rgDdos
  params: {
    name: ddosStandard.planName
    location: location
  }
}

// UDRs will be configured after an Azure Firewll instance has been deployed or updated.
// To ensure all traffic is inspected, initiate the UDR with NextHop set to None.  This ensures that all traffic through
// the subnet will be blackholed until the Azure Firewall instance is running.  When Azure Firewall deployment is
// complete, the route table will be updated with the appropriate routes to force traffic through the Firewall.
//
// Note:  When the hub network is updated, all routes in the Route Table will be replaced with the "blackhole" route
// until the Azure Firewall is updated.  Once updated, the routes will be replaced with the ones found in the deployment.
// As a result, there will be ~ 30 seconds of network outage for traffic flowing through the Public Access Zone & Management
// Restricted Zone spoke virtual network.
module publicAccessZoneUdr '../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-${hubPazSubnetName}Udr'
  scope: rgHubVnet
  params: {
    location: location
    name: '${hubPazSubnetName}Udr'
    routes: [
      {
        name: 'Blackhole'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'None'
        }
      }
    ]
  }
}

module managementRestrictedZoneUdr '../../azresources/network/udr/udr-custom.bicep' = {
  name: 'deploy-route-table-MrzSpokeUdr'
  scope: rgHubVnet
  params: {
    location: location
    name: 'MrzSpokeUdr'
    routes: [
      {
        name: 'Blackhole'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'None'
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

    pazSubnetName: hubPazSubnetName
    pazSubnetAddressPrefix: hubPazSubnetAddressPrefix
    pazUdrId: publicAccessZoneUdr.outputs.udrId

    azureFirewallSubnetAddressPrefix: hubAzureFirewallSubnetAddressPrefix
    azureFirewallManagementSubnetAddressPrefix: hubAzureFirewallManagementSubnetAddressPrefix
    gatewaySubnetAddressPrefix: hubGatewaySubnetAddressPrefix
    bastionSubnetAddressPrefix: hubBastionSubnetAddressPrefix

    azureFirewallForcedTunnelingEnabled: azureFirewallForcedTunnelingEnabled
    azureFirewallForcedTunnelingNextHop: azureFirewallForcedTunnelingNextHop

    ddosStandardPlanId: ddosStandard.enabled ? ddosPlan.outputs.ddosPlanId : ''
  }
}

// Azure Firewall
module azureFirewall '../../azresources/network/firewall.bicep' = {
  name: 'deploy-azure-firewall'
  scope: rgHubVnet
  params: {
    location: location
    name: azureFirewallName
    zones: azureFirewallZones
    firewallSubnetId: hubVnet.outputs.AzureFirewallSubnetId
    firewallManagementSubnetId: hubVnet.outputs.AzureFirewallManagementSubnetId
    existingFirewallPolicyId: azureFirewallExistingPolicyId
    forcedTunnelingEnabled: azureFirewallForcedTunnelingEnabled
  }
}

// Route Tables
// Update the Route Tables to force traffic through Azure Firewall.  Routes defined in this definition will be the only
// routes remaining once updated.  As a result, it's recommended that all routes in the Hub Networking is updated through 'hub-vnet-routes.bicep'
// for consistency.
module hubVnetRoutes 'hub-vnet/hub-vnet-routes.bicep' = {
  name: 'deploy-hub-vnet-routes'
  scope: rgHubVnet
  params: {
    location: location
    
    azureFirwallPrivateIp: azureFirewall.outputs.firewallPrivateIp
    hubVnetAddressPrefixRFC1918: hubVnetAddressPrefixRFC1918
    hubVnetAddressPrefixRFC6598: hubVnetAddressPrefixRFC6598

    publicAccessZoneUdrName: publicAccessZoneUdr.outputs.udrName
    managementRestrictedZoneUdrName: managementRestrictedZoneUdr.outputs.udrName
  }
}

// Private DNS Zones
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

// Bastion
module azureBastion '../../azresources/network/bastion.bicep' = if (bastion.enabled) {
  name: 'deploy-bastion'
  scope: rgHubVnet
  params: {
    location: location
    name: bastion.name
    sku: bastion.sku
    scaleUnits: bastion.scaleUnits
    subnetId: hubVnet.outputs.AzureBastionSubnetId
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
