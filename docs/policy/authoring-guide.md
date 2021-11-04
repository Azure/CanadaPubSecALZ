# Azure Policy Authoring Guide

This reference implementation uses Built-In and Custom Policies to provide guardrails in the Azure environment.  The goal of this authoring guide is to provide step-by-step instructions to manage and customize policy definitions and assignments to align to your organization's compliance requirements.

## Table of Contents

* [Existing configuration](#existing-configuration)
* [Built-in policies](#built-in-policies)
  * [New built-in policy assignment](#new-built-in-policy-assignment)
    * [Step 1: Collect information](#step-1-collect-information)
    * [Step 2: Create Bicep template & parameters JSON file](#step-2-create-bicep-template--parameters-json-file)
    * [Step 3: Update Azure DevOps Pipeline](#step-3-update-azure-devops-pipeline)
    * [Step 4: Verify policy set assignment](#step-4-verify-policy-set-assignment)
  * [Remove built-in policy assignment](#remove-built-in-policy-assignment)
    * [Step 1: Remove policy set assignment from Azure DevOps Pipeline](#step-1--remove-policy-set-assignment-from-azure-devops-pipeline)
    * [Step 2: Delete policy set assignment's IAM assignments](#step-2-delete-policy-set-assignments-iam-assignments)
* [Custom policies](#custom-policies)
  * [New custom policy definition](#new-custom-policy-definition)
    * [Step 1: Create policy definition template](#step-1-create-policy-definition-template)
    * [Step 2: Deploy policy definition template](#step-2-deploy-policy-definition-template)
    * [Step 3: Verify policy definition deployment](#step-3-verify-policy-definition-deployment)
    * Step 4: Add policy definition to a [new custom policy set](#new-custom-policy-set-definition--assignment) or [update an existing policy set](#update-custom-policy-set-definition--assignment)
  * [New custom policy set definition & assignment](#new-custom-policy-set-definition--assignment)
    * [Step 1: Create policy set definition template](#step-1-create-policy-set-definition-template)
    * [Step 2: Create policy set assignment template](#step-2-create-policy-set-assignment-template)
    * [Step 3: Configure Azure DevOps Pipeline](#step-3-configure-azure-devops-pipeline)
    * [Step 4: Deploy definition & assignment](#step-4-deploy-definition--assignment)
    * [Step 5: Verify policy set definition and assignment deployment](#step-5-verify-policy-set-definition-and-assignment-deployment)
  * [Update custom policy definition](#update-custom-policy-definition)
    * [Step 1: Update policy definition](#step-1-update-policy-definition)
    * [Step 2: Verify policy definition deployment after update](#step-2-verify-policy-definition-deployment-after-update)
  * [Update custom policy set definition & assignment](#update-custom-policy-set-definition--assignment)
    * [Step 1: Update policy set definition & assignment](#step-1-update-policy-set-definition--assignment)
    * [Step 2: Verify policy set definition & assignment after update](#step-2-verify-policy-set-definition--assignment-after-update)

---
## Existing configuration

### Built-in policy assignments

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


### Custom policy set definitions and assignments

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

## Built-In policies

The built-in policy sets are used as-is to ensure future improvements from Azure Engineering teams are automatically incorporated into the Azure environment.

### **New built-in policy assignment**

**Steps**

* [Step 1: Collect information](#step-1-collect-information)
* [Step 2: Create Bicep template & parameters JSON file](#step-2-create-bicep-template--parameters-json-file)
* [Step 3: Update Azure DevOps Pipeline](#step-3-update-azure-devops-pipeline)
* [Step 4: Verify policy set assignment](#step-4-verify-policy-set-assignment)

#### **Step 1: Collect information**

1. Navigate to [Azure Portal -> Azure Policy -> Definitions](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Definitions)
2. Open the Built-In Policy Set (it is also called an Initiative) that will be assigned through automation.  For example: `Canada Federal PBMM`

    *Collect the following information:*

      * **Name** (i.e. `Canada Federal PBMM`)
      * **Definition ID** (i.e. `/providers/Microsoft.Authorization/policySetDefinitions/4c4a5f27-de81-430b-b4e5-9cbd50595a87`)

3. Click the **Assign** button and **select a scope** for the assignment.  We will not be assigning the policy through Azure Portal, but use this step to identify the permissions required for the Policy Assignment.

    *Collect the following information from the **Remediation** tab:*

    * **Permissions** - required when there are auto remediation policies.  You may see zero, one (i.e. `Contributor`) or many comma-separated (i.e. `Log Analytics Contributor, Virtual Machine Contributor, Monitoring Contributor`) roles listed.  Permissions will not be listed when none are required for the policy assignment to function.

    Once the permissions are identified, click the **Cancel** button to discard the changes.

    Use [Azure Built-In Roles table](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles) to map the permission name to it's Resource ID.  Resource ID will be used when defining the role assignments. 

4. Click on the **Duplicate initiative** button.  We will not be duplicating the policy set definition, but use this step to identify the parameter names that will need to be populated during policy assignment.

    *Collect the following information from the **Initiative parameters** tab:*

    * **Parameters** (i.e. `logAnalytics`, `logAnalyticsWorkspaceId`, `listOfResourceTypesToAuditDiagnosticSettings`).  You may see zero, one or many parameters listed.  It is possible that a policy set doesn't have any parameters.


#### **Step 2: Create Bicep template & parameters JSON file**

1. Navigate to `policy/builtin/assignments` folder and create two files.  Replace `POLICY_ASSIGNMENT` with the name of your assignment such as `pbmm`.

   * POLICY_ASSIGNMENT.bicep (i.e. `pbmm.bicep`) - this file defines the policy assignment deployment
   * POLICY_ASSIGNMENT.parameters.json (i.e. `pbmm.parameters.json`) - this file defines the parameters used to deploy the policy assignment.

2. Edit the Bicep file to include the following template.  This template can be customized as required.  Pre-requisites are:

    * targetScope must be `managementGroup`
    * parameter `policyAssignmentManagementGroupId` must be defined.  It is used to set the policy assignment through automation.

    ```bicep
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
    ```bicep
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

    You may use any of the [templated parameters](#templated-parameters) listed above to set values based on environment configuration or hard code them as needed. 

    ```json
    {
        "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {
            "policyAssignmentManagementGroupId": {
                "value": "{{var-topLevelManagementGroupName}}"
            },
            "EXTRA_POLICY_ASSIGNMENT_PARAMETER_NAME_1": {
                "value": "EXTRA_POLICY_ASSIGNMENT_PARAMETER_VALUE_1"
            },
            "EXTRA_POLICY_ASSIGNMENT_PARAMETER_NAME_2": {
                "value": "EXTRA_POLICY_ASSIGNMENT_PARAMETER_VALUE_2"
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

#### **Step 3: Update Azure DevOps Pipeline**

  * Edit `.pipelines/policy.yml`
  * Navigate to the `BuiltInPolicyJob` Job definition
  * Navigate to the `Assign Policy Set` Step definition
  * Add the policy assignment file name (without extension) to the `deployTemplates` array parameter

#### **Step 4: Verify policy set assignment**

  * You may navigate to [Azure Policy Compliance](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Compliance) to verify in Azure Portal.
  * When there are deployment errors:
  
      * Navigate to [Management Groups](https://portal.azure.com/#blade/Microsoft_Azure_ManagementGroups/ManagementGroupBrowseBlade/MGBrowse_overview) in Azure Portal
      * Select the top level management group (i.e. `pubsec`)
      * Select Deployments
      * Review the deployment errors

---

### Remove built-in policy assignment

**Steps**

* [Step 1: Remove policy set assignment from Azure DevOps Pipeline](#step-1--remove-policy-set-assignment-from-azure-devops-pipeline)
* [Step 2: Delete policy set assignment's IAM assignments](#step-2-delete-policy-set-assignments-iam-assignments)

#### **Step 1:  Remove policy set assignment from Azure DevOps Pipeline**

* Edit `.pipelines/policy.yml`
* Navigate to the `BuiltInPolicyJob` Job definition
* Navigate to the `Assign Policy Set` Step definition
* Remove the policy assignment from the `deployTemplates` array parameter

> Automation does not remove an existing policy set assignment.  Removing the policy set assignment from the Azure DevOps pipeline ensures that the policy assignment is no longer created.  Any existing policy set assignments must be deleted manually.

#### **Step 2: Delete policy set assignment's IAM assignments**

* Navigate to [Azure Policy Assignments](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Assignments) in Azure Portal
  * Find the policy set assignment
  * Click on the `...` beside the policy set assignment and select `Delete assignment`
* Navigate to [Management Groups](https://portal.azure.com/#blade/Microsoft_Azure_ManagementGroups/ManagementGroupBrowseBlade/MGBrowse_overview) in Azure Portal
  * Select the top level management group (i.e. `pubsec`)
  * Select Access control (IAM)
  * Select Role Assignments
  * Use the `Type` filter to find any `Unknown` role assignments and delete them.  This step is required since deleting the policy set assignment does not automatically remove any role assignments.  When the policy set assignment is removed, it's managed identity is also removed thus marking these role assignments as `Unknown`.

---

## Custom policies

### **New custom policy definition**

> We recommend custom policies are organized into a custom policy sets and assigned as a unit.  This approach will reduce the management overhead and complexity in the future.  You may have as many custom policy sets as required.

**Steps**

* [Step 1: Create policy definition template](#step-1-create-policy-definition-template)
* [Step 2: Deploy policy definition template](#step-2-deploy-policy-definition-template)
* [Step 3: Verify policy definition deployment](#step-3-verify-policy-definition-deployment)
* Step 4: Add policy definition to a [new custom policy set](#new-custom-policy-set-definition--assignment) or [update an existing policy set](#update-custom-policy-set-definition--assignment)

#### **Step 1: Create policy definition template**

1. Create a subdirectory in `policy/custom/definitions/policy`  Each policy is organized into it's own folder.  The folder name must not have any spaces nor special characters.

2. Create 3 files in the newly created directory:

    * `azurepolicy.config.json` - metadata used by Azure DevOps Pipeline to configure the policy.
    * `azurepolicy.parameters.json` - contains parameters used in the policy.
    * `azurepolicy.rules.json` - the policy rule definition.

3. Edit `azurepolicy.config.json`.

    Information from this file is used as part of deploying Azure Policy definitions.

    Example: 

    ```yml
    {
      "name": "Audit diagnostic setting - Logs",
      "mode": "all"
    }
    ```

    The `mode` determines which resource types are evaluated for a policy definition. The supported modes are:

    * all: evaluate resource groups, subscriptions, and all resource types
    * indexed: only evaluate resource types that support tags and location

    See [Azure Policy Reference](https://docs.microsoft.com/azure/governance/policy/concepts/definition-structure#mode) for more information.

4. Edit `azurepolicy.parameters.json`.  

    Define parameters that are required by the policy definition.  Using parameters enable the policy to be used with different configuration.

    See [Azure Parameter Reference](https://docs.microsoft.com/azure/governance/policy/concepts/definition-structure#parameters) for more information.

    Example: 
    ```yml
    {
      "listOfResourceTypes": {
        "type": "Array",
        "metadata": {
          "displayName": "Resource Types",
          "description": null,
          "strongType": "resourceTypes"
        }
      }
    }
    ```

5. Edit `azurepolicy.rules.json`

    Describes the policy rule that will be evaluated by Azure Policy.  The rule can have any effect such as Audit, Deny, DeployIfNotExists.

    Example:

    ```yml
    {
      "if": {
        "field": "type",
        "in": "[parameters('listOfResourceTypes')]"
      },
      "then": {
        "effect": "AuditIfNotExists",
        "details": {
          "type": "Microsoft.Insights/diagnosticSettings",
          "existenceCondition": {
            "allOf": [
              {
                "field": "Microsoft.Insights/diagnosticSettings/logs.enabled",
                "equals": "true"
              }
            ]
          }
        }
      }
    }
    ```

#### **Step 2: Deploy policy definition template**

Execute `Azure DevOps Policy pipeline` to deploy.  The policy definition will be deployed to the `top level management group`.

> Deploying the policy definition does not put it in effect.  You must either [create a new policy set](#new-custom-policy-set-definition--assignment) or [update an existing policy set](#update-custom-policy-set-definition--assignment) to put it in effect.

#### **Step 3: Verify policy definition deployment**

Navigate to [Azure Policy Definitions](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Definitions) to verify that the policy has been created.

When there are deployment errors:

  * Navigate to [Management Groups](https://portal.azure.com/#blade/Microsoft_Azure_ManagementGroups/ManagementGroupBrowseBlade/MGBrowse_overview) in Azure Portal
  * Select the top level management group (i.e. `pubsec`)
  * Select Deployments
  * Review the deployment errors

---

### **New custom policy set definition & assignment**

**Steps**

* [Step 1: Create policy set definition template](#step-1-create-policy-set-definition-template)
* [Step 2: Create policy set assignment template](#step-2-create-policy-set-assignment-template)
* [Step 3: Configure Azure DevOps Pipeline](#step-3-configure-azure-devops-pipeline)
* [Step 4: Deploy definition & assignment](#step-4-deploy-definition--assignment)
* [Step 5: Verify policy set definition and assignment deployment](#step-5-verify-policy-set-definition-and-assignment-deployment)

#### **Step 1: Create policy set definition template**

1. Navigate to `policy/custom/definitions/policyset` and create two files.  Replace `POLICY_SET_DEFINITION` with the name of your assignment such as `loganalytics`.

   * POLICY_SET_DEFINITION.bicep (i.e. `loganalytics.bicep`) - this file defines the policy set definition deployment
   * POLICY_SET_DEFINITION.parameters.json (i.e. `loganalytics.parameters.json`) - this file defines the parameters used to deploy the policy set definition

2. Edit the Bicep file to include the following template.  This template can be customized as required.  Pre-requisites are:

    * targetScope must be `managementGroup`
    * parameter `policyDefinitionManagementGroupId` must be defined.  This parameter identifies the scope of the policy set definition (i.e. `pubsec`).

    Example [See Log Analytics Policy Set definition](../../policy/custom/definitions/policyset/EnableLogAnalytics.bicep).

    ```bicep
      targetScope = 'managementGroup'

      @description('Management Group scope for the policy definition.')
      param policyDefinitionManagementGroupId string

      var customPolicyDefinitionMgScope = tenantResourceId('Microsoft.Management/managementGroups', policyDefinitionManagementGroupId)

      resource policyset_name 'Microsoft.Authorization/policySetDefinitions@2020-03-01' = {
        // Policy definition name.  This value is used when setting up the policy assignment template in the follow steps.  It should be all lowercase and no spaces.
        // i.e. name: 'custom-enable-logging-to-loganalytics'
        name: '<< NAME >>
        properties: {
          // Display name for the policy set definition
          displayName: '<< POLICY SET DEFINITION DISPLAY NAME >> '
          parameters: {
            // Add any parameters required for the policy set definition.  These parameters are used to pass down information to each policy.
          }
          policyDefinitionGroups: [
            // Define policy definition groups.  These are arbitrary groups that can be created based on your organization's requirements.
            // The group names are referenced when defining the policies.
            {
              name: 'CUSTOM'
              displayName: 'Additional Controls as Custom Policies'
            }
          ]
          policyDefinitions: [
            // List the policies in this policy set.  Repeat this block for every policy definition
            {
              groupNames: [
                'CUSTOM'
              ]
              policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/5ee9e9ed-0b42-41b7-8c9c-3cfb2fbe2069'
              policyDefinitionReferenceId: toLower(replace('Deploy Log Analytics agent for Linux virtual machine scale sets', ' ', '-'))
              parameters: {
                // Set the values of parameters for each policy.
              }
            }
          ]
        }
      }
    ```

3. Edit the JSON parameters file to define the input parameters for the Bicep template.  This parameters JSON file is used by Azure Resource Manager (ARM) for runtime inputs.

    You may use any of the [templated parameters](#templated-parameters) listed above to set values based on environment configuration or hard code them as needed. 

    ```json
      {
          "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
          "contentVersion": "1.0.0.0",
          "parameters": {
              "policyDefinitionManagementGroupId": {
                  "value": "{{var-topLevelManagementGroupName}}"
              },
              "EXTRA_POLICY_SET_ASSIGNMENT_PARAMETER_NAME_1": {
                  "value": "EXTRA_POLICY_SET_ASSIGNMENT_PARAMETER_VALUE_1"
              },
              "EXTRA_POLICY_SET_ASSIGNMENT_PARAMETER_NAME_2": {
                  "value": "EXTRA_POLICY_SET_ASSIGNMENT_PARAMETER_VALUE_2"
              }
          }
      }
    ```

    Example:  Log Analytics Policy Set Parameters

    ```json
      {
          "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
          "contentVersion": "1.0.0.0",
          "parameters": {
              "policyDefinitionManagementGroupId": {
                  "value": "{{var-topLevelManagementGroupName}}"
              }
          }
      }
    ```

#### **Step 2: Create policy set assignment template**

1. Navigate to `policy/custom/assignments` and create two files.  Replace `POLICY_SET_ASSIGNMENT` with the name of your assignment such as `loganalytics`.

   * POLICY_SET_ASSIGNMENT.bicep (i.e. `loganalytics.bicep`) - this file defines the policy set assignment deployment
   * POLICY_SET_ASSIGNMENT.parameters.json (i.e. `loganalytics.parameters.json`) - this file defines the parameters used to deploy the policy set assignment

2. Edit the Bicep file to include the following template.  This template can be customized as required.  Pre-requisites are:

    * targetScope must be `managementGroup`
    * parameter `policyDefinitionManagementGroupId` must be defined.  This parameter identifies the scope of the policy set definition (i.e. `pubsec`).
    * parameter `policyAssignmentManagementGroupId` must be defined.  This parameter identifies the scope of the policy set assignment (i.e. `pubsec`).

    ```bicep
    targetScope = 'managementGroup'

    @description('Management Group scope for the policy definition.')
    param policyDefinitionManagementGroupId string

    @description('Management Group scope for the policy assignment.')
    param policyAssignmentManagementGroupId string

    // Start - Any custom parameters required for your policy set assignment
    param ...
    // End - Any custom parameters required for your policy set assignment

    var policyId = '<< NAME OF THE POLICY SET DEFINITION >>'
    var assignmentName = '<< DISPLAY NAME OF THE POLICY SET ASSIGNMENT >>'

    var scope = tenantResourceId('Microsoft.Management/managementGroups', policyAssignmentManagementGroupId)
    var policyScopedId = '/providers/Microsoft.Management/managementGroups/${policyDefinitionManagementGroupId}/providers/Microsoft.Authorization/policySetDefinitions/${policyId}'

    resource policySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
      // Set the name of the policy set assignment
      // Example: name: 'logging-${uniqueString('law-',policyAssignmentManagementGroupId)}'

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
    // Set the role definition id based on the policies in the policy set
    resource policySetRoleAssignmentLogAnalyticsContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
      name: guid(policyAssignmentManagementGroupId, 'loganalytics', 'Log Analytics Contributor')
      scope: managementGroup()
      properties: {
        roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
        principalId: policySetAssignment.identity.principalId
        principalType: 'ServicePrincipal'
      }
    }
    ```

    Example: Log Analytics Policy Set Assignment

    ```
      targetScope = 'managementGroup'

      @description('Management Group scope for the policy definition.')
      param policyDefinitionManagementGroupId string

      @description('Management Group scope for the policy assignment.')
      param policyAssignmentManagementGroupId string

      @description('Log Analytics Workspace Resource Id')
      param logAnalyticsResourceId string

      @description('Log Analytics Workspace Id')
      param logAnalyticsWorkspaceId string

      var policyId = 'custom-enable-logging-to-loganalytics'
      var assignmentName = 'Custom - Log Analytics for Azure Services'

      var scope = tenantResourceId('Microsoft.Management/managementGroups', policyAssignmentManagementGroupId)
      var policyScopedId = '/providers/Microsoft.Management/managementGroups/${policyDefinitionManagementGroupId}/providers/Microsoft.Authorization/policySetDefinitions/${policyId}'

      resource policySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
        name: 'logging-${uniqueString('law-',policyAssignmentManagementGroupId)}'
        properties: {
          displayName: assignmentName
          policyDefinitionId: policyScopedId
          scope: scope
          notScopes: [
          ]
          parameters: {
            logAnalytics: {
              value: logAnalyticsResourceId
            }
            logAnalyticsWorkspaceId: {
              value: logAnalyticsWorkspaceId
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
      resource policySetRoleAssignmentLogAnalyticsContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
        name: guid(policyAssignmentManagementGroupId, 'loganalytics', 'Log Analytics Contributor')
        scope: managementGroup()
        properties: {
          roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
          principalId: policySetAssignment.identity.principalId
          principalType: 'ServicePrincipal'
        }
      }

      resource policySetRoleAssignmentVirtualMachineContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
        name: guid(policyAssignmentManagementGroupId, 'loganalytics', 'Virtual Machine Contributor')
        scope: managementGroup()
        properties: {
          roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
          principalId: policySetAssignment.identity.principalId
          principalType: 'ServicePrincipal'
        }
      }

      resource policySetRoleAssignmentMonitoringContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
        name: guid(policyAssignmentManagementGroupId, 'loganalytics', 'Monitoring Contributor')
        scope: managementGroup()
        properties: {
          roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
          principalId: policySetAssignment.identity.principalId
          principalType: 'ServicePrincipal'
        }
      }
    ```

3. Edit the JSON parameters file to define the input parameters for the Bicep template.  This parameters JSON file is used by Azure Resource Manager (ARM) for runtime inputs.

    You may use any of the [templated parameters](#templated-parameters) listed above to set values based on environment configuration or hard code them as needed. 

    ```json
      {
        "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {
          "policyDefinitionManagementGroupId": {
              "value": "{{var-topLevelManagementGroupName}}"
          },
          "policyAssignmentManagementGroupId": {
              "value": "{{var-topLevelManagementGroupName}}"
          },
          "EXTRA_POLICY_ASSIGNMENT_PARAMETER_NAME_1": {
              "value": "EXTRA_POLICY_ASSIGNMENT_PARAMETER_VALUE_1"
          },
          "EXTRA_POLICY_ASSIGNMENT_PARAMETER_NAME_2": {
              "value": "EXTRA_POLICY_ASSIGNMENT_PARAMETER_VALUE_2"
          }
        }
      }
    ```

    Example:  Log Analytics Policy Set Parameters

    ```json
      {
          "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
          "contentVersion": "1.0.0.0",
          "parameters": {
            "policyDefinitionManagementGroupId": {
                "value": "{{var-topLevelManagementGroupName}}"
            },
            "policyAssignmentManagementGroupId": {
                "value": "{{var-topLevelManagementGroupName}}"
            },
            "logAnalyticsWorkspaceId": {
                "value": "{{var-logging-logAnalyticsWorkspaceId}}"
            },
            "logAnalyticsResourceId": {
                "value": "{{var-logging-logAnalyticsWorkspaceResourceId}}"
            }
          }
      }
    ```

#### **Step 3: Configure Azure DevOps Pipeline**

  * Edit `.pipelines/policy.yml`
  * Navigate to the `CustomPolicyJob` Job definition
  * Navigate to the `Define Policy Set` Step definition and add the policy definition file name (without extension) to the `deployTemplates` array parameter
  * Navigate to the `Assign Policy Set` Step definition and add the policy assignment file name (without extension) to the `deployTemplates` array parameter

#### **Step 4: Deploy definition & assignment**

Execute `Azure DevOps Policy pipeline` to deploy.  The policy set definition and assignment will be deployed to the `top level management group`.

> It takes around 30 minutes for the assignment to be applied to the defined scope. Once it's applied, the evaluation cycle begins for resources within that scope against the newly assigned policy or initiative and depending on the effects used by the policy or initiative, resources are marked as compliant, non-compliant, or exempt. A large policy or initiative evaluated against a large scope of resources can take time. As such, there's no pre-defined expectation of when the evaluation cycle completes. Once it completes, updated compliance results are available in the portal and SDKs.


#### **Step 5: Verify policy set definition and assignment deployment**

Execute `Azure DevOps Policy pipeline` to deploy the policy set definition & assignment.

Navigate to [Azure Policy Definitions](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Definitions) and [Azure Policy Assignments](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Assignments) to verify that the policy set has been created.

When there are deployment errors:

  * Navigate to [Management Groups](https://portal.azure.com/#blade/Microsoft_Azure_ManagementGroups/ManagementGroupBrowseBlade/MGBrowse_overview) in Azure Portal
  * Select the top level management group (i.e. `pubsec`)
  * Select Deployments
  * Review the deployment errors

--- 
### **Update custom policy definition**

**Steps**

* [Step 1: Update policy definition](#step-1-update-policy-definition)
* [Step 2: Verify policy definition deployment after update](#step-2-verify-policy-definition-deployment-after-update)

#### **Step 1: Update policy definition**

Update `azurepolicy.config.json`, `azurepolicy.parameters.json` and `azurepolicy.rules.json` as required. 

#### **Step 2: Verify policy definition deployment after update**

Execute `Azure DevOps Policy pipeline` to automatically deploy the policy definition update.

Navigate to [Azure Policy Definitions](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Definitions) to verify that the policy has been updated.

> It takes around 30 minutes for the update to be applied. Once it's applied, the evaluation cycle begins for resources within that scope against the newly assigned policy or initiative and depending on the effects used by the policy or initiative, resources are marked as compliant, non-compliant, or exempt. A large policy or initiative evaluated against a large scope of resources can take time. As such, there's no pre-defined expectation of when the evaluation cycle completes. Once it completes, updated compliance results are available in the portal and SDKs.

When there are deployment errors:

  * Navigate to [Management Groups](https://portal.azure.com/#blade/Microsoft_Azure_ManagementGroups/ManagementGroupBrowseBlade/MGBrowse_overview) in Azure Portal
  * Select the top level management group (i.e. `pubsec`)
  * Select Deployments
  * Review the deployment errors

---

### **Update custom policy set definition & assignment**

**Steps**

* [Step 1: Update policy set definition & assignment](#step-1-update-policy-set-definition--assignment)
* [Step 2: Verify policy set definition & assignment after update](#step-2-verify-policy-set-definition--assignment-after-update)


#### **Step 1: Update policy set definition & assignment**

* Update policy set definition Bicep template as required.
* Update policy set assignment Bicep template as required (typically when a new role assignment expected to support a new policy).

Consider when updating a policy set definition & assignment:

* Any new parameter added to the policy set definition must have a `default value` to stay backward compatible with existing assignments.
* Ensure that any new role assignments are incorporated in the policy assignment definition.
* Avoid changing the policy set definition name.  If this is required, remove the policy set assignment and its role assignments first.
* Avoid changing the policy set role assignment names.  If this is required, remove the policy set assignment and its role assignments first.


#### **Step 2: Verify policy set definition & assignment after update**

Execute `Azure DevOps Policy pipeline` to deploy the policy set definition & assignment update.

Navigate to [Azure Policy Definitions](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Definitions) and [Azure Policy Assignments](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Assignments) to verify that the policy set has been updated.

When there are deployment errors:

  * Navigate to [Management Groups](https://portal.azure.com/#blade/Microsoft_Azure_ManagementGroups/ManagementGroupBrowseBlade/MGBrowse_overview) in Azure Portal
  * Select the top level management group (i.e. `pubsec`)
  * Select Deployments
  * Review the deployment errors
