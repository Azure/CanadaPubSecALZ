// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param subnetId string
param vmName string
param vmSize string

param username string
@secure()
param password string

param availabilityZone string
param enableAcceleratedNetworking bool

@description('When true, customer managed key will be enabled')
param useCMK bool
@description('Required when useCMK=true')
param akvResourceGroupName string
@description('Required when useCMK=true')
param akvName string

@description('Enable encryption at host (double encryption)')
param encryptionAtHost bool = true

module vmWithoutCMK 'vm-ubuntu1804-without-cmk.bicep' = if (!useCMK) {
    name: 'deploy-vm-without-cmk'
    params: {
        vmName: vmName
        vmSize: vmSize

        subnetId: subnetId

        availabilityZone: availabilityZone
        enableAcceleratedNetworking: enableAcceleratedNetworking

        username: username
        password: password

        encryptionAtHost: encryptionAtHost
    }
}

module vmWithCMK 'vm-ubuntu1804-with-cmk.bicep' = if (useCMK) {
    name: 'deploy-vm-with-cmk'
    params: {
        vmName: vmName
        vmSize: vmSize

        subnetId: subnetId

        availabilityZone: availabilityZone
        enableAcceleratedNetworking: enableAcceleratedNetworking

        username: username
        password: password

        encryptionAtHost: encryptionAtHost

        akvName: akvName
        akvResourceGroupName: akvResourceGroupName
    }
}

output vmName string = (useCMK) ? vmWithCMK.outputs.vmName : vmWithoutCMK.outputs.vmName
output vmId string = (useCMK) ? vmWithCMK.outputs.vmId : vmWithoutCMK.outputs.vmId
output nicId string = (useCMK) ? vmWithCMK.outputs.nicId : vmWithoutCMK.outputs.nicId
