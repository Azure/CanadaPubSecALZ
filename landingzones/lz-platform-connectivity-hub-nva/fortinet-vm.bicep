// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param VM_name string = 'FW1'
param VM_sku string = 'Standard_F8s_v2'
param VM_nic1_ip string
param VM_nic1_subnetId string
param VM_nic2_ip string
param VM_nic2_subnetId string
param VM_nic3_ip string
param VM_nic3_subnetId string
param VM_nic4_ip string
param VM_nic4_subnetId string
param availabilityZone string
//fortinet:fortinet_fortigate-vm_v5:fortinet_fg-vm:6.4.5 //BYOL - works with MSDN free subs
//fortinet:fortinet_fortigate-vm_v5:fortinet_fg-vm-payg_20190624:6.4.5 //PAYG - needs credit card
param cfg_FW_publisher string = 'fortinet'
param cfg_FW_productoffer string = 'fortinet_fortigate-vm_v5'
param cfg_FW_planname string = 'fortinet_fg-vm'
param cfg_FW_sku string = 'fortinet_fg-vm'
param cfg_FW_version string = '6.4.5' 

param username string
@secure()
param password string

resource nic1 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${VM_name}-nic1'
  location: resourceGroup().location
  tags: {}
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: VM_nic1_ip
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: VM_nic1_subnetId
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
  name: '${VM_name}-nic2'
  location: resourceGroup().location
  tags: {}
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: VM_nic2_ip
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: VM_nic2_subnetId
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
  name: '${VM_name}-nic3'
  location: resourceGroup().location
  tags: {}
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: VM_nic3_ip
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: VM_nic3_subnetId
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
  name: '${VM_name}-nic4'
  location: resourceGroup().location
  tags: {}
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: VM_nic4_ip
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: VM_nic4_subnetId
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
  name: VM_name
  location: resourceGroup().location
  tags: {}
  zones: [
    availabilityZone
  ]
  // do not include a plan:{} block when using Ubuntu. It cannot be made conditional (must be null)
  plan: { 
     name: cfg_FW_planname
     product: cfg_FW_productoffer
     publisher: cfg_FW_publisher
   }
  properties: {
    hardwareProfile: {
      vmSize: VM_sku
    }
    storageProfile: {
      imageReference: {
        publisher: cfg_FW_publisher 
        offer: cfg_FW_productoffer 
        sku: cfg_FW_sku
        version: cfg_FW_version 
      }
      osDisk: {
        osType: 'Linux'
        name: '${VM_name}_OsDisk_1'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      dataDisks: [
        {
          lun: 0
          name: '${VM_name}_disk2'
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
      computerName: VM_name
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
