# Archetype: Machine Learning

## Table of Contents

- [Archetype: Machine Learning](#archetype-machine-learning)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Data Flow](#data-flow)
  - [Access Control](#access-control)
  - [Networking and Security Configuration](#networking-and-security-configuration)
  - [Customer Managed Keys](#customer-managed-keys)
  - [Secrets](#secrets)
  - [Logging](#logging)
  - [AKS Egress/Firewall configuration](#aks-egressfirewall-configuration)
  - [Testing](#testing)
    - [Test Scenarios](#test-scenarios)
  - [Azure Deployment](#azure-deployment)
    - [Schema Definition](#schema-definition)
    - [Deployment Scenarios](#deployment-scenarios)
    - [Example Deployment Parameters](#example-deployment-parameters)
    - [Deployment Instructions](#deployment-instructions)

## Overview

Teams can request subscriptions from CloudOps team with up to Owner permissions for **Data & AI workloads**, thus democratizing access to deploy, configure, and manage their applications with limited involvement from CloudOps team.  CloudOps team can choose to limit the permission using custom roles as deemed appropriate based on risk and requirements.

Azure Policies are used to provide governance, compliance and protection while enabling teams to use their preferred toolset to use Azure services.

![Archetype:  Machine Learning](../media/architecture/archetype-machinelearning.jpg)

**CloudOps team will be required for**

1. Establishing connectivity to Hub virtual network (required for egress traffic flow & Azure Bastion).
2. Creating App Registrations (required for service principal accounts).  This is optional based on whether App Registrations are disabled for all users or not.

**Workflow**

*  A new subscription is created through existing process (either via ea.azure.com or Azure Portal).
*  The subscription will automatically be assigned to the **pubsecSandbox** management group.
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
| Hub Networking | Configures virtual network peering to Hub Network which is required for egress traffic flow and hub-managed DNS resolution (on-premises or other spokes, private endpoints).
| Networking | A spoke virtual network with minimum 4 zones: oz (Operational Zone), paz (Public Access Zone), rz (Restricted Zone), hrz (Highly Restricted Zone).  Additional subnets can be configured at deployment time using configuration (see below). |
| Key Vault | Deploys a spoke managed Azure Key Vault instance that is used for key and secret management. |
| SQL Database | Deploys Azure SQL Database.  Optional. |
| SQL Managed Instances | Deploys Azure SQL Managed Instance.  Optional. |
| Azure Data Lake Store Gen 2 | Deploys an Azure Data Lake Gen 2 instance with hierarchical namespace.  *There aren't any parameters for customization.* |
| Azure Machine Learning | Deploys Azure Machine Learning Service. | 
| Azure Databricks | Deploys an Azure Databricks instance.  *There aren't any parameters for customization.* |
| Azure Data Factory | Deploys an Azure Data Factory instance with Managed Virtual Network and Managed Integrated Runtime.  *There aren't any parameters for customization.* |
| Azure Kubernetes Services | Deploys an AKS Cluster that will be used for deploying machine learning models, with option to choose either: Network Plugin: Kubenet + Network Policy: Calico **OR** Network Plugin: Azure CNI + Network Policy: Calico (Network Policy) **OR** Network Plugin: Azure CNI + Network Policy: Azure (Network Policy). Optional.|
| Azure App Service | Deploys an App Service on Linux (container). Optional.
| Azure Container Registry | Deploys an Azure Container Registry to store machine learning models as container images.  ACR is used when deploying pods to AKS. *There aren't any parameters for customization. |
| Application Insights | Deploys an Application Insights instance that is used by Azure Machine Learning instance.  *There aren't any parameters for customization.* |

## Data Flow

![Data Flow](../media/architecture/archetype-machinelearning-dataflow.jpg)

| Category | Service | Configuration | Reference |
| --- | --- | --- | --- |
| Storage | Azure Data Lake Gen 2 - Cloud storage enabling big data analytics | Hierarchical namespace enabled.  Optional – Customer Managed Keys | [Azure Docs](https://docs.microsoft.com/azure/storage/blobs/data-lake-storage-introduction)
| Compute | Azure Databricks - Managed Spark cloud platform for data analytics and data science | Premium tier; Secured Cluster Connectivity enabled with load balancer for egress | [Azure Docs](https://docs.microsoft.com/azure/databricks/scenarios/what-is-azure-databricks) |
| Ingestion | Azure Data Factory - Managed cloud service for data integration and orchestration | Managed virtual network.  Optional – Customer Managed Keys | [Azure Docs](https://docs.microsoft.com/azure/data-factory/introduction) |
| Machine learning and deployment | Azure Machine Learning - Cloud platform for end-to-end machine learning workflows | Optional – Customer Managed Keys, High Business Impact Workspace | [Azure Docs](https://docs.microsoft.com/azure/machine-learning/overview-what-is-azure-ml) |
| Machine learning and deployment | Azure Container Registry - Managed private Docker cloud registry | Premium SKU.  Optional – Customer Managed Keys | [Azure Docs](https://docs.microsoft.com/azure/container-registry/container-registry-intro) |
| Machine learning and deployment | Azure Kubernetes Service - Cloud hosted Kubernetes service | Private cluster enabled; Managed identity type; Network plugin set to kubenet.  Optional – Customer Managed Keys for Managed Disks | [Azure Docs](https://docs.microsoft.com/azure/aks/intro-kubernetes) |
| Machine learning and deployment | Azure App Service on Linux (container) - Cloud hosted web app for model deployment | With App Service Plan SKU default as Premium 1 V2. Virtual network integration | [Azure Docs](https://docs.microsoft.com/en-us/azure/app-service/overview) |
| SQL Storage | Azure SQL Managed Instance - Cloud database storage enabling lift and shift on-premise application migrations | Optional – Customer Managed Keys | [Azure Docs](https://docs.microsoft.com/azure/azure-sql/managed-instance/sql-managed-instance-paas-overview)
| SQL Storage | Azure SQL Database - Fully managed cloud database engine | Optional – Customer Managed Keys | [Azure Docs](https://docs.microsoft.com/azure/azure-sql/database/sql-database-paas-overview) |
| Key Management | Azure Key Vault - Centralized cloud storage of secrets and keys | Private Endpoint | [Azure Docs](https://docs.microsoft.com/azure/key-vault/general/overview)
| Monitoring | Application Insights - Application performance and monitoring cloud service | - | [Azure Docs](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview)


The intended cloud service workflows and data movements for this archetype include:

1. Data can be ingested from various sources using Data Factory, which uses managed virtual network for its Azure hosted integration runtime.
2. The data would be stored in Azure Data Lake Gen 2.
3. Structured data can be stored in SQL Database, or SQL Managed Instance.
4. Data engineering and transformation tasks can be done with Spark using Azure Databricks. Transformed data would be stored back in the data lake.
5. Machine learning would be done using Azure Machine Learning.
6. Models would be containerized and pushed to Azure Container Registry from Azure ML.
7. Models would be the deployed as services to either Azure Kubernetes Service or App Service from Container Registry.
8. Secrets and keys would be stored safely in Azure Key Vault.
9. Monitoring and logging would be through Application Insights.

## Access Control

Once the machine learning archetype is deployed and available to use, access control best practices should be applied. Below is the recommend set of security groups & their respective Azure role assignments.  This is not an inclusive list and could be updated as required.

**Replace `PROJECT_NAME` placeholder in the security group names with the appropriate project name for the workload**.

| Security Group | Azure Role | Notes |
| --- | --- | --- |
| SG_PROJECT_NAME_ADMIN | Subscription with `Owner` role. | Admin group for subscription. |
| SG_PROJECT_NAME_READ | Subscription with `Reader` role. | Reader group for subscription. |
| SG_PROJECT_NAME_DATA_PROVIDER | Data Lake (main storage account) service with `Storage Blob Data Contributor` role.  Key Vault service with `Key Vault Secrets User`. | Data group with access to data as well as key vault secrets usage.
| SG_PROJECT_NAME_DATA_SCIENCE | Azure ML service with `Contributor` role.  Azure Databricks service with `Contributor` role.  Key Vault service with `Key Vault Secrets User`. | Data science group with compute access as well as key vault secrets usage. |

## Networking and Security Configuration

![Networking](../media/architecture/archetype-machinelearning-networking.jpg)

| Service Name | Settings | Private Endpoints / DNS | Subnet(s)|
| --- | --- | --- | --- |
| Azure Key Vault | Network ACL Deny | Private endpoint on `vault` + DNS registration to either hub or spoke | `privateEndpoints`|
| SQL Mananged Instance | N/A | N/A | `sqlmi`|
| SQL Database | Deny public network access | Private endpoint on `sqlserver` + DNS registration to either hub or spoke | `privateEndpoints`|
| Azure Data Lake Gen 2 | Network ACL deny | Private endpoint on `blob`, `dfs` + DNS registration to either hub or spoke | `privateEndpoints`|
| Azure Databricks | No public IP enabled (secure cluster connectivity), load balancer for egress with IP and outbound rules, virtual network ibjection | N/A |  `databricksPrivate`, `databricksPublic`|
| Azure Machine Learning | No public workspace access | Private endpoint on `amlWorkspace` + DNS registration to either hub or spoke | `privateEndpoints`|
| Azure Storage Account for Azure ML | Network ACL deny | Private endpoint on `blob`, `file` + DNS registration to either hub or spoke | `privateEndpoints`|
| Azure Data Factory | Public network access disabled, Azure integration runtime with managed virtual network | Private endpoint on `dataFactory` + DNS registration to either hub or spoke | `privateEndpoints`|
| Azure Kubernetes Service | Private cluster, network profile set with either kubenet or Azure CNI | N/A | `aks`|
| Azure App Service | Virtual Network integration. Public network access can be disabled, using private endpoint instead | Private endpoint on `azureWebsites` + DNS registration to either hub or spoke | `appService`, `privateEndpoints` | 
| Azure Container Registry | Network ACL deny, public network access disabled | Private endpoint on `registry` + DNS registration to either hub or spoke | `privateEndpoints`|f
| Azure Application Insights | N/A | N/A | N/A |

> For App Service, private endpoint requires the SKU tier `Premium`: https://docs.microsoft.com/azure/app-service/networking/private-endpoint so this may require a quota increase.

This archetype also has the following security features as options for deployment:

* Customer managed keys for encryption at rest, including Azure ML, storage, Container Registry, Data Factory, SQL Database / Managed Instance, and Kubernetes Service.

* Azure ML has ability to enable high-business impact workspace which controls amount of data Microsoft collects for diagnostic purposes.

## Customer Managed Keys

To enable customer-managed key scenarios, some services including Azure Storage Account and Azure Container Registry require deployment scripts to run with a user-assigned identity to enable encryption key on the respective instances.

Therefore, when the `useCMK` parameter is `true`, a deployment identity is created and assigned `Owner` role to the compute and storage resource groups to run the deployment scripts as needed. Once the services are provisioned with customer-managed keys, the role assignments are automatically deleted.

The artifacts created by the deployment script such as Azure Container Instance and Storage accounts will be automatically deleted 1 hour after completion.

## Secrets

Temporary passwords are autogenerated, and connection strings are automatically stored as secrets in Key Vault. They include:

* SQL Database username, password, and connection string In the case of choosing SQL Authentication, if choosing Azure AD authentication, no secrets needed.
* SQL Managed Instance username, password, and connection string

## Logging

Azure Policy will enable diagnostic settings for all PaaS components in the machine learning archetype and the logs will be sent to the centralized log analytics workspace.  These policies are configured at the management group scope and are not explicitly deployed.

## AKS Egress/Firewall configuration

Since all traffic is redirected through the NVA / Firewall, the following destination endpoints should be allowed on it for the AKS cluster to be properly provisioned and operational

| Destination Endpoint | Protocol | Port | Use |
|:-------------------- |:-------- |:---- |:--- |
| `ntp.ubuntu.com` | UDP | 123 | Ubuntu NTP |
 `*.hcp.canadacentral.azmk8s.io` ; `mcr.microsoft.com` ; `*.data.mcr.microsoft.com` ; `management.azure.com` ;    `login.microsoftonline.com` ; `packages.microsoft.com` ; `acs-mirror.azureedge.net` ; `canadacentral.dp.kubernetesconfiguration.azure.com` ; `canadaeast.dp.kubernetesconfiguration.azure.com` | HTTPS | 443 | AKS required FQDNs |
 | `dc.services.visualstudio.com` ; `*.ods.opinsights.azure.com` ; `*.oms.opinsights.azure.com` ; `*.monitoring.azure.com` ; `data.policy.core.windows.net` ; `store.policy.core.windows.net` | HTTPS | 443 | AKS Addons required FQDNs|
 | `security.ubuntu.com` ; `azure.archive.ubuntu.com` ; `changelogs.ubuntu.com` | HTTP | 80 | AKS Optional recommended FQDNs |


## Testing

Test scripts are provided to verify end to end integration. These tests are not automated so minor modifications are needed to set up and run.

The test scripts are located in [tests/landingzones/lz-machinelearning/e2e-flow-tests](../../tests/landingzones/lz-machinelearning/e2e-flow-tests)

The scripts are:

1. Azure ML SQL connection and Key Vault integration test
2. Azure ML terminal connection to ACR test
3. Databricks integration with Key Vault, SQL MI, SQL Database, Data Lake test
4. Azure ML deployment through ACR to AKS test
5. Azure ML deployment through ACR (using `model.package()`) to App Service test

### Test Scenarios

**Azure ML SQL / Key vault test**

1. Access the ML landing zone network and log into Azure ML through https://ml.azure.com
2. Set up a compute instance and create a new notebook to run Python notebook
3. Use the provided test script to test connection to Key Vault by retrieving the SQL password
4. Create a datastore connecting to SQL DB
5. Create a dataset connecting to a table in SQL DB
6. Use the provided dataset consume code to verify connectivity to SQL DB

**Azure ML terminal connection to ACR test**

1. Access the ML landing zone network and log into Azure ML through https://ml.azure.com
2. Set up a compute instance and use its built-in terminal
3. Use the provided test script to pull a hello-word Docker image and push to ACR

**Databricks integration tests**

1. Access Azure Databricks workspace
2. Create a new compute cluster
3. Create a new Databricks notebook in the workspace and copy in the integration test script
4. Run the test script to verify connectivity to Key Vault, SQL DB/MI, and data lake

**Azure ML deployment test to AKS**

1. Access the ML network and log into Azure ML through https://ml.azure.com
2. Set up a compute instance and import the provided tests to the workspace
3. Run the test script, which will build a Docker Azure ML model image, push it to ACR, and then AKS to pull and run the ML model

**Azure ML deployment test to App Service**
1. Access the ML network and log into Azure ML through https://ml.azure.com
2. Set up a compute instance and import the provided tests to the workspace
3. Run the test script to build a Docker Azure ML model image and push it to ACR using `model.package()`
4. Ensure that the app service has `arcpull` permission for ACR
5. Run the Azure CLI script to configure app service and run the container of the model service on App Service (Linux container)

## Azure Deployment

### Schema Definition

Reference implementation uses parameter files with `object` parameters to consolidate parameters based on their context.  The schemas types are:

* Schema (version: `latest`)

  * [Spoke deployment parameters definition](../../schemas/latest/landingzones/lz-machinelearning.json)

  * Common types
    * [Service Health Alerts](../../schemas/latest/landingzones/types/serviceHealthAlerts.json)
    * [Microsoft Defender for Cloud](../../schemas/latest/landingzones/types/securityCenter.json)
    * [Subscription Role Assignments](../../schemas/latest/landingzones/types/subscriptionRoleAssignments.json)
    * [Subscription Budget](../../schemas/latest/landingzones/types/subscriptionBudget.json)
    * [Subscription Tags](../../schemas/latest/landingzones/types/subscriptionTags.json)
    * [Resource Tags](../../schemas/latest/landingzones/types/resourceTags.json)

  * Spoke types
    * [Automation](../../schemas/latest/landingzones/types/automation.json)
    * [Hub Network](../../schemas/latest/landingzones/types/hubNetwork.json)
    * [Azure Kubernetes Service](../../schemas/latest/landingzones/types/aks.json)
    * [Azure App Service for Linux Containers](../../schemas/latest/landingzones/types/appServiceLinuxContainer.json)
    * [Azure Machine Learning](../../schemas/latest/landingzones/types/aml.json)
    * [Azure Key Vault](../../schemas/latest/landingzones/types/keyVault.json)
    * [Azure SQL Database](../../schemas/latest/landingzones/types/sqldb.json)
    * [Azure SQL Managed Instances](../../schemas/latest/landingzones/types/sqlmi.json)

### Deployment Scenarios

| Scenario | Example JSON Parameters | Notes |
|:-------- |:----------------------- |:----- |
| Deployment with Hub Virtual Network | [tests/schemas/lz-machinelearning/FullDeployment-With-Hub.json](../../tests/schemas/lz-machinelearning/FullDeployment-With-Hub.json) | - |
| Deployment without Hub Virtual Network | [tests/schemas/lz-machinelearning/FullDeployment-Without-Hub.json](../../tests/schemas/lz-machinelearning/FullDeployment-Without-Hub.json) | `parameters.hubNetwork.value.*` fields are empty & `parameters.network.value.peerToHubVirtualNetwork` is false. |
| Deployment with subscription budget | [tests/schemas/lz-machinelearning/BudgetIsTrue.json](../../tests/schemas/lz-machinelearning/BudgetIsTrue.json) | `parameters.subscriptionBudget.value.createBudget` is set to `true` and budget information filled in. |
| Deployment without subscription budget | [tests/schemas/lz-machinelearning/BudgetIsFalse.json](../../tests/schemas/lz-machinelearning/BudgetIsFalse.json) | `parameters.subscriptionBudget.value.createBudget` is set to `false` and budget information removed. |
| Deployment without resource tags | [tests/schemas/lz-machinelearning/EmptyResourceTags.json](../../tests/schemas/lz-machinelearning/EmptyResourceTags.json) | `parameters.resourceTags.value` is an empty object. |
| Deployment without subscription tags | [tests/schemas/lz-machinelearning/EmptySubscriptionTags.json](../../tests/schemas/lz-machinelearning/EmptySubscriptionTags.json) | `parameters.subscriptionTags.value` is an empty object. |
| Deployment without SQL DB | [tests/schemas/lz-machinelearning/SQLDBIsFalse.json](../../tests/schemas/lz-machinelearning/SQLDBIsFalse.json) | `parameters.sqldb.value.enabled` is false. |
| Deployment without SQL Managed Instances | [tests/schemas/lz-machinelearning/SQLMIIsFalse.json](../../tests/schemas/lz-machinelearning/SQLMIIsFalse.json) | `parameters.sqlmi.value.enabled` is false. |
| Deployment with SQL DB using AAD only authentication | [tests/schemas/lz-machinelearning/SQLDB-aadAuthOnly.json](../../tests/schemas/lz-machinelearning/SQLDB-aadAuthOnly.json) | `parameters.sqldb.value.aadAuthenticationOnly` is true, `parameters.sqldb.value.aad*` fields filled in. |
| Deployment with SQL DB using SQL authentication | [tests/schemas/lz-machinelearning/SQLDB-sqlAuth.json](../../tests/schemas/lz-machinelearning/SQLDB-sqlAuth.json) | `parameters.sqldb.value.aadAuthenticationOnly` is false & `parameters.sqldb.value.sqlAuthenticationUsername` filled in. |
| Deployment with SQL DB using mixed mode authentication | [tests/schemas/lz-machinelearning/SQLDB-mixedAuth.json](../../tests/schemas/lz-machinelearning/SQLDB-mixedAuth.json) | `parameters.sqldb.value.aadAuthenticationOnly` is false,  `parameters.sqldb.value.aad*` fields filled in & `parameters.sqldb.value.sqlAuthenticationUsername` filled in. |
| Deployment without customer managed keys | [tests/schemas/lz-machinelearning/WithoutCMK.json](../../tests/schemas/lz-machinelearning/WithoutCMK.json) | `parameters.useCMK.value` is false. |
| Deployment without AKS | [tests/schemas/lz-machinelearning/AKSIsFalse.json](../../tests/schemas/lz-machinelearning/AKSIsFalse.json) | `parameters.aks.value.enabled` is false. |
| Deployment with AKS using Network Plugin: Kubenet + Network Policy: Calico | [tests/schemas/lz-machinelearning/AKS-Kubenet-Calico.json](../../tests/schemas/lz-machinelearning/AKS-Kubenet-Calico.json) | `parameters.aks.value.networkPlugin`  equals ***kubenet***, `parameters.aks.value.networkPlugin`  equals ***calico***, `parameters.aks.value.podCidr` is filled, `parameters.aks.value.serviceCidr` is filled, `parameters.aks.value.dnsServiceIP` is filled and `parameters.aks.value.dockerBridgeCidr`  is filled |
| Deployment with AKS using Network Plugin: Azure CNI + Network Policy: Calico | [tests/schemas/lz-machinelearning/AKS-AzureCNI-Calico.json](../../tests/schemas/lz-machinelearning/AKS-AzureCNI-Calico.json) | `parameters.aks.value.networkPlugin`  equals ***azure***, `parameters.aks.value.networkPlugin`  equals ***calico***, `parameters.aks.value.podCidr` is ***empty***, `parameters.aks.value.serviceCidr` is filled, `parameters.aks.value.dnsServiceIP` is filled and `parameters.aks.value.dockerBridgeCidr`  is filled |
| Deployment with AKS using Network Plugin: Azure CNI + Network Policy: Azure | [tests/schemas/lz-machinelearning/AKS-AzureCNI-AzureNP.json](../../tests/schemas/lz-machinelearning/AKS-AzureCNI-AzureNP.json) | `parameters.aks.value.networkPlugin`  equals ***azure***, `parameters.aks.value.networkPlugin`  equals ***azure***, `parameters.aks.value.podCidr` is ***empty***, `parameters.aks.value.serviceCidr` is filled, `parameters.aks.value.dnsServiceIP` is filled and `parameters.aks.value.dockerBridgeCidr`  is filled |
| Deployment without Azure App Service for Linux Containers | [tests/schemas/lz-machinelearning/AppServiceLinuxContainerIsFalse.json](../../tests/schemas/lz-machinelearning/AppServiceLinuxContainerIsFalse.json) | `parameters.appServiceLinuxContainer.value.enabled` is false. |
| Deployment with Azure App Service for Linux Containers without Private Endpoint| [tests/schemas/lz-machinelearning/AppServiceLinuxContainerPrivateEndpointIsFalse.json](../../tests/schemas/lz-machinelearning/AppServiceLinuxContainerPrivateEndpointIsFalse.json) | `parameters.appServiceLinuxContainer.value.enabled` is true, `parameters.appServiceLinuxContainer.value.sku{Name,Tier}` are filled, and `parameters.appServiceLinuxContainer.value.enablePrivateEndpoint` is false. |
### Example Deployment Parameters

This example configures:

1. Service Health Alerts
2. Microsoft Defender for Cloud
3. Subscription Role Assignments using built-in and custom roles
4. Subscription Budget with $1000
5. Subscription Tags
6. Resource Tags (aligned to the default tags defined in [Policies](../../policy/custom/definitions/policyset/Tags.parameters.json))
7. Automation Account
8. Spoke Virtual Network with Hub-managed DNS, Hub-managed private endpoint DNS Zones, Virtual Network Peering and all required subnets (zones).
9. Deploys Azure resources with Customer Managed Keys.

> **Note 1:**  Azure Automation Account is not deployed with Customer Managed Key as it requires an Azure Key Vault instance with public network access.

> **Note 2:** All secrets stored in Azure Key Vault will have 10 year expiration (configurable) & all RSA Keys (used for CMK) will not have an expiration.

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "serviceHealthAlerts": {
      "value": {
        "resourceGroupName": "pubsec-service-health",
        "incidentTypes": [ "Incident", "Security" ],
        "regions": [ "Global", "Canada East", "Canada Central" ],
        "receivers": {
          "app": [ "alzcanadapubsec@microsoft.com" ],
          "email": [ "alzcanadapubsec@microsoft.com" ],
          "sms": [ { "countryCode": "1", "phoneNumber": "5555555555" } ],
          "voice": [ { "countryCode": "1", "phoneNumber": "5555555555" } ]
        },
        "actionGroupName": "Sub5 ALZ action group",
        "actionGroupShortName": "sub5-alert",
        "alertRuleName": "Sub5 ALZ alert rule",
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
        "automation": "azml-Automation",
        "compute": "azml-Compute",
        "monitor": "azml-Monitor",
        "networking": "azml-Network",
        "networkWatcher": "NetworkWatcherRG",
        "security": "azml-Security",
        "storage": "azml-Storage"
      }
    },
    "useCMK": {
      "value": true
    },
    "automation": {
      "value": {
        "name": "azml-automation"
      }
    },
    "keyVault": {
      "value": {
        "secretExpiryInDays": 3650
      }
    },
    "aks": {
      "value": {
        "version": "1.21.2",
        "enabled": true,
        "networkPlugin": "kubenet" ,
        "networkPolicy": "calico",
        "podCidr": "11.0.0.0/16",
        "serviceCidr": "20.0.0.0/16" ,
        "dnsServiceIP": "20.0.0.10",
        "dockerBridgeCidr": "30.0.0.1/16"
      }
    },
    "sqldb": {
      "value": {
          "enabled": true,
          "aadAuthenticationOnly":true,
          "aadLoginName":"DBA Group",
          "aadLoginObjectID":"4e4ea47c-ee21-4add-ad2f-a75d0d8014e0",
          "aadLoginType":"Group"
        }
    },
    "sqlmi": {
      "value": {
        "enabled": true,
        "username": "azadmin"
      }
    },
    "appServiceLinuxContainer": {
      "value": {
        "enabled": true,
        "skuName": "P1V2",
        "skuTier": "Premium",
        "enablePrivateEndpoint": true
      }
    },
    "aml": {
      "value": {
        "enableHbiWorkspace": false
      }
    },
    "hubNetwork": {
      "value": {
        "virtualNetworkId": "/subscriptions/ed7f4eed-9010-4227-b115-2a5e37728f27/resourceGroups/pubsec-hub-networking-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet",
        "rfc1918IPRange": "10.18.0.0/22",
        "rfc6598IPRange": "100.60.0.0/16",
        "egressVirtualApplianceIp": "10.18.1.4",
        "privateDnsManagedByHub": true,
        "privateDnsManagedByHubSubscriptionId": "ed7f4eed-9010-4227-b115-2a5e37728f27",
        "privateDnsManagedByHubResourceGroupName": "pubsec-dns-rg"
      }
    },
    "network": {
      "value": {
        "peerToHubVirtualNetwork": true,
        "useRemoteGateway": false,
        "name": "azml-vnet",
        "dnsServers": [
          "10.18.1.4"
        ],
        "addressPrefixes": [
          "10.4.0.0/16"
        ],
        "subnets": {
          "oz": {
            "comments": "Foundational Elements Zone (OZ)",
            "name": "oz",
            "addressPrefix": "10.4.1.0/25"
          },
          "paz": {
            "comments": "Presentation Zone (PAZ)",
            "name": "paz",
            "addressPrefix": "10.4.2.0/25"
          },
          "rz": {
            "comments": "Application Zone (RZ)",
            "name": "rz",
            "addressPrefix": "10.4.3.0/25"
          },
          "hrz": {
            "comments": "Data Zone (HRZ)",
            "name": "hrz",
            "addressPrefix": "10.4.4.0/25"
          },
          "sqlmi": {
            "comments": "SQL Managed Instances Delegated Subnet",
            "name": "sqlmi",
            "addressPrefix": "10.4.5.0/25"
          },
          "databricksPublic": {
            "comments": "Databricks Public Delegated Subnet",
            "name": "databrickspublic",
            "addressPrefix": "10.4.6.0/25"
          },
          "databricksPrivate": {
            "comments": "Databricks Private Delegated Subnet",
            "name": "databricksprivate",
            "addressPrefix": "10.4.7.0/25"
          },
          "privateEndpoints": {
            "comments": "Private Endpoints Subnet",
            "name": "privateendpoints",
            "addressPrefix": "10.4.8.0/25"
          },
          "aks": {
            "comments": "AKS Subnet",
            "name": "aks",
            "addressPrefix": "10.4.9.0/25"
          }
          "appService": {
            "comments": "App Service Subnet",
            "name": "appService",
            "addressPrefix": "10.4.10.0/25"
          }
        }
      }
    }
  }
}
```

### Deployment Instructions

Please see [archetype authoring guide for deployment instructions](authoring-guide.md#deployment-instructions).
