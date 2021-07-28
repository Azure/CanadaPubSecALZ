// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------
targetScope = 'subscription'

@minValue(1)
param loopCounter int

@minLength(2)
@maxLength(50)
param waitNamePrefix string

@batchSize(1)
module wait 'waitOnARM-subscription.bicep' = [for i in range(1, loopCounter): {
  scope: subscription()
  name: '${waitNamePrefix}-${i}'
  params: {
    input: 'waitOnArm-${i}'
  }
}]
