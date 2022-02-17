# Archetype: Generic Subscription

## Table of Contents

* [Overview](#overview)
* [Azure Deployment](#azure-deployment)
  * [Schema Definition](#schema-definition)
  * [Deployment Scenarios](#deployment-scenarios)
  * [Example Deployment Parameters](#example-deployment-parameters)
  * [Deployment Instructions](#deployment-instructions)

## Overview

Teams can request subscriptions for **General Use** from CloudOps team with up to Owner permissions, thus democratizing access to deploy, configure, and manage their applications with limited involvement from CloudOps team.  CloudOps team can choose to limit the permission using custom roles as deemed appropriate based on risk and requirements.

Examples of generalized use includes:

* Prototypes & Proof of Concepts
* Lift & Modernize
* Specialized architectures including commercial/ISV software deployments

Azure Policies are used to provide governance, compliance and protection while enabling teams to use their preferred toolset to use Azure services.

![Archetype:  Generic Subscription](../media/architecture/archetype-generic-subscription.jpg)

**CloudOps team will be required for**

1. Establishing connectivity to Hub virtual network (required for egress traffic flow & Azure Bastion).
2. Creating App Registrations (required for service principal accounts).  This is optional based on whether App Registrations are disabled for all users or not.

**Workflow**

* A new subscription is created through existing process (either via ea.azure.com or Azure Portal).
* The subscription will automatically be assigned to the **pubsecSandbox** management group.
* CloudOps will create a Service Principal Account (via App Registration) that will be used for future DevOps automation.
* CloudOps will scaffold the subscription with baseline configuration.
* CloudOps will hand over the subscription to requesting team.

**Subscription Move**

Subscription can be moved to a target Management Group through Azure ARM Templates/Bicep.  Move has been incorporated into the landing zone Azure DevOps Pipeline automation.

**Capabilities**

| Capability | Description |
| --- | --- |
| Service Health Alerts | Configures Service Health alerts such as Security, Incident, Maintenance.  Alerts are configured with email, sms and voice notifications. |
| Microsoft Defender for Cloud | Configures security contact information (email and phone). |
| Subscription Role Assignments | Configures subscription scoped role assignments.  Roles can be built-in or custom. |
| Subscription Budget | Configures monthly subscription budget with email notification. Budget is configured by default for 10 years and the amount. |
| Subscription Tags | A set of tags that are assigned to the subscription. |
| Resource Tags | A set of tags that are assigned to the resource group and resources.  These tags must include all required tags as defined the Tag Governance policy. |
| Automation | Deploys an Azure Automation Account in each subscription. |
| Backup Recovery Vault | Configures a backup recovery vault . |
| Hub Networking | Configures virtual network peering to Hub Network which is required for egress traffic flow and hub-managed DNS resolution (on-premises or other spokes, private endpoints).
| Networking | A spoke virtual network with minimum 4 zones: oz (Operational Zone), paz (Public Access Zone), rz (Restricted Zone), hrz (Highly Restricted Zone).  Additional subnets can be configured at deployment time using configuration (see below). 

## Azure Deployment

### Schema Definition

Reference implementation uses parameter files with `object` parameters to consolidate parameters based on their context.  The schemas types are:

* Schema (version: `latest`)

  * [Spoke deployment parameters definition](../../schemas/latest/landingzones/lz-generic-subscription.json)

  * Common types
    * [Location](../../schemas/latest/landingzones/types/location.json)
    * [Service Health Alerts](../../schemas/latest/landingzones/types/serviceHealthAlerts.json)
    * [Microsoft Defender for Cloud](../../schemas/latest/landingzones/types/securityCenter.json)
    * [Subscription Role Assignments](../../schemas/latest/landingzones/types/subscriptionRoleAssignments.json)
    * [Subscription Budget](../../schemas/latest/landingzones/types/subscriptionBudget.json)
    * [Subscription Tags](../../schemas/latest/landingzones/types/subscriptionTags.json)
    * [Resource Tags](../../schemas/latest/landingzones/types/resourceTags.json)

  * Spoke types
    * [Automation](../../schemas/latest/landingzones/types/automation.json)
    * [Backup Recovery Vault](../../schemas/latest/landingzones/types/backupRecoveryVault.json)
    * [Hub Network](../../schemas/latest/landingzones/types/hubNetwork.json)

### Deployment Scenarios

| Scenario | Example JSON Parameters | Notes |
|:-------- |:----------------------- |:----- |
| Deployment with Hub Virtual Network | [tests/schemas/lz-generic-subscription/FullDeployment-With-Hub.json](../../tests/schemas/lz-generic-subscription/FullDeployment-With-Hub.json) | - |
| Deployment with Location | [tests/schemas/lz-generic-subscription/FullDeployment-With-Location.json](../../tests/schemas/lz-generic-subscription/FullDeployment-With-Location.json) | `parameters.location.value` is `canadacentral` |
| Deployment without Hub Virtual Network | [tests/schemas/lz-generic-subscription/FullDeployment-Without-Hub.json](../../tests/schemas/lz-generic-subscription/FullDeployment-Without-Hub.json) | `parameters.hubNetwork.value.*` fields are empty & `parameters.network.value.peerToHubVirtualNetwork` is false. |
| Deployment with subscription budget | [tests/schemas/lz-generic-subscription/BudgetIsTrue.json](../../tests/schemas/lz-generic-subscription/BudgetIsTrue.json) | `parameters.subscriptionBudget.value.createBudget` is set to `true` and budget information filled in. |
| Deployment without subscription budget | [tests/schemas/lz-generic-subscription/BudgetIsFalse.json](../../tests/schemas/lz-generic-subscription/BudgetIsFalse.json) | `parameters.subscriptionBudget.value.createBudget` is set to `false` and budget information removed. |
| Deployment without resource tags | [tests/schemas/lz-generic-subscription/EmptyResourceTags.json](../../tests/schemas/lz-generic-subscription/EmptyResourceTags.json) | `parameters.resourceTags.value` is an empty object. |
| Deployment without subscription tags | [tests/schemas/lz-generic-subscription/EmptySubscriptionTags.json](../../tests/schemas/lz-generic-subscription/EmptySubscriptionTags.json) | `parameters.subscriptionTags.value` is an empty object. |
| Deployment with optional subnets | [tests/schemas/lz-generic-subscription/WithOptionalSubnets.json](../../tests/schemas/lz-generic-subscription/WithOptionalSubnets.json) | `parameters.network.value.subnets.optional` array has one subnet.  Many others can be added following the same syntax. |
| Deployment without optional subnets | [tests/schemas/lz-generic-subscription/WithoutOptionalSubnets.json](../../tests/schemas/lz-generic-subscription/WithoutOptionalSubnets.json) | `parameters.network.value.subnets.optional` array is empty. |
| Deployment without custom DNS | [tests/schemas/lz-generic-subscription/WithoutCustomDNS.json](../../tests/schemas/lz-generic-subscription/WithoutCustomDNS.json) | `parameters.network.value.dnsServers` array is empty.  Defaults to Azure managed DNS when array is empty. |
| Deployment with Backup Recovery Vault | [tests/schemas/lz-generic-subscription/BackupRecoveryVaultIsTrue.json](../../tests/schemas/lz-generic-subscription/BackupRecoveryVaultIsTrue.json) | `parameters.backupRecoveryVault.value.enabled` is set to `true and vault name is filled in. |
| Deployment without Backup Recovery Vault | [tests/schemas/lz-generic-subscription/BackupRecoveryVaultIsFalse.json](../../tests/schemas/lz-generic-subscription/BackupRecoveryVaultIsFalse.json) | `parameters.backupRecoveryVault.value.enabled` is set to `false` and vault name is removed. |

### Example Deployment Parameters

This example configures:

1. Service Health Alerts
2. Microsoft Defender for Cloud
3. Subscription Role Assignments using built-in and custom roles
4. Subscription Budget with $1000
5. Subscription Tags
6. Resource Tags (aligned to the default tags defined in [Policies](../../policy/custom/definitions/policyset/Tags.parameters.json))
7. Automation Account
8. Backup Recovery Vault
9. Spoke Virtual Network with Hub-managed DNS, Virtual Network Peering, 4 required subnets (zones) and 1 additional subnet `web`.


```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "location": {
            "value": "canadacentral"
        },
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
                            "phoneNumber": "5555555555"
                        }
                    ],
                    "voice": [
                        {
                            "countryCode": "1",
                            "phoneNumber": "5555555555"
                        }
                    ]
                },
                "actionGroupName": "Sub1 ALZ action group",
                "actionGroupShortName": "sub1-alert",
                "alertRuleName": "Sub1 ALZ alert rule",
                "alertRuleDescription": "Alert rule for Azure Landing Zone"
            }
        },
        "securityCenter": {
            "value": {
                "email": "alzcanadapubsec@microsoft.com",
                "phone": "5555555555"
            }
        },
        "subscriptionRoleAssignments": {
            "value": [
                {
                    "comments": "Built-in Role: Contributor",
                    "roleDefinitionId": "b24988ac-6180-42a0-ab88-20f7382dd24c",
                    "securityGroupObjectIds": [
                        "38f33f7e-a471-4630-8ce9-c6653495a2ee"
                    ]
                },
                {
                    "comments": "Custom Role: Landing Zone Application Owner",
                    "roleDefinitionId": "b4c87314-c1a1-5320-9c43-779585186bcc",
                    "securityGroupObjectIds": [
                        "38f33f7e-a471-4630-8ce9-c6653495a2ee"
                    ]
                }
            ]
        },
        "subscriptionBudget": {
            "value": {
                "createBudget": true,
                "name": "MonthlySubscriptionBudget",
                "amount": 1000,
                "timeGrain": "Monthly",
                "contactEmails": [
                    "alzcanadapubsec@microsoft.com"
                ]
            }
        },
        "subscriptionTags": {
            "value": {
                "ISSO": "isso-tag"
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
        "resourceGroups": {
            "value": {
                "automation": "rgAutomation",
                "networking": "rgVnet",
                "networkWatcher": "NetworkWatcherRG",
                "backupRecoveryVault":"rgRecoveryVault"
            }
        },
        "automation": {
            "value": {
                "name": "automation"
            }
        },
        "backupRecoveryVault":{
            "value": {
                "enableBackUpRecoveryVault":true,
                "name":"bkupvault"
            }
        },
        "hubNetwork": {
            "value": {
                "virtualNetworkId": "/subscriptions/ed7f4eed-9010-4227-b115-2a5e37728f27/resourceGroups/pubsec-hub-networking-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet",
                "rfc1918IPRange": "10.18.0.0/22",
                "rfc6598IPRange": "100.60.0.0/16",
                "egressVirtualApplianceIp": "10.18.1.4"
            }
        },
        "network": {
            "value": {
                "deployVnet": true,
                "peerToHubVirtualNetwork": true,
                "useRemoteGateway": false,
                "name": "vnet",
                "dnsServers": [
                    "10.18.1.4"
                ],
                "addressPrefixes": [
                    "10.2.0.0/16"
                ],
                "subnets": {
                    "oz": {
                        "comments": "Foundational Elements Zone (OZ)",
                        "name": "oz",
                        "addressPrefix": "10.2.1.0/25",
                        "nsg": {
                            "enabled": true
                        },
                        "udr": {
                            "enabled": true
                        }
                    },
                    "paz": {
                        "comments": "Presentation Zone (PAZ)",
                        "name": "paz",
                        "addressPrefix": "10.2.2.0/25",
                        "nsg": {
                            "enabled": true
                        },
                        "udr": {
                            "enabled": true
                        }
                    },
                    "rz": {
                        "comments": "Application Zone (RZ)",
                        "name": "rz",
                        "addressPrefix": "10.2.3.0/25",
                        "nsg": {
                            "enabled": true
                        },
                        "udr": {
                            "enabled": true
                        }
                    },
                    "hrz": {
                        "comments": "Data Zone (HRZ)",
                        "name": "hrz",
                        "addressPrefix": "10.2.4.0/25",
                        "nsg": {
                            "enabled": true
                        },
                        "udr": {
                            "enabled": true
                        }
                    },
                    "optional": [
                        {
                            "comments": "App Service",
                            "name": "appservice",
                            "addressPrefix": "10.2.5.0/25",
                            "nsg": {
                                "enabled": false
                            },
                            "udr": {
                                "enabled": false
                            },
                            "delegations": {
                                "serviceName": "Microsoft.Web/serverFarms"
                            }
                        }
                    ]
                }
            }
        }
    }
}
```

### Deployment Instructions

Please see [archetype authoring guide for deployment instructions](authoring-guide.md#deployment-instructions).
