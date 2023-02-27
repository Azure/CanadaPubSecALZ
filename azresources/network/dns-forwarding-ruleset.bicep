// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string
param location string = resourceGroup().location

@description('Outbound endpoint id')
param outEndpointId string

param forwardingRuleSet array

param linkRuleSetToVnet bool = false
param linkName string = ''
param vnetId string = '' 



resource ruleset 'Microsoft.Network/dnsForwardingRulesets@2022-07-01' = {
  name: name
  location: location
  properties: {
    dnsResolverOutboundEndpoints: [
      {
        id: outEndpointId
      }
    ]
  }
}

resource fwRule 'Microsoft.Network/dnsForwardingRulesets/forwardingRules@2022-07-01' = [for rule in forwardingRuleSet: {
  name: rule.name
  parent: ruleset
  properties: {
    forwardingRuleState: rule.state
    domainName: endsWith(rule.domain, '.') ? rule.domain : '${rule.domain}.'
    targetDnsServers: rule.targetDnsServers
  }
}]


module dnsResolverLinkVnet 'dnsresolver-vnet-link.bicep'= if(linkRuleSetToVnet){
  name:'deploy-private-dns-resolver-vnet-link'
  params:{
    forwardingRulesetName: ruleset.name
    linkName: linkName
    vnetId: vnetId
  }
}

output ruleSetName string = ruleset.name
 
