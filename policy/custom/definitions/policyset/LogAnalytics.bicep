// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

@description('Management Group scope for the policy definition.')
param policyDefinitionManagementGroupId string

var customPolicyDefinitionMgScope = tenantResourceId('Microsoft.Management/managementGroups', policyDefinitionManagementGroupId)

resource policyset_name 'Microsoft.Authorization/policySetDefinitions@2020-03-01' = {
  name: 'custom-enable-logging-to-loganalytics'
  properties: {
    displayName: 'Custom - Log Analytics for Azure Services'
    parameters: {
      logAnalytics: {
        type: 'String'
        metadata: {
          strongType: 'omsWorkspace'
          displayName: 'Log Analytics workspace resource id'
          description: 'Select Log Analytics workspace from dropdown list. If this workspace is outside of the scope of the assignment you must manually grant \'Log Analytics Contributor\' permissions (or similar) to the policy assignment\'s principal ID.'
        }
      }
      logAnalyticsWorkspaceId: {
        type: 'String'
        metadata: {
          displayName: 'Log Analytics workspace id'
          description: 'Log Analytics workspace id that should be used for VM logs'
        }
      }
      listOfResourceTypesToAuditDiagnosticSettings: {
        type: 'Array'
        metadata: {
          displayName: 'Resource Types'
          strongType: 'resourceTypes'
        }
        defaultValue: [
          'Microsoft.AnalysisServices/servers'
          'Microsoft.ApiManagement/service'
          'Microsoft.Network/applicationGateways'
          'Microsoft.Automation/automationAccounts'
          // 'Microsoft.ContainerInstance/containerGroups'  # Removed since it doesn't have any logs
          'Microsoft.ContainerRegistry/registries'
          'Microsoft.ContainerService/managedClusters'
          'Microsoft.Batch/batchAccounts'
          'Microsoft.Cdn/profiles/endpoints'
          'Microsoft.CognitiveServices/accounts'
          'Microsoft.DocumentDB/databaseAccounts'
          'Microsoft.DataFactory/factories'
          'Microsoft.DataLakeAnalytics/accounts'
          'Microsoft.DataLakeStore/accounts'
          'Microsoft.EventGrid/systemTopics'
          'Microsoft.EventGrid/eventSubscriptions'
          'Microsoft.EventGrid/topics'
          'Microsoft.EventHub/namespaces'
          'Microsoft.Network/expressRouteCircuits'
          'Microsoft.Network/azureFirewalls'
          'Microsoft.HDInsight/clusters'
          'Microsoft.Devices/IotHubs'
          'Microsoft.KeyVault/vaults'
          'Microsoft.Network/loadBalancers'
          'Microsoft.Logic/integrationAccounts'
          'Microsoft.Logic/workflows'
          'Microsoft.DBforMySQL/servers'
          //'Microsoft.Network/networkInterfaces' # Removed since it doesn't have any logs
          'Microsoft.Network/networkSecurityGroups'
          'Microsoft.Network/bastionHosts'
          'Microsoft.Kusto/clusters'
          'Microsoft.DBForMariaDB/servers'
          'Microsoft.DBforPostgreSQL/servers'
          'Microsoft.PowerBIDedicated/capacities'
          'Microsoft.Network/publicIPAddresses'
          'Microsoft.RecoveryServices/vaults'
          'Microsoft.Cache/redis'
          'Microsoft.Relay/namespaces'
          'Microsoft.Search/searchServices'
          'Microsoft.ServiceBus/namespaces'
          'Microsoft.SignalRService/SignalR'
          'Microsoft.Sql/servers/databases'
          //'Microsoft.Sql/servers/elasticPools' # Removed since it doesn't have any logs
          'Microsoft.StreamAnalytics/streamingjobs'
          'Microsoft.TimeSeriesInsights/environments'
          'Microsoft.Network/trafficManagerProfiles'
          //'Microsoft.Compute/virtualMachines' # Logs are collected through Microsoft Monitoring Agent
          //'Microsoft.Compute/virtualMachineScaleSets' Removed since it is not supported
          'Microsoft.Network/virtualNetworks'
          'Microsoft.Network/virtualNetworkGateways'
          'Microsoft.Web/sites'
          'Microsoft.Media/mediaservices'
        ]
      }
    }
    policyDefinitionGroups: [
      {
        name: 'BUILTIN'
        displayName: 'Additional Controls as Builtin Policies'
      }
      {
        name: 'CUSTOM'
        displayName: 'Additional Controls as Custom Policies'
      }
    ]
    policyDefinitions: [
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/5ee9e9ed-0b42-41b7-8c9c-3cfb2fbe2069'
        policyDefinitionReferenceId: toLower(replace('Deploy Log Analytics agent for Linux virtual machine scale sets', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
        }
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/3c1b3629-c8f8-4bf6-862c-037cb9094038'
        policyDefinitionReferenceId: toLower(replace('Deploy Log Analytics agent for Windows virtual machine scale sets', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
        }
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/4da21710-ce6f-4e06-8cdb-5cc4c93ffbee'
        policyDefinitionReferenceId: toLower(replace('Deploy Dependency agent for Linux virtual machines', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/1c210e94-a481-4beb-95fa-1571b434fb04'
        policyDefinitionReferenceId: toLower(replace('Deploy Dependency agent for Windows virtual machines', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/765266ab-e40e-4c61-bcb2-5a5275d0b7c0'
        policyDefinitionReferenceId: toLower(replace('Deploy Dependency agent for Linux virtual machine scale sets', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/3be22e3b-d919-47aa-805e-8985dbeb0ad9'
        policyDefinitionReferenceId: toLower(replace('Deploy Dependency agent for Windows virtual machine scale sets', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/6f8f98a4-f108-47cb-8e98-91a0d85cd474'
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic settings for storage accounts to Log Analytics workspace', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          StorageDelete: {
            value: 'True'
          }
          StorageWrite: {
            value: 'True'
          }
          StorageRead: {
            value: 'True'
          }
          Transaction: {
            value: 'True'
          }
        }
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/c84e5349-db6d-4769-805e-e14037dab9b5'
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Batch Account to Log Analytics workspace', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
        }
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/d56a5a7c-72d7-42bc-8ceb-3baf4c0eae03'
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Data Lake Analytics to Log Analytics workspace', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
        }
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/25763a0a-5783-4f14-969e-79d4933eb74b'
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Data Lake Storage Gen1 to Log Analytics workspace', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
        }
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/1f6e93e8-6b31-41b1-83f6-36e449a42579'
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Event Hub to Log Analytics workspace', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
        }
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/bef3f64c-5290-43b7-85b0-9b254eef4c47'
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Key Vault to Log Analytics workspace', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
        }
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/b889a06c-ec72-4b03-910a-cb169ee18721'
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Logic Apps to Log Analytics workspace', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
        }
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/08ba64b8-738f-4918-9686-730d2ed79c7d'
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Search Services to Log Analytics workspace', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
        }
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/04d53d87-841c-4f23-8a5b-21564380b55e'
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Service Bus to Log Analytics workspace', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
        }
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/237e0f7e-b0e8-4ec4-ad46-8c12cb66d673'
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Stream Analytics to Log Analytics workspace', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
        }
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/6c66c325-74c8-42fd-a286-a74b0e2939d8'
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Azure Kubernetes Service to Log Analytics workspace', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
        }
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/053d3325-282c-4e5c-b944-24faffd30d77'
        policyDefinitionReferenceId: toLower(replace('Deploy Log Analytics agent for Linux VMs', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
        }
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/0868462e-646c-4fe3-9ced-a733534b6a2c'
        policyDefinitionReferenceId: toLower(replace('Deploy Log Analytics agent for Windows VMs', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
        }
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/32133ab0-ee4b-4b44-98d6-042180979d50'
        policyDefinitionReferenceId: toLower(replace('Audit Log Analytics Agent Deployment - VM Image (OS) unlisted', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/5c3bc7b8-a64c-4e08-a9cd-7ff0f31e1138'
        policyDefinitionReferenceId: toLower(replace('Audit Log Analytics agent deployment in virtual machine scale sets - VM Image (OS) unlisted', ' ', '-'))
        parameters: {}
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/f47b5582-33ec-4c5c-87c0-b010a6b2e917'
        policyDefinitionReferenceId: toLower(replace('Audit Log Analytics Workspace for VM - Report Mismatch', ' ', '-'))
        parameters: {
          logAnalyticsWorkspaceId: {
            value: '[parameters(\'logAnalyticsWorkspaceId\')]'
          }
        }
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/752154a7-1e0f-45c6-a880-ac75a7e4f648'
        policyDefinitionReferenceId: toLower(replace('Public IP addresses should have resource logs enabled for Azure DDoS Protection Standard', ' ', '-'))
        parameters: {
          effect: {
            value: 'DeployIfNotExists'
          }
          profileName: {
            value: 'setByPolicy'
          }
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
        }
      }
      {
        groupNames: [
          'BUILTIN'
        ]
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/7f89b1eb-583c-429a-8828-af049802c1d9'
        policyDefinitionReferenceId: toLower(replace('Audit diagnostic setting', ' ', '-'))
        parameters: {
          listOfResourceTypes: {
            value: '[parameters(\'listOfResourceTypesToAuditDiagnosticSettings\')]'
          }
          logsEnabled: {
            value: true
          }
          metricsEnabled: {
            value: false
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Resources-Subscriptions')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Subscriptions to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          location: {
            value: 'canadacentral'
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Network-bastionHosts')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Bastion Hosts to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Databricks-workspaces')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Databricks to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Network-virtualNetworks')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Virtual Network to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Network-networkSecurityGroups')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Network Security Groups to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Network-applicationGateways')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Azure Application Gateway to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Network-azureFirewalls')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Azure Firewall to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Automation-automationAccounts')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Automation Account to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Sql-managedInstances')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for SQL Managed Instance to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Sql-servers-databases')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for SQLDB Database to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.DataFactory-factories')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Data Factory to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.MachineLearningServices-workspaces')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Azure Machine Learning workspaces to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.ContainerRegistry-registries')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Azure Container Registry to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Synapse-workspaces')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Synapse workspace to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.CognitiveServices-accounts-CognitiveServices')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Azure Cognitive Services to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.HealthcareApis-services-fhir-R4')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for FHIR R4 to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.HealthcareApis-services-fhir-STU3')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for FHIR STU3 to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.OperationalInsights-workspaces')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Log Analytics Workspace', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.AzureRecoveryVault-SiteRecovery')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Site Recovery Events to Log Analytics Workspace', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy-asr'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.AzureRecoveryVault-Backup')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Azure Backup Events to Log Analytics Workspace', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy-backup'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Web-sites-app')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for App Service to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Web-sites-functionapp')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Function App to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.AnalysisServices-servers')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Analysis Service to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Cache-Redis')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Redis Cache to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.DBForMariaDB-servers')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for MariaDB to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.DBforMySQL-servers')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for MySQL to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.DBforPostgreSQL-servers')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for PostgreSQL to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.DocumentDB-databaseAccounts')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Cosmos DB to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Kusto-clusters')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Data Explorer to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'Microsoft.TimeSeriesInsights-environments-Gen2')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Time Series Insights Gen 2 to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.ApiManagement-service')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for API Management to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Media-mediaservices')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Media Services to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Devices-IotHubs')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for IoT Hub to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.EventGrid-systemTopics')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Event Grid System Topic to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.EventGrid-topics')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Event Grid Topic to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Relay-namespaces')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Relay to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.SignalRService-SignalR')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for SignalR to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Cdn-profiles-endpoints')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for CDN Endpoint to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Cdn-profiles-frontdoor')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Frontdoor to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'global'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Network-expressRouteCircuits')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Express Route Circuit to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Network-loadBalancers')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Load Balancer to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Network-trafficmanagerprofiles')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Traffic Manager to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'global'
            ]
          }
        }
      }
      {
        groupNames: [
          'CUSTOM'
        ]
        policyDefinitionId: extensionResourceId(customPolicyDefinitionMgScope, 'Microsoft.Authorization/policyDefinitions', 'LA-Microsoft.Network-virtualNetworkGateways')
        policyDefinitionReferenceId: toLower(replace('Deploy Diagnostic Settings for Virtual Network Gateway to Log Analytics Workspaces', ' ', '-'))
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalytics\')]'
          }
          profileName: {
            value: 'setByPolicy'
          }
          azureRegions: {
            value: [
              'canadacentral'
              'canadaeast'
            ]
          }
        }
      }
    ]
  }
}
