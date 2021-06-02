// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

param managementGroupId string
param subscriptionId string

resource move 'Microsoft.Management/managementGroups/subscriptions@2020-05-01' = {
  name: '${managementGroupId}/${subscriptionId}'
  scope: tenant()
}
