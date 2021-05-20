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
param cfg_FW_publisher string = 'Canonical'
param cfg_FW_productoffer string = 'UbuntuServer'
param cfg_FW_sku string = '18.04-LTS'
param cfg_FW_version string = 'latest'  

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
  //do not include a plan:{} block when using Ubuntu. It cannot be made conditional (must be null)
  // plan: { 
  //   name: cfg_FW_planname
  //   product: cfg_FW_productoffer
  //   publisher: cfg_FW_publisher
  // }
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
