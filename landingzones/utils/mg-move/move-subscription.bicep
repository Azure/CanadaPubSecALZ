// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

@description('Target management group id.')
param managementGroupId string

@description('Subscription that is being moved to a new management group.')
param subscriptionId string

resource move 'Microsoft.Management/managementGroups/subscriptions@2020-05-01' = {
  name: '${managementGroupId}/${subscriptionId}'
  scope: tenant()
}
