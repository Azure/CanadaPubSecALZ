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

@description('Network configuration for the spoke virtual network.  It includes name, dnsServers, address spaces, vnet peering and subnets.')
param network object

// Private DNS Resolver
@description('Private DNS Resolver configuration for Inbound connections.')
param privateDnsResolver object

// Private DNS Resolver Ruleset
@description('Private DNS Resolver Default Ruleset Configuration')
param privateDnsResolverRuleset object

// Private DNS Resolver Ruleset
@description('Private DNS Resolver Default Ruleset Configuration')
param dnsResolverRG string

// vnet resource group
@description('virtual network resource group name')
param rgVnet string

// vnet 
@description('virtual network ID')
param vnetId string

// vnet 
@description('virtual network Name')
param vnetName string




// Create Private DNS Resolver Resource Group
resource rgPrivateDnsResolver 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: dnsResolverRG
  location: location
  tags: resourceTags
}

//create Private DNS Resolver 
module dnsResolver '../../azresources/network/dnsresolver.bicep' ={
  name:'deploy-private-dns-resolver'
  scope: rgPrivateDnsResolver
  params:{
    name: privateDnsResolver.name
    location: location
    inboundEndpointName: privateDnsResolver.inboundEndpointName
    inboundSubnetName: network.subnets.dnsResolverInbound.name
    outboundEndpointName: privateDnsResolver.outboundEndpointName
    outboundSubnetName: network.subnets.dnsResolverOutbound.name
    vnetResourceGroupName: rgVnet
    vnetId: vnetId
    vnetName: vnetName
  }
}

module dnsResolverFwRuleset '../../azresources/network/dns-forwarding-ruleset.bicep' = if (privateDnsResolverRuleset.enabled) {
  name:'deploy-private-dns-resolver-fw-ruleset'
  scope: rgPrivateDnsResolver

  params:{
    name: privateDnsResolverRuleset.name
    location: location    
    outEndpointId: dnsResolver.outputs.outboundEndpointId

    forwardingRuleSet: privateDnsResolverRuleset.forwardingRules
    
    linkRuleSetToVnet: privateDnsResolverRuleset.linkRuleSetToVnet
    linkName: privateDnsResolverRuleset.linkRuleSetToVnetName
    vnetId: vnetId
  }
}
