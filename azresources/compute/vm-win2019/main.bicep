// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Virtual Machine Name.')
param vmName string

@description('Virtual Machine SKU.')
param vmSize string

@description('Azure Availability Zone for VM.')
param availabilityZone string

// Credentials
@description('Virtual Machine Username.')
@secure()
param username string

@description('Virtual Machine Password')
@secure()
param password string

// Networking
@description('Subnet Resource Id.')
param subnetId string

@description('Boolean flag that enables Accelerated Networking.')
param enableAcceleratedNetworking bool

// Customer Managed Key
@description('Boolean flag that determines whether to enable Customer Managed Key.')
param useCMK bool

// Azure Key Vault
@description('Azure Key Vault Resource Group Name.  Required when useCMK=true.')
param akvResourceGroupName string

@description('Azure Key Vault Name.  Required when useCMK=true.')
param akvName string

// Host Encryption
@description('Boolean flag to enable encryption at host (double encryption).  This feature can not be used with Azure Disk Encryption.')
param encryptionAtHost bool = true

// Deploy VM without Customer Managed Key for Managed Disks.
module vmWithoutCMK 'vm-win2019-without-cmk.bicep' = if (!useCMK) {
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

// Deploy VM with Customer Managed Key for Managed Disks.
module vmWithCMK 'vm-win2019-with-cmk.bicep' = if (useCMK) {
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

// Outputs
output vmName string = (useCMK) ? vmWithCMK.outputs.vmName : vmWithoutCMK.outputs.vmName
output vmId string = (useCMK) ? vmWithCMK.outputs.vmId : vmWithoutCMK.outputs.vmId
output nicId string = (useCMK) ? vmWithCMK.outputs.nicId : vmWithoutCMK.outputs.nicId
