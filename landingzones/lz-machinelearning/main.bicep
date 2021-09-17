// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

// Groups
@description('An array of Security Group object ids that should be granted Owner built-in role.  Default: []')
param subscriptionOwnerGroupObjectIds array = []

@description('An array of Security Group object ids that should be granted Contributor built-in role.  Default: []')
param subscriptionContributorGroupObjectIds array = []

@description('An array of Security Group object ids that should be granted Reader built-in role.  Default: []')
param subscriptionReaderGroupObjectIds array = []

@description('An array of Security Group object ids that should be granted Application Owner custom role.  Default: []')
param subscriptionAppOwnerGroupObjectIds array = []

@description('Reference to Application Owner custom role definition id.  Default: empty string')
param lzAppOwnerRoleDefinitionId string = ''

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
@description('Azure Automation Account name')
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

@description('Hub Virtual Network IP Address - RFC 6598')
param hubCGNATIPRange string

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

// Budget
@description('Boolean flag to determine whether to create subscription budget.  Default: true')
param createBudget bool = true

@description('Subscription budget name.')
param budgetName string

@description('Subscription budget amount.')
param budgetAmount int

@description('Subscription budget email notification address.')
param budgetNotificationEmailAddress string

@description('Subscription budget start date.  New budget can not be created with the same name and different start date.  You must delete the old budget before recreating or disable budget creation through createBudget flag.  Default:  1st day of current month')
param budgetStartDate string = utcNow('yyyy-MM-01')

@description('Budget Time Window.  Options are Monthly, Quarterly or Annually.  Default: Monthly')
@allowed([
  'Monthly'
  'Quarterly'
  'Annually'
])
param budgetTimeGrain string = 'Monthly'

// Azure Key Vault
@description('Azure Key Vault Secret Expiry in days.')
param secretExpiryInDays int

// Tags
@description('Subscription scoped tag - ISSO')
param tagISSO string

@description('Resource Group scoped tag - Client Organization')
param tagClientOrganization string

@description('Resource Group scoped tag - Cost Center')
param tagCostCenter string

@description('Resource Group scoped tag - Data Sensitivity')
param tagDataSensitivity string

@description('Resource Group scoped tag - Project Contact')
param tagProjectContact string

@description('Resource Group scoped tag - Project Name')
param tagProjectName string

@description('Resource Group scoped tag - Technical Contact')
param tagTechnicalContact string

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
    * Subscription Budget
    * Subscription Tag:  ISSO
*/
module subScaffold '../scaffold-subscription.bicep' = {
  name: 'configure-subscription'
  scope: subscription()
  params: {
    lzAppOwnerRoleDefinitionId: lzAppOwnerRoleDefinitionId
    subscriptionAppOwnerGroupObjectIds: subscriptionAppOwnerGroupObjectIds
    subscriptionOwnerGroupObjectIds: subscriptionOwnerGroupObjectIds
    subscriptionContributorGroupObjectIds: subscriptionContributorGroupObjectIds
    subscriptionReaderGroupObjectIds: subscriptionReaderGroupObjectIds

    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    
    securityContactEmail: securityContactEmail
    securityContactPhone: securityContactPhone
    
    createBudget: createBudget
    budgetName: budgetName
    budgetAmount: budgetAmount
    budgetTimeGrain: budgetTimeGrain
    budgetStartDate: budgetStartDate
    budgetNotificationEmailAddress: budgetNotificationEmailAddress
    
    tagISSO: tagISSO
  }
}

// Deploy Landing Zone
module landingZone 'lz.bicep' = {
  name: 'deploy-machinelearning-archetype'
  scope: subscription()
  params: {
    tagClientOrganization: tagClientOrganization
    tagCostCenter: tagCostCenter
    tagDataSensitivity: tagDataSensitivity
    tagProjectContact: tagProjectContact
    tagProjectName: tagProjectName
    tagTechnicalContact: tagTechnicalContact
  
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
    hubCGNATIPRange: hubCGNATIPRange
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
