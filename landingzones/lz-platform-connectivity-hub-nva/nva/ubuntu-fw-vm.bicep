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

// VM
@description('Virtual Machine Name.')
param vmName string

@description('Virtual Machine SKU.')
param vmSku string

@description('Virtual Machine Availability Zone')
param availabilityZone string

// Network Interfaces
@description('NIC #1 - Private IP')
param nic1PrivateIP string

@description('NIC #1 - Subnet Resource Id')
param nic1SubnetId string

@description('NIC #2 - Private IP')
param nic2PrivateIP string

@description('NIC #2 - Subnet Resource Id')
param nic2SubnetId string

@description('NIC #3 - Private IP')
param nic3PrivateIP string
@description('NIC #3 - Subnet Resource Id')
param nic3SubnetId string

@description('NIC #4 - Private IP')
param nic4PrivateIP string
@description('NIC #4 - Subnet Resource Id')
param nic4SubnetId string

// VM Image
@description('Ubuntu - Publisher.  Default: Canonical')
param vmImagePublisher string = 'Canonical'

@description('Ubuntu - Image Offer.  Default: UbuntuServer')
param vmImageOffer string = 'UbuntuServer'

@description('Ubuntu - SKU.  Default: 18.04-LTS')
param vmImageSku string = '18.04-LTS'

@description('Ubuntu - Image Version.  Default: latest')
param vmImageVersion string = 'latest'  

@description('Temporary username for firewall virtual machine.')
@secure()
param username string

@description('Temporary password for firewall virtual machine.')
@secure()
param password string

resource nic1 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${vmName}-nic1'
  location: location
  tags: {}
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: nic1PrivateIP
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: nic1SubnetId
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: true
    enableIPForwarding: true
  }
}

resource nic2 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${vmName}-nic2'
  location: location
  tags: {}
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: nic2PrivateIP
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: nic2SubnetId
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: true
    enableIPForwarding: true
  }
}
resource nic3 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${vmName}-nic3'
  location: location
  tags: {}
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: nic3PrivateIP
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: nic3SubnetId
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: true
    enableIPForwarding: true
  }
}
resource nic4 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${vmName}-nic4'
  location: location
  tags: {}
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: nic4PrivateIP
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: nic4SubnetId
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: true
    enableIPForwarding: true
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location: location
  tags: {}
  zones: [
    availabilityZone
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSku
    }
    storageProfile: {
      imageReference: {
        publisher: vmImagePublisher 
        offer: vmImageOffer 
        sku: vmImageSku
        version: vmImageVersion 
      }
      osDisk: {
        osType: 'Linux'
        name: '${vmName}_OsDisk_1'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: username
      adminPassword: password
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
        }
      }
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic1.id
          properties: {
            primary: true
          }
        }
        {
          id: nic2.id
          properties: {
            primary: false
          }
        }
        {
          id: nic3.id
          properties: {
            primary: false
          }
        }
        {
          id: nic4.id
          properties: {
            primary: false
          }
        }
      ]
    }
  }
}

output vmName string = vm.name
output vmId string = vm.id
