// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Location for the deployment.')
param location string = resourceGroup().location

@description('Virtual Machine Name.')
param vmName string

@description('Virtual Machine SKU.')
param vmSize string

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


resource nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
    name: '${vmName}-nic'
    location: location
    properties: {
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
    location: location
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
                publisher: 'MicrosoftWindowsServer'
                offer: 'WindowsServer'
                sku: '2019-Datacenter'
                version: 'latest'
            }
            osDisk: {
                name: '${vmName}-os'
                caching: 'ReadWrite'
                createOption: 'FromImage'
                managedDisk: {
                    storageAccountType: 'Premium_LRS'
                }
            }
        }
        osProfile: {
            computerName: vmName
            adminUsername: username
            adminPassword: password
        }
    }
}

// Outputs
output vmName string = vm.name
output vmId string = vm.id
output nicId string = nic.id
