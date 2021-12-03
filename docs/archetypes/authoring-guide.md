# Archetype Authoring Guide

This reference implementation provides 6 archetypes that can be used as-is or customized further to suit business needs.  This implementation provides two types of archetypes:  Spoke archetypes & Platform archetypes.

Spoke archetypes are used to configure subscriptions for line of business use cases and Platform archetypes are used to configure shared infrastructure such as Logging, Hub Networking and Firewalls.  Intent of the archetypes is to **provide a repeatable method** for configuring subscriptions.  It offers **consistent deployment experience and supports common scenarios** required by your organization.

To avoid archetype sprawl, we recommend a **maximum of 3-5 spoke archetypes**.  When there are new capabilities or Azure services to add, consider evolving an existing archetypes through **feature flags**.
Once an archetype is deployed, the application teams can further modify the deployment for scale or new capabilities using their preferred deployment tools.

The goal of this authoring guide is to provide step-by-step instructions to create new and update existing archetypes.

## Table of Contents

- [Folder structure](#folder-structure)
- [Common features](#common-features)
- [JSON Schema for deployment parameters](#json-schema-for-deployment-parameters)
- [Update a spoke archetype](#update-a-spoke-archetype)
- [Deployment instructions](#deployment-instructions)

---

## Folder structure

Archetypes are located in `landingzones` folder and organized as folder per archetype.  For example:

- Platform archetypes
  - [`lz-platform-connectivity-hub-azfw`](hubnetwork-azfw.md) - configures a Hub Virtual Network with Azure Firewall.
  - [`lz-platform-connectivity-hub-nva`](hubnetwork-nva-fortigate.md) - configures a Hub Virtual Network with Fortinet Firewall.
  - [`lz-platform-logging`](logging.md) - configures central logging infrastructure using Log Analytics Workspace and Microsoft Sentinel.
- Spoke archetypes
  - [`lz-generic-subscription`](generic-subscription.md) - configures a subscription for general purpose use.
  - [`lz-healthcare`](healthcare.md) - configures a subscription for healthcare scenarios.
  - [`lz-machinelearning`](machinelearning.md) - configures a subscription for machine learning .scenarios.

Each archetype is intended to be self-contained and provides all deployment templates required to configure a subscription.  Key requirements for each archetype:

- Folder must start with `lz-` followed by the archetype name.  For example `lz-machinelearning`.
- Entrypoint for an archetype is `main.bicep`. Every archetype must provide `main.bicep` in it's respective folder.

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

## Update a spoke archetype

It is common to update existing archetypes to evolve and adapt the implementation based on your organization's requirements.

Following changes are required when updating:

- Update archetype deployment template(s) through `main.bicep` or one of it's dependent Bicep template(s).
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

## Deployment Instructions

> Use the [Onboarding Guide for Azure DevOps](../onboarding/ado.md) to configure the `subscription` pipeline.  This pipeline will deploy workload archetypes such as Machine Learning.

Parameter files for archetype deployment are configured in [config/subscription](../../config/subscriptions) folder.  The folder hierarchy is comprised of the following elements, from this folder downward:

1. A environment folder named for the Azure DevOps Org and Git Repo branch name, e.g. 'CanadaESLZ-main'.
2. The management group hierarchy defined for your environment, e.g. `pubsec/LandingZones/Prod`. The location of the config file represents which Management Group the subscription is a member of.

For example, if your Azure DevOps organization name is 'CanadaESLZ', you have two Git Repo branches named 'main' and 'dev', and you have top level management group named 'pubsec' with the standard structure, then your path structure would look like this:

```none
/config/subscriptions
    /CanadaESLZ-main           <- Your environment, e.g. CanadaESLZ-main, CanadaESLZ-dev, etc.
        /pubsec                <- Your top level management root group name
            /LandingZones
                /Prod
                    /xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx_machinelearning.json
                    /yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy_machinelearning_canadacentral.json
```

The JSON config file name is in one of the following two formats:

- [AzureSubscriptionGUID]\_[TemplateName].json
- [AzureSubscriptionGUID]\_[TemplateName]\_[DeploymentLocation].json

The subscription GUID is needed by the pipeline; since it's not available in the file contents, it is specified in the config file name.

The template name/type is a text fragment corresponding to a path name (or part of a path name) under the '/landingzones' top level path. It indicates which Bicep templates to run on the subscription. For example, the machine learning path is `/landingzones/lz-machinelearning`, so we remove the `lz-` prefix and use `machinelearning` to specify this type of landing zone.

The deployment location is the short name of an Azure deployment location, which may be used to override the `deploymentRegion` YAML variable. The allowable values for this value can be determined by looking at the `Name` column output of the command: `az account list-locations -o table`.
