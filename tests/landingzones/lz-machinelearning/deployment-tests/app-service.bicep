// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

resource rgCompute 'Microsoft.Resources/resourceGroups@2020-06-01' existing = {
  name: 'testasp234'
}

module appInsights '../../../../azresources/monitor/ai-web.bicep' = {
  name: 'deploy-appinsights-web'
  scope: rgCompute
  params: {
    name: 'ai'
  }
}

module networking 'app-service-vnet.bicep' = {
  name: 'deploy-network'
  scope: rgCompute
}
// azure machine learning uses a metadata data lake storage account

module dataLakeMetaData '../../../../azresources/storage/storage-generalpurpose.bicep' = {
  name: 'deploy-aml-metadata-storage'
  scope: rgCompute
  params: {
    name: 'storagehudua123'

    privateEndpointSubnetId: networking.outputs.privateEndpointSubnetId
    blobPrivateZoneId: networking.outputs.dataLakeBlobPrivateDnsZoneId
    filePrivateZoneId: networking.outputs.dataLakeFilePrivateDnsZoneId

    useCMK: false
    deploymentScriptIdentityId: ''
    akvResourceGroupName: ''
    akvName: ''
  }
}


module appServicePlan '../../../../azresources/compute/web/app-service-plan-linux.bicep' = {
  name: 'deploy-app-service-plan'
  scope: rgCompute
  params: {
    name: 'asp-test'
    skuName: 'P1V2'
    skuTier: 'Premium'
  }
}


module appService '../../../../azresources/compute/web/appservice-linux-container.bicep' = {
  name: 'deploy-app-service'
  scope: rgCompute
  params: {
    name: 'ashudua123'
    appServicePlanId: appServicePlan.outputs.planId
    aiIKey: appInsights.outputs.aiIKey

    storageName: dataLakeMetaData.outputs.storageName
    storageId: dataLakeMetaData.outputs.storageId
    
    vnetIntegrationSubnetId: networking.outputs.appServiceSubnetId
  }
}



