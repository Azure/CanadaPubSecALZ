# Schema Change History

## Landing Zone Schemas

### August 10, 2022

* [Schema definition update for Logging](../../docs/archetypes/logging.md)

    <details>
        <summary>Expand/collapse</summary>

    ```json
    "dataCollectionRule": {
      "value": {
        "enabled": true,
        "name": "DCR-AzureMonitorLogs",
        "windowsEventLogs": [
          {
              "streams": [
                  "Microsoft-Event"
              ],
              "xPathQueries": [
                  "Application!*[System[(Level=1 or Level=2 or Level=3)]]",
                  "Security!*[System[(band(Keywords,13510798882111488))]]",
                  "System!*[System[(Level=1 or Level=2 or Level=3)]]"
              ],
              "name": "eventLogsDataSource"
          }
        ],
        "syslog": [
          {
              "streams": [
                  "Microsoft-Syslog"
              ],
              "facilityNames": [
                  "auth",
                  "authpriv",
                  "cron",
                  "daemon",
                  "mark",
                  "kern",
                  "local0",
                  "local1",
                  "local2",
                  "local3",
                  "local4",
                  "local5",
                  "local6",
                  "local7",
                  "lpr",
                  "mail",
                  "news",
                  "syslog",
                  "user",
                  "uucp"
              ],
              "logLevels": [
                  "Debug",
                  "Info",
                  "Notice",
                  "Warning",
                  "Error",
                  "Critical",
                  "Alert",
                  "Emergency"
              ],
              "name": "sysLogsDataSource"
          }
        ]
      }
    }
    ```
    </details>
### April 25, 2022

* [Schema definition update for Hub Networking with Azure Firewall](../../docs/archetypes/hubnetwork-azfw.md)

    <details>
      <summary>Expand/collapse</summary>

    ```json
    {
      "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {
        "serviceHealthAlerts": {
          "value": {
            "resourceGroupName": "pubsec-service-health",
            "incidentTypes": [
              "Incident",
              "Security"
            ],
            "regions": [
              "Global",
              "Canada East",
              "Canada Central"
            ],
            "receivers": {
              "app": [
                "alzcanadapubsec@microsoft.com"
              ],
              "email": [
                "alzcanadapubsec@microsoft.com"
              ],
              "sms": [
                {
                  "countryCode": "1",
                  "phoneNumber": "6045555555"
                }
              ],
              "voice": [
                {
                  "countryCode": "1",
                  "phoneNumber": "6045555555"
                }
              ]
            },
            "actionGroupName": "ALZ action group",
            "actionGroupShortName": "alz-alert",
            "alertRuleName": "ALZ alert rule",
            "alertRuleDescription": "Alert rule for Azure Landing Zone"
          }
        },
        "securityCenter": {
          "value": {
            "email": "alzcanadapubsec@microsoft.com",
            "phone": "6045555555"
          }
        },
        "subscriptionRoleAssignments": {
          "value": [
            {
              "comments": "Built-in Contributor Role",
              "roleDefinitionId": "b24988ac-6180-42a0-ab88-20f7382dd24c",
              "securityGroupObjectIds": [
                "38f33f7e-a471-4630-8ce9-c6653495a2ee"
              ]
            }
          ]
        },
        "subscriptionBudget": {
          "value": {
            "createBudget": false
          }
        },
        "subscriptionTags": {
          "value": {
            "ISSO": "isso-tbd"
          }
        },
        "resourceTags": {
          "value": {
            "ClientOrganization": "client-organization-tag",
            "CostCenter": "cost-center-tag",
            "DataSensitivity": "data-sensitivity-tag",
            "ProjectContact": "project-contact-tag",
            "ProjectName": "project-name-tag",
            "TechnicalContact": "technical-contact-tag"
          }
        },
        "privateDnsZones": {
          "value": {
            "enabled": true,
            "resourceGroupName": "pubsec-dns"
          }
        },
        "ddosStandard": {
          "value": {
            "enabled": false,
            "resourceGroupName": "pubsec-ddos",
            "planName": "ddos-plan"
          }
        },
        "publicAccessZone": {
          "value": {
            "enabled": true,
            "resourceGroupName": "pubsec-public-access-zone"
          }
        },
        "managementRestrictedZone": {
          "value": {
            "enabled": true,
            "resourceGroupName": "pubsec-management-restricted-zone",
            "network": {
              "name": "management-restricted-vnet",
              "addressPrefixes": ["10.18.4.0/22"],
              "subnets": [
                {
                  "comments": "Management (Access Zone) Subnet",
                  "name": "MazSubnet",
                  "addressPrefix": "10.18.4.0/25",
                  "nsg": {
                      "enabled": true
                  },
                  "udr": {
                      "enabled": true
                  }
                },
                {
                  "comments": "Infrastructure Services (Restricted Zone) Subnet",
                  "name": "InfSubnet",
                  "addressPrefix": "10.18.4.128/25",
                  "nsg": {
                      "enabled": true
                  },
                  "udr": {
                      "enabled": true
                  }
                },
                {
                  "comments": "Security Services (Restricted Zone) Subnet",
                  "name": "SecSubnet",
                  "addressPrefix": "10.18.5.0/26",
                  "nsg": {
                      "enabled": true
                  },
                  "udr": {
                      "enabled": true
                  }
                },
                {
                  "comments": "Logging Services (Restricted Zone) Subnet",
                  "name": "LogSubnet",
                  "addressPrefix": "10.18.5.64/26",
                  "nsg": {
                      "enabled": true
                  },
                  "udr": {
                      "enabled": true
                  }
                },
                {
                  "comments": "Core Management Interfaces (Restricted Zone) Subnet",
                  "name": "MgmtSubnet",
                  "addressPrefix": "10.18.5.128/26",
                  "nsg": {
                      "enabled": true
                  },
                  "udr": {
                      "enabled": true
                  }
                }
              ]
            }
          }
        },
        "hub": {
          "value": {
            "resourceGroupName": "pubsec-hub-networking",
            "bastion": {
              "enabled": true,
              "name": "bastion",
              "sku": "Standard",
              "scaleUnits": 2
            },
            "azureFirewall": {
              "name": "pubsecAzureFirewall",
              "availabilityZones": ["1", "2", "3"],
              "forcedTunnelingEnabled": false,
              "forcedTunnelingNextHop": "10.17.1.4"
            },
            "network": {
              "name": "hub-vnet",
              "addressPrefixes": [
                "10.18.0.0/22",
                "100.60.0.0/16"
              ],
              "addressPrefixBastion": "192.168.0.0/16",
              "subnets": {
                "gateway": {
                  "comments": "Gateway Subnet used for VPN and/or Express Route connectivity",
                  "name": "GatewaySubnet",
                  "addressPrefix": "10.18.0.0/27"
                },
                "firewall": {
                  "comments": "Azure Firewall",
                  "name": "AzureFirewallSubnet",
                  "addressPrefix": "10.18.1.0/24"
                },
                "firewallManagement": {
                  "comments": "Azure Firewall Management",
                  "name": "AzureFirewallManagementSubnet",
                  "addressPrefix": "10.18.2.0/26"
                },
                "bastion": {
                  "comments": "Azure Bastion",
                  "name": "AzureBastionSubnet",
                  "addressPrefix": "192.168.0.0/24"
                },
                "publicAccess": {
                  "comments": "Public Access Zone (Application Gateway)",
                  "name": "PAZSubnet",
                  "addressPrefix": "100.60.1.0/24"
                },
                "optional": []
              }
            }
          }
        },
        "networkWatcher": {
          "value": {
            "resourceGroupName": "NetworkWatcherRG"
          }
        }
      }
    }
    ```

    </details>

* [Schema definition update for Hub Networking with Network Virtual Appliances (NVA)](../../docs/archetypes/hubnetwork-nva-fortigate.md)

    <details>
      <summary>Expand/collapse</summary>

    ```json
    {
      "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {
        "serviceHealthAlerts": {
          "value": {
            "resourceGroupName": "pubsec-service-health",
            "incidentTypes": [
              "Incident",
              "Security"
            ],
            "regions": [
              "Global",
              "Canada East",
              "Canada Central"
            ],
            "receivers": {
              "app": [
                "alzcanadapubsec@microsoft.com"
              ],
              "email": [
                "alzcanadapubsec@microsoft.com"
              ],
              "sms": [
                {
                  "countryCode": "1",
                  "phoneNumber": "6045555555"
                }
              ],
              "voice": [
                {
                  "countryCode": "1",
                  "phoneNumber": "6045555555"
                }
              ]
            },
            "actionGroupName": "ALZ action group",
            "actionGroupShortName": "alz-alert",
            "alertRuleName": "ALZ alert rule",
            "alertRuleDescription": "Alert rule for Azure Landing Zone"
          }
        },
        "securityCenter": {
          "value": {
            "email": "alzcanadapubsec@microsoft.com",
            "phone": "6045555555"
          }
        },
        "subscriptionRoleAssignments": {
          "value": [
            {
              "comments": "Built-in Contributor Role",
              "roleDefinitionId": "b24988ac-6180-42a0-ab88-20f7382dd24c",
              "securityGroupObjectIds": [
                "38f33f7e-a471-4630-8ce9-c6653495a2ee"
              ]
            }
          ]
        },
        "subscriptionBudget": {
          "value": {
            "createBudget": false
          }
        },
        "subscriptionTags": {
          "value": {
            "ISSO": "isso-tbd"
          }
        },
        "resourceTags": {
          "value": {
            "ClientOrganization": "client-organization-tag",
            "CostCenter": "cost-center-tag",
            "DataSensitivity": "data-sensitivity-tag",
            "ProjectContact": "project-contact-tag",
            "ProjectName": "project-name-tag",
            "TechnicalContact": "technical-contact-tag"
          }
        },
        "privateDnsZones": {
          "value": {
            "enabled": true,
            "resourceGroupName": "pubsec-dns"
          }
        },
        "ddosStandard": {
          "value": {
            "enabled": false,
            "resourceGroupName": "pubsec-ddos",
            "planName": "ddos-plan"
          }
        },
        "publicAccessZone": {
          "value": {
            "enabled": true,
            "resourceGroupName": "pubsec-public-access-zone"
          }
        },
        "managementRestrictedZone": {
          "value": {
            "enabled": true,
            "resourceGroupName": "pubsec-management-restricted-zone",
            "network": {
              "name": "management-restricted-vnet",
              "addressPrefixes": ["10.18.4.0/22"],
              "subnets": [
                {
                  "comments": "Management (Access Zone) Subnet",
                  "name": "MazSubnet",
                  "addressPrefix": "10.18.4.0/25",
                  "nsg": {
                      "enabled": true
                  },
                  "udr": {
                      "enabled": true
                  }
                },
                {
                  "comments": "Infrastructure Services (Restricted Zone) Subnet",
                  "name": "InfSubnet",
                  "addressPrefix": "10.18.4.128/25",
                  "nsg": {
                      "enabled": true
                  },
                  "udr": {
                      "enabled": true
                  }
                },
                {
                  "comments": "Security Services (Restricted Zone) Subnet",
                  "name": "SecSubnet",
                  "addressPrefix": "10.18.5.0/26",
                  "nsg": {
                      "enabled": true
                  },
                  "udr": {
                      "enabled": true
                  }
                },
                {
                  "comments": "Logging Services (Restricted Zone) Subnet",
                  "name": "LogSubnet",
                  "addressPrefix": "10.18.5.64/26",
                  "nsg": {
                      "enabled": true
                  },
                  "udr": {
                      "enabled": true
                  }
                },
                {
                  "comments": "Core Management Interfaces (Restricted Zone) Subnet",
                  "name": "MgmtSubnet",
                  "addressPrefix": "10.18.5.128/26",
                  "nsg": {
                      "enabled": true
                  },
                  "udr": {
                      "enabled": true
                  }
                }
              ]
            }
          }
        },
        "hub": {
          "value": {
            "resourceGroupName": "pubsec-hub-networking",
            "bastion": {
              "enabled": true,
              "name": "bastion",
              "sku": "Standard",
              "scaleUnits": 2
            },
            "network": {
              "name": "hub-vnet",
              "addressPrefixes": [
                "10.18.0.0/22",
                "100.60.0.0/16"
              ],
              "addressPrefixBastion": "192.168.0.0/16",
              "subnets": {
                "gateway": {
                  "comments": "Gateway Subnet used for VPN and/or Express Route connectivity",
                  "name": "GatewaySubnet",
                  "addressPrefix": "10.18.1.0/27"
                },
                "bastion": {
                  "comments": "Azure Bastion",
                  "name": "AzureBastionSubnet",
                  "addressPrefix": "192.168.0.0/24"
                },
                "public": {
                  "comments": "Public Subnet Name (External Facing (Internet/Ground))",
                  "name": "PublicSubnet",
                  "addressPrefix": "100.60.0.0/24"
                },
                "publicAccessZone": {
                  "comments": "Public Access Zone (i.e. Application Gateway)",
                  "name": "PAZSubnet",
                  "addressPrefix": "100.60.1.0/24"
                },
                "externalAccessNetwork": {
                  "comments": "External Access Network",
                  "name": "EanSubnet",
                  "addressPrefix": "10.18.0.0/27"
                },
                "nonProductionInternal": {
                  "comments": "Non-production Internal for firewall appliances (Internal Facing Non-Production Traffic)",
                  "name": "DevIntSubnet",
                  "addressPrefix": "10.18.0.64/27"
                },
                "productionInternal": {
                  "comments": "Production Internal for firewall appliances (Internal Facing Production Traffic)",
                  "name": "PrdIntSubnet",
                  "addressPrefix": "10.18.0.32/27"
                },
                "managementRestrictedZoneInternal": {
                  "comments": "Management Restricted Zone",
                  "name": "MrzSubnet",
                  "addressPrefix": "10.18.0.96/27"
                },
                "highAvailability": {
                  "comments": "High Availability (Firewall to Firewall heartbeat)",
                  "name": "HASubnet",
                  "addressPrefix": "10.18.0.128/28"
                },
                "optional": []
              }
            },
            "nvaFirewall": {
              "image": {
                "publisher": "fortinet",
                "offer": "fortinet_fortigate-vm_v5",
                "sku": "fortinet_fg-vm",
                "version": "6.4.5",
                "plan": "fortinet_fg-vm"
              },
              "nonProduction": {
                "internalLoadBalancer": {
                  "name": "pubsecDevFWILB",
                  "tcpProbe": {
                    "name": "lbprobe",
                    "port": 8008,
                    "intervalInSeconds": 5,
                    "numberOfProbes": 2 
                  },
                  "internalIp": "10.18.0.68",
                  "externalIp": "100.60.0.7"
                },
                "deployVirtualMachines": true,
                "virtualMachines": [
                  {
                    "name": "pubsecDevFW1",
                    "vmSku": "Standard_D8s_v4",
                    "internalIp": "10.18.0.69",
                    "externalIp": "100.60.0.8",
                    "mrzInternalIp": "10.18.0.104",
                    "highAvailabilityIp": "10.18.0.134",
                    "availabilityZone": "2"
                  },
                  {
                    "name": "pubsecDevFW2",
                    "vmSku": "Standard_D8s_v4",
                    "internalIp": "10.18.0.70",
                    "externalIp": "100.60.0.9",
                    "mrzInternalIp": "10.18.0.105",
                    "highAvailabilityIp": "10.18.0.135",
                    "availabilityZone": "3"
                  }
                ]
              },
              "production": {
                "internalLoadBalancer": {
                  "name": "pubsecProdFWILB",
                  "tcpProbe": {
                    "name": "lbprobe",
                    "port": 8008,
                    "intervalInSeconds": 5,
                    "numberOfProbes": 2 
                  },
                  "internalIp": "10.18.0.36",
                  "externalIp": "100.60.0.4"
                },
                "deployVirtualMachines": true,
                "virtualMachines": [
                  {
                    "name": "pubsecProdFW1",
                    "vmSku": "Standard_F8s_v2",
                    "internalIp": "10.18.0.37",
                    "externalIp": "100.60.0.5",
                    "mrzInternalIp": "10.18.0.101",
                    "highAvailabilityIp": "10.18.0.132",
                    "availabilityZone": "1"
                  },
                  {
                    "name": "pubsecProdFW2",
                    "vmSku": "Standard_F8s_v2",
                    "internalIp": "10.18.0.38",
                    "externalIp": "100.60.0.6",
                    "mrzInternalIp": "10.18.0.102",
                    "highAvailabilityIp": "10.18.0.133",
                    "availabilityZone": "2"
                  }
                ]
              }
            }
          }
        },
        "networkWatcher": {
          "value": {
            "resourceGroupName": "NetworkWatcherRG"
          }
        }
      }
    }
    ```

    </details>

### April 21, 2022

* Schema definition update for Machine Learning & Healthcare archetypes.  Expanded the spoke network subnet configuration to contain 0 or more optional subnets.  This change enables network configuration to be more flexible.

  * Machine Learning archetype network configuration with optional subnets

    <details>
      <summary>Expand/collapse</summary>

    ```json
        "network": {
          "value": {
            "peerToHubVirtualNetwork": true,
            "useRemoteGateway": false,
            "name": "azmlsqlauth2022Q1vnet",
            "dnsServers": [
              "10.18.1.4"
            ],
            "addressPrefixes": [
              "10.6.0.0/16"
            ],
            "subnets": {
              "sqlmi": {
                "comments": "SQL Managed Instances Delegated Subnet",
                "name": "sqlmi",
                "addressPrefix": "10.6.5.0/25"
              },
              "databricksPublic": {
                "comments": "Databricks Public Delegated Subnet",
                "name": "databrickspublic",
                "addressPrefix": "10.6.6.0/25"
              },
              "databricksPrivate": {
                "comments": "Databricks Private Delegated Subnet",
                "name": "databricksprivate",
                "addressPrefix": "10.6.7.0/25"
              },
              "privateEndpoints": {
                "comments": "Private Endpoints Subnet",
                "name": "privateendpoints",
                "addressPrefix": "10.6.8.0/25"
              },
              "aks": {
                "comments": "AKS Subnet",
                "name": "aks",
                "addressPrefix": "10.6.9.0/25"
              },
              "appService": {
                "comments": "App Service Subnet",
                "name": "appService",
                "addressPrefix": "10.6.10.0/25"
              },
              "optional": [
                {
                  "comments": "Optional Subnet 1",
                  "name": "virtualMachines",
                  "addressPrefix": "10.6.11.0/25",
                  "nsg": {
                    "enabled": true
                  },
                  "udr": {
                    "enabled": true
                  }
                },
                {
                  "comments": "Optional Subnet 2 with delegation for NetApp Volumes",
                  "name": "NetappVolumes",
                  "addressPrefix": "10.6.12.0/25",
                  "nsg": {
                    "enabled": false
                  },
                  "udr": {
                    "enabled": false
                  },
                  "delegations": {
                      "serviceName": "Microsoft.NetApp/volumes"
                  }
                }
              ]
            }
          }
        }
    ```

    </details>

  * Healthcare archetype network configuration with optional subnets

    <details>
      <summary>Expand/collapse</summary>

      ```json
          "network": {
              "value": {
                  "peerToHubVirtualNetwork": true,
                  "useRemoteGateway": false,
                  "name": "health2022Q1vnet",
                  "dnsServers": [
                      "10.18.1.4"
                  ],
                  "addressPrefixes": [
                      "10.5.0.0/16"
                  ],
                  "subnets": {
                      "databricksPublic": {
                          "comments": "Databricks Public Delegated Subnet",
                          "name": "databrickspublic",
                          "addressPrefix": "10.5.5.0/25"
                      },
                      "databricksPrivate": {
                          "comments": "Databricks Private Delegated Subnet",
                          "name": "databricksprivate",
                          "addressPrefix": "10.5.6.0/25"
                      },
                      "privateEndpoints": {
                          "comments": "Private Endpoints Subnet",
                          "name": "privateendpoints",
                          "addressPrefix": "10.5.7.0/25"
                      },
                      "web": {
                          "comments": "Azure Web App Delegated Subnet",
                          "name": "webapp",
                          "addressPrefix": "10.5.8.0/25"
                      },
                      "optional": [
                          {
                              "comments": "Optional Subnet 1",
                              "name": "virtualMachines",
                              "addressPrefix": "10.5.9.0/25",
                              "nsg": {
                              "enabled": true
                              },
                              "udr": {
                              "enabled": true
                              }
                          },
                          {
                              "comments": "Optional Subnet 2 with delegation for NetApp Volumes",
                              "name": "NetappVolumes",
                              "addressPrefix": "10.5.10.0/25",
                              "nsg": {
                              "enabled": false
                              },
                              "udr": {
                              "enabled": false
                              },
                              "delegations": {
                                  "serviceName": "Microsoft.NetApp/volumes"
                              }
                          }
                      ]
                  }
              }
          }
      ```

    </details>

### April 20, 2022

* Schema definition update for Generic Subscription.  Spoke network's subnet configuration is now defined as an array.  The array can have 0 to many subnet definitions.

* Removed 4 subnets from Machine Learning archetype's virtual network: `oz`, `paz`, `rz` and `hrz`.

* Removed 4 subnets from Healthcare archetype's virtual network: `oz`, `paz`, `rz` and `hrz`.

* Schema definition for Hub Networking archetypes (Azure Firewall & NVA).  See documentation:

  * [Hub Networking with Azure Firewall](../../docs/archetypes/hubnetwork-azfw.md)
  * [Hub Networking with Network Virtual Appliance (e.g. Fortigate Firewalls)](../../docs/archetypes/hubnetwork-nva-fortigate.md)

### April 18, 2022

Change in `synapse` schema object to support Azure AD authentication.

| Setting | Type | Description |
| ------- | ---- | ----------- |
| aadAuthenticationOnly | Boolean | Indicate that either AAD auth only or both AAD & SQL auth (required) |
| sqlAuthenticationUsername | String | The SQL authentication user name optional, required when `aadAuthenticationOnly` is false |
| aadLoginName | String | The name of the login or group in the format of first-name last-name |
| aadLoginObjectID | String | The object id of the Azure AD object whether it's a login or a group |
| aadLoginType | String | Represent the type of the object, it can be **User**, **Group** or **Application** (in case of service principal) |

**Examples**

SQL authentication only | Json (used in parameter files)

```json
"synapse": {
      "value": {
        "aadAuthenticationOnly": false,
        "sqlAuthenticationUsername": "azadmin"
      }
```
  
SQL authentication only | bicep (used when calling bicep module from another)
  
```bicep
{
  aadAuthenticationOnly: false 
  sqlAuthenticationUsername: 'azadmin'
}
```
  
Azure AD authentication only | Json (used in parameters files)
  
```json
   "synapse": {
      "value": {
        "aadAuthenticationOnly": true,
        "aadLoginName": "az.admins",
        "aadLoginObjectID": "e0357d81-55d8-44e9-9d9c-ab09dc710785",
        "aadLoginType":"Group"
      }
```

Azure AD authentication only | bicep (used when calling bicep module from another)
  
```bicep
{
  aadAuthenticationOnly: true 
  aadLoginName:'John Smith',
  aadLoginObjectID:'88888-888888-888888-888888',
  aadLoginType:'User'
}
```
  
Mixed authentication |  Json (used in parameters files)

```json
     "synapse": {
      "value": {
        "aadAuthenticationOnly": false,
        "sqlAuthenticationUsername": "azadmin",
        "aadLoginName": "az.admins",
        "aadLoginObjectID": "e0357d81-55d8-44e9-9d9c-ab09dc710785",
        "aadLoginType":"Group"
      }
 ```
  
  Mixed authentication | bicep (used when calling bicep module from another)
  
```bicep
  {
    aadAuthenticationOnly: false
    sqlAuthenticationUsername: 'azadmin' 
    aadLoginName:'John Smith',
    aadLoginObjectID:'88888-888888-888888-888888',
    aadLoginType:'User'
  }
```

### April 7, 2022

Schema definition for Logging archetype.  See [documentation](../../docs/archetypes/logging.md).

### April 6, 2022

Added `logAnalyticsWorkspaceResourceId` to archetypes.  This is an optional parameter in the JSON file as it can be set at runtime.

**Example**

```json
    "logAnalyticsWorkspaceResourceId": {
        "value": "LOG_ANALYTICS_WORKSPACE_RESOURCE_ID"
    }
```

### February 14, 2022

Added location schema object.  This is an optional setting for archetypes.  This setting will default to `deployment().location`.

**Example**

```json
    "location": {
        "value": "canadacentral"
    }
```

### January 16, 2021
Changed `appServiceLinuxContainer` schema object to support optional inbound private endpoint.

**Example**
```json
"appServiceLinuxContainer": {
  "value": {
    "enablePrivateEndpoint": true
  }
}
```

### December 30, 2021

Changed `aks` schema object to support optional deployment of AKS using the `enabled` key as a required field.

**Example**
```json
"aks": {
  "value": {
    "enabled": true
  }
}
```

Added `appServiceLinuxContainer` schema object to support optional deployment of App Service (for model deployments) using the `enabled` key as a required field. Sku name and tier are also required fields.

**Example**
```json
"appServiceLinuxContainer": {
  "value": {
    "enabled": true,
    "skuName": "P1V2",
    "skuTier": "Premium"
  }
}
```

Added required `appService` subnet as well as the `appServiceLinuxContainer` object in machine learning schema json file.


### November 27, 2021

Change in `aks` schema object to support Options for the creation of AKS Cluster with one of the following three scenarios:

* Network Plugin: Kubenet + Network Policy: Calico (Network Policy)
* Network Plugin: Azure CNI + Network Policy: Calico (Network Policy)
* Network Plugin: Azure CNI + Network Policy: Azure (Network Policy).

| Setting | Type | Description |
| ------- | ---- | ----------- |
| version | String | Kubernetes version to use for the AKS Cluster (required) |
| networkPlugin | String | Network Plugin to use: `kubenet` (for Kubenet) **or** `azure` (for Azure CNI) (required) |
| networkPolicy | String | Network Policy to use: `calico` (for Calico); which can be used with either **kubenet** or **Azure** Network Plugins **or** `azure` (for Azure NP); which can only be used with **Azure CNI**  |

**Note**

`podCidr` value shoud be set to ( **''** ) when Azure CNI is used

**Examples**

* Network Plugin: Kubenet + Network Policy: Calico (Network Policy)

```json
"aks": {
  "value": {
    "version": "1.21.2",
    "networkPlugin": "kubenet" ,
    "networkPolicy": "calico",
    "podCidr": "11.0.0.0/16",
    "serviceCidr": "20.0.0.0/16" ,
    "dnsServiceIP": "20.0.0.10",
    "dockerBridgeCidr": "30.0.0.1/16"
  }
}
```

* Network Plugin: Azure CNI + Network Policy: Calico (Network Policy)

```json
"aks": {
  "value": {
    "version": "1.21.2",
    "networkPlugin": "azure" ,
    "networkPolicy": "calico",
    "podCidr": "",
    "serviceCidr": "20.0.0.0/16" ,
    "dnsServiceIP": "20.0.0.10",
    "dockerBridgeCidr": "30.0.0.1/16"
  }
}
```

* Network Plugin: Azure CNI + Network Policy: Azure (Network Policy).

```json
"aks": {
  "value": {
    "version": "1.21.2",
    "networkPlugin": "azure" ,
    "networkPolicy": "azure",
    "podCidr": "",
    "serviceCidr": "20.0.0.0/16" ,
    "dnsServiceIP": "20.0.0.10",
    "dockerBridgeCidr": "30.0.0.1/16"
  }
}
```
### November 26, 2021

Added Azure Recovery Vault schema to enable the creation of a Recovery Vault in the generic Archtetype subscription
| Setting | Type | Description |
| ------- | ---- | ----------- |
| enabled | Boolean | Indicate whether or not to deploy Azure Recovery Vault (required) |
| name | String | The name of the Recovery Vault |


**Examples**

Enable recovery vault | Json (used in parameter files)
```json
    "backupRecoveryVault":{
            "value": {
                "enabled":true,
                "name":"bkupvault"
            }
        }
```

### November 25, 2021

* Remove `uuid` format check on `privateDnsManagedByHubSubscriptionId` for type `schemas/latest/landingzones/types/hubNetwork.json`

### November 23, 2021

Change in `sqldb` schema object to support Azure AD authentication.

| Setting | Type | Description |
| ------- | ---- | ----------- |
| enabled | Boolean | Indicate whether or not to deploy Azure SQL Database (required) |
| aadAuthenticationOnly | Boolean | Indicate that either AAD auth only or both AAD & SQL auth (required) |
| sqlAuthenticationUsername | String | The SQL authentication user name optional, required when `aadAuthenticationOnly` is false |
| aadLoginName | String | The name of the login or group in the format of first-name last-name |
| aadLoginObjectID | String | The object id of the Azure AD object whether it's a login or a group |
| aadLoginType | String | Represent the type of the object, it can be **User**, **Group** or **Application** (in case of service principal) |

**Examples**

SQL authentication only | Json (used in parameter files)

```json
"sqldb": {
  "value": {
    "aadAuthenticationOnly":false,
    "enabled": true,
    "sqlAuthenticationUsername": "azadmin"
  }
}
```
  
SQL authentication only | bicep (used when calling bicep module from another)
  
```bicep
{
  enabled: true
  aadAuthenticationOnly: false 
  sqlAuthenticationUsername: 'azadmin'
}
```
  
Azure AD authentication only | Json (used in parameters files)
  
```json
"sqldb": {
  "value": {
    "enabled":true,
    "aadAuthenticationOnly":true,
    "aadLoginName":"John Smith",
    "aadLoginObjectID":"88888-888888-888888-888888",
    "aadLoginType":"User"
  }
}
```

Azure AD authentication only | bicep (used when calling bicep module from another)
  
```bicep
{
  enabled: true
  aadAuthenticationOnly: true 
  aadLoginName:'John Smith',
  aadLoginObjectID:'88888-888888-888888-888888',
  aadLoginType:'User'
}
```
  
Mixed authentication |  Json (used in parameters files)

```json
  "sqldb": {
    "value": {
      "enabled":true,
      "aadAuthenticationOnly":false,
      "sqlAuthenticationUsername": "azadmin",
      "aadLoginName":"John Smith",
      "aadLoginObjectID":"88888-888888-888888-888888",
      "aadLoginType":"User"
    }
  }
 ```
  
  Mixed authentication | bicep (used when calling bicep module from another)
  
```bicep
  {
    enabled: true
    aadAuthenticationOnly: false
    sqlAuthenticationUsername: 'azadmin' 
    aadLoginName:'John Smith',
    aadLoginObjectID:'88888-888888-888888-888888',
    aadLoginType:'User'
  }
```

### November 12, 2021

* Initial version based on v0.1.0 of the schema definitions.
