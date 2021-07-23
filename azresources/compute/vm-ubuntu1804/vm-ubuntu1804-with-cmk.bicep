// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param subnetId string
param vmName string
param vmSize string = 'Standard_DS1_v2'

param username string
@secure()
param password string

param availabilityZone string = '1'
param enableAcceleratedNetworking bool = false

param publisher string = 'Canonical'
param offer string = 'UbuntuServer'
param sku string = '18.04-LTS'
param version string = 'latest' 
param storageAccountType string = 'StandardSSD_LRS'

param akvResourceGroupName string
param akvName string

@description('Enable encryption at host (double encryption)')
param encryptionAtHost bool = true

resource akv 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
    scope: resourceGroup(akvResourceGroupName)
    name: akvName
}

module akvKey '../../security/key-vault-key-rsa2048.bicep' = {
    name: 'add-cmk-${vmName}'
    scope: resourceGroup(akvResourceGroupName)
    params: {
        akvName: akvName
        keyName: 'cmk-vmdisks-${vmName}'
    }
}

resource diskEncryptionSet 'Microsoft.Compute/diskEncryptionSets@2020-12-01' = {
    name: '${vmName}-disk-encryption-set'
    location: resourceGroup().location
    identity: {
        type: 'SystemAssigned'
    }

    properties: {
        rotationToLatestKeyVersionEnabled: true
        encryptionType: 'EncryptionAtRestWithPlatformAndCustomerKeys'
        activeKey: {
            keyUrl: akvKey.outputs.keyUriWithVersion
        }
    }
}

module diskEncryptionSetRoleAssignmentForCMK '../../iam/resource/key-vault-role-assignment-to-sp.bicep' = {
    name: 'rbac-${diskEncryptionSet.name}-key-vault'
    scope: resourceGroup(akvResourceGroupName)
    params: {
        keyVaultName: akv.name
        roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e147488a-f6f5-4113-8e2d-b22465e65bf6') // Key Vault Crypto Service Encryption User
        resourceSPObjectIds: array(diskEncryptionSet.identity.principalId)
    }
}

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
    dependsOn: [
        diskEncryptionSetRoleAssignmentForCMK
    ]
    
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
                    diskEncryptionSet: {
                        id: diskEncryptionSet.id
                    }
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
                        diskEncryptionSet: {
                            id: diskEncryptionSet.id
                        }
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

output vmName string = vm.name
output vmId string = vm.id
output nicId string = nic.id
