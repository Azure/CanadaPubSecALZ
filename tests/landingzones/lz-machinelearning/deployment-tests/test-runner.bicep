// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

@description('Location for the deployment.')
param location string = deployment().location

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

var rgNetworking = '${testRunnerId}Network'
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
    location: location

    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId

    securityCenter: {
      email: 'alzcanadapubsec@microsoft.com'
      phone: '555-555-5555'
    }

    subscriptionTags: {
      ISSO: '${testRunnerId}ISSO'
    }

    resourceTags: {
      ClientOrganization: '${testRunnerId}Org'
      CostCenter: '${testRunnerId}CostCenter'
      DataSensitivity: '${testRunnerId}DataSensitivity'
      ProjectContact: '${testRunnerId}ProjectContact'
      ProjectName: tagProjectName
      TechnicalContact: '${testRunnerId}TechContact'
    }

    subscriptionBudget: {
      createBudget: false
    }

    resourceGroups: {
      automation: rgAutomationName
      compute: rgComputeName
      monitor: rgMonitorName
      networking: rgNetworking
      networkWatcher: 'NetworkWatcherRG'
      security: rgSecurityName
      storage: rgStorageName
    }

    useCMK: useCMK

    automation: {
      name: '${testRunnerId}AutomationAccount'
    }

    aks: {
      version: '1.21.2'
    }

    keyVault: {
      secretExpiryInDays: 365
    }

    sqldb: {
      value: {
        enabled: deploySQLDB
        aadAuthenticationOnly: false 
        sqlAuthenticationUsername: 'azadmin'
      }
    }

    sqlmi: {
      enabled: deploySQLMI
      username: 'azadmin'
    }

    aml: {
      enableHbiWorkspace: false
    }

    appServiceLinuxContainer: {
      enabled: true
      skuName: 'P1V2'
      skuTier: 'Premium'
      enablePrivateEndpoint: true
    }

    hubNetwork: {
      virtualNetworkId: hubVnetId
      egressVirtualApplianceIp: egressVirtualApplianceIp

      rfc1918IPRange: hubRFC1918IPRange
      rfc6598IPRange: hubRFC6598IPRange

      privateDnsManagedByHub: false
      privateDnsManagedByHubSubscriptionId: ''
      privateDnsManagedByHubResourceGroupName: ''
    }

    network: {
      peerToHubVirtualNetwork: true
      useRemoteGateway: false
      name: 'vnet'
      dnsServers: []
      addressPrefixes: [
        '10.2.0.0/16'
      ]
      subnets: {
        oz: {
          comments: 'App Management Zone (OZ)'
          name: 'oz'
          addressPrefix: '10.2.1.0/25'
        }
        paz: {
          comments: 'Presentation Zone (PAZ)'
          name: 'paz'
          addressPrefix: '10.2.2.0/25'
        }
        rz: {
          comments: 'Application Zone (RZ)'
          name: 'rz'
          addressPrefix: '10.2.3.0/25'
        }
        hrz: {
          comments: 'Data Zone (HRZ)'
          name: 'hrz'
          addressPrefix: '10.2.4.0/25'
        }
        privateEndpoints: {
          comments: 'Private Endpoints Subnet'
          name: 'privateendpoints'
          addressPrefix: '10.2.5.0/25'
        }
        sqlmi: {
          comments: 'SQL Managed Instances Delegated Subnet'
          name: 'sqlmi'
          addressPrefix: '10.2.6.0/25'
        }
        databricksPublic: {
          comments: 'Databricks Public Delegated Subnet'
          name: 'databrickspublic'
          addressPrefix: '10.2.7.0/25'
        }
        databricksPrivate: {
          comments: 'Databricks Private Delegated Subnet'
          name: 'databricksprivate'
          addressPrefix: '10.2.8.0/25'
        }
        aks: {
          comments: 'AKS Subnet'
          name: 'aks'
          addressPrefix: '10.2.9.0/25'
        }
        appService: {
          comments: 'App Service Subnet'
          name: 'appService'
          addressPrefix: '10.2.10.0/25'
        }
      }
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
    deploymentScript: format(cleanUpScript, subscription().subscriptionId, rgAutomationName, rgMonitorName, rgSecurityName, rgComputeName, rgStorageName, rgNetworking)
    deploymentScriptName: 'cleanup-test-${testRunnerId}'
    deploymentScriptIdentityId: deploymentScriptIdentityId
    timeout: 'PT6H'

    location: location
  }
}
