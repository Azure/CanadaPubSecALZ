// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

var location = 'canadacentral' 
param vmName string = 'adeel-testvm'
param sshkey string
var subnetID = '/subscriptions/c8515022-4cc9-4ed5-a3fe-182e05d732d8/resourceGroups/azmlnocmk102021W1Network/providers/Microsoft.Network/virtualNetworks/azmlnocmk102021W1vnet/subnets/aks'

// RGs
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name:'adeel-testvm-rg'
  location: location

}

module vm './vm-ubuntu1804.bicep' =  {
  dependsOn: [
    rg
  ]
  name: 'deploy-vm-${vmName}'
  scope: rg
  params: {
    vmName: vmName
    subnetID: subnetID
    sshkey: sshkey
  }
}

