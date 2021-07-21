// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string = 'sqlmi${uniqueString(resourceGroup().id)}'
param skuName string = 'GP_Gen5'

param vCores int = 4
param storageSizeInGB int = 32

param subnetId string

param storagePath string
param saLoggingName string

param securityContactEmail string

param tags object = {}

@secure()
param sqlmiUsername string

@secure()
param sqlmiPassword string

@description('When true, customer managed key will be enabled')
param useCMK bool
@description('Required when useCMK=true')
param akvResourceGroupName string
@description('Required when useCMK=true')
param akvName string

module sqlmiWithoutCMK 'sqlmi-without-cmk.bicep' = if (!useCMK) {
  name: 'deploy-sqlmi-without-cmk'
  params: {
    name: name
    skuName: skuName

    vCores: vCores
    storageSizeInGB: storageSizeInGB

    subnetId: subnetId

    storagePath: storagePath
    saLoggingName: saLoggingName

    sqlmiUsername: sqlmiUsername
    sqlmiPassword: sqlmiPassword

    securityContactEmail: securityContactEmail

    tags: tags
  }
}

module sqlmiWithCMK 'sqlmi-with-cmk.bicep' = if (useCMK) {
  name: 'deploy-sqlmi-with-cmk'
  params: {
    name: name
    skuName: skuName

    vCores: vCores
    storageSizeInGB: storageSizeInGB

    subnetId: subnetId

    storagePath: storagePath
    saLoggingName: saLoggingName

    sqlmiUsername: sqlmiUsername
    sqlmiPassword: sqlmiPassword

    securityContactEmail: securityContactEmail

    tags: tags

    akvResourceGroupName: akvResourceGroupName
    akvName: akvName
  }
}

output sqlMiFqdn string = useCMK ? sqlmiWithCMK.outputs.sqlMiFqdn : sqlmiWithoutCMK.outputs.sqlMiFqdn
