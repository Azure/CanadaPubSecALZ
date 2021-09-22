// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

param deploymentScriptIdentityId string
param deploymentScriptResourceGroupName string

param hubVnetId string
param egressVirtualApplianceIp string
param hubRFC1918IPRange string
param hubRFC6598IPRange string

param logAnalyticsWorkspaceResourceId string

param deploySQLDB bool
param deploySQLMI bool
param useCMK bool

param testRunnerCleanupAfterDeployment bool = true
param testRunnerId string = 'dt${uniqueString(utcNow())}'

var rgVnetName = '${testRunnerId}Network'
var rgAutomationName = '${testRunnerId}Automation'
var rgStorageName = '${testRunnerId}Storage'
var rgComputeName = '${testRunnerId}Compute'
var rgSecurityName = '${testRunnerId}Security'
var rgMonitorName = '${testRunnerId}Monitor'

var tagProjectName = '${testRunnerId}ProjectName'

module test '../../../../landingzones/lz-machinelearning/main.bicep' = {
  name: 'execute-test-${testRunnerId}'
  scope: subscription()
  params: {
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    securityContactEmail: 'alzcanadapubsec@microsoft.com'
    securityContactPhone: '555-555-5555'

    rgVnetName: rgVnetName
    rgAutomationName: rgAutomationName
    rgStorageName: rgStorageName
    rgComputeName: rgComputeName
    rgSecurityName: rgSecurityName
    rgMonitorName: rgMonitorName
    
    // Automation
    automationAccountName: '${testRunnerId}AutomationAccount'
    
    // VNET
    vnetName: '${testRunnerId}Vnet'
    vnetAddressSpace: '10.1.0.0/16'
    
    // Internal Foundational Elements (OZ) Subnet
    subnetFoundationalElementsName: 'foundationalElements'
    subnetFoundationalElementsPrefix: '10.1.1.0/25'
    
    // Presentation Zone (PAZ) Subnet
    subnetPresentationName: 'presentation'
    subnetPresentationPrefix: '10.1.2.0/25'
    
    // Application zone (RZ) Subnet
    subnetApplicationName: 'application'
    subnetApplicationPrefix: '10.1.3.0/25'
    
    // Data Zone (HRZ) Subnet
    subnetDataName: 'data'
    subnetDataPrefix: '10.1.4.0/25'
    
    // Delegated Subnets
    subnetSQLMIName: 'sqlmi'
    subnetSQLMIPrefix: '10.1.5.0/25'
    
    subnetDatabricksPublicName: 'databrickspublic'
    subnetDatabricksPublicPrefix: '10.1.6.0/25'
    
    subnetDatabricksPrivateName: 'databricksprivate'
    subnetDatabricksPrivatePrefix: '10.1.7.0/25'
    
    // Priavte Endpoint Subnet
    subnetPrivateEndpointsName: 'privateendpoints'
    subnetPrivateEndpointsPrefix: '10.1.8.0/25'
    
    // AKS Subnet
    subnetAKSName: 'aks'
    subnetAKSPrefix: '10.1.9.0/25'
    
    // Hub Virtual Network for virtual network peering
    hubVnetId: hubVnetId
    
    // Virtual Appliance IP
    egressVirtualApplianceIp: egressVirtualApplianceIp
    
    // Hub IP Ranges
    hubRFC1918IPRange: hubRFC1918IPRange
    hubRFC6598IPRange: hubRFC6598IPRange
    
    // AKS version
    aksVersion: '1.21.2'
    
    // parameters for Budget
    subscriptionBudget: {
      createBudget: false
    }
        
    // parameter for expiry of key vault secrets in days
    secretExpiryInDays: 365

    deploySQLDB: deploySQLDB
    deploySQLMI: deploySQLMI
    useCMK: useCMK

    sqldbUsername: 'azadmin'
    sqlmiUsername: 'azadmin'
   
    // parameters for Tags
    subscriptionTags: {
      'ISSO': '${testRunnerId}ISSO'
    }
    resourceTags: {
      'ClientOrganization': '${testRunnerId}Org'
      'CostCenter': '${testRunnerId}CostCenter'
      'DataSensitivity': '${testRunnerId}DataSensitivity'
      'ProjectContact': '${testRunnerId}ProjectContact'
      'ProjectName': tagProjectName
      'TechnicalContact': '${testRunnerId}TechContact'      
    }
  }
}


/*
  Clean up script will:
    - Delete the private endpoints in the Storage resource group
    - Delete all resource groups created by the landing zone
*/
var cleanUpScript = '''

  az account set -s {0}

  az network private-endpoint list -g {6} --query "[].id" -o json | jq -r '. | join(" ")' | xargs -t az network private-endpoint delete --ids 

  az group delete --name NetworkWatcherRG --yes --no-wait
  az group delete --name {1} --yes --no-wait
  az group delete --name {2} --yes --no-wait
  az group delete --name {3} --yes
  az group delete --name {4} --yes
  az group delete --name {5} --yes
  az group delete --name {6} --yes

'''

module testCleanup '../../../../azresources/util/deployment-script.bicep' = if (testRunnerCleanupAfterDeployment) {
  dependsOn: [
    test
  ]

  scope: resourceGroup(deploymentScriptResourceGroupName) 
  name: 'cleanup-test-${testRunnerId}'
  params: {
    deploymentScript: format(cleanUpScript, subscription().subscriptionId, rgAutomationName, rgMonitorName, rgSecurityName, rgComputeName, rgStorageName, rgVnetName)
    deploymentScriptName: 'cleanup-test-${testRunnerId}'
    deploymentScriptIdentityId: deploymentScriptIdentityId
    timeout: 'PT6H'
  }
}
