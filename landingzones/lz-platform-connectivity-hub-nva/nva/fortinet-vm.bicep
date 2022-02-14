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


//fortinet:fortinet_fortigate-vm_v5:fortinet_fg-vm:6.4.5 //BYOL - works with MSDN free subs
//fortinet:fortinet_fortigate-vm_v5:fortinet_fg-vm-payg_20190624:6.4.5 //PAYG - needs credit card

// VM Image
@description('Fortigate Firewall - Publisher.  Default: fortinet')
param vmImagePublisher string = 'fortinet'

@description('Fortigate Firewall - Image Offer.  Default: fortinet_fortigate')
param vmImageOffer string = 'fortinet_fortigate-vm_v5'

@description('Fortigate Firewall - Plan.  Default: fortinet_fg-vm')
param vmImagePlanName string = 'fortinet_fg-vm'

@description('Fortigate Firewall - SKU.  Default: fortinet_fg-vm')
param vmImageSku string = 'fortinet_fg-vm'

@description('Fortigate Firewall - Image Version.  Default: 6.4.5')
param vmImageVersion string = '6.4.5' 

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
  plan: { 
     name: vmImagePlanName
     product: vmImageOffer
     publisher: vmImagePublisher
   }
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
      dataDisks: [
        {
          lun: 0
          name: '${vmName}_disk2'
          createOption: 'Empty'
          caching: 'None'
          diskSizeGB: 128
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
          toBeDetached: false
        }
      ]
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
