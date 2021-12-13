// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------
@description('Azure Firewall Policy Name')
param name string

resource policy 'Microsoft.Network/firewallPolicies@2021-02-01' = {
  name: name
  location: resourceGroup().location
  properties: {
    sku: {
      tier: 'Premium'
    }
    dnsSettings: {
      enableProxy: true
    }
    intrusionDetection: {
      mode: 'Alert'
    }
    threatIntelMode: 'Alert'
  }

  // Azure / Priority: 200
  resource azureCollectionGroup 'ruleCollectionGroups@2021-02-01' = {
    name: 'Azure'
    properties: {
      priority: 200
      ruleCollections: [
        // Azure AD
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'Azure AD'
          priority: 100
          action: {
            type: 'Allow'
          }
          rules: [
            {
              ruleType: 'NetworkRule'
              name: 'Azure AD Tag'
              destinationAddresses: [
                'AzureActiveDirectory'
              ]
              destinationPorts: [
                '443'
              ]
              sourceAddresses: [
                '*'
              ]
              ipProtocols: [
                'TCP'
              ]
            }
            {
              ruleType: 'NetworkRule'
              name: 'Azure AD FQDNs'
              destinationFqdns: [
                'aadcdn.msauth.net'
                'aadcdn.msftauth.net'
              ]
              destinationPorts: [
                '443'
              ]
              sourceAddresses: [
                '*'
              ]
              ipProtocols: [
                'TCP'
              ]
            }
          ]
        }
        // Azure Resource Manager
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'Azure Resource Manager'
          priority: 105
          action: {
            type: 'Allow'
          }
          rules: [
            {
              ruleType: 'NetworkRule'
              name: 'Azure Resource Manager Tag'
              destinationAddresses: [
                'AzureResourceManager'
              ]
              destinationPorts: [
                '443'
              ]
              sourceAddresses: [
                '*'
              ]
              ipProtocols: [
                'TCP'
              ]
            }
          ]
        }
        // Azure Portal
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'Azure Portal'
          priority: 110
          action: {
            type: 'Allow'
          }
          rules: [
            {
              ruleType: 'NetworkRule'
              name: 'Azure Portal Tag'
              destinationAddresses: [
                'AzurePortal'
              ]
              destinationPorts: [
                '443'
              ]
              sourceAddresses: [
                '*'
              ]
              ipProtocols: [
                'TCP'
              ]
            }
            {
              ruleType: 'NetworkRule'
              name: 'Azure Portal FQDNs'
              destinationFqdns: [
                'afd.hosting.portal.azure.net'
                'bmxservice.trafficmanager.net'
              ]
              destinationPorts: [
                '443'
              ]
              sourceAddresses: [
                '*'
              ]
              ipProtocols: [
                'TCP'
              ]
            }
          ]
        }
        // Azure Monitor
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'Azure Monitor'
          priority: 120
          action: {
            type: 'Allow'
          }
          rules: [
            {
              ruleType: 'NetworkRule'
              name: 'Azure Monitor Tag'
              destinationAddresses: [
                'AzureMonitor'
              ]
              destinationPorts: [
                '443'
              ]
              sourceAddresses: [
                '*'
              ]
              ipProtocols: [
                'TCP'
              ]
            }
          ]
        }
        // Azure Automation & Guest Configuration
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'Azure Automation and Guest Configuration'
          action: {
            type: 'Allow'
          }
          priority: 130
          rules: [
            {
              ruleType: 'NetworkRule'
              name: 'GuestAndHybridManagement Tag'
              destinationAddresses: [
                'GuestAndHybridManagement'
              ]
              destinationPorts: [
                '443'
              ]
              sourceAddresses: [
                '*'
              ]
              ipProtocols: [
                'TCP'
              ]
            }
            {
              ruleType: 'NetworkRule'
              name: 'Guest Configuration - FQDNs'
              destinationFqdns: [
                'agentserviceapi.guestconfiguration.azure.com'
                'oaasguestconfigwcuss1.blob.core.windows.net'
              ]
              destinationPorts: [
                '443'
              ]
              sourceAddresses: [
                '*'
              ]
              ipProtocols: [
                'TCP'
              ]
            }
          ]
        }
        // Data Factory
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'Azure Data Factory'
          action: {
            type: 'Allow'
          }
          priority: 139
          rules: [
            {
              ruleType: 'NetworkRule'
              name: 'Data Factory Tag'
              destinationAddresses: [
                'DataFactory'
                'DataFactoryManagement'
              ]
              destinationPorts: [
                '443'
              ]
              sourceAddresses: [
                '*'
              ]
              ipProtocols: [
                'TCP'
              ]
            }
          ]
        }
        // Azure Databricks
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'Azure Databricks'
          action: {
            type: 'Allow'
          }
          priority: 140
          rules: [
            {
              ruleType: 'NetworkRule'
              name: 'Azure Databricks Tag'
              destinationAddresses: [
                'AzureDatabricks'
              ]
              destinationPorts: [
                '443'
              ]
              sourceAddresses: [
                '*'
              ]
              ipProtocols: [
                'TCP'
              ]
            }
            {
              ruleType: 'NetworkRule'
              name: 'databricks.com'
              destinationFqdns: [
                'sourcemaps.dev.databricks.com'
              ]
              destinationPorts: [
                '443'
              ]
              sourceAddresses: [
                '*'
              ]
              ipProtocols: [
                'TCP'
              ]
            }
          ]
        }
        // Azure Machine Learning
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'Azure ML'
          action: {
            type: 'Allow'
          }
          priority: 150
          rules: [
            {
              ruleType: 'NetworkRule'
              name: 'Azure ML Tag'
              destinationAddresses: [
                'AzureMachineLearning'
              ]
              destinationPorts: [
                '443'
              ]
              sourceAddresses: [
                '*'
              ]
              ipProtocols: [
                'TCP'
              ]
            }
          ]
        }
        // Signal R
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'SignalR'
          action: {
            type: 'Allow'
          }
          priority: 160
          rules: [
            {
              ruleType: 'NetworkRule'
              name: 'SignalR Tag'
              destinationAddresses: [
                'AzureSignalR'
              ]
              destinationPorts: [
                '443'
              ]
              sourceAddresses: [
                '*'
              ]
              ipProtocols: [
                'TCP'
              ]
            }
          ]
        }
        // Azure Synapse Analytics Application Rules
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'Synapse Analytics FQDNs'
          action: {
            type: 'Allow'
          }
          priority: 997
          rules: [
            {
              ruleType: 'ApplicationRule'
              name: 'Synapse Analytics FQDNs'
              targetFqdns: [
                'web.azuresynapse.net'
                '*.dev.azuresynapse.net'
                '*.sql.azuresynapse.net'
              ]
              sourceAddresses: [
                '*'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
          ]
        }
        // Azure Data Factory Application Rules
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'Azure Data Factory FQDNs'
          action: {
            type: 'Allow'
          }
          priority: 998
          rules: [
            {
              ruleType: 'ApplicationRule'
              name: 'Azure Data Factory FQDNs'
              targetFqdns: [
                'adf.azure.com'

                // https://docs.microsoft.com/en-us/azure/data-factory/data-factory-ux-troubleshoot-guide
                'dpcanadacentral.svc.datafactory.azure.com'
                'dpcanadaeast.svc.datafactory.azure.com'
              ]
              sourceAddresses: [
                '*'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
          ]
        }
        // Azure Machine Learning Application Rules
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'Azure ML FQDNs'
          action: {
            type: 'Allow'
          }
          priority: 999
          rules: [
            {
              ruleType: 'ApplicationRule'
              name: 'AzureML Notebooks FQDNs'
              targetFqdns: [
                '*.notebooks.azure.net'
              ]
              sourceAddresses: [
                '*'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              ruleType: 'ApplicationRule'
              name: 'AzureML API FQDNs'
              targetFqdns: [
                '*.api.azureml.ms'
              ]
              sourceAddresses: [
                '*'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              ruleType: 'ApplicationRule'
              name: 'AzureML Samples FQDNs'
              targetFqdns: [
                'notebieastus.blob.core.windows.net'
              ]
              sourceAddresses: [
                '*'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
          ]
        }
        // Qualys Rule Collection
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          priority: 1000
          name: 'Microsoft Defender for Cloud - Qualys'
          action: {
            type: 'Allow'
          }
          rules: [
            // Reference:  https://docs.microsoft.com/azure/security-center/deploy-vulnerability-assessment-vm#deploy-the-integrated-scanner-to-your-azure-and-hybrid-machines
            {
              ruleType: 'ApplicationRule'
              name: 'US Data Center'
              targetFqdns: [
                'qagpublic.qg3.apps.qualys.com'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
              sourceAddresses: [
                '*'
              ]
            }
            {
              ruleType: 'ApplicationRule'
              name: 'European Data Center'
              targetFqdns: [
                'qagpublic.qg2.apps.qualys.eu'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
              sourceAddresses: [
                '*'
              ]
            }
          ]
        }
        // Azure Backup
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'Azure Backup'
          action: {
            type: 'Allow'
          }
          priority: 1100
          rules: [
            {
              ruleType: 'ApplicationRule'
              name: 'Azure Backup'
              fqdnTags: [
                'AzureBackup'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
              sourceAddresses: [
                '*'
              ]
            }
          ]
        }
      ]
    }
  }

  // Windows // Priority 1000
  resource windowsCollectionGroup 'ruleCollectionGroups@2021-02-01' = {
    dependsOn: [
      azureCollectionGroup
    ]

    name: 'Windows'
    properties: {
      priority: 1000
      ruleCollections: [
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'Windows KMS'
          action: {
            type: 'Allow'
          }
          priority: 100
          rules: [
            {
              ruleType: 'NetworkRule'
              name: 'Azure Global - IP'
              destinationAddresses: [
                '23.102.135.246'
              ]
              destinationPorts: [
                '1688'
              ]
              ipProtocols: [
                'TCP'
              ]
              sourceAddresses: [
                '*'
              ]
            }
            {
              ruleType: 'NetworkRule'
              name: 'Azure Global - FQDN'
              destinationFqdns: [
                'kms.core.windows.net'
              ]
              destinationPorts: [
                '1688'
              ]
              ipProtocols: [
                'TCP'
              ]
              sourceAddresses: [
                '*'
              ]
            }
            {
              // https://support.microsoft.com/en-us/topic/windows-activation-or-validation-fails-with-error-code-0x8004fe33-a9afe65e-230b-c1ed-3414-39acd7fddf52
              ruleType: 'NetworkRule'
              name: 'Licensing FQDNs'
              destinationFqdns: [
                'activation.sls.microsoft.com'
                'activation-v2.sls.microsoft.com'

                'crl.microsoft.com'

                'displaycatalog.mp.microsoft.com'
                'displaycatalog.md.mp.microsoft.com'

                'licensing.mp.microsoft.com'
                'licensing.md.mp.microsoft.com'

                'purchase.mp.microsoft.com'
                'purchase.md.mp.microsoft.com'

                'validation.sls.microsoft.com'
                'validation-v2.sls.microsoft.com'
              ]
              destinationPorts: [
                '1688'
              ]
              ipProtocols: [
                'TCP'
              ]
              sourceAddresses: [
                '*'
              ]
            }
          ]
        }
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'Windows NTP'
          action: {
            type: 'Allow'
          }
          priority: 150
          rules: [
            {
              ruleType: 'NetworkRule'
              name: 'time.windows.com - FQDN'
              destinationFqdns: [
                'time.windows.com'
              ]
              destinationPorts: [
                '123'
              ]
              ipProtocols: [
                'UDP'
              ]
              sourceAddresses: [
                '*'
              ]
            }
            {
              ruleType: 'NetworkRule'
              name: 'time.windows.com - IP'
              destinationAddresses: [
                '168.61.215.74'
              ]
              destinationPorts: [
                '123'
              ]
              ipProtocols: [
                'UDP'
              ]
              sourceAddresses: [
                '*'
              ]
            }
          ]
        }
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'Windows Diagnostics'
          action: {
            type: 'Allow'
          }
          priority: 200
          rules: [
            {
              ruleType: 'ApplicationRule'
              name: 'Windows Diagnostics Tag'
              fqdnTags: [
                'WindowsDiagnostics'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
              sourceAddresses: [
                '*'
              ]
            }
            {
              ruleType: 'ApplicationRule'
              name: 'Windows Diagnostics FQDNs'
              targetFqdns: [
                'umwatson.events.data.microsoft.com'
                'v20.events.data.microsoft.com'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
              sourceAddresses: [
                '*'
              ]
            }
          ]
        }
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'Microsoft Active Protection Service (MAPS) Tag'
          action: {
            type: 'Allow'
          }
          priority: 210
          rules: [
            {
              ruleType: 'ApplicationRule'
              name: 'Microsoft Active Protection Service (MAPS)'
              fqdnTags: [
                'MicrosoftActiveProtectionService'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
              sourceAddresses: [
                '*'
              ]
            }
          ]
        }
        {
          // https://docs.microsoft.com/azure/firewall/fqdn-tags
          // https://docs.microsoft.com/mem/configmgr/sum/get-started/install-a-software-update-point
          name: 'Windows Update'
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          priority: 1000
          action: {
            type: 'Allow'
          }
          rules: [
            {
              ruleType: 'ApplicationRule'
              name: 'Windows Update Tag'
              fqdnTags: [
                'WindowsUpdate'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
              sourceAddresses: [
                '*'
              ]
            }
          ]
        }
      ]
    }
  }

  // AKS required FQDNs 
  // https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic
  resource AKSCollectionGroup 'ruleCollectionGroups@2021-02-01' = {
    dependsOn: [
      windowsCollectionGroup
    ]
    name: 'Aks'
    properties: {
      priority: 1200
      ruleCollections: [
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'Ubuntu NTP'
          action: {
            type: 'Allow'
          }
          priority: 100
          rules: [
            {
              ruleType: 'NetworkRule'
              name: 'Ubuntu NTP - FQDN'
              destinationAddresses: [
                'ntp.ubuntu.com'
              ]
              destinationPorts: [
                '123'
              ]
              ipProtocols: [
                'UDP'
              ]
              sourceAddresses: [
                '*'
              ]
            }
          ]
        }
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'AKS Azure Global required FQDNs'
          action: {
            type: 'Allow'
          }
          priority: 150
          rules: [
            {
              ruleType: 'ApplicationRule'
              name: 'AKS required FQDNs'
              targetFqdns: [
                '*.hcp.canadacentral.azmk8s.io'
                'mcr.microsoft.com'
                '*.data.mcr.microsoft.com'
                'management.azure.com'
                'login.microsoftonline.com'
                'packages.microsoft.com'
                'acs-mirror.azureedge.net'
                'canadacentral.dp.kubernetesconfiguration.azure.com'
                'canadaeast.dp.kubernetesconfiguration.azure.com'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
              sourceAddresses: [
                '*'
              ]
            }
            {
              ruleType: 'ApplicationRule'
              name: 'AKS Addons required FQDNs'
              targetFqdns: [
                'dc.services.visualstudio.com'
                '*.ods.opinsights.azure.com'
                '*.oms.opinsights.azure.com'
                '*.monitoring.azure.com'
                'data.policy.core.windows.net'
                'store.policy.core.windows.net'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
              sourceAddresses: [
                '*'
              ]
            }
          ]
        }
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'AKS Optional recommended FQDNs'
          action: {
            type: 'Allow'
          }
          priority: 200
          rules: [
            {
              ruleType: 'ApplicationRule'
              name: 'AKS Optional recommended FQDNs'
              targetFqdns: [
                'security.ubuntu.com'
                'azure.archive.ubuntu.com'
                'changelogs.ubuntu.com'
              ]
              protocols: [
                {
                  port: 80
                  protocolType: 'Http'
                }
              ]
              sourceAddresses: [
                '*'
              ]
            }
          ]
        }
      ]        
    }
  }  

  // RedHat / Priority: 2000
  resource redhatCollectionGroup 'ruleCollectionGroups@2021-02-01' = {
    dependsOn: [
      AKSCollectionGroup
    ]

    name: 'RedHat'
    properties: {
      priority: 2000
      ruleCollections: [
        {
          // https://docs.microsoft.com/azure/virtual-machines/workloads/redhat/redhat-rhui#the-ips-for-the-rhui-content-delivery-servers
          name: 'RedHat Update Infrastructure'
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          priority: 100
          action: {
            type: 'Allow'
          }
          rules: [
            {
              ruleType: 'NetworkRule'
              name: 'Azure Global'
              destinationAddresses: [
                '13.91.47.76'
                '40.85.190.91'
                '52.187.75.218'
                '52.174.163.213'
                '52.237.203.198'
              ]
              destinationPorts: [
                '*'
              ]
              sourceAddresses: [
                '*'
              ]
              ipProtocols: [
                'TCP'
              ]
            }
            {
              ruleType: 'NetworkRule'
              name: 'Azure US Government'
              destinationAddresses: [
                '13.72.186.193'
                '13.72.14.155'
                '52.244.249.194'
              ]
              destinationPorts: [
                '*'
              ]
              sourceAddresses: [
                '*'
              ]
              ipProtocols: [
                'TCP'
              ]
            }
            {
              ruleType: 'NetworkRule'
              name: 'Azure Germany'
              destinationAddresses: [
                '51.5.243.77'
                '51.4.228.145'
              ]
              destinationPorts: [
                '*'
              ]
              sourceAddresses: [
                '*'
              ]
              ipProtocols: [
                'TCP'
              ]
            }
          ]
        }
      ]
    }
  }
}

output policyId string = policy.id
