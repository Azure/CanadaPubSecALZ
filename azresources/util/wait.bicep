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
