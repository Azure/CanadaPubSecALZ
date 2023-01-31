# Archetype: Generic Subscription

## Table of Contents

- [Archetype: Generic Subscription](#archetype-generic-subscription)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Azure Deployment](#azure-deployment)
    - [Schema Definition](#schema-definition)
    - [Delete Locks](#delete-locks)
    - [Service Health](#service-health)
    - [Deployment Scenarios](#deployment-scenarios)
    - [Example Deployment Parameters](#example-deployment-parameters)
  - [Recommended Parameter Property Updates](#recommended-parameter-property-updates)
    - [Service Health Alerts](#service-health-alerts)
    - [Security Center](#security-center)
    - [Subscription Role Assignments](#subscription-role-assignments)
    - [Resource Tags and Preferred Naming Convention](#resource-tags-and-preferred-naming-convention)
    - [Hub Virtual Network ID](#hub-virtual-network-id)
    - [Deployment Instructions](#deployment-instructions)

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
    * [Log Analytics Workspace](../../schemas/latest/landingzones/types/logAnalyticsWorkspaceId.json)

  * Spoke types
    * [Automation](../../schemas/latest/landingzones/types/automation.json)
    * [Backup Recovery Vault](../../schemas/latest/landingzones/types/backupRecoveryVault.json)
    * [Hub Network](../../schemas/latest/landingzones/types/hubNetwork.json)

### Delete Locks

As an administrator, you can lock a subscription, resource group, or resource to prevent other users in your organization from accidentally deleting or modifying critical resources. The lock overrides any permissions the user might have.  You can set the lock level to `CanNotDelete` or `ReadOnly`.  Please see [Azure Docs](https://learn.microsoft.com/azure/azure-resource-manager/management/lock-resources) for more information.

**This archetype does not use `CanNotDelete` nor `ReadOnly` locks as part of the deployment.  You may customize the deployment templates when it's required for your environment.**

### Service Health

[Service health notifications](https://learn.microsoft.com/azure/service-health/service-health-notifications-properties) are published by Azure, and contain information about the resources under your subscription.  Service health notifications can be informational or actionable, depending on the category.

Our examples configure service health alerts for `Security` and `Incident`.  However, these categories can be customized based on your need.  Please review the possible options in [Azure Docs](https://learn.microsoft.com/azure/service-health/service-health-notifications-properties#details-on-service-health-level-information).

### Deployment Scenarios

> Sample deployment scenarios are based on the latest JSON parameters file schema definition.  If you have an older version of this repository, please use the examples from your repository.

| Scenario | Example JSON Parameters | Notes |
|:-------- |:----------------------- |:----- |
| Deployment with Hub Virtual Network | [tests/schemas/lz-generic-subscription/FullDeployment-With-Hub.json](../../tests/schemas/lz-generic-subscription/FullDeployment-With-Hub.json) | - |
| Deployment with Location | [tests/schemas/lz-generic-subscription/FullDeployment-With-Location.json](../../tests/schemas/lz-generic-subscription/FullDeployment-With-Location.json) | `parameters.location.value` is `canadacentral` |
| Deployment without Hub Virtual Network | [tests/schemas/lz-generic-subscription/FullDeployment-Without-Hub.json](../../tests/schemas/lz-generic-subscription/FullDeployment-Without-Hub.json) | `parameters.hubNetwork.value.*` fields are empty & `parameters.network.value.peerToHubVirtualNetwork` is false. |
| Deployment with subscription budget | [tests/schemas/lz-generic-subscription/BudgetIsTrue.json](../../tests/schemas/lz-generic-subscription/BudgetIsTrue.json) | `parameters.subscriptionBudget.value.createBudget` is set to `true` and budget information filled in. |
| Deployment without subscription budget | [tests/schemas/lz-generic-subscription/BudgetIsFalse.json](../../tests/schemas/lz-generic-subscription/BudgetIsFalse.json) | `parameters.subscriptionBudget.value.createBudget` is set to `false` and budget information removed. |
| Deployment without resource tags | [tests/schemas/lz-generic-subscription/EmptyResourceTags.json](../../tests/schemas/lz-generic-subscription/EmptyResourceTags.json) | `parameters.resourceTags.value` is an empty object. |
| Deployment without subscription tags | [tests/schemas/lz-generic-subscription/EmptySubscriptionTags.json](../../tests/schemas/lz-generic-subscription/EmptySubscriptionTags.json) | `parameters.subscriptionTags.value` is an empty object. |
| Deployment without subnets | [tests/schemas/lz-generic-subscription/WithoutSubnets.json](../../tests/schemas/lz-generic-subscription/WithoutSubnets.json) | `parameters.network.value.subnets` array is empty. |
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
7. Log Analytics Workspace integration through Azure Defender for Cloud
8. Automation Account
9. Backup Recovery Vault
10. Spoke Virtual Network with Hub-managed DNS, Virtual Network Peering and 5 subnets.

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "location": {
            "value": "canadacentral"
        },
        "logAnalyticsWorkspaceResourceId": {
            "value": "/subscriptions/bc0a4f9f-07fa-4284-b1bd-fbad38578d3a/resourcegroups/pubsec-central-logging/providers/microsoft.operationalinsights/workspaces/log-analytics-workspace"
        },
        "serviceHealthAlerts": {
            "value": {
                "resourceGroupName": "service-health",
                "incidentTypes": [ "Incident", "Security" ],
                "regions": [ "Global", "Canada East", "Canada Central" ],
                "receivers": {
                    "app": [ "alzcanadapubsec@microsoft.com" ],
                    "email": [ "alzcanadapubsec@microsoft.com" ],
                    "sms": [ { "countryCode": "1", "phoneNumber": "5555555555" } ],
                    "voice": [ { "countryCode": "1", "phoneNumber": "5555555555" } ]
                },
                "actionGroupName": "Service health action group",
                "actionGroupShortName": "health-alert",
                "alertRuleName": "Incidents and Security",
                "alertRuleDescription": "Service Health: Incidents and Security"
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
                "createBudget": false
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
                "automation": "automation",
                "networking": "networking",
                "networkWatcher": "NetworkWatcherRG",
                "backupRecoveryVault":"backup"
            }
        },
        "automation": {
            "value": {
                "name": "automation"
            }
        },
        "backupRecoveryVault":{
            "value": {
                "enabled":true,
                "name":"backup-vault"
            }
        },
        "hubNetwork": {
            "value": {
                "virtualNetworkId": "/subscriptions/ed7f4eed-9010-4227-b115-2a5e37728f27/resourceGroups/pubsec-hub-networking/providers/Microsoft.Network/virtualNetworks/hub-vnet",
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
                "subnets": [
                    {
                        "comments": "App Management Zone (OZ)",
                        "name": "appManagement",
                        "addressPrefix": "10.2.1.0/25",
                        "nsg": {
                            "enabled": true
                        },
                        "udr": {
                            "enabled": true
                        }
                    },
                    {
                        "comments": "Presentation Zone (PAZ)",
                        "name": "web",
                        "addressPrefix": "10.2.2.0/25",
                        "nsg": {
                            "enabled": true
                        },
                        "udr": {
                            "enabled": true
                        }
                    },
                    {
                        "comments": "Application Zone (RZ)",
                        "name": "app",
                        "addressPrefix": "10.2.3.0/25",
                        "nsg": {
                            "enabled": true
                        },
                        "udr": {
                            "enabled": true
                        }
                    },
                    {
                        "comments": "Data Zone (HRZ)",
                        "name": "data",
                        "addressPrefix": "10.2.4.0/25",
                        "nsg": {
                            "enabled": true
                        },
                        "udr": {
                            "enabled": true
                        }
                    },
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
```

## Recommended Parameter Property Updates

### Service Health Alerts

Update the **serviceHealthAlerts** properties with specific email addresses and phone numbers as required.

![Generic Subscription: Service Health Alerts](../../docs/media/archetypes/service-health-alerts-receivers.jpg)

### Security Center

Change the **securityCenter** properties with specific email and address values to reflect your actual point of contact.

![Generic Subscription: Security Center](../../docs/media/archetypes/security-center-contact-info.jpg)

### Subscription Role Assignments

Modify the two **subscriptionRoleAssignments** properties with your specific unique object ids of the respective groups for the **Contributor** built-in
and **Custom Role: Landing Zone Application Owner** roles for this landing zone subscription. These assignments are optional and can be 0 or more role assignments using either Built-In or Custom roles and security groups.

![Generic Subscription: Subscription Role Assignments](../../docs/media/archetypes/subscription-role-assignments.jpg)

### Resource Tags and Preferred Naming Convention

1. Specify the desired custom values for the **resourceTags** properties.
You may also include any additional name value pairs of tags required. Generally, these tags can be modified and even replaced as required, and should also align to the Tagging policy set paramters at: [Tag Policy](https://github.com/Azure/CanadaPubSecALZ/blob/main/policy/custom/definitions/policyset/Tags.parameters.json).

2. Addtionally, you can customize default resources and resource group names with any specific preferred naming convention, as indicated by the item **2** circles shown below.
   

![Generic Subscription: Tags and Naming Conventions](../../docs/media/archetypes/resource-tags-and-naming-conventions.jpg)

### Hub Virtual Network ID

**IMPORTANT**

To avoid a failure when running any of the connectivity pipelines, the subscriptionId segment value of the **hubNetwork** string (item **1**), must be updated from it's default value to the specific hubNetwork subscriptionId that was actually deployed previously, so that the virtual network in this spoke subscription can be VNET Peered to the Hub Network.

![Generic Subscription: Hub Virtual Network ID](../../docs/media/archetypes/virtual-network-id.jpg)

The rest of the segments for the **virtualNetworkId** string must also match the actual resources that were deployed from the connectivity pipeline, such as the name of the resource group,
in case a different prefix besides **pubsec** was used to conform to a specific and preferred naming convention or organization prefix (item **2**), or the default VNET name of hub-vnet was also changed to something else,
(**item 3**) - again based on a specific and preferred naming convention that may have been used before when the actual hub VNET was deployed.

### Deployment Instructions

### Virtual Appliance IP
To ensure traffic is routed/filtered via the firewall, please validate or update the "egressVirtualApplianceIp" value to the firewall IP in your environment: 
  - For Azure Firewall, use the firewall IP address
  - For Network Virtual Appliances (i.e. Fortigate firewalls), use the internal load-balancer IP (item **1**)
![Generic Subscription:Egress Virtual Appliance IP](../../docs/media/archetypes/egressvirtualApplianceIP.jpg)

Please see [archetype authoring guide for deployment instructions](authoring-guide.md#deployment-instructions).
