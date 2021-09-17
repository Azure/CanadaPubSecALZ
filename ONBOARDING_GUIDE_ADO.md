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

    1.    Go to Pipelines
    2.    New Pipeline
    3.    Choose Azure Repos Git
    4.    Select Repository
    5.    Select Existing Azure Pipeline YAML file
    6.    Identify the pipeline in `.pipelines/management-groups.yml`.
    7.  Save the pipeline (don't run it yet)
    8.  Rename the pipeline to `management-groups-ci`


2. Run pipeline and wait for completion.


## Step 4:  Logging Landing Zone

### Step 4.1:  Setup Azure AD Security Group (Optional)

At least one Azure AD Security Group is required for role assignment.  Role assignment can be set for Owner, Contributor, and/or Reader roles.  Note down the Security Group object id, it will be required for next step.

### Step 4.2:  Update configuration files in git repository

Set the configuration parameters even if there's an existing central Log Analytics Workspace.  These settings are used by other deployments such as Azure Policy for Log Analytics.  In this case, use the values of the existing Log Analytics Workspace.

When a Log Analytics Workspace & Automation account already exists, enter Subscription ID, Resource Group, Log Analytics Workspace name and Automation account name.  The automation will update the existing deployment instead of creating new resources.

1. Edit `.pipelines/templates/variables/<devops-org-name>-<branch-name>.yml` in Git.  This configuration file was created in Step 3.

    **Sample environment YAML**

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
    var-logging-logAnalyticsResourceGroupName: pubsec-central-logging-rg
    var-logging-logAnalyticsWorkspaceName: log-analytics-workspace
    var-logging-logAnalyticsAutomationAccountName: automation-account
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

    1.    Go to Pipelines
    2.    New Pipeline
    3.    Choose Azure Repos Git
    4.    Select Repository
    5.    Select Existing Azure Pipeline YAML file
    6.    Identify the pipeline in `.pipelines/platform-logging.yml`.
    7.  Save the pipeline (don't run it yet)
    8.  Rename the pipeline to `platform-logging-ci`


2. Run pipeline and wait for completion.

## Step 5:  Configure Azure Policies

1. Pipeline definition for Azure Policies.

    *Note: Pipelines are stored as YAML definitions in Git and imported into Azure DevOps Pipelines.  This approach allows for portability and change tracking.*

    1.    Go to Pipelines
    2.    New Pipeline
    3.    Choose Azure Repos Git
    4.    Select Repository
    5.    Select Existing Azure Pipeline YAML file
    6.    Identify the pipeline in `.pipelines/policy.yml`.
    7.  Save the pipeline (don't run it yet)
    8.  Rename the pipeline to `policy-ci`


2. Run pipeline and wait for completion.


## Step 6:  Configure Custom Roles

1. Pipeline definition for Custom Roles.

    *Note: Pipelines are stored as YAML definitions in Git and imported into Azure DevOps Pipelines.  This approach allows for portability and change tracking.*

    1.    Go to Pipelines
    2.    New Pipeline
    3.    Choose Azure Repos Git
    4.    Select Repository
    5.    Select Existing Azure Pipeline YAML file
    6.    Identify the pipeline in `.pipelines/roles.yml`.
    7.  Save the pipeline (don't run it yet)
    8.  Rename the pipeline to `roles-ci`


2. Run pipeline and wait for completion.

## Step 7:  Configure Hub Networking using NVAs

1. Edit `.pipelines/templates/variables/<devops-org-name>-<branch-name>.yml` in Git.  This configuration file was created in Step 3.

   Update configuration with the networking section.

    **Sample environment YAML**

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
    var-logging-logAnalyticsResourceGroupName: pubsec-central-logging-rg
    var-logging-logAnalyticsWorkspaceName: log-analytics-workspace
    var-logging-logAnalyticsAutomationAccountName: automation-account
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

    # Hub Networking
    var-hubnetwork-managementGroupId: pubsecPlatform
    var-hubnetwork-subscriptionId: ed7f4eed-9010-4227-b115-2a5e37728f27
    var-hubnetwork-subscriptionOwnerGroupObjectIds: '[]'
    var-hubnetwork-subscriptionContributorGroupObjectIds: '["38f33f7e-a471-4630-8ce9-c6653495a2ee"]'
    var-hubnetwork-subscriptionReaderGroupObjectIds: '[]'
    var-hubnetwork-securityContactEmail: alzcanadapubsec@microsoft.com
    var-hubnetwork-securityContactPhone: 5555555555
    var-hubnetwork-createBudget: false
    var-hubnetwork-budgetName: SubscriptionBudget
    var-hubnetwork-budgetAmount: 100
    var-hubnetwork-budgetTimeGrain: Monthly
    var-hubnetwork-budgetNotificationEmailAddress: alzcanadapubsec@microsoft.com
    var-hubnetwork-tagISSO: tbd
    var-hubnetwork-tagClientOrganization: tbd
    var-hubnetwork-tagCostCenter: tbd
    var-hubnetwork-tagDataSensitivity: tbd
    var-hubnetwork-tagProjectContact: tbd
    var-hubnetwork-tagProjectName: tbd
    var-hubnetwork-tagTechnicalContact: tbd
    var-hubnetwork-budgetStartDate: yyyy-MM-01

    ## Hub Networking - Private Dns Zones
    var-hubnetwork-deployPrivateDnsZones: true
    var-hubnetwork-rgPrivateDnsZonesName: pubsec-dns-rg

    ## Hub Networking - DDOS
    var-hubnetwork-deployDdosStandard: false
    var-hubnetwork-rgDdosName: pubsec-ddos-rg
    var-hubnetwork-ddosPlanName: ddos-plan

    ## Hub Networking - Core Virtual Network
    var-hubnetwork-rgHubName: pubsec-hub-networking-rg
    var-hubnetwork-hubVnetName: hub-vnet
    var-hubnetwork-hubVnetAddressPrefixRFC1918: 10.18.0.0/22
    var-hubnetwork-hubVnetAddressPrefixRFC6598: 100.60.0.0/16
    var-hubnetwork-hubVnetAddressPrefixBastion: 192.168.0.0/16

    var-hubnetwork-hubEanSubnetName: EanSubnet
    var-hubnetwork-hubEanSubnetAddressPrefix: 10.18.0.0/27

    var-hubnetwork-hubPublicSubnetName: PublicSubnet
    var-hubnetwork-hubPublicSubnetAddressPrefix: 100.60.0.0/24

    var-hubnetwork-hubPazSubnetName: PAZSubnet
    var-hubnetwork-hubPazSubnetAddressPrefix: 100.60.1.0/24

    var-hubnetwork-hubDevIntSubnetName: DevIntSubnet
    var-hubnetwork-hubDevIntSubnetAddressPrefix: 10.18.0.64/27

    var-hubnetwork-hubSubnetProdIntName: PrdIntSubnet
    var-hubnetwork-hubSubnetProdIntAddressPrefix: 10.18.0.32/27

    var-hubnetwork-hubSubnetMrzIntName: MrzSubnet
    var-hubnetwork-hubSubnetMrzIntAddressPrefix: 10.18.0.96/27

    var-hubnetwork-hubSubnetHAName: HASubnet
    var-hubnetwork-hubSubnetHAAddressPrefix: 10.18.0.128/28

    var-hubnetwork-hubSubnetGatewaySubnetPrefix: 10.18.1.0/27

    var-hubnetwork-hubSubnetBastionAddressPrefix: 192.168.0.0/24
    var-hubnetwork-bastionName: bastion

    ## Hub Networking - Firewall Virtual Appliances
    var-hubnetwork-deployFirewallVMs: false
    var-hubnetwork-useFortigateFW: false

    ### Hub Networking - Firewall Virtual Appliances - For Non-production Traffic
    var-hubnetwork-fwDevILBName: pubsecDevFWILB
    var-hubnetwork-fwDevVMSku: Standard_D8s_v4
    var-hubnetwork-fwDevVM1Name: pubsecDevFW1
    var-hubnetwork-fwDevVM2Name: pubsecDevFW2
    var-hubnetwork-fwDevILBExternalFacingIP: 100.60.0.7
    var-hubnetwork-fwDevVM1ExternalFacingIP: 100.60.0.8
    var-hubnetwork-fwDevVM2ExternalFacingIP: 100.60.0.9
    var-hubnetwork-fwDevILBMrzIntIP: 10.18.0.103
    var-hubnetwork-fwDevVM1MrzIntIP: 10.18.0.104
    var-hubnetwork-fwDevVM2MrzIntIP: 10.18.0.105
    var-hubnetwork-fwDevILBDevIntIP: 10.18.0.68
    var-hubnetwork-fwDevVM1DevIntIP: 10.18.0.69
    var-hubnetwork-fwDevVM2DevIntIP: 10.18.0.70
    var-hubnetwork-fwDevVM1HAIP: 10.18.0.134
    var-hubnetwork-fwDevVM2HAIP: 10.18.0.135

    ### Hub Networking - Firewall Virtual Appliances - For Production Traffic
    var-hubnetwork-fwProdILBName: pubsecProdFWILB
    var-hubnetwork-fwProdVMSku: Standard_F8s_v2
    var-hubnetwork-fwProdVM1Name: pubsecProdFW1
    var-hubnetwork-fwProdVM2Name: pubsecProdFW2
    var-hubnetwork-fwProdILBExternalFacingIP: 100.60.0.4
    var-hubnetwork-fwProdVM1ExternalFacingIP: 100.60.0.5
    var-hubnetwork-fwProdVM2ExternalFacingIP: 100.60.0.6
    var-hubnetwork-fwProdILBMrzIntIP: 10.18.0.100
    var-hubnetwork-fwProdVM1MrzIntIP: 10.18.0.101
    var-hubnetwork-fwProdVM2MrzIntIP: 10.18.0.102
    var-hubnetwork-fwProdILBPrdIntIP: 10.18.0.36
    var-hubnetwork-fwProdVM1PrdIntIP: 10.18.0.37
    var-hubnetwork-fwProdVM2PrdIntIP: 10.18.0.38
    var-hubnetwork-fwProdVM1HAIP: 10.18.0.132
    var-hubnetwork-fwProdVM2HAIP: 10.18.0.133

    ## Hub Networking - Management Restricted Zone Virtual Network
    var-hubnetwork-rgMrzName: pubsec-management-restricted-zone-rg
    var-hubnetwork-mrzVnetName: management-restricted-vnet
    var-hubnetwork-mrzVnetAddressPrefixRFC1918: 10.18.4.0/22

    var-hubnetwork-mrzMazSubnetName: MazSubnet
    var-hubnetwork-mrzMazSubnetAddressPrefix: 10.18.4.0/25
    
    var-hubnetwork-mrzInfSubnetName: InfSubnet
    var-hubnetwork-mrzInfSubnetAddressPrefix: 10.18.4.128/25
    
    var-hubnetwork-mrzSecSubnetName: SecSubnet
    var-hubnetwork-mrzSecSubnetAddressPrefix: 10.18.5.0/26
    
    var-hubnetwork-mrzLogSubnetName: LogSubnet
    var-hubnetwork-mrzLogSubnetAddressPrefix: 10.18.5.64/26
    
    var-hubnetwork-mrzMgmtSubnetName: MgmtSubnet
    var-hubnetwork-mrzMgmtSubnetAddressPrefix: 10.18.5.128/26

    ## Hub Networking - Public Zone
    var-hubnetwork-rgPazName: pubsec-public-access-zone-rg
    ```

2. Configure Variable Group:  firewall-secrets

    * In Azure DevOps, go to Pipelines -> Library
    * Select + Variable group
    * Set Variable group name:  firewall-secrets
    * Add two variables:

      These two variables are used when creating Firewall virtual machines.  These are temporary passwords and recommended to be changed after creation. The same username and password are used for all virtual machines.

      When creating both variables, toggle the lock icon to make it a secret.  This ensures that the values are not shown in logs nor to Azure DevOps users.

      Write down the username and password as it's not retrievable once saved.

        * var-hubnetwork-fwUsername
        * var-hubnetwork-fwPassword

    * Click Save 

3. Configure Pipeline for Platform – Hub Networking using NVAs

    > Note: Pipelines are stored as YAML definitions in Git and imported into Azure DevOps Pipelines.  This approach allows for portability and change tracking.

    1. Go to Pipelines
    2. New Pipeline
    3. Choose Azure Repos Git
    4. Select Repository
    5. Select Existing Azure Pipeline YAML file
    6. Identify the pipeline in `.pipelines/platform-connectivity-hub-nva.yml`.
    7. Save the pipeline (don't run it yet)
    8. Rename the pipeline to `platform-connectivity-hub-nva-ci`

4. Configure Pipeline permissions for the secrets.

    * In Azure DevOps, go to Pipelines -> Library
    * Select variable group previously created (i.e. "firewall-secrets")
    * Click "Pipeline Permissions", and in resulting dialog window:
        * Click "Restrict permission"
        * Click "+" button
        * Select the "platform-connectivity-hub-nva-ci" pipeline
        * Close the dialog window

5. Run pipeline and wait for completion.

## Step 8:  Configure Subscription Archetype

1. Configure Pipeline definition for subscription archetypes

    > Pipelines are stored as YAML definitions in Git and imported into Azure DevOps Pipelines.  This approach allows for portability and change tracking.

    1. Go to Pipelines
    2. New Pipeline
    3. Choose Azure Repos Git
    4. Select Repository
    5. Select Existing Azure Pipeline YAML file
    6. Identify the pipeline in `.pipelines/subscriptions.yml`.
    7. Save the pipeline (don't run it yet)
    8. Rename the pipeline to `subscription-ci`

2. Create a subscription configuration file (JSON)

    1. Make a copy of an existing subscription configuration file under `config/subscriptions/CanadaESLZ-main` as a starting point

    2. Be sure to rename the file in one of the following formats:
       * `[GUID]_[TYPE].json`
       * `[GUID]_[TYPE]_[LOCATION].json`

       Replace `[GUID]` with the subscription GUID. Replace `[TYPE]` with the subscription archetype. Optionally, add (replace) `[LOCATION]` with an Azure deployment location, e.g. `canadacentral`. If you do not specify a location in the configuration file name, the `deploymentRegion` variable will be used by default.

       > If a fourth specifier is added to the configuration filename at some future point and you do not want to supply an explicit deployment location in the third part of the configuration file name, you can either leave it empty (two consecutive underscore characters) or provide the case-sensitive value `default` to signal the `deploymentRegion` variable value should be used.

    3. Save the subscription configuration file in a subfolder (under `config/subscriptions`) that is named for your Azure DevOps organization combined with the branch name corresponding to your deployment environment. For example, if your Azure DevOps organization name is `Contoso` and your Azure Repos branch for the target deployment environment is `main`, then the subfolder name would be `Contoso-main`.

    4. Update the contents of the newly created subscription configuration file to match your deployment environment.

    5. Commit the subscription file to Azure Repos.

3. Run the subscription pipeline

    1. In Azure DevOps, go to Pipelines
    2. Select the `subscription-ci` pipeline and run it.

       > The `subscription-ci` pipeline YAML is configured, by default, to **not** run automatically; you can change this if desired.

    3. In the Run Pipelines dialog window, enter the first 4 digits of your new subscription configuration file name (4 is usually enough of the GUID to uniquely identify the subscription) between the square brackets in the `subscriptions` parameter field. For example: `[802e]`.

    4. In the Run Pipelines dialog window, click the `Run` button to start the pipeline.

