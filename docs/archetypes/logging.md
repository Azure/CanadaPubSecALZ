# Archetype:  Logging

## Table of Contents

* [Overview](#overview)
* [Schema Definition](#schema-definition)
* [Delete Locks](#delete-locks)
* [Service Health](#service-health)
* [Deployment Scenarios](#deployment-scenarios)
* [Example Deployment Parameters](#example-deployment-parameters)
* [Deployment Instructions](#deployment-instructions)

## Overview

Centralized logging landing zone allows a common subscription for managing Log Analytics Workspace & Automation Account.  This landing zone will be in the `pubsecPlatformManagement` management group.

![Archetype:  Logging](../media/architecture/archetype-logging.jpg)

**Workflow**

*  A new subscription is created through existing process (either via ea.azure.com or Azure Portal).
*  The subscription will automatically be assigned to the **pubsecSandbox** management group.
*  Update configuration in Azure DevOps Git repo.
*  Execute the **Platform – Logging** Azure DevOps Pipeline.  The pipeline will:
  * Move it to the target management group.
  *  Scaffold the subscription with baseline configuration.

**Subscription Move**

Subscription can be moved to a target Management Group through Azure ARM Templates/Bicep.  Move has been incorporated into the landing zone Azure DevOps Pipeline automation.

**Capabilities**

| Capability | Description |
| --- | --- |
| Service Health Alerts | Configures Service Health alerts such as Security, Incident, Maintenance.  Alerts are configured with email, sms and voice notifications. |
| Microsoft Defender for Cloud | Configures security contact information (email and phone). |
| Subscription Role Assignments | Configures subscription scoped role assignments.  Roles can be built-in or custom. |
| Subscription Budget | Configures monthly subscription budget with email notification. Budget is configured by default for 10 years and the amount. |
| Log Analytics | Configures Automation Account, Log Analytics Workspace and Log Analytics Solutions (AgentHealthAssessment, AntiMalware, AzureActivity, ChangeTracking, Security, SecurityInsights, ServiceMap, SQLAdvancedThreatProtection, SQLAssessment, SQLVulnerabilityAssessment, Updates, VMInsights).  **SecurityInsights** solution pack will enable Microsoft Sentinel. |
| Data Collection Rule | Configures one data collection rule with Windows Event Logs & syslog data sources. |
| Subscription Tags | A set of tags that are assigned to the subscription. |
| Resource Tags | A set of tags that are assigned to the resource group and resources.  These tags must include all required tags as defined the Tag Governance policy. |

## Schema Definition

Reference implementation uses parameter files with `object` parameters to consolidate parameters based on their context.  The schemas types are:

* Schema (version: `latest`)

  * [Logging deployment parameters definition](../../schemas/latest/landingzones/lz-platform-logging.json)

  * Common
    * [Service Health Alerts](../../schemas/latest/landingzones/types/serviceHealthAlerts.json)
    * [Microsoft Defender for Cloud](../../schemas/latest/landingzones/types/securityCenter.json)
    * [Subscription Role Assignments](../../schemas/latest/landingzones/types/subscriptionRoleAssignments.json)
    * [Subscription Budget](../../schemas/latest/landingzones/types/subscriptionBudget.json)
    * [Subscription Tags](../../schemas/latest/landingzones/types/subscriptionTags.json)
    * [Resource Tags](../../schemas/latest/landingzones/types/resourceTags.json)

## Delete Locks

As an administrator, you can lock a subscription, resource group, or resource to prevent other users in your organization from accidentally deleting or modifying critical resources. The lock overrides any permissions the user might have.  You can set the lock level to `CanNotDelete` or `ReadOnly`.  Please see [Azure Docs](https://learn.microsoft.com/azure/azure-resource-manager/management/lock-resources) for more information.

By default, this archetype deploys `CanNotDelete` lock to prevent accidental deletion on all resource groups it creates.

## Service Health

[Service health notifications](https://learn.microsoft.com/azure/service-health/service-health-notifications-properties) are published by Azure, and contain information about the resources under your subscription.  Service health notifications can be informational or actionable, depending on the category.

Our examples configure service health alerts for `Security` and `Incident`.  However, these categories can be customized based on your need.  Please review the possible options in [Azure Docs](https://learn.microsoft.com/azure/service-health/service-health-notifications-properties#details-on-service-health-level-information).

## Deployment Scenarios

> Sample deployment scenarios are based on the latest JSON parameters file schema definition.  If you have an older version of this repository, please use the examples from your repository.

| Scenario | Example JSON Parameters | Notes |
|:-------- |:----------------------- |:----- |
| Full Deployment | [tests/schemas/lz-platform-logging/FullDeployment.json](../../tests/schemas/lz-platform-logging/FullDeployment.json) | - |
| Deployment with Location | [tests/schemas/tests/schemas/lz-platform-logging/FullDeployment-With-Location.json](../../tests/schemas/lz-platform-logging/FullDeployment-With-Location.json) | `parameters.location.value` is `canadacentral` |
| Deployment without subscription budget | [tests/schemas/tests/schemas/lz-platform-logging/BudgetIsFalse.json](../../tests/schemas/lz-platform-logging/BudgetIsFalse.json) | `parameters.subscriptionBudget.value.createBudget` is set to `false` and budget information removed. |
| Deployment without resource tags | [tests/schemas/tests/schemas/lz-platform-logging/EmptyResourceTags.json](../../tests/schemas/lz-platform-logging/EmptyResourceTags.json) | `parameters.resourceTags.value` is an empty object. |
| Deployment without subscription tags | [tests/schemas/tests/schemas/lz-platform-logging/EmptySubscriptionTags.json](../../tests/schemas/lz-platform-logging/EmptySubscriptionTags.json) | `parameters.subscriptionTags.value` is an empty object. |
| Deployment without subscription role assignments | [tests/schemas/tests/schemas/lz-platform-logging/WithoutSubscriptionRoleAssignments.json](../../tests/schemas/lz-platform-logging/WithoutSubscriptionRoleAssignments.json) | `parameters.subscriptionRoleAssignments.value` is an empty array. |

## Example Deployment Parameters

This example configures:

1. Service Health Alerts
2. Microsoft Defender for Cloud
3. Subscription Role Assignments using built-in and custom roles
4. Subscription Budget with $1000
5. Subscription Tags
6. Resource Tags (aligned to the default tags defined in [Policies](../../policy/custom/definitions/policyset/Tags.parameters.json))
7. Automation Account
8. Log Analytics Workspace
9. Data Collection Rule

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
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
        "createBudget": false,
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
    "logAnalyticsResourceGroupName": {
      "value": "pubsec-central-logging"
    },
    "logAnalyticsWorkspaceName": {
      "value": "log-analytics-workspace"
    },
    "logAnalyticsRetentionInDays": {
      "value": 730
    },
    "logAnalyticsAutomationAccountName": {
      "value": "automation-account"
    },
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
  }
}
```

## Deployment Instructions

Use the [Azure DevOps Pipelines](../onboarding/azure-devops-pipelines.md) onboarding guide to configure this archetype.
