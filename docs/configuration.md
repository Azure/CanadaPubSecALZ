# Automation

> Copyright (c) Microsoft Corporation.  
  Licensed under the MIT license.  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

## Introduction

This document discusses the scripts available to help simplify the onboarding process to Azure Landing Zones design using Azure DevOps pipelines. The [Azure DevOps Pipelines Onboarding Guide](./azure-devops-pipelines.md) document contains detailed onboarding instructions, and is referenced in this document.

## Table of Contents

- [Creating the Service Principal](#creating-the-service-principal)
- [](#)
- [](#)
- [](#)
- [](#)

---

## Required Tools

The instructions in this document and scripts in the `/scripts/automation` folder require the latest versions of the following tools are installed. Review each tool and complete any post-install configuration instructions provided.

### Azure CLI

Install instructions:

---

## Overview

The scripts in the `/scripts/automation` folder are used to simplify the onboarding process to Azure Landing Zones design using Azure DevOps pipelines. The scripts are designed to be run in the following order:

Category | Script | Description
-- | -------- | ------------
Credential | New-AlzCredential.ps1 | Creates the ALZ credential file
Credential | Test-AlzCredential.ps1 | Tests the ALZ credential file
Credential | Remove-AlzCredential.ps1 | Removes the ALZ credential file
Configuration | New-AlzConfiguration.ps1 | Creates the ALZ configuration file
Configuration | Remove-AlzConfiguration.ps1 Removes the ALZ configuration file
Deployment | New-AlzDeployment.ps1 | Creates the ALZ deployment file
Deployment | Remove-AlzDeployment.ps1 | Removes the ALZ deployment file
Deployment | Test-AlzDeployment.ps1 | Tests the ALZ deployment file




---

## Creating the Service Principal

### Create ALZ Credential

This section deals with creating the ALZ credential, which is used by the CanadaPubSecALZ automation scripts to authenticate to Azure. The ALZ credential file is a JSON file that contains the following information: `appId`, `displayName`, `password`, and `tenant`. The `appId` and `password` are used to authenticate to Azure, and the `tenant` is used to identify the tenant to which the service principal belongs. The `displayName` is used to identify the service principal.

#### Generate the Credential

The first step is to generate the credential. This is done by running the `New-AlzCredential.ps1` script. This script will create a service principal in the tenant specified by the `TenantId` parameter. The service principal will be created with the `Owner` role in the tenant. The script will also create the ALZ credential file in the `$HOME/ALZ/credentials` folder. The name of the ALZ credential file will be the same as the name of the environment specified by the `Environment` parameter.

```powershell
PS> $Environment = 'CanadaPubSecALZ'
PS> .\New-AlzCredential.ps1 -Environment $Environment
```

```text
Creating Service Principal for environment (CanadaPubSecALZ) in tenant (domain.onmicrosoft.com)
  appId: 20000000-0000-0000-0000-000000000000
  displayName: CanadaPubSecALZ
  password: **********
  tenant: 10000000-0000-0000-0000-000000000000

Saving Service Principal to file (C:\Users\username\ALZ\credentials/CanadaPubSecALZ.json)

Elapsed time: 00:00:05.3650544
```

#### Check Credential File Creation

The next step is to check that the credential file was created successfully. The credential file will be located in the `$HOME/ALZ/credentials` folder. The name of the credential file will be the same as the name of the environment specified by the `Environment` parameter.

```powershell
PS> Get-ChildItem -Path $HOME/ALZ/credentials
```

```text
    Directory: C:\Users\username\ALZ\credentials

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a---         1/31/2023  10:40 AM            206 CanadaPubSecALZ.json
```

#### Check Credential File Contents

The next step is to check that the credential file contains the correct information. The credential file will be a JSON file that contains the following information: `appId`, `displayName`, `password`, and `tenant`. The `appId` and `password` are used to authenticate to Azure, and the `tenant` is used to identify the tenant to which the service principal belongs. The `displayName` is used to identify the service principal.

```powershell
PS> Get-Content -Raw -Path $HOME/ALZ/credentials/$Environment.json
```

```text
{
  "appId": "20000000-0000-0000-0000-000000000000",
  "displayName": "CanadaPubSecALZ",
  "password": "this-is-not-a-real-password",
  "tenant": "10000000-0000-0000-0000-000000000000"
}
```

#### Test Credentials

The next step is to test the credentials. This is done by running the `Test-AlzCredential.ps1` script. This script will test the credentials by logging in to Azure using the service principal specified by the `Environment` parameter. The script will check the following:

- the service principal has the `Owner` role in the tenant
- the service principal can be used to log in to Azure
- the Azure context is set to the correct environment

```powershell
PS> .\Test-AlzCredential.ps1 -Environment $Environment
```

```text
Service Principal (CanadaPubSecALZ) for environment (CanadaPubSecALZ) from tenant (10000000-0000-0000-0000-000000000000) is an Owner of the tenant.

Current Azure context:

Name                     Account      SubscriptionName   Environment   TenantId
----                     -------      ----------------   -----------   --------
ALZ-Workload (00000000-… user@domain  ALZ-Workload       AzureCloud    10000000-0000-0000-0000-000…

Logging in to Azure using service principal...

Service Principal Azure context:

Id                    : 30000000-0000-0000-0000-000000000000
Type                  : ServicePrincipal
Tenants               : {10000000-0000-0000-0000-000000000000}
AccessToken           :
Credential            :
TenantMap             : {}
CertificateThumbprint :

Original Azure context:

Name                     Account      SubscriptionName   Environment   TenantId
----                     -------      ----------------   -----------   --------
ALZ-Workload (00000000-… user@domain  ALZ-Workload       AzureCloud    10000000-0000-0000-0000-000…

Elapsed time: 00:00:04.9138939
```

---

---

## Working with Configuration Files

### Configuration File Structure

Configurations for the CanadaPubSecALZ implementation are stored under the `config` folder in the root of the repository. There are four subfolders under the `config` folder:

- The `logging` subfolder contains the configuration files for the logging and monitoring components of the implementation.
- The `networking` subfolder contains the configuration files for the networking components of the implementation.
- The `subscriptions` subfolder contains the configuration files for the subscriptions used by the implementation.
- The `variables` subfolder contains the configuration files for the variables used by the implementation.

The `logging`, `networking`, and `subscriptions` subfolders contain JSON configuration files for each environment. An environment is named using the following convention: `<org/repo>-<branch>`. For example, the `CanadaPubSecALZ` environment corresponding to the `CanadaPubSecALZ` organization name (for Azure DevOps) or repository name (for GitHub) and the `main` branch of the repository is named `CanadaPubSecALZ-main`.

The `variables` subfolder contains a YAML configuration file for each environment. An environment is named using the following convention: `<org/repo>-<branch>`. For example, the `CanadaPubSecALZ` environment corresponding to the `CanadaPubSecALZ` organization name (for Azure DevOps) or repository name (for GitHub) and the `main` branch of the repository is named `CanadaPubSecALZ-main`.

Take a moment to familiarize yourself with the contents of the `config` folder, its subfolders, and the JSON and YAML configuration files therein. The configuration files in the main repository are provided as a starting point for your implementation. You will need to make copies of and modify the configuration files to suit your implementation.

In order to streamline the process of creating configuration files tailored for your environment(s), the `New-AlzConfiguration.ps1` script has been provided. This script will create the configuration files for your implementation. It uses existing configuration files in the main repository as a starting point, combining information from a YAML file you create in your `$HOME/ALZ/config` folder that contains a subset of the most commonly updated configuration values. The script will then create the configuration files for your environment(s) in the correct location.

### Using a Configuration Template

Create a YAML file in your `$HOME/ALZ/config` folder that contains the configuration values for your implementation. The file name should be the name of your environment, followed by the `.yml` extension. For example, if your environment is named `MyAzureDevOpsOrgName-main`, the file name should be `MyAzureDevOpsOrgName-main.yml`.

Copy the following sample into your YAML file, and update the values to suit your implementation. The values you provide will be used to create the configuration files for your environment(s).

Some notes about the values you provide:

- Some sections in the sample YAML file are commented out. You can uncomment these sections and provide values for them if you need to override the default values.
- You may comment out sections that you do not need to override the default values.
- Most of the values you are likely to change are represented in the YAML template, with the exception of the network CIDR blocks. These are defined in the `networking` configuration files, and are discussed in more detail in the [Azure DevOps Pipelines Onboarding Guide](./azure-devops-pipelines.md).
- The `Source` attribute is the name of the environment you are copying the configuration from. This environment must already exist in your repository's `config` folder.
- The `Target` attribute is empty in the sample YAML file. When no value is specified, the base name of the YAML template file will be used to form your new environment name. For example, if your YAML template file is named `MyAzureDevOpsOrgName-main.yml`, the `Target` attribute will be set to `MyAzureDevOpsOrgName-main` by default.
- The following GUIDs are provided as placeholders. You must replace them with the actual GUID values for your environment:
  - `10000000-0000-0000-0000-000000000000`: Tenant
  - `20000000-0000-0000-0000-000000000000`: Logging subscription
  - `30000000-0000-0000-0000-000000000000`: Network Hub subscription
  - `40000000-0000-0000-0000-000000000000`: Generic subscription
  - `50000000-0000-0000-0000-000000000000`: Azure AD group to assign Contributor role in logging subscription
  - `60000000-0000-0000-0000-000000000000`: Azure AD group to assign Contributor role in network subscription
  - `70000000-0000-0000-0000-000000000000`: Azure AD group to assign Contributor role in generic subscription
  - `80000000-0000-0000-0000-000000000000`: Azure AD group to assign custom landing zone application owners role in generic subscription

```YAML
Environment:
  Source: CanadaPubSecALZ-main
  Target:

DeployRegion: canadacentral

ManagementGroupHierarchy:
  name: Tenant Root Group
  id: 10000000-0000-0000-0000-000000000000
  children:
  - name: Azure Landing Zones for Canadian Public Sector
    id: pubsec
    children:
    - name: Platform
      id: Platform
      children:
      - name: Management
        id: Management
        children: []
      - name: Connectivity
        id: Connectivity
        children: []
      - name: Identity
        id: Identity
        children: []
    - name: LandingZones
      id: LandingZones
      children:
      - name: NonProd
        id: NonProd
        children: []
      - name: Prod
        id: Prod
        children: []
    - name: Sandbox
      id: Sandbox
      children: []

Logging:
  SubscriptionId: 20000000-0000-0000-0000-000000000000
  ManagementGroupId: Management
  SecurityCenter:
    email: 'security@example.com'
    phone: '6135555555'
  ServiceHealthAlerts:
    resourceGroupName: service-health-alerts-rg
    incidentTypes: ['Incident', 'Security']
    regions: ['Global', 'Canada Central', 'Canada East']
    receivers:
      app: ['logging@example.com']
      email: ['logging@example.com']
      sms: [{ countryCode: '1', phoneNumber: '6135555555' }]
      voice: [{ countryCode: '1', phoneNumber: '6135555555' }]
    actionGroupName: 'Logging Alerts'
    actionGroupShortName: 'logging-ag'
    alertRuleName: 'Logging Alerts'
    alertRuleDescription: 'Logging Alerts for Incidents and Security'
  RoleAssignments:
    - comments: 'Built-in Contributor Role'
      roleDefinitionId: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
      securityGroupObjectIds: ['50000000-0000-0000-0000-000000000000']
  # SubscriptionTags:
  #   ISSO: isso-tag
  # ResourceTags:
  #   ClientOrganization: client-organization-tag
  #   CostCenter: cost-center-tag
  #   DataSensitivity: data-sensitivity-tag
  #   ProjectContact: project-contact-tag
  #   ProjectName: project-name-tag
  #   TechnicalContact: technical-contact-tag
  DataCollectionRule:
    Enabled: false

HubNetwork:
  SubscriptionId: 30000000-0000-0000-0000-000000000000
  ManagementGroupId: Connectivity
  SecurityCenter:
    email: 'security@example.com'
    phone: '6135555555'
  ServiceHealthAlerts:
    resourceGroupName: service-health-alerts-rg
    incidentTypes: ['Incident', 'Security']
    regions: ['Global', 'Canada Central', 'Canada East']
    receivers:
      app: ['networking@example.com']
      email: ['networking@example.com']
      sms: [{ countryCode: '1', phoneNumber: '6135555555' }]
      voice: [{ countryCode: '1', phoneNumber: '6135555555' }]
    actionGroupName: 'Networking Alerts'
    actionGroupShortName: 'network-ag'
    alertRuleName: 'Networking Alerts'
    alertRuleDescription: 'Networking Alerts for Incidents and Security'
  RoleAssignments:
    - comments: 'Built-in Contributor Role'
      roleDefinitionId: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
      securityGroupObjectIds: ['60000000-0000-0000-0000-000000000000']
  # SubscriptionTags:
  #   ISSO: isso-tag
  # ResourceTags:
  #   ClientOrganization: client-organization-tag
  #   CostCenter: cost-center-tag
  #   DataSensitivity: data-sensitivity-tag
  #   ProjectContact: project-contact-tag
  #   ProjectName: project-name-tag
  #   TechnicalContact: technical-contact-tag
  PrivateDNS:
    enabled: true
    resourceGroupName: private-dns-rg
  DDoS:
    # https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-faq#are-services-unsafe-in-azure-without-the-service-
    enabled: false
    resourceGroupName: ddos-rg
    planName: ddos-plan

Subscriptions:
- '8ec38788':   # Generic
    SubscriptionId: 40000000-0000-0000-0000-000000000000
    ManagementGroupId: NonProd
    Location: canadacentral
    SecurityCenter:
      email: 'security@example.com'
      phone: '6135555555'
    ServiceHealthAlerts:
      resourceGroupName: service-health-alerts-rg
      incidentTypes: ['Incident', 'Security']
      regions: ['Global', 'Canada Central', 'Canada East']
      receivers:
        app: ['subscription-owners@example.com']
        email: ['subscription-owners@example.com']
        sms: [{ countryCode: '1', phoneNumber: '6135555555' }]
        voice: [{ countryCode: '1', phoneNumber: '6135555555' }]
      actionGroupName: 'Subscription Owners Alerts'
      actionGroupShortName: 'sub-own-ag'
      alertRuleName: 'Subscription Owners Alerts'
      alertRuleDescription: 'Subscription Owners Alerts for Incidents and Security'
    RoleAssignments:
      - comments: 'Built-in Contributor Role'
        roleDefinitionId: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
        securityGroupObjectIds: ['70000000-0000-0000-0000-000000000000']
      - comments: 'Custom Role: Landing Zone Application Owner'
        roleDefinitionId: 'b4c87314-c1a1-5320-9c43-779585186bcc'
        securityGroupObjectIds: ['80000000-0000-0000-0000-000000000000']
    # SubscriptionTags:
    #   ISSO: isso-tag
    # ResourceTags:
    #   ClientOrganization: client-organization-tag
    #   CostCenter: cost-center-tag
    #   DataSensitivity: data-sensitivity-tag
    #   ProjectContact: project-contact-tag
    #   ProjectName: project-name-tag
    #   TechnicalContact: technical-contact-tag
```

### Creating Configuration Files from a Template

The next step is to create the configuration files for the target environment. The following command will create a new set of configuration files in the `config` folder, based on the configuration files in the `config/CanadaPubSecALZ-main` folder.

```powershell
PS> $Environment = 'CanadaPubSecALZ-main'
PS> .\New-AlzConfiguration.ps1 -Environment $Environment
```

```text
This script creates a new set of configuration files, using an existing CanadaPubSecALZ configuration. Select configuration elements are replaced with values specific to the target environment.

Reading parameters from file (C:\Users\username\ALZ\config\CanadaPubSecALZ-main.yml)
Checking configuration path (config)

Generating Variables configurations

  Updating variables configuration
  Writing variables configuration file: config/variables/CanadaPubSecALZ-main.yml

Generating Logging configurations

  Reading source environment logging configuration file: config/logging/CanadaPubSecALZ-main/logging.parameters.json
  Updating logging configuration
  Writing logging configuration file: config/logging/CanadaPubSecALZ-main/logging.parameters.json

Generating Network Azure Firewall configurations

  Reading source environment network Azure Firewall configuration file: config/networking/CanadaPubSecALZ-main/hub-azfw/hub-network.parameters.json
  Updating network Azure Firewall configuration
  Writing network Azure Firewall configuration file: config/networking/CanadaPubSecALZ-main/hub-azfw/hub-network.parameters.json

Generating Network Azure Firewall Policy configurations

  Reading source environment network Azure Firewall Policy configuration file: config/networking/CanadaPubSecALZ-main/hub-azfw-policy/azure-firewall-policy.parameters.json
  Updating network Azure Firewall Policy configuration
  Writing network Azure Firewall Policy configuration file: config/networking/CanadaPubSecALZ-main/hub-azfw-policy/azure-firewall-policy.parameters.json

Generating Network NVA configurations

  Reading source environment network NVA configuration file: config/networking/CanadaPubSecALZ-main/hub-nva/hub-network.parameters.json
  Updating network NVA configuration
  Writing network NVA configuration file: config/networking/CanadaPubSecALZ-main/hub-nva/hub-network.parameters.json

Generating subscription configurations

  Looking for source environment subscription configuration file(s) matching specified pattern (8ec38788)
  Reading subscription configuration (8ec38788-46f1-4ba4-a6e2-993b5b895772_generic-subscription_canadacentral.json)
  Updating subscription configuration
  Writing new subscription configuration (config/subscriptions/CanadaPubSecALZ-main/NonProd/40000000-0000-0000-0000-000000000000_generic-subscription_canadacentral.json)

Elapsed time: 00:00:00.9637356
```

### Deleting Configuration Files


```powershell
PS> $Environment = 'CanadaPubSecALZ-main'
PS> .\Remove-AlzConfiguration.ps1 -Environment $Environment
```

```text
This script removes an existing set of configuration files.

Checking configuration path (P:\CanadaPubSecALZ\CanadaPubSecALZ\config)
Removing variables configuration file: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/variables/CanadaPubSecALZ-main.yml
Removing logging configuration directory: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/logging/CanadaPubSecALZ-main
Removing network configuration directory: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/networking/CanadaPubSecALZ-main
Removing subscription configuration directory: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/subscriptions/CanadaPubSecALZ-main

Elapsed time: 00:00:00.1053294
```






