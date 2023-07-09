# Configuration Scripts

> Copyright (c) Microsoft Corporation.  
  Licensed under the MIT license.  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

## Introduction

This document discusses the scripts available to help simplify creating and using configuration files for a CanadaPubSecALZ deployment.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Creating the Service Principal](#creating-the-service-principal)
- [Working with Configuration Files](#working-with-configuration-files)

---

## Prerequisites

The instructions in this document and scripts in the `/scripts/configuration` folder have a number of prerequisites. Please review the prerequisites below and complete any missing prerequisites before proceeding.

### Azure PowerShell

Install the latest version of the Azure PowerShell module. Review the [Azure PowerShell documentation](https://docs.microsoft.com/powershell/azure/install-az-ps) for installation instructions.

### Azure CLI

Install the latest version of the Azure CLI. Review the [Azure CLI documentation](https://docs.microsoft.com/cli/azure/install-azure-cli) for installation instructions.

### Required Permissions

Review the [Required Permissions](./azure-devops-scripts.md#required-permissions) section of the [Azure DevOps Scripts](./azure-devops-scripts.md) document for the required permissions to run the scripts in the `/scripts/configuration` folder.

---

## Overview

The scripts in the `/scripts/configuration` folder can be used to simplify part of the Azure Landing Zones onboarding process related to creating the configuration files (`.yml` and `.json`) for your environment.

Using these scripts is optional.If you choose not to use them, you can still follow the manual steps in the [Azure DevOps Pipelines Onboarding Guide](./azure-devops-pipelines.md) document to create the configuration files.

These scripts consolidate most, but not all, of the common settings available in the configuration files used to for a CanadaPubSecALZ deployment. Notable examples of configuration values you will need to update directly in the finished configuration files include network settings such as IP addresses and CIDR ranges. Therefore, you will still need to review and update the configuration files after they are created by these scripts.

Benefits of using these scripts:

- Simplifies the process of creating a new service principal and credential file.
- Simplifies the process of creating a new set of configuration files based on an existing set of configuration files.
- Automatically copies an existing set of configuration files to a new set of configuration files, putting the new files in their correct folder locations, retaining common configuration settings, and overriding select configuration settings using a single YAML file stored outside of the repository.
- Provide detailed logging for all credential, configuration, and deployment operations in datetime-stamped log files located in your home directory for easier troubleshooting.
- Provide a foundation for automating the creation and management of configuration files using Azure DevOps pipelines or GitHub Actions.

The following scripts are available:

Script | Category | Description
---- | -------- | ------------
Connect-AlzCredential.ps1 | Credentials | Connects to Azure using one of the following methods: Credential file, Service Principal, or Interactive login.
Get-AlzConfiguration.ps1 | Configuration | Gets the ALZ configuration file. Used primarily by other scripts in this folder.
Get-AlzSubscriptions.ps1 | Configuration | Gets an array of ALZ subscription identifiers. Used primarily by other scripts in this folder.
Install-Prerequisites.ps1 | Prerequisites | Installs the PowerShell module prerequisites.
New-AlzConfiguration.ps1 | Configuration | Creates the ALZ configuration files in a specified Target Environment from existing configuration files in a specified Source Environment.
New-AlzCredential.ps1 | Credentials | Creates an ALZ credential file in your home directory.
New-AlzDeployment.ps1 | Deployment | Deploys the ALZ configuration files to the specified Target Environment. Uses the `../deployments/RunWorkflows.ps1` script to deploy the configuration files.
Remove-AlzConfiguration.ps1 | Configuration | Removes the ALZ configuration file.
Remove-AlzCredential.ps1 | Credentials | Removes the ALZ credential file.
Remove-AlzDeployment.ps1 | Deployment | Removes the ALZ configuration files. This is useful, for example, if you need to remove configuration files that were created and used for testing purposes, but do not want to commit them to the repository.
Test-AlzCredential.ps1 | Credentials | Tests the ALZ credential file.

>Note: The scripts in this folder are designed to be run from the folder they are located in (`/scripts/configuration`). Running them from any other location may result in errors.

The configuration scripts take some common parameters. These parameters are used to specify the location of the ALZ configuration files. The default values for these parameters are as follows:

```powershell
[string]$UserRootPath = "$HOME"
[string]$UserLogsPath = "$UserRootPath/ALZ/logs"
[string]$UserCredsPath = "$UserRootPath/ALZ/credentials"
[string]$UserConfigPath = "$UserRootPath/ALZ/config"
```

These parameters can be overridden by specifying the parameters when running the scripts. By default, they are set to the current user's home directory, which is usually outside of the repository. This is done to prevent the ALZ configuration files from being committed to the repository since some of these configuration files contain sensitive information such as credentials that should not be shared.

The `logs` folder contains log output from the scripts. The `credentials` folder contains the ALZ credential files. The `config` folder contains the ALZ configuration input files.

The following sections of this document will outline the end-to-end process of creating the ALZ credentials, creating the ALZ configuration files, and then using the ALZ configuration files to deploy the Azure Landing Zones design using either PowerShell or the Azure DevOps pipelines.

---

## Creating the Service Principal

This section deals with creating the ALZ credential, which is used by the CanadaPubSecALZ configuration scripts to authenticate to Azure during deployment.

You must be signed in to Azure via the Azure PowerShell SDK before running the scripts in this section. You can do this by either running `Connect-AzAccount` or by using the `Connect-AlzCredential.ps1` script with the `-TenantId` parameter.

For example:

```powershell
PS> $TenantId = '10000000-0000-0000-0000-000000000000'
PS> .\Connect-AlzCredential.ps1 -TenantId $TenantId
```

You will need certain permissions to run the scripts in this section. Review the [Required Permissions](./azure-devops-scripts.md#required-permissions) section of the [Azure DevOps Scripts](./azure-devops-scripts.md) document for the required permissions to run the scripts in this folder.

### The ALZ Credential

The ALZ credential file is a JSON file that contains the following information: `appId`, `displayName`, `password`, and `tenant`. The `appId` and `password` are used to authenticate to Azure, and the `tenant` is used to identify the tenant to which the service principal belongs. The `displayName` is used to identify the service principal.

### Generate the Credential

The first step is to generate the credential. This is done by running the `New-AlzCredential.ps1` script. This script will create a service principal in the tenant specified by the `TenantId` parameter. The service principal will be created with the `Owner` role in the tenant. The script will also create the ALZ credential file in the `$HOME/ALZ/credentials` folder. The name of the ALZ credential file will be the same as the name of the environment specified by the `Environment` parameter.

```powershell
PS> $Environment = 'MyAzureDevOpsOrg-main'
PS> .\New-AlzCredential.ps1 -Environment $Environment
```

```text
Creating Service Principal for environment (MyAzureDevOpsOrg-main) in tenant (domain.onmicrosoft.com)
  appId: 20000000-0000-0000-0000-000000000000
  displayName: MyAzureDevOpsOrg-main
  password: **********
  tenant: 10000000-0000-0000-0000-000000000000

Saving Service Principal to file (C:\Users\username\ALZ\credentials/MyAzureDevOpsOrg-main.json)

Elapsed time: 00:00:05.3650544
```

### Check Credential File Creation

The next step is to check that the credential file was created successfully. The credential file will be located in the `$HOME/ALZ/credentials` folder. The name of the credential file will be the same as the name of the environment specified by the `Environment` parameter.

```powershell
PS> $Environment = 'MyAzureDevOpsOrg-main'
PS> Get-ChildItem -Path $HOME/ALZ/credentials
```

```text
    Directory: C:\Users\username\ALZ\credentials

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a---          7/1/2023  10:40 AM            206 MyAzureDevOpsOrg-main.json
```

### Check Credential File Contents

The next step is to check that the credential file contains the correct information. The credential file will be a JSON file that contains the following information: `appId`, `displayName`, `password`, and `tenant`. The `appId` and `password` are used to authenticate to Azure, and the `tenant` is used to identify the tenant to which the service principal belongs. The `displayName` is used to identify the service principal.

```powershell
PS> $Environment = 'MyAzureDevOpsOrg-main'
PS> Get-Content -Raw -Path $HOME/ALZ/credentials/$Environment.json
```

```text
{
  "appId": "20000000-0000-0000-0000-000000000000",
  "displayName": "MyAzureDevOpsOrg-main",
  "password": "this-is-not-a-real-password",
  "tenant": "10000000-0000-0000-0000-000000000000"
}
```

### Test Credentials

The next step is to test the credentials. This is done by running the `Test-AlzCredential.ps1` script. This script will test the credentials by logging in to Azure using the service principal specified by the `Environment` parameter. The script will check the following:

- the service principal has the `Owner` role in the tenant
- the service principal can be used to log in to Azure
- the Azure context is set to the correct environment

```powershell
PS> $Environment = 'MyAzureDevOpsOrg-main'
PS> .\Test-AlzCredential.ps1 -Environment $Environment
```

```text
Service Principal (MyAzureDevOpsOrg-main) for environment (MyAzureDevOpsOrg-main) from tenant (10000000-0000-0000-0000-000000000000) is an Owner of the tenant.

Current Azure context:

Name                     Account      SubscriptionName   Environment   TenantId
----                     -------      ----------------   -----------   --------
ALZ-Workload (00000000-… user@domain  ALZ-Workload       AzureCloud    10000000-0000-0000-0000-000…

Logging in to Azure using service principal...

Service Principal Azure context:

Id                    : 00000000-0000-0000-0000-000000000000
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

## Working with Configuration Files

### Configuration File Structure

Configurations for the CanadaPubSecALZ implementation are stored under the `config` folder in the root of the repository. There are four subfolders under the `config` folder:

- The `logging` subfolder contains the configuration files for the logging and monitoring components of the implementation.
- The `networking` subfolder contains the configuration files for the networking components of the implementation.
- The `identity` subfolder contains the configuration files for the identity components of the implementation.
- The `subscriptions` subfolder contains the configuration files for the subscriptions used by the implementation.
- The `variables` subfolder contains the configuration files for the variables used by the implementation.

The `logging`, `networking`, `identity`, and `subscriptions` subfolders contain JSON configuration files for each environment. An environment is named using the following convention: `<org/repo>-<branch>`. For example, the `CanadaPubSecALZ` environment corresponding to the `CanadaPubSecALZ` organization name (for Azure DevOps) or repository name (for GitHub) and the `main` branch of the repository is named `CanadaPubSecALZ-main`.

The `variables` subfolder contains a YAML configuration file for each environment. An environment is named using the following convention: `<org/repo>-<branch>`. For example, the `CanadaPubSecALZ` environment corresponding to the `CanadaPubSecALZ` organization name (for Azure DevOps) or repository name (for GitHub) and the `main` branch of the repository is named `CanadaPubSecALZ-main`.

Take a moment to familiarize yourself with the contents of the `config` folder, its subfolders, and the JSON and YAML configuration files therein. The configuration files in the main repository are provided as a starting point for your implementation. You will need to make copies of and modify the configuration files to suit your implementation.

In order to streamline the process of creating configuration files tailored for your environment(s), the `New-AlzConfiguration.ps1` script has been provided. This script will create the configuration files for your implementation. It uses configuration files for an existing environment in the main repository as a starting point, combining information from a YAML file you create in your `$HOME/ALZ/config` folder that contains a subset of the most commonly updated configuration values. The script will then create the configuration files for your environment(s) in the correct location.

### Using a Configuration Template

Create a YAML file in your `$HOME/ALZ/config` folder that contains the configuration values for your implementation. The file name should be the name of your environment, followed by the `.yml` extension. For example, if your environment is named `MyAzureDevOpsOrg-main`, the file name should be `MyAzureDevOpsOrg-main.yml`.

Some notes about the values shown in the sample YAML template below:

- Some sections in the sample YAML file are commented out. You can uncomment these sections and provide values for them if you need to override the default values.

- You may comment out sections that you do not need to override the existing values from the source environment configuration.

- Most of the values you are likely to change are represented in the YAML template, with the exception of the network CIDR blocks. These are defined in the `networking` configuration files, and are discussed in more detail in the [Azure DevOps Pipelines Onboarding Guide](./azure-devops-pipelines.md).

- The `Source` attribute is the name of the environment you are copying the configuration from. This environment must already exist in your repository's `config` folder.

- The `Target` attribute is empty in the sample YAML file. When no value is specified, the base name of the YAML template file will be used to form your new environment name. For example, if your YAML template file is named `MyAzureDevOpsOrg-main.yml`, the `Target` attribute will be set to `MyAzureDevOpsOrg-main` by default.

- The following GUID is provided as a placeholder for the Azure AD tenant identifier. You must replace them with the actual GUID value of the Azure AD tenant in your environment:
  - `10000000-0000-0000-0000-000000000000`: Tenant

- The following GUIDs are provided as placeholders for Azure subscription identifiers. You must replace them with the actual GUID values of the subscriptions in your environment:
  - `20000000-0000-0000-0000-000000000000`: Logging subscription
  - `30000000-0000-0000-0000-000000000000`: Network Hub subscription
  - `40000000-0000-0000-0000-000000000000`: Identity subscription
  - `70000000-0000-0000-0000-000000000000`: Generic subscription
  - `80000000-0000-0000-0000-000000000000`: Machine Learning subscription
  - `90000000-0000-0000-0000-000000000000`: Healthcare subscription
  
  Note that the last 3 subscriptions correspond to each of the 3 archetypes provided in the reference implementation: Generic, Machine Learning, and Healthcare. These are optional and one or more of these can be removed if not needed.

- The following GUIDs are provided as placeholders for Azure AD security group identifiers. You must replace them with the actual GUID values of the security groups in your environment:
  - `00000000-1000-0000-0000-000000000000`: Azure AD group to assign Contributor role in Logging subscription
  - `00000000-2000-0000-0000-000000000000`: Azure AD group to assign Contributor role in Network subscription
  - `00000000-3000-0000-0000-000000000000`: Azure AD group to assign Contributor role in Identity subscription
  - `00000000-4000-0000-0000-000000000000`: Azure AD group to assign Contributor role in Generic subscription
  - `00000000-5000-0000-0000-000000000000`: Azure AD group to assign custom landing zone application owners role in Generic subscription
  - `00000000-6000-0000-0000-000000000000`: Azure AD group to assign Contributor role in Machine Learning subscription
  - `00000000-7000-0000-0000-000000000000`: Azure AD group to assign custom landing zone application owners role in Machine Learning subscription
  - `00000000-8000-0000-0000-000000000000`: Azure AD group to assign Contributor role in Healthcare subscription
  - `00000000-9000-0000-0000-000000000000`: Azure AD group to assign custom landing zone application owners role in Healthcare subscription

- The following partial GUIDs (8-character prefix) are provided as placeholders for the Azure subscription identifiers for 3 of the archetype subscriptions in the `CanadaPubSecALZ-main` configuration: Generic, Machine Learning, and Healthcare. You can replace them with partial GUIDs of alternate subscription configurations from a different source environment, or you can leave them as-is to use the subscription configurations provided in the `CanadaPubSecALZ-main` configuration:
  - `8422552f`: The Generic subscription from the `CanadaPubSecALZ-main` configuration
  - `f881fccb`: One of the Machine Learning subscriptions from the `CanadaPubSecALZ-main` configuration
  - `1f519216`: The Healthcare subscription from the `CanadaPubSecALZ-main` configuration

- The `Subscriptions:` element in the YAML template is a list of subscriptions from an existing source environment that will be used to create corresponding subscriptions in your target (new) environment. You may add or remove (delete or comment out) items in this list as needed.

Copy the following sample into your YAML file, and update the values to suit your implementation. The values you provide will be used to create the configuration files for your environment(s).

```yaml
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
      - name: DevTest
        id: DevTest
        children: []
      - name: QA
        id: QA
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
      securityGroupObjectIds: ['00000000-1000-0000-0000-000000000000']
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
      securityGroupObjectIds: ['00000000-2000-0000-0000-000000000000']
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
    # https://learn.microsoft.com/azure/ddos-protection/ddos-faq#are-services-unsafe-in-azure-without-the-service-
    enabled: false
    resourceGroupName: ddos-rg
    planName: ddos-plan

Identity:
  SubscriptionId: 40000000-0000-0000-0000-000000000000
  ManagementGroupId: Identity
  SecurityCenter:
    email: 'security@example.com'
    phone: '6135555555'
  ServiceHealthAlerts:
    resourceGroupName: service-health-alerts-rg
    incidentTypes: ['Incident', 'Security']
    regions: ['Global', 'Canada Central', 'Canada East']
    receivers:
      app: ['identity@example.com']
      email: ['identity@example.com']
      sms: [{ countryCode: '1', phoneNumber: '6135555555' }]
      voice: [{ countryCode: '1', phoneNumber: '6135555555' }]
    actionGroupName: 'Identity Alerts'
    actionGroupShortName: 'identity-ag'
    alertRuleName: 'Identity Alerts'
    alertRuleDescription: 'Identity Alerts for Incidents and Security'
  RoleAssignments:
    - comments: 'Built-in Contributor Role'
      roleDefinitionId: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
      securityGroupObjectIds: ['00000000-3000-0000-0000-000000000000']
  # SubscriptionTags:
  #   ISSO: isso-tag
  # ResourceTags:
  #   ClientOrganization: client-organization-tag
  #   CostCenter: cost-center-tag
  #   DataSensitivity: data-sensitivity-tag
  #   ProjectContact: project-contact-tag
  #   ProjectName: project-name-tag
  #   TechnicalContact: technical-contact-tag

Subscriptions:
- '8422552f':   # Generic subscription ID prefix from {$Environment.Source}
    SubscriptionId: 70000000-0000-0000-0000-000000000000
    ManagementGroupId: DevTest
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
        securityGroupObjectIds: ['00000000-4000-0000-0000-000000000000']
      - comments: 'Custom Role: Landing Zone Application Owner'
        roleDefinitionId: 'b4c87314-c1a1-5320-9c43-779585186bcc'
        securityGroupObjectIds: ['00000000-5000-0000-0000-000000000000']
    # SubscriptionTags:
    #   ISSO: isso-tag
    # ResourceTags:
    #   ClientOrganization: client-organization-tag
    #   CostCenter: cost-center-tag
    #   DataSensitivity: data-sensitivity-tag
    #   ProjectContact: project-contact-tag
    #   ProjectName: project-name-tag
    #   TechnicalContact: technical-contact-tag

- 'f881fccb':   # Machine Learning 1 subscription ID prefix from {$Environment.Source}
    SubscriptionId: 80000000-0000-0000-0000-000000000000
    ManagementGroupId: DevTest
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
        securityGroupObjectIds: ['00000000-6000-0000-0000-000000000000']
      - comments: 'Custom Role: Landing Zone Application Owner'
        roleDefinitionId: 'b4c87314-c1a1-5320-9c43-779585186bcc'
        securityGroupObjectIds: ['00000000-7000-0000-0000-000000000000']
    # SubscriptionTags:
    #   ISSO: isso-tag
    # ResourceTags:
    #   ClientOrganization: client-organization-tag
    #   CostCenter: cost-center-tag
    #   DataSensitivity: data-sensitivity-tag
    #   ProjectContact: project-contact-tag
    #   ProjectName: project-name-tag
    #   TechnicalContact: technical-contact-tag

- '1f519216':   # Healthcare subscription ID prefix from {$Environment.Source}
    SubscriptionId: 90000000-0000-0000-0000-000000000000
    ManagementGroupId: DevTest
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
        securityGroupObjectIds: ['00000000-8000-0000-0000-000000000000']
      - comments: 'Custom Role: Landing Zone Application Owner'
        roleDefinitionId: 'b4c87314-c1a1-5320-9c43-779585186bcc'
        securityGroupObjectIds: ['00000000-9000-0000-0000-000000000000']
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

The next step is to create the configuration files for the target environment. The following command will create a new set of configuration files in the `config` folder, based on the settings in the YAML template file created in the previous section.

```powershell
PS> $Environment = 'MyAzureDevOpsOrg-main'
PS> .\New-AlzConfiguration.ps1 -Environment $Environment
```

Running the `New-AlzConfiguration.ps1` script as shown above will create the new set of configuration files and produce output similar to the following:

```text
This script creates a new set of configuration files, using an existing CanadaPubSecALZ configuration. Select configuration elements are replaced with values specific to the target environment.

Reading parameters from file (C:\Users\username\ALZ\config\MyAzureDevOpsOrg-main.yml)
Checking configuration path (P:\CanadaPubSecALZ\CanadaPubSecALZ\config)
  Source environment: CanadaPubSecALZ-main
  Target environment: MyAzureDevOpsOrg-main

Generating Variables configurations

  Updating variables configuration
  Writing variables configuration file: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/variables/MyAzureDevOpsOrg-main.yml

Generating Logging configurations

  Reading source environment logging configuration file: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/logging/CanadaPubSecALZ-main/logging.parameters.json
  Updating logging configuration
  Writing logging configuration file: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/logging/MyAzureDevOpsOrg-main/logging.parameters.json

Generating Network Azure Firewall configurations

  Reading source environment network Azure Firewall configuration file: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/networking/CanadaPubSecALZ-main/hub-azfw/hub-network.parameters.json
  Updating network Azure Firewall configuration
  Writing network Azure Firewall configuration file: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/networking/MyAzureDevOpsOrg-main/hub-azfw/hub-network.parameters.json

Generating Network Azure Firewall Policy configurations

  Reading source environment network Azure Firewall Policy configuration file: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/networking/CanadaPubSecALZ-main/hub-azfw-policy/azure-firewall-policy.parameters.json
  Updating network Azure Firewall Policy configuration
  Writing network Azure Firewall Policy configuration file: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/networking/MyAzureDevOpsOrg-main/hub-azfw-policy/azure-firewall-policy.parameters.json

Generating Network NVA configurations

  Reading source environment network NVA configuration file: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/networking/CanadaPubSecALZ-main/hub-nva/hub-network.parameters.json
  Updating network NVA configuration
  Writing network NVA configuration file: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/networking/MyAzureDevOpsOrg-main/hub-nva/hub-network.parameters.json

Generating Identity configurations

  Reading source environment identity configuration file: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/identity/CanadaPubSecALZ-main/identity.parameters.json
  Updating identity configuration
  Writing identity configuration file: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/identity/MyAzureDevOpsOrg-main/identity.parameters.json

Generating subscription configurations

  Looking for source environment subscription configuration file(s) matching specified pattern (8422552f)
  Reading subscription configuration (8422552f-3840-4934-a971-6ee349ffbb05_generic-subscription_canadacentral.json)
  Updating subscription configuration
  Writing new subscription configuration (P:\CanadaPubSecALZ\CanadaPubSecALZ\config/subscriptions/MyAzureDevOpsOrg-main/DevTest/70000000-0000-0000-0000-000000000000_generic-subscription_canadacentral.json)

  Looking for source environment subscription configuration file(s) matching specified pattern (f881fccb)
  Reading subscription configuration (f881fccb-2598-4b9c-b87c-b392f5e16f12_machinelearning_canadacentral.json)
  Updating subscription configuration
  Writing new subscription configuration (P:\CanadaPubSecALZ\CanadaPubSecALZ\config/subscriptions/MyAzureDevOpsOrg-main/DevTest/80000000-0000-0000-0000-000000000000_machinelearning_canadacentral.json)

  Looking for source environment subscription configuration file(s) matching specified pattern (1f519216)
  Reading subscription configuration (1f519216-5e39-4b51-a9b6-10cc2b79b6c7_healthcare_canadacentral.json)
  Updating subscription configuration
  Writing new subscription configuration (P:\CanadaPubSecALZ\CanadaPubSecALZ\config/subscriptions/MyAzureDevOpsOrg-main/DevTest/90000000-0000-0000-0000-000000000000_healthcare_canadacentral.json)

Elapsed time: 00:00:00.5295725
```

### Deleting Configuration Files

If you create a set of configuration files and decide you no longer need them, you can delete them using the `Remove-AlzConfiguration.ps1` script. The following command will delete the configuration files for the target environment.

```powershell
PS> $Environment = 'MyAzureDevOpsOrg-main'
PS> .\Remove-AlzConfiguration.ps1 -Environment $Environment
```

Running the `Remove-AlzConfiguration.ps1` script as shown above will delete the configuration files for the target environment and produce output similar to the following:

```text
This script removes an existing set of configuration files.

Checking configuration path (P:\CanadaPubSecALZ\CanadaPubSecALZ\config)
Removing variables configuration file: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/variables/MyAzureDevOpsOrg-main.yml
Removing logging configuration directory: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/logging/MyAzureDevOpsOrg-main
Removing network configuration directory: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/networking/MyAzureDevOpsOrg-main
Removing identity configuration directory: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/identity/MyAzureDevOpsOrg-main
Removing subscription configuration directory: P:\CanadaPubSecALZ\CanadaPubSecALZ\config/subscriptions/MyAzureDevOpsOrg-main

Elapsed time: 00:00:00.1053294
```

If you have deleted the configuration files for an environment and want to recreate them, you can do so by running the `New-AlzConfiguration.ps1` script as described in the previous section, assuming you have not deleted the source environment configuration files and the YAML template file is still available.

---

## Working with Deployments

### Deploying a Configuration

Once you have created a set of configuration files for an environment, you can deploy the configuration using the `New-AlzDeployment.ps1` script.

>Note: The `New-AlzDeployment.ps1` script will deploy all stages of the specified environment configuration, including: management groups, logging, policies, networking, identity, and subscriptions. If you only want to deploy a subset of the configuration, you can use the `/scripts/deployments/RunWorkflows.ps1` script or invoke the individual Azure DevOps pipelines / GitHub workflows for each stage.

The following invocation of the `New-AlzDeployment.ps1` script will deploy all stages of the configuration files for the target environment using the previously created credential file and the `AzFW` (Azure Firewall) network hub type:

```powershell
PS> $Environment = 'MyAzureDevOpsOrg-main'
PS> .\New-AlzDeployment.ps1 -Environment $Environment -CredentialFile $Environment -NetworkType 'AzFW'
```

The following invocation of the `New-AlzDeployment.ps1` script will deploy all stages of the configuration files for the target environment using the previously created credential file and the `NVA` (Network Virtual Appliance) network hub type:

```powershell
PS> $Environment = 'MyAzureDevOpsOrg-main'
PS> .\New-AlzDeployment.ps1 -Environment $Environment -CredentialFile $Environment -NetworkType 'NVA'
```

The `.\New-AlzDeployment.ps1` script also provides for alternate authentication methods to the credential file. You may also use a service principal or interactive authentication.

When you deploy from local configuration files, remember that detailed log output is available in `$HOME/ALZ/logs` (by default) and the log files generated for deployment operations can be very useful for troubleshooting.
