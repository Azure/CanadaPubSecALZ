// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

@minValue(1)
param loopCounter int

@batchSize(1)
module wait 'waitOnARM.bicep' = [for i in range(1, loopCounter): {
  name: 'waitOnArm-${i}'
  scope: subscription()
  params: {
    input: 'waitOnArm-${i}'
  }
}]
