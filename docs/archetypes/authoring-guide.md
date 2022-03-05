# Archetype Authoring Guide

[Azure landing zones](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/) are the output of a multi-subscription Azure environment that accounts for scale, security governance, networking, and identity. Therefore, deploying an archetype will result in an Azure landing zone that can be enhanced, scaled and refined based on business need.

This reference implementation provides a number of archetypes that can be used as-is or customized further to suit business needs.  Archetypes are self-contained Bicep deployment templates that are used to configure multiple subscriptions.  Archetypes provide the ability to configure new subscriptions with use case specific architecture in a repeatable method. One archetype can be used to configure many subscriptions.

This implementation provides two types of archetypes:  Spoke archetypes & Platform archetypes.  Spoke archetypes are used to configure subscriptions for line of business use cases such as Machine Learning & Healthcare.  Platform archetypes are used to configure shared infrastructure such as Logging, Hub Networking and Firewalls.  Intent of the archetypes is to **provide a repeatable method** for configuring subscriptions.  It offers a **consistent deployment experience and supports common scenarios** required by your organization.

To avoid archetype sprawl, we recommend a **maximum of 3-5 spoke archetypes**.  When there are new capabilities or Azure services to add, consider evolving an existing archetypes through **feature flags**.  Once an archetype is deployed, the application teams can further modify the deployment for scale or new capabilities using their preferred deployment tools.

The goal of this authoring guide is to provide step-by-step instructions to create new and update existing archetypes.

## Table of Contents

- [Folder structure](#folder-structure)
- [Create a new spoke archetype](#create-a-spoke-archetype)
  - [Build new or reuse existing archetypes?](#build-new-or-reuse-existing-archetypes)
  - [Requirements for archetypes](#requirements-for-archetypes)
  - [Approach](#approach)
- [Update a spoke archetype](#update-a-spoke-archetype)
- [Common features](#common-features)
- [JSON Schema for deployment parameters](#json-schema-for-deployment-parameters)
- [Telemetry](#telemetry)
- [Deployment instructions](#deployment-instructions)

---

## Folder structure

Archetypes are located in [`landingzones`](../../landingzones) folder and organized as folder per archetype.  Here are the current archetypes with links to documentation:

- Platform archetypes
  - [`lz-platform-connectivity-hub-azfw`](hubnetwork-azfw.md) - configures a Hub Virtual Network with Azure Firewall.
  - [`lz-platform-connectivity-hub-nva`](hubnetwork-nva-fortigate.md) - configures a Hub Virtual Network with Fortinet Firewall.
  - [`lz-platform-logging`](logging.md) - configures central logging infrastructure using Log Analytics Workspace and Microsoft Sentinel.
- Spoke archetypes
  - [`lz-generic-subscription`](generic-subscription.md) - configures a subscription for general purpose use.
  - [`lz-healthcare`](healthcare.md) - configures a subscription for healthcare scenarios.
  - [`lz-machinelearning`](machinelearning.md) - configures a subscription for machine learning scenarios.

---

## Create a new spoke archetype

Archetypes are self-contained Bicep deployment templates that are used to configure multiple subscriptions.  Archetypes provide the ability to configure new subscriptions with use case specific architecture in a repeatable method. One archetype can be used to configure many subscriptions.

### Build new or reuse existing archetypes?

You should develop new archetypes when a common deployment architecture or pattern emerges within your organization.  There's limited value when an archetype is created for 1 or 2 deployments.  The return on investment increases when the archetype is deployed to 10s or 100s of subscriptions.

You should start by evaluating the [existing archetypes for enhancement opportunities](#update-a-spoke-archetype).  New features can be placed behind feature flags to provide customization/choices of Azure services to configure at deployment time.  For example, we use feature flags to control SQL Database and SQL Managed Instance deployment in the Machine Learning archetype.

The `sqldb.enabled` feature flag for SQL Database deployment:

```json
"sqldb": {
  "value": {
    "enabled": true,
    "sqlAuthenticationUsername": "azadmin",
    "aadAuthenticationOnly": false
  }
}
```

The `sqlmi.enabled` feature flag for SQL Managed Instance deployment:

```json
"sqlmi": {
  "value": {
    "enabled": false
  }
}
```

### Requirements for archetypes

Each archetype is intended to be self-contained and provides all deployment templates required to configure a subscription.  Key requirements for each archetype are:

- Archetype folder must start with `lz-` followed by the archetype name.  For example `lz-machinelearning`.
- Entrypoint for an archetype is `main.bicep`. Every archetype must provide `main.bicep` in its respective folder.
- Deployment must be scoped to `subscription`.  Scope is set in `main.bicep` using `targetScope` declaration.

    ```bicep
    targetScope = 'subscription'
    ```

- Implements [common features](#common-features).
- Implements [JSON Schema for pre-deployment JSON parameters file validation](#json-schema-for-deployment-parameters).
- Implements spoke virtual network with support for virtual network peering to Hub Virtual Network.
- Implements Private DNS Zones for private endpoints with support for spoke-managed and hub-managed Private DNS Zones.
- Implements [telemetry tracking](#telemetry).
- Validated with Azure Firewall for routing & traffic filtering.  Additional Firewall rules may need to be implemented to support control plane & data plane integration.

### Approach

1. Identify at least 5 use cases that can benefit from an archetype and label all common features.  This is the MVP for the archetype.  An application team would receive the implementation of the MVP features deployed in their subscription. Use case specific features can be added to a deployment by the application team as they adapt their environment.

2. Design the spoke virtual network to support the archetype.  You must consider Hub & Spoke network topology, Private Endpoints, Private DNS Zones, Network egress from the spoke virtual network (i.e. to Azure, to on-premises, to Internet)

3. Scaffold the archetype:

      - Create a new folder under `landingzones` prefixed with `lz-`.  For example, `lz-cloudnative`.
      - Create `main.bicep`, set the `targetScope` as `subscription`
      - Create required parameters for [common features](#common-features)
      - Create a test parameters.json and run a subscription scoped deployment through Azure CLI.  You may place the test parameters.json in `/tests/schemas/` based on the archetype.

        ```bash
        az deployment sub create --template-file <path to archetype main.bicep> --parameters @<path to archetype test parameters file> --subscription-id <subscription id> --location canadacentral
        ```

          This is a validation that the archetype scaffolding is in-place.

4. Add [telemetry tracking](#telemetry).

5. Add archetype specific deployment instructions and incrementally verify through test deployment.

6. Create a JSON Schema definition for the archetype.  Consider using a tool such as [JSON to Jsonschema](https://jsonformatter.org/json-to-jsonschema) to generate the initial schema definition that you customize.  For all common features, you must reference the existing definitions for the types. See example: [schemas/latest/landingzones/lz-generic-subscription.json](../../schemas/latest/landingzones/lz-generic-subscription.json)

7. Verify archetype deployment through `subscription-ci` Azure DevOps Pipeline.  More information on the pipeline can be found in [Azure DevOps Onboarding Guide](../onboarding/ado.md#step-8--configure-subscription-archetypes).

      - Create a subscription JSON Parameters file per [deployment instructions](#deployment-instructions).
      - Run the pipeline by providing the subscription guid

    `subscription-ci` pipeline will automatically identify the archetype, the subscription and region based on the file name.  The JSON Schema is located by the archetype name and used for pre-deployment verification.  

    Once verifications are complete, the pipeline will move the subscription to the target management group (based on the folder structure) and execute `main.bicep`.

8. Debug deployment failures.

    - Navigate to the subscription in Azure Portal
    - Navigate to **Deployments** under **Settings**
    - Identify the failed deployment step & troubleshoot

9. Update documentation.

---

## Update a spoke archetype

It is common to update existing archetypes to evolve and adapt the implementation based on your organization's requirements.

Following changes are required when updating:

- Update archetype deployment template(s) through `main.bicep` or one of its dependent Bicep template(s).
- Update Visio diagrams in `docs\visio` (if required).
- Update documentation in `docs\archetypes` and revise Visio diagram images.
- When parameters are added, updated or removed:
  - Modify JSON Schema
    - Update definitions in `schemas\latest\landingzones`
    - Update changelog in `schemas\latest\readme.md`
    - Update existing unit tests in `tests\schemas`
    - Update existing deployment JSON parameter files to match new schema definition in `config\subscriptions\*.json`.  This is required for compatibility for subscriptions that have already been configured.
  - Unit test
    - Unit tests are based on the scenarios.  Provide only valid scenarios.  These should be added to the appropriate landingzone folder in `tests\schemas`
    - Verify JSON parameter files conform to the updated schema

      ```bash
        cd tests/schemas
        ./run-tests.sh
      ```

  - Documentation
    - Unit tests are treated as deployment scenarios.  Therefore, reference these in the appropriate archetype document in `docs\archetypes` under the **Deployment Scenarios** section.

---

## Common features

An archetype can deploy & configure any number of Azure services.  For consistency across all archetypes, We recommend the following common features:

- **Microsoft Defender for Cloud** - configures Azure Defender Plans & Log Analytics Workspace settings.
- **Service Health Alerts** - configures Service Health alerts for the subscription
- **Subscription Role Assignments to Security Groups** - configures role-based access control at subscription scope
- **Subscription Budget** - configures subscription scoped budget
- **Subscription Tags** - configures subscription tags
- **Resource Tags** - configures tags on resource groups

> **Log Analytics Workspace integration**: `main.bicep` must accept an input parameter named `logAnalyticsWorkspaceResourceId`.  This parameter is automatically set by `subscription-ci` Pipeline based on the environment configuration.  This parameter is used to link Microsoft Defender for Cloud to Log Analytics Workspace.

Input parameters for common features are:

```bicep
  // Service Health
  @description('Service Health alerts')
  param serviceHealthAlerts object = {}
  
  // Log Analytics
  @description('Log Analytics Resource Id to integrate Microsoft Defender for Cloud.')
  param logAnalyticsWorkspaceResourceId string
  
  // Microsoft Defender for Cloud
  @description('Microsoft Defender for Cloud configuration.  It includes email and phone.')
  param securityCenter object
  
  // Subscription Role Assignments
  @description('Array of role assignments at subscription scope.  The array will contain an object with comments, roleDefinitionId and array of securityGroupObjectIds.')
  param subscriptionRoleAssignments array = []
  
  // Subscription Budget
  @description('Subscription budget configuration containing createBudget flag, name, amount, timeGrain and array of contactEmails')
  param subscriptionBudget object
  
  // Tags
  @description('A set of key/value pairs of tags assigned to the subscription.')
  param subscriptionTags object
  
  // Example (JSON)
  @description('A set of key/value pairs of tags assigned to the resource group and resources.')
  param resourceTags object
```

These features are packaged into a Bicep module and can be invoked by the archetype (i.e. by `main.bicep`).  This module is located in `landingzones\scaffold-subscription.bicep`.

Example module execution from `main.bicep`:

```bicep
module subScaffold '../scaffold-subscription.bicep' = {
  name: 'configure-subscription'
  scope: subscription()
  params: {
    serviceHealthAlerts: serviceHealthAlerts
    subscriptionRoleAssignments: subscriptionRoleAssignments
    subscriptionBudget: subscriptionBudget
    subscriptionTags: subscriptionTags
    resourceTags: resourceTags
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    securityCenter: securityCenter
  }
}
```

---

## JSON Schema for deployment parameters

Spoke archetypes are deployed to a subscription using a JSON parameters file.  This parameters file defines all configuration expected by the archetype in order to deploy and configure a subscription.  An archetype can have an arbitrary number of parameters (up to a [maximum of 256 parameters](https://docs.microsoft.com/azure/azure-resource-manager/templates/best-practices#template-limits)).  

While these parameters offer customization benefits, they incur overhead when defining input values and correlating them to the resources that are deployed.  To keep all related parameters together and to make them contextual, we've chosen to use `object` parameter type.  This type can contain simple and complex nested types and offers greater flexibility when defining many related parameters together.  For example:

A simple object parameter used for configuring Microsoft Defender for Cloud:

```json
  "securityCenter": {
    "value": {
      "email": "alzcanadapubsec@microsoft.com",
      "phone": "5555555555"
    }
  }
```

A complex object parameter used for configuring Service Health alerts:

```json
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
  }
```

Azure Resource Manager templates (and by extension Bicep) does not support parameter validation for `object` type.  Therefore, it's not possible to depend on Azure Resource Manager to perform pre-deployment validation.  The input validation supported for parameters are described in [Azure Docs](https://docs.microsoft.com/azure/azure-resource-manager/templates/parameters).

As a result, we could either

- have Azure deploy the archetype and fail on invalid inputs.  An administrator would have to deploy multiple times to fix all errors; or

- attempt to detect invalid inputs as a pre-check in our `subscription-ci` pipeline.

We chose to check the input parameters prior to deployment to identify misconfigurations faster.  Validations are performed using JSON Schema definitions.  These definitions are located in [schemas/latest/landingzones](../../schemas/latest/landingzones) folder.

> JSON Schema definitions increases the learning curve but it is necessary to preserve consistency of the archetypes and the parameters they depend on for deployment.

---

## Telemetry

This reference implementation is instrumented to track deployment telemetry per module through [customer usage attribution](https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution).  When a new archetype is developed, the telemetry settings must be updated to reference the tracking id.  Telemetry configuration is located at [`config/telemetry.json`](../../config/telemetry.json).

To support per-module tracking, we've split each archetype to be tracked independently.  At the moment, a single tracking id is used for all modules and can be modified in the future when required.

### Instructions

1. Add new archetype name & value in `customerUsageAttribution.modules.archetypes` object.  The name represents the new archetype and the value is the tracking id.

    ```json
    {
      "customerUsageAttribution": {
        "enabled": true,
        "modules": {
          "managementGroups": "a83f6385-f514-415f-991b-2d9bd7aed658",
          "policy": "a83f6385-f514-415f-991b-2d9bd7aed658",
          "roles": "a83f6385-f514-415f-991b-2d9bd7aed658",
          "logging": "a83f6385-f514-415f-991b-2d9bd7aed658",
          "networking": {
            "nvaFortinet": "a83f6385-f514-415f-991b-2d9bd7aed658",
            "azureFirewall": "a83f6385-f514-415f-991b-2d9bd7aed658"
          },
          "archetypes": {
            "genericSubscription": "a83f6385-f514-415f-991b-2d9bd7aed658",
            "machineLearning": "a83f6385-f514-415f-991b-2d9bd7aed658",
            "healthcare": "a83f6385-f514-415f-991b-2d9bd7aed658"
          }
        }
      }
    }
    ```

2. Include telemetry tracking deployment in `main.bicep`.  Replace `NEW_ARCHETYPE_NAME` with the name defined in step 1.

```bicep
// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution

var telemetry = json(loadTextContent('../../config/telemetry.json'))
module telemetryCustomerUsageAttribution '../../azresources/telemetry/customer-usage-attribution-subscription.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.archetypes.NEW_ARCHETYPE_NAME}'
}
```

---

## Deployment Instructions

> Use the [Onboarding Guide for Azure DevOps](../onboarding/azure-devops-pipelines.md) to configure the `subscription` pipeline.  This pipeline will deploy workload archetypes such as Generic Subscription, Machine Learning and Healthcare.

Azure Resource Manager (ARM) parameters files provide deployment information to setup subscriptions.  Deployment information can include `location`, `resource group names`, `resource names` and `networking`. You can find more information in [Azure Docs](https://docs.microsoft.com/azure/azure-resource-manager/templates/parameter-files) on ARM parameter files.

These parameter files are located in [config/subscription](../../config/subscriptions) folder.  This folder is configurable in `common.yml` and you can override in environment configuration files using the `subscriptionsPathFromRoot` setting.  By default it is set to `config/subscriptions`.  

Immediate subfolder defines the environment which is based on Azure DevOps Organization (i.e. `CanadaESLZ`) & Git branch name (i.e. `main`), for example the subfolder will be called `CanadaESLZ-main`.  You can have many environments based on Git branch names such as `CanadaESLZ-feature-1`, `CanadaESLZ-dev`, etc.

ARM parameter files are used by `subscription-ci` Azure DevOps Pipeline when configuring subscriptions with Azure resources.  The pipeline will detect environment, management group, subscription, deployment location and deployment parameters using the folder hierarchy, file name and file content.

For example when the file path is:

`config/subscriptions/CanadaESLZ-main/pubsec/LandingZones/DevTest/8c6e48a4-4c73-4a1f-9f95-9447804f2c98_machinelearning_canadacentral.json`

- **Folder hierarchy:** config/subscriptions/CanadaESLZ-main/pubsec/LandingZones/DevTest/
- **File name:** 8c6e48a4-4c73-4a1f-9f95-9447804f2c98_machinelearning_canadacentral.json

| Deployment Information | Approach | Example |
|:---------------------- |:-------- |:------- |
| Environment | DevOps organization name & Git branch name | `CanadaESLZ-main` |
| Management Group | Calculated based on concatenating the folder hierarchy under `config/subscription/CanadaESLZ-main` | pubsecLandingZonesDevTest (without the `/`).  [See below for details](#management-group-id-detection).
| Subscription | Part of the file name | `8c6e48a4-4c73-4a1f-9f95-9447804f2c98` |
| Deployment location | Part of the file name | `canadacentral` |
| Deployment parameters | Content of the file | [See file content](../../config/subscriptions/CanadaESLZ-main/pubsec/LandingZones/DevTest/8c6e48a4-4c73-4a1f-9f95-9447804f2c98_machinelearning_canadacentral.json) |

The ARM parameter file name can be in one of two formats:

- `[SubscriptionGUID]`\_`[ArchetypeName]`.json
- `[SubscriptionGUID]`\_`[ArchetypeName]`\_`[DeploymentLocation]`.json

The subscription GUID is required by the pipeline to target the archetype deployment.

The template name/type is a text fragment corresponding to a path name (or part of a path name) under the '/landingzones' top level path. It indicates which Bicep templates to run on the subscription. For example, the machine learning path is `/landingzones/lz-machinelearning`, so we remove the `lz-` prefix and use `machinelearning` to specify this type of landing zone (archetype).

The deployment location is the short name of an Azure deployment location, which may be used to override the `deploymentRegion` YAML variable.  This parameter is configurable in `common.yml` and you can also override in environment configuration files.  By default it is set to `canadacentral`.  The allowable values for this value can be determined by looking at the `Name` column output of the command: `az account list-locations -o table`.

### Management Group Id detection

Management Group Id must be unique within an Azure environment.  Since a management group hierarchy can be up to 6 levels deep with many child management groups , it is important to ensure uniqueness across all management groups ids.

There are two approaches for achieving uniquness:

1. Use the parent management group id as the prefix for every child management group id.  For example:

    ```none
        - pubsec
          - pubsecLandingZones
            - pubsecLandingZonesDevTest
    ```

    In this approach, the prefix creates the natural uniqueness.

2. Create a management group hierarchy where every management group id can be unique and it is manually checked.  For example:

    ```none
        - pubsec
          - LandingZones
            - DevTest
    ```

    In this approach, you must ensure all management group ids are unique yourself.

The `subscription-ci` management group detection logic is built to accommodate both scenarios.

**To support approach #1:**

- Folder structure in `config/subscription/` is created without including the prefixes.  For example:

    ```none
          config/subscription/CanadaESLZ-main
            - pubsec
                - LandingZones
                    - DevTest
    ```

- `subscription-ci` will then take the folder structure and concatenate it to create the management group id.  In this example `DevTest` management group id will be `pubsecLandingZonesDevTest`.

**To support approach #2:**

- Folder structure in `config/subscription/` should be flat.  For example:

    ```none
          config/subscription/CanadaESLZ-main
            - pubsec
            - LandingZones
            - DevTest
    ```

- `subscription-ci` will then take the folder name as the structure (since there aren't any sub folders).  In this example `DevTest` management group id will be `DevTest`.
