// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

@description('Loop Counter.')
@minValue(1)
param loopCounter int

@description('Prefix used for loop.')
@minLength(2)
@maxLength(50)
param waitNamePrefix string

@batchSize(1)
module wait 'wait-on-arm-subscription.bicep' = [for i in range(1, loopCounter): {
  scope: subscription()
  name: '${waitNamePrefix}-${i}'
  params: {
    input: 'waitOnArm-${i}'
  }
}]
