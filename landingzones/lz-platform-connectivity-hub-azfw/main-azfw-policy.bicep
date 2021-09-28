// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------
targetScope = 'subscription'

// Tags
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

// Firewall Policy
@description('Azure Firewall Policy Resource Group Name')
param resourceGroupName string

@description('Azure Firewall Policy Name')
param policyName string

resource rgFirewallPolicy 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroupName
  location: deployment().location
  tags: resourceTags
}

module firewallPolicy 'azfw-policy/azure-firewall-policy.bicep' = {
  scope: rgFirewallPolicy
  name: 'deploy-azure-firewall-policy'
  params: {
    name: policyName
  }
}

output firewallPolicyId string = firewallPolicy.outputs.policyId
