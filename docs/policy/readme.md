# Azure Policy for Guardrails

## Table of Contents

* [Overview](#overview)
* [Built-In Policy Sets Assignments](#built-in-policy-sets-assignments)
* [Custom Policies and Policy Sets](#custom-policies-and-policy-sets)
  * [Custom Policy Definitions](#custom-policy-definitions)
  * [Custom Policy Set Definitions](#custom-policy-set-definitions)
  * [Custom Policy Set Assignments](#custom-policy-set-assignments)
* [Templated Parameters](#templated-parameters)
* [Authoring Guide](#authoring-guide)
  * [Built-In Policies](#built-in-policies)
    * [New Built-In Policy Assignment](#new-built-in-policy-assignment)
    * [Remove Built-In Policy Assignment](#remove-built-in-policy-assignment)
  * [Custom Policies](#custom-policies)
    * [New Custom Policy Definition](#new-custom-policy-definition)
    * [New Custom Policy Set Definition](#new-custom-policy-set-definition)
    * [Update Custom Policy Set Definition](#update-custom-policy-set-definition)

## Overview

Guardrails in Azure are deployed through [Azure Policy](https://docs.microsoft.com/azure/governance/policy/overview).  Azure Policy helps to enforce organizational standards and to assess compliance at-scale. Through its compliance dashboard, it provides an aggregated view to evaluate the overall state of the environment, with the ability to drill down to the per-resource, per-policy granularity. It also helps to bring your resources to compliance through bulk remediation for existing resources and automatic remediation for new resources.

Common use cases for Azure Policy include implementing governance for resource consistency, regulatory compliance, security, cost, and management. Policy definitions for these common use cases are already available in your Azure environment as built-ins to help you get started.

![Azure Policy Compliance](../media/architecture/policy-compliance.jpg)

Azure Landing Zones for Canadian Public Sector is configured with a set of built-in Azure Policy Sets based on Regulatory Compliance.  Custom policy sets have been designed to increase compliance for logging, networking & tagging requirements.  These can be further extended or removed as required by the department through automation.

---

## Built-In Policy Sets Assignments

> **Note**: The built-in policy sets are used as-is to ensure future improvements from Azure Engineering teams are automatically incorporated into the Azure environment.

All built-in policy set assignments are located in [policy/builtin/assignments](../../policy/builtin/assignments) folder.

* Deployment templates can be customized for additional policy parameters & role assignments for policy remediation.
* Configuration files are used to define runtime parameters during policy set assignment.  

Azure DevOps Pipeline ([.pipelines/policy.yml](../../.pipelines/policy.yml)) is used for policy set assignment automation.  Assigned policy sets can be customized through pipeline configuration.

**Pipeline Step**
```yml
    - template: templates/steps/assign-policy.yml
      parameters:
        description: 'Assign Policy Set'
        deployTemplates: [asb, cis-msft-130, location, nist80053r4, nist80053r5, pbmm, hitrust-hipaa, fedramp-moderate]
        deployOperation: ${{ variables['deployOperation'] }}
        workingDir: $(System.DefaultWorkingDirectory)/policy/builtin/assignments
```

All policy set assignments are at the `pubsec` top level management group.  This top level management group is retrieved from configuration parameter `var-topLevelManagementGroupName`.  See [Onboarding Guide for Azure DevOps](../onboarding/ado.md) for instructions to setting up management groups & policy pipeline.


| Policy Set | Description | Deployment Template | Configuration |
| --- | --- | --- | --- |
| [Canada Federal PBMM][pbmmPolicySet] | This initiative includes audit and virtual machine extension deployment policies that address a subset of Canada Federal PBMM controls. | [pbmm.bicep](../../policy/builtin/assignments/pbmm.bicep) | [pbmm.parameters.json](../../policy/builtin/assignments/pbmm.parameters.json) |
| [NIST SP 800-53 Revision 4][nist80053R4policySet] | This initiative includes policies that address a subset of NIST SP 800-53 Rev. 4 controls. | [nist80053r4.bicep](../../policy/builtin/assignments/nist80053r4.bicep) | [nist80053r4.parameters.json](../../policy/builtin/assignments/nist80053r4.parameters.json) |
| [NIST SP 800-53 Revision 5][nist80053R5policySet] | This initiative includes policies that address a subset of NIST SP 800-53 Rev. 5 controls. | [nist80053r5.bicep](../../policy/builtin/assignments/nist80053r5.bicep) | [nist80053r5.parameters.json](../../policy/builtin/assignments/nist80053r5.parameters.json) |
| [Azure Security Benchmark][asbPolicySet] | The Azure Security Benchmark initiative represents the policies and controls implementing security recommendations defined in Azure Security Benchmark v2, see https://aka.ms/azsecbm. This also serves as the Azure Security Center default policy initiative. | [asb.bicep](../../policy/builtin/assignments/asb.bicep) | [asb.parameters.json](../../policy/builtin/assignments/asb.parameters.json) |
| [CIS Microsoft Azure Foundations Benchmark 1.3.0][cisMicrosoftAzureFoundationPolicySet] | This initiative includes policies that address a subset of CIS Microsoft Azure Foundations Benchmark recommendations. | [cis-msft-130.bicep](../../policy/builtin/assignments/cis-msft-130.bicep) | [cis-msft-130.parameters.json](../../policy/builtin/assignments/cis-msft-130.parameters.json) |
|	[FedRAMP Moderate][fedrampmPolicySet] | This initiative includes policies that address a subset of FedRAMP Moderate controls. | [fedramp-moderate.bicep](../../policy/builtin/assignments/fedramp-moderate.bicep) | [fedramp-moderate.parameters.json](../../policy/builtin/assignments/fedramp-moderate.parameters.json) |
| [HIPAA / HITRUST 9.2][hipaaHitrustPolicySet] | This initiative includes audit and virtual machine extension deployment policies that address a subset of HITRUST/HIPAA controls. | [hitrust-hipaa.bicep](../../policy/builtin/assignments/hitrust-hipaa.bicep) | [fedramp-moderate.parameters.json](../../policy/builtin/assignments/fedramp-moderate.parameters.json)
| Location | Restrict deployments to Canadian regions. | [location.bicep](../../policy/builtin/assignments/location.bicep) | [location.parameters.json](../../policy/builtin/assignments/location.parameters.json) |

---

## Custom Policies and Policy Sets

> **Note**: The custom policies & policy sets are used when built-in alternative does not exist.  Automation is regularly revised to use built-in policies and policy sets as new options are made available.

All policies and policy set definitions & assignments are at the `pubsec` top level management group.  This top level management group is retrieved from configuration parameter `var-topLevelManagementGroupName`.  See [Onboarding Guide for Azure DevOps](../onboarding/ado.md) for instructions to setting up management groups & policy pipeline.

### Custom Policy Definitions

All custom policy definitions are located in [policy/custom/definitions/policy](../../policy/custom/definitions/policy) folder.

Each policy is organized into it's own folder.  The folder name must not have any spaces nor special characters.  Each folder contains 3 files:

1. azurepolicy.config.json - metadata used by Azure DevOps Pipeline to configure the policy.
2. azurepolicy.parameters.json - contains parameters used in the policy.
3. azurepolicy.rules.json - the policy rule definition.

See [instructions for creating custom policies](../../policy/custom/definitions/policy/readme.md) for more information.

Azure DevOps Pipeline ([.pipelines/policy.yml](../../.pipelines/policy.yml)) is used for policy definition automation.  The automation enumerates the policy definition directory (`policy/custom/definitions/policy`) and creates/updates policies that it identifies.

**Pipeline Step**
```yml
    - template: templates/steps/define-policy.yml
      parameters:
        description: 'Define Policies'
        workingDir: $(System.DefaultWorkingDirectory)/policy/custom/definitions/policy
```

### Custom Policy Set Definitions

All custom policy set definitions are located in [policy/custom/definitions/policyset](../../policy/custom/definitions/policyset) folder.  Custom policy sets contain built-in and custom policies.

Azure DevOps Pipeline ([.pipelines/policy.yml](../../.pipelines/policy.yml)) is used for policy set definition automation.  Defined policy sets can be customized through pipeline configuration.

**Pipeline Step**
```yml
    - template: templates/steps/define-policyset.yml
      parameters:
        description: 'Define Policy Set'
        deployTemplates: [AKS, EnableAzureDefender, EnableLogAnalytics, Network, DNSPrivateEndpoints, Tags]
        deployOperation: ${{ variables['deployOperation'] }}
        workingDir: $(System.DefaultWorkingDirectory)/policy/custom/definitions/policyset
```

| Policy Set | Description | Deployment Template | Configuration |
| --- | --- | --- | --- |
| Azure Kubernetes Service | Azure Policy Add-on to Azure Kubernetes Service clusters. | [AKS.bicep](../../policy/custom/definitions/policyset/AKS.bicep) | [AKS.parameters.json](../../policy/custom/definitions/policyset/AKS.parameters.json)
| Private DNS Zones for Private Endpoints | Policies to configure DNS Zone records for Private Endpoints.  Policy set is used when private endpoint DNS zones are managed in the Hub Network. | [DNSPrivateEndpoints.bicep](../../policy/custom/definitions/policyset/DNSPrivateEndpoints.bicep) | [DNSPrivateEndpoints.parameters.json](../../policy/custom/definitions/policyset/DNSPrivateEndpoints.parameters.json)
| Azure Defender | Configures Azure Defender for subscription and resources. | [EnableAzureDefender.bicep](../../policy/custom/definitions/policyset/EnableAzureDefender.bicep) | [EnableAzureDefender.parameters.json](../../policy/custom/definitions/policyset/EnableAzureDefender.parameters.json)
| Log Analytics for Azure Services (IaaS and PaaS) | Configures monitoring agents for IaaS and diagnostic settings for PaaS to send logs to a central Log Analytics Workspace. | [EnableLogAnalytics.bicep](../../policy/custom/definitions/policyset/EnableLogAnalytics.bicep) | [EnableLogAnalytics.parameters.json](../../policy/custom/definitions/policyset/EnableLogAnalytics.parameters.json)
| Networking | Configures policies for network resources. | [Network.bicep](../../policy/custom/definitions/policyset/Network.bicep) | [Network.parameters.json](../../policy/custom/definitions/policyset/Network.parameters.json)
| Tag Governance | Configures required tags and tag propagation from resource groups to resources. | [Tags.bicep](../../policy/custom/definitions/policyset/Tags.bicep) | [Tags.parameters.json](../../policy/custom/definitions/policyset/Tags.parameters.json)


### Custom Policy Set Assignments

All custom policy set assignments are located in [policy/custom/assignments](../../policy/custom/assignments) folder.

* Deployment templates can be customized for additional policy parameters & role assignments for policy remediation.
* Configuration files are used to define runtime parameters during policy set assignment.  

Azure DevOps Pipeline ([.pipelines/policy.yml](../../.pipelines/policy.yml)) is used for policy set assignment automation.  Assigned policy sets can be customized through pipeline configuration.

**Pipeline Step**
```yml
    - template: templates/steps/assign-policy.yml
      parameters:
        description: 'Assign Policy Set'
        deployTemplates: [aks, asc, loganalytics, network, tags]
        deployOperation: ${{ variables['deployOperation'] }}
        workingDir: $(System.DefaultWorkingDirectory)/policy/custom/assignments
```

| Policy Set | Description | Deployment Template | Configuration |
| --- | --- | --- | --- |
| Azure Kubernetes Service | Azure Policy Add-on to Azure Kubernetes Service clusters & Pod Security. | [aks.bicep](../../policy/custom/assignments/aks.bicep) | [aks.parameters.json](../../policy/custom/assignments/aks.parameters.json)
| Azure Security Center | Configures Azure Security Center, including Azure Defender for subscription and resources. | [asc.bicep](../../policy/custom/assignments/asc.bicep) | [asc.parameters.json](../../policy/custom/assignments/asc.parameters.json)
| Azure DDOS | Configures policy to automatically protect virtual networks with public IP addresses.  Policy set is assigned through deployment pipeline when DDOS Standard is configured. | [ddos.bicep](../../policy/custom/assignments/ddos.bicep) | [ddos.parameters.json](../../policy/custom/assignments/ddos.parameters.json)
| Private DNS Zones for Private Endpoints | Policies to configure DNS Zone records for Private Endpoints.  Policy set is assigned through deployment pipeline when private endpoint DNS zones are managed in the Hub Network. | [dns-private-endpoints.bicep](../../policy/custom/assignments/dns-private-endpoints.bicep) | [dns-private-endpoints.parameters.json](../../policy/custom/assignments/dns-private-endpoints.parameters.json)
| Log Analytics for Azure Services (IaaS and PaaS) | Configures monitoring agents for IaaS and diagnostic settings for PaaS to send logs to a central Log Analytics Workspace. | [loganalytics.bicep](../../policy/custom/assignments/loganalytics.bicep) | [loganalytics.parameters.json](../../policy/custom/assignments/loganalytics.parameters.json)
| Networking | Configures policies for network resources. | [network.bicep](../../policy/custom/assignments/network.bicep) | [network.parameters.json](../../policy/custom/assignments/network.parameters.json)
| Tag Governance | Configures required tags and tag propagation from resource groups to resources. | [tags.bicep](../../policy/custom/assignments/tags.bicep) | [tags.parameters.json](../../policy/custom/assignments/tags.parameters.json)

---

## Templated Parameters

Parameters can be templated using the syntax `{{PARAMETER_NAME}}`.  Following parameters are supported:

| Templated Parameter | Source Value | Example |
| --- | --- | --- |
| {{var-topLevelManagementGroupName}} | Environment configuration file such as [config/variables/CanadaESLZ-main.yml](../../config/variables/CanadaESLZ-main.yml)  | `pubsec`
| {{var-logging-logAnalyticsWorkspaceResourceId}} | Resource ID is inferred using Log Analytics settings in environment configuration file such as [config/variables/CanadaESLZ-main.yml](../../config/variables/CanadaESLZ-main.yml)  | `/subscriptions/bc0a4f9f-07fa-4284-b1bd-fbad38578d3a/resourcegroups/pubsec-central-logging-rg/providers/microsoft.operationalinsights/workspaces/log-analytics-workspace`
| {{var-logging-logAnalyticsWorkspaceId}} |  Workspace ID is inferred using Log Analytics settings in environment configuration file such as [config/variables/CanadaESLZ-main.yml](../../config/variables/CanadaESLZ-main.yml) | `fcce3f30-158a-4561-a714-361623f42168`
| {{var-logging-logAnalyticsResourceGroupName}} | Environment configuration file such as [config/variables/CanadaESLZ-main.yml](../../config/variables/CanadaESLZ-main.yml)  | `pubsec-central-logging-rg`
| {{var-logging-logAnalyticsRetentionInDays}} | Environment configuration file such as [config/variables/CanadaESLZ-main.yml](../../config/variables/CanadaESLZ-main.yml) | `730`
| {{var-logging-diagnosticSettingsforNetworkSecurityGroupsStoragePrefix}} | Environment configuration file such as [config/variables/CanadaESLZ-main.yml](../../config/variables/CanadaESLZ-main.yml)  | `pubsecnsg`

---

## Authoring Guide

This reference implementation uses Built-In and Custom Policies to provide guardrails in the Azure environment.  The goal of this authoring guide is to provide step-by-step instructions to manage and customize policy definitions and assignments to align to your organization's compliance requirements.

### Built-In Policies

The built-in policy sets are used as-is to ensure future improvements from Azure Engineering teams are automatically incorporated into the Azure environment.

#### **New Built-In Policy Assignment**

**Step 1:**  To add a new built-in policy to the automation, gather the following information using Azure Portal.

1. Navigate to [Azure Portal -> Azure Policy -> Definitions](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Definitions)
2. Open the Built-In Policy Set (it is also called an Initiative) that will be assigned through automation.  For example: `Canada Federal PBMM`

    *Collect the following information:*

      * **Name** (i.e. `Canada Federal PBMM`)
      * **Definition ID** (i.e. `/providers/Microsoft.Authorization/policySetDefinitions/4c4a5f27-de81-430b-b4e5-9cbd50595a87`)

4. Click the **Assign** button and **select a scope** for the assignment.  We will not be assigning the policy through Azure Portal, but use this step to identify the permissions required for the Policy Assignment.

    *Collect the following information from the **Remediation** tab:*

    * **Permissions** - required when there are auto remediation policies.  You may see zero, one (i.e. `Contributor`) or many comma-separated (i.e. `Log Analytics Contributor, Virtual Machine Contributor, Monitoring Contributor`) roles listed.  Permissions will not be listed when none are required for the policy assignment to function.

    Once the permissions are identified, click the **Cancel** button to discard the changes.

    Use [Azure Built-In Roles table](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles) to map the permission name to it's Resource ID.  Resource ID will be used when defining the role assignments. 

5. Click on the **Duplicate initiatve** button.  We will not be duplicating the policy set definition, but use this step to identify the parameter names that will need to be populated during policy assignment.

    *Collect the following information from the **Initiative parameters** tab:*

    * **Parameters** (i.e. `logAnalytics`, `logAnalyticsWorkspaceId`, `listOfResourceTypesToAuditDiagnosticSettings`).  You may see zero, one or many parameters listed.  It is possible that a policy set doesn't have any parameters.


**Step 2:** Once the required information is gathered, you are ready to create a Bicep template with the policy assignment.

1. Navigate to `policy/builtin/assignments` folder and create two files.  Replace `POLICY_ASSIGNMENT` with the name of your assignment such as `pbmm`.

   * POLICY_ASSIGNMENT.bicep (i.e. `pbmm.bicep`) - this file defines the policy assignment deployment
   * POLICY_ASSIGNMENT.parameters.json (i.e. `pbmm.parameters.json`) - this file defines the parameters used to deploy the policy assignment.

2. Edit the Bicep file to include the following template.  This template can be customized as required.  Pre-requisites are:

    * targetScope must be `managementGroup`
    * parameter `policyAssignmentManagementGroupId` must be defined.  It is used to set the policy assignment through automation.

    ```c
      targetScope = 'managementGroup'

      @description('Management Group scope for the policy assignment.')
      param policyAssignmentManagementGroupId string

      // Start - Any custom parameters required for your policy assignment
      param ...
      // End - Any custom parameters required for your policy assignment

      // Add the GUID from the Definition ID that was gathered above
      var policyId = '<< GUID >>'

      // Add the policy set assignment name (i.e. the name of the Policy Set Name)
      var assignmentName = '<< POLICY ASSIGNMENT NAME >>'

      var scope = tenantResourceId('Microsoft.Management/managementGroups', policyAssignmentManagementGroupId)
      var policyScopedId = resourceId('Microsoft.Authorization/policySetDefinitions', policyId)

      resource policySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {

        // Set the name of the policy assignment
        // Example: name: 'pbmm-${uniqueString('pbmm-',policyAssignmentManagementGroupId)}'

        name: '<< NAME >>'

        properties: {
          displayName: assignmentName
          policyDefinitionId: policyScopedId
          scope: scope
          notScopes: [
          ]
          parameters: {
            // Add any parameters identified earlier into this section
          }
          enforcementMode: 'Default'
        }
        identity: {
          type: 'SystemAssigned'
        }
        location: deployment().location
      }

      // These role assignments are required to allow Policy Assignment to remediate.
      // Add this section only when there are permissions to assign to the policy set.
      // Ensure that the name is a GUID and generated with a deterministic formula such as the example below.
      // Set the role definition id based on the information gathered earlier.
      resource policySetRoleAssignmentContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
        name: guid(policyAssignmentManagementGroupId, 'pbmm-Contributor')
        scope: managementGroup()
        properties: {
          roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          principalId: policySetAssignment.identity.principalId
          principalType: 'ServicePrincipal'
        }
      }
    ```

    Example: PBMM Policy Set Assignment
    ```c
      targetScope = 'managementGroup'

      @description('Management Group scope for the policy assignment.')
      param policyAssignmentManagementGroupId string

      @description('Log Analytics Resource Id to integrate Azure Security Center.')
      param logAnalyticsWorkspaceId string

      @description('List of members that should be excluded from Windows VM Administrator Group.')
      param listOfMembersToExcludeFromWindowsVMAdministratorsGroup string

      @description('List of members that should be included in Windows VM Administrator Group.')
      param listOfMembersToIncludeInWindowsVMAdministratorsGroup string

      var policyId = '4c4a5f27-de81-430b-b4e5-9cbd50595a87' // Canada Federal PBMM
      var assignmentName = 'Canada Federal PBMM'

      var scope = tenantResourceId('Microsoft.Management/managementGroups', policyAssignmentManagementGroupId)
      var policyScopedId = resourceId('Microsoft.Authorization/policySetDefinitions', policyId)

      resource policySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
        name: 'pbmm-${uniqueString('pbmm-',policyAssignmentManagementGroupId)}'
        properties: {
          displayName: assignmentName
          policyDefinitionId: policyScopedId
          scope: scope
          notScopes: [
          ]
          parameters: {
            logAnalyticsWorkspaceIdforVMReporting: {
              value: logAnalyticsWorkspaceId
            }
            listOfMembersToExcludeFromWindowsVMAdministratorsGroup: {
              value: listOfMembersToExcludeFromWindowsVMAdministratorsGroup
            }
            listOfMembersToIncludeInWindowsVMAdministratorsGroup: {
              value: listOfMembersToIncludeInWindowsVMAdministratorsGroup
            }
          }
          enforcementMode: 'Default'
        }
        identity: {
          type: 'SystemAssigned'
        }
        location: deployment().location
      }

      // These role assignments are required to allow Policy Assignment to remediate.
      resource policySetRoleAssignmentContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
        name: guid(policyAssignmentManagementGroupId, 'pbmm-Contributor')
        scope: managementGroup()
        properties: {
          roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          principalId: policySetAssignment.identity.principalId
          principalType: 'ServicePrincipal'
        }
      }
    ```

3. Edit the JSON parameters file to define the input parameters for the Bicep template.  This parameters JSON file is used by Azure Resource Manager (ARM) for runtime inputs.

    You may use any of the [templated parameters](#templated-parameters) listed above to set values based on environment configuration or hardcode them as needed. 

    ```json
    {
        "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {
            "policyAssignmentManagementGroupId": {
                "value": "{{var-topLevelManagementGroupName}}"
            },
            "CUSTOM_POLICY_ASSIGNMENT_PARAMETER_NAME_1": {
                "value": "CUSTOM_POLICY_ASSIGNMENT_PARAMETER_VALUE_1"
            },
            "CUSTOM_POLICY_ASSIGNMENT_PARAMETER_NAME_2": {
                "value": "CUSTOM_POLICY_ASSIGNMENT_PARAMETER_VALUE_2"
            }
        }
    }
    ```

    Example:  PBMM Policy Set Parameters

    ```json
    {
        "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {
            "policyAssignmentManagementGroupId": {
                "value": "{{var-topLevelManagementGroupName}}"
            },
            "logAnalyticsWorkspaceId": {
                "value": "{{var-logging-logAnalyticsWorkspaceId}}"
            },
            "listOfMembersToExcludeFromWindowsVMAdministratorsGroup": {
                "value": "__tbd__implementation_specific__"
            },
            "listOfMembersToIncludeInWindowsVMAdministratorsGroup": {
                "value": "__tbd__implementation_specific__"
            }
        }
    }
    ```

**Step 3:** Update the Azure DevOps Policy pipeline to deploy the policy assignment.

  * Edit `.pipelines/policy.yml`
  * Navigate to the `BuiltInPolicyJob` Job definition
  * Navigate to the `Assign Policy Set` Step definition
  * Add the policy assignment file name (without extension) to the `deployTemplates` array parameter

**Step 4:** Execute the Azure Policy pipeline and verify the policy deployment pipeline succeeds.

  * You may navigate to [Azure Policy Compliance](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Compliance) to verify in Azure Portal.
  * When there are deployment errors:
  
      * Navigate [Management Groups](https://portal.azure.com/#blade/Microsoft_Azure_ManagementGroups/ManagementGroupBrowseBlade/MGBrowse_overview) in Azure Portal
      * Select the top level management group (i.e. `pubsec`)
      * Select Deployments
      * Review the deployment errors

#### **Remove Built-In Policy Assignment**

**Step 1:** Remove policy set assignment from Azure DevOps Pipeline.

* Edit `.pipelines/policy.yml`
* Navigate to the `BuiltInPolicyJob` Job definition
* Navigate to the `Assign Policy Set` Step definition
* Remove the policy assignment from the `deployTemplates` array parameter

> Automation does not remove an existing policy set assignment.  Removing the policy set assignment from the Azure DevOps pipeline ensures that the policy assignment is no longer created.  Any existing policy set assignments must be deleted manually.

**Step 2:** Delete policy set assignment's role assignments.

* Navigate to [Azure Policy Assignments](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Assignments) in Azure Portal
  * Find the policy set assignment
  * Click on the `...` beside the policy set assignment and select `Delete assignment`
* Navigate [Management Groups](https://portal.azure.com/#blade/Microsoft_Azure_ManagementGroups/ManagementGroupBrowseBlade/MGBrowse_overview) in Azure Portal
  * Select the top level management group (i.e. `pubsec`)
  * Select Access control (IAM)
  * Select Role Assignments
  * Use the `Type` filter to find any `Unknown` role assignments and delete them.  This step is required since deleting the policy set assignment does not automatically remove any role assignments.  When the policy set assignment is removed, it's managed identity is also removed thus marking these role assignments as `Unknown`.

### Custom Policies

#### **New Custom Policy Definition**
#### **New Custom Policy Set Definition**
#### **Update Custom Policy Set Definition**




[nist80053r4Policyset]: https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4
[nist80053r5Policyset]: https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5
[pbmmPolicyset]: https://docs.microsoft.com/azure/governance/policy/samples/canada-federal-pbmm
[asbPolicySet]: https://docs.microsoft.com/security/benchmark/azure/overview
[cisMicrosoftAzureFoundationPolicySet]: https://docs.microsoft.com/azure/governance/policy/samples/cis-azure-1-3-0
[fedrampmPolicySet]: https://docs.microsoft.com/azure/governance/policy/samples/fedramp-moderate
[hipaaHitrustPolicySet]: https://docs.microsoft.com/azure/governance/policy/samples/hipaa-hitrust-9-2
