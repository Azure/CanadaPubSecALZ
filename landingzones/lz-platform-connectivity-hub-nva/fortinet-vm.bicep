// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

// VM
param vmName string = 'FW1'
param vmSku string = 'Standard_F8s_v2'
param availabilityZone string

// Network Interfaces
param nic1PrivateIP string
param nic1SubnetId string

param nic2PrivateIP string
param nic2SubnetId string

param nic3PrivateIP string
param nic3SubnetId string

param nic4PrivateIP string
param nic4SubnetId string


//fortinet:fortinet_fortigate-vm_v5:fortinet_fg-vm:6.4.5 //BYOL - works with MSDN free subs
//fortinet:fortinet_fortigate-vm_v5:fortinet_fg-vm-payg_20190624:6.4.5 //PAYG - needs credit card

// VM Image
param vmImagePublisher string = 'fortinet'
param vmImageOffer string = 'fortinet_fortigate-vm_v5'
param vmImagePlanName string = 'fortinet_fg-vm'
param vmImageSku string = 'fortinet_fg-vm'
param vmImageVersion string = '6.4.5' 

param username string
@secure()
param password string

resource nic1 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${vmName}-nic1'
  location: resourceGroup().location
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
  location: resourceGroup().location
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
  location: resourceGroup().location
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
  location: resourceGroup().location
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

resource VM_resource 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location: resourceGroup().location
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

output vmName string = VM_resource.name
output vmId string = VM_resource.id
