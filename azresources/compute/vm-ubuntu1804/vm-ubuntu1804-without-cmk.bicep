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

// Host Encryption
@description('Boolean flag to enable encryption at host (double encryption).  This feature can not be used with Azure Disk Encryption.')
param encryptionAtHost bool = true

// VM Image
@description('VM Publisher.  Default: Canonical')
param publisher string = 'Canonical'

@description('VM Offer.  Default: UbuntuServer')
param offer string = 'UbuntuServer'

@description('VM SKU.  Default: 18.04-LTS')
param sku string = '18.04-LTS'

@description('VM Version.  Default: latest')
param version string = 'latest'

@description('VM Managed Disk Storage Account Type.  Default: StandardSSD_LRS')
param storageAccountType string = 'StandardSSD_LRS'

resource nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
    name: '${vmName}-nic'
     location: resourceGroup().location
     properties: {
        enableAcceleratedNetworking: enableAcceleratedNetworking
        ipConfigurations: [
            {
                name: 'IpConf'
                properties: {
                    subnet: {
                        id: subnetId
                    }
                    privateIPAllocationMethod: 'Dynamic'
                    privateIPAddressVersion: 'IPv4'
                    primary: true
                }
            }
        ]
     }
}

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
    name: vmName
    location: resourceGroup().location
    zones: [
        availabilityZone
    ]
    properties: {
        hardwareProfile: {
            vmSize: vmSize
        }
        networkProfile: {
            networkInterfaces: [
                {
                    id: nic.id
                }
            ]
        }
        storageProfile: {
            imageReference: {
                publisher: publisher
                offer: offer
                sku: sku
                version: version
            }
            osDisk: {
                name: '${vmName}-os'
                caching: 'ReadWrite'
                createOption: 'FromImage'
                managedDisk: {
                    storageAccountType: storageAccountType
                }
            }
            dataDisks: [
                {
                    caching: 'None'
                    name: '${vmName}-data-1'
                    diskSizeGB: 128
                    lun: 0
                    managedDisk: {
                        storageAccountType: 'Premium_LRS'
                    }
                    createOption: 'Empty'
                }
            ]
        }
        osProfile: {
            computerName: vmName
            adminUsername: username
            adminPassword: password
        }
        securityProfile: {
            encryptionAtHost: encryptionAtHost
        }
    }
}

// Outputs
output vmName string = vm.name
output vmId string = vm.id
output nicId string = nic.id
