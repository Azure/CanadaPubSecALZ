# Onboarding Guide for Azure DevOps

This document provides steps required to onboard to the Azure Landing Zones design based on Azure DevOps Pipelines.

**All steps will need to be repeated per Azure AD tenant.**

## Step 1:  Create Service Principal Account & Assign RBAC

A service principal account is required to automate the Azure DevOps pipelines. 

* **Service Principal Name**:  any name (i.e. spn-azure-platform-ops)

* **RBAC Assignment**

    * Scope:  Tenant Root Group (this is a management group)

    * Role:  Owner

## Step 2:  Configure Service Connection in Azure DevOps Project Configuration

* **Scope Level**:  Management Group

* **Service Connection Name**:  spn-azure-platform-ops

    *Service Connection Name will be used to configure Azure DevOps Pipelines.*

*  **Instructions**:  [Service connections in Azure Pipelines - Azure Pipelines | Microsoft Docs](https://docs.microsoft.com/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml)


## Step 3:  Configure Management Group Deployment

### Step: 3.1: Update common.yml in git repository

Create/edit **.pipelines/templates/variables/common.yml** in Git.  This file is used in all Azure DevOps pipelines.

**Sample YAML**
```yaml
variables:

  deploymentRegion: canadacentral
  serviceConnection: spn-azure-platform-ops
  vmImage: ubuntu-latest
  deployOperation: create

```

### Step 3.2:  Update environment config file in git repository

1. Create/edit **./pipelines/templates/variables/<devops-org-name>-<branch-name>.yml** in Git (i.e. CanadaESLZ-main.yml).  This file name is automatically inferred based on the Azure DevOps organization name and the branch.

    **Sample environment YAML**

    ```yaml
    variables:

        # Management Groups
        var-parentManagementGroupId: abcddfdb-bef5-46d9-99cf-ed67dabc8783
        var-topLevelManagementGroupName: pubsec

    ```

2. Commit the changes to git repository

### Step 3.3:  Configure Azure DevOps Pipeline

1. Pipeline definition for Management Group.

    *Note: Pipelines are stored as YAML definitions in Git and imported into Azure DevOps Pipelines.  This approach allows for portability and change tracking.*

    1.	Go to Pipelines
    2.	New Pipeline
    3.	Choose Azure Repos Git
    4.	Select Repository
    5.	Select Existing Azure Pipeline YAML file
    6.	Identify the pipeline in `.pipelines/management-groups.yml`.
    7.  Save the pipeline (don't run it yet)
    8.  Rename the pipeline to `management-groups-ci`


2. Run pipeline and wait for completion.


## Step 4:  Logging Landing Zone

### Step 4.1:  Setup Azure AD Security Group (Optional)

At least one Azure AD Security Group is required for role assignment.  Role assignment can be set for Owner, Contributor, and/or Reader roles.  Note down the Security Group object id, it will be required for next step.

### Step 4.2:  Update configuration files in git repository

Set the configuration parameters even if there’s an existing central Log Analytics Workspace.  These settings are used by other deployments such as Azure Policy for Log Analytics.  In this case, use the values of the existing Log Analytics Workspace.

When a Log Analytics Workspace & Automation account already exists, enter Subscription ID, Resource Group, Log Analytics Workspace name and Automation account name.  The automation will update the existing deployment instead of creating new resources.

1. Edit `.pipelines/templates/variables/<devops-org-name>-<branch-name>.yml` in Git.  This configuration file was created in Step 3.

    ```yml
    variables:
    # Management Groups
    var-parentManagementGroupId: acbddfdb-bef5-46d9-99cf-ed67d5941234
    var-topLevelManagementGroupName: pubsec

    # Logging
    var-logging-managementGroupId: pubsecPlatform
    var-logging-subscriptionId: bc0a4f9f-07fa-4284-b1bd-fbad38578d3a
    var-logging-subscriptionOwnerGroupObjectIds: '[]'
    var-logging-subscriptionContributorGroupObjectIds: '["38f33f7e-a471-4630-8ce9-c6653495a2ee"]'
    var-logging-subscriptionReaderGroupObjectIds: '[]'
    var-logging-logAnalyticsResourceGroupName: pubSecLogAnalyticsRG
    var-logging-logAnalyticsWorkspaceName: pubSecLogAnalytics
    var-logging-logAnalyticsAutomationAccountName: pubSecLogAnalyticsAutomation
    var-logging-diagnosticSettingsforNetworkSecurityGroupsStoragePrefix: pubsecnsg
    var-logging-securityContactEmail: alzcanadapubsec@microsoft.com
    var-logging-securityContactPhone: 5555555555
    var-logging-createBudget: false
    var-logging-budgetName: SubscriptionBudget
    var-logging-budgetAmount: 100
    var-logging-budgetTimeGrain: Monthly
    var-logging-budgetNotificationEmailAddress: alzcanadapubsec@microsoft.com
    var-logging-tagISSO: tbd
    var-logging-tagClientOrganization: tbd
    var-logging-tagCostCenter: tbd
    var-logging-tagDataSensitivity: tbd
    var-logging-tagProjectContact: tbd
    var-logging-tagProjectName: tbd
    var-logging-tagTechnicalContact: tbd
    ```


2. Commit the changes to git repository.

### Step 4.3:  Configure Azure DevOps Pipeline (only required if a new central Log Analytics Workspace is required)

1. Pipeline definition for Central Logging.

    *Note: Pipelines are stored as YAML definitions in Git and imported into Azure DevOps Pipelines.  This approach allows for portability and change tracking.*

    1.	Go to Pipelines
    2.	New Pipeline
    3.	Choose Azure Repos Git
    4.	Select Repository
    5.	Select Existing Azure Pipeline YAML file
    6.	Identify the pipeline in `.pipelines/platform-logging.yml`.
    7.  Save the pipeline (don't run it yet)
    8.  Rename the pipeline to `platform-logging-ci`


2. Run pipeline and wait for completion.

## Step 5:  Configure Azure Policies

1. Pipeline definition for Azure Policies.

    *Note: Pipelines are stored as YAML definitions in Git and imported into Azure DevOps Pipelines.  This approach allows for portability and change tracking.*

    1.	Go to Pipelines
    2.	New Pipeline
    3.	Choose Azure Repos Git
    4.	Select Repository
    5.	Select Existing Azure Pipeline YAML file
    6.	Identify the pipeline in `.pipelines/policy.yml`.
    7.  Save the pipeline (don't run it yet)
    8.  Rename the pipeline to `policy-ci`


2. Run pipeline and wait for completion.


## Step 6:  Configure Custom Roles

1. Pipeline definition for Custom Roles.

    *Note: Pipelines are stored as YAML definitions in Git and imported into Azure DevOps Pipelines.  This approach allows for portability and change tracking.*

    1.	Go to Pipelines
    2.	New Pipeline
    3.	Choose Azure Repos Git
    4.	Select Repository
    5.	Select Existing Azure Pipeline YAML file
    6.	Identify the pipeline in `.pipelines/roles.yml`.
    7.  Save the pipeline (don't run it yet)
    8.  Rename the pipeline to `roles-ci`


2. Run pipeline and wait for completion.

## Step 7:  Configure Hub Networking using NVAs

1.	Configure Variable Group:  firewall-secrets

    * In Azure DevOps, go to Pipelines -> Library

    * Select + Variable group
    
    * Set Variable group name:  firewall-secrets
    
    * Add two variables:

        These two variables are used when creating Firewall virtual machines.  These are temporary passwords and recommended to be changed after creation. The same username and password are used for all virtual machines.

        When creating both variables, toggle the lock icon to make it a secret.  This ensures that the values are not shown in logs nor to Azure DevOps users.

        Write down the username and password as it’s not retrievable once saved.

        * var-hubnetwork-fwUsername
        * var-hubnetwork-fwPassword

    * Click Save 

2.	Configure Pipeline for Platform – Hub Networking using NVAs

    *Note: Pipelines are stored as YAML definitions in Git and imported into Azure DevOps Pipelines.  This approach allows for portability and change tracking.*

    1.	Go to Pipelines
    2.	New Pipeline
    3.	Choose Azure Repos Git
    4.	Select Repository
    5.	Select Existing Azure Pipeline YAML file
    6.	Identify the pipeline in `.pipelines/platform-connectivity-hub-nva.yml`.
    7.  Save the pipeline (don't run it yet)
    8.  Rename the pipeline to `platform-connectivity-hub-nva-ci`

3.	Configure Pipeline permissions for the secrets.

    * In Azure DevOps, go to Pipelines -> Library
    * Select variable group previously created (i.e. “firewall-secrets”)
    * Click “Pipeline Permissions”, and in resulting dialog window:
        * Click “Restrict permission”
        * Click “+” button
        * Select the “platform-connectivity-hub-nva-ci” pipeline
        * Close the dialog window

4.	Run pipeline and wait for completion.

## Step 8:  Configure Subscription Archetype

1.	Configure Pipeline definition for subscription archetypes

    *Note: Pipelines are stored as YAML definitions in Git and imported into Azure DevOps Pipelines.  This approach allows for portability and change tracking.*

    1.	Go to Pipelines
    2.	New Pipeline
    3.	Choose Azure Repos Git
    4.	Select Repository
    5.	Select Existing Azure Pipeline YAML file
    6.	Identify the pipeline in `.pipelines/subscriptions.yml`.
    7.  Save the pipeline (don't run it yet)
    8.  Rename the pipeline to `subscription-ci`