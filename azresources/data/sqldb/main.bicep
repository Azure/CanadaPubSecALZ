// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param sqlServerName string = 'sqlserver${uniqueString(resourceGroup().id)}'

param privateEndpointSubnetId string
param privateZoneId string

param securityContactEmail string

param saLoggingName string
param storagePath string

param tags object = {}

@secure()
param sqldbUsername string

@secure()
param sqldbPassword string

@description('When true, customer managed key will be enabled')
param useCMK bool
@description('Required when useCMK=true')
param akvResourceGroupName string
@description('Required when useCMK=true')
param akvName string


module sqldbWithoutCMK 'sqldb-without-cmk.bicep' = if (!useCMK) {
  name: 'deploy-sqldb-without-cmk'
  params: {
    sqlServerName: sqlServerName

    privateEndpointSubnetId: privateEndpointSubnetId
    privateZoneId: privateZoneId
    
    securityContactEmail: securityContactEmail

    saLoggingName: saLoggingName
    storagePath: storagePath

    sqldbUsername: sqldbUsername
    sqldbPassword: sqldbPassword

    tags: tags
  }
}

module sqldbWithCMK 'sqldb-with-cmk.bicep' = if (useCMK) {
  name: 'deploy-sqldb-with-cmk'
  params: {
    sqlServerName: sqlServerName

    privateEndpointSubnetId: privateEndpointSubnetId
    privateZoneId: privateZoneId
    
    securityContactEmail: securityContactEmail

    saLoggingName: saLoggingName
    storagePath: storagePath

    sqldbUsername: sqldbUsername
    sqldbPassword: sqldbPassword

    tags: tags

    akvResourceGroupName: akvResourceGroupName
    akvName: akvName
  }
}

output sqlDbFqdn string = useCMK ? sqldbWithCMK.outputs.sqlDbFqdn : sqldbWithoutCMK.outputs.sqlDbFqdn
