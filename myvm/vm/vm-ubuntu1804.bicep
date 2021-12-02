// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param subnetID string

@description('Size of VMs in the VM Scale Set.')
param vmSku string = 'Standard_D2s_v3'

@description('String used as a base for naming resources (9 characters or less). A hash is prepended to this string for some resources, and resource-specific information is appended.')
param vmName string

@description('Admin username on all VMs.')
param adminUsername string = 'azuser'

param resourceTags object 

@allowed([
  'sshPublicKey'
  'password'
])
@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
param authenticationType string = 'sshPublicKey'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param sshkey string
var storageAccountType = 'Premium_LRS'

var nicName = '${vmName}nic'
var osType = {
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: '18.04-LTS'
  version: 'latest'
}
var imageReference = osType
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: sshkey
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: nicName
  location: resourceGroup().location
  tags: resourceTags
  properties: {
      enableAcceleratedNetworking: true
      ipConfigurations: [
          {
              name: 'IpConf'
              properties: {
                  subnet: {
                      id: subnetID
                  }
                  privateIPAllocationMethod: 'Dynamic'
                  privateIPAddressVersion: 'IPv4'
                  primary: true
              }
          }
      ]
   }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: vmName
  location: resourceGroup().location
  tags: resourceTags
  properties: {
      hardwareProfile: {
          vmSize: vmSku
      }
      networkProfile: {
          networkInterfaces: [
              {
                  id: nic.id
              }
          ]
      }
      storageProfile: {
          imageReference: imageReference
          osDisk: {
              name: '${vmName}-os'
              caching: 'ReadWrite'
              createOption: 'FromImage'
              managedDisk: {
                  storageAccountType: storageAccountType
              }
          }
      }
      osProfile: {
        computerName: vmName
        allowExtensionOperations: true
        adminUsername: adminUsername
        adminPassword: sshkey
        linuxConfiguration: ((authenticationType == 'password') ? json('null') : linuxConfiguration)
      }
    }
  }

resource vmextnesion 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  name: 'azcli'
  parent: vm
  location: resourceGroup().location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'curl -sL https://aka.ms/InstallAzureCLIDeb | sudo -u ${adminUsername} bash"'
    }
  }
}
