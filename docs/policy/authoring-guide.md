# Azure Policy Authoring Guide

This reference implementation uses Built-In and Custom Policies to provide guardrails in the Azure environment.  The goal of this authoring guide is to provide step-by-step instructions to manage and customize policy definitions and assignments to align to your organization's compliance requirements.

## Table of Contents

* [Built-in policies](#built-in-policies)
  * [New built-in policy assignment](#new-built-in-policy-assignment)
  * [Remove built-in policy assignment](#remove-built-in-policy-assignment)
* [Custom policies](#custom-policies)
  * [New custom policy definition](#new-custom-policy-definition)
  * [New custom policy set definition & assignment](#new-custom-policy-set-definition--assignment)
  * [Update custom policy set definition & assignment](#update-custom-policy-set-definition--assignment)

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

4. Click on the **Duplicate initiatve** button.  We will not be duplicating the policy set definition, but use this step to identify the parameter names that will need to be populated during policy assignment.

    *Collect the following information from the **Initiative parameters** tab:*

    * **Parameters** (i.e. `logAnalytics`, `logAnalyticsWorkspaceId`, `listOfResourceTypesToAuditDiagnosticSettings`).  You may see zero, one or many parameters listed.  It is possible that a policy set doesn't have any parameters.


#### **Step 2: Create Bicep template & parameters JSON file**

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

### Remove built-in policy assignment

**Steps:**

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

**Steps**

* [Step 1: Create policy definition template](#step-1-create-policy-definition-template)
* [Step 2: Deploy policy definition template](#step-2-deploy-policy-definition-template)
* [Step 3: Verify policy definition deployment](#step-3-verify-policy-definition-deployment)

#### **Step 1: Create policy definition template**
#### **Step 2: Deploy policy definition template**
#### **Step 3: Verify policy definition deployment**


### **New custom policy set definition & assignment**

**Steps**

* [Step 1: Create policy set definition template](#step-1-create-policy-set-definition-template)
* [Step 2: Create policy set assignment template](#step-2-create-policy-set-assignment-template)
* [Step 3: Configure Azure DevOps Pipeline](#step-3-configure-azure-devops-pipeline)
* [Step 4: Deploy definition & assignment](#step-4-deploy-definition--assignment)
* [Step 5: Verify policy set definition and assignment deployment](#step-5-verify-policy-set-definition-and-assignment-deployment)

#### **Step 1: Create policy set definition template**
#### **Step 2: Create policy set assignment template**
#### **Step 3: Configure Azure DevOps Pipeline**
#### **Step 4: Deploy definition & assignment**
#### **Step 5: Verify policy set definition and assignment deployment**

### **Update custom policy definition**

**Steps**

* [Step 1: Update policy definition](#step-1-update-policy-definition)
* [Step 2: Verify policy definition deployment after update](#step-2-verify-policy-definition-deployment-after-update)

#### **Step 1: Update policy definition**
#### **Step 2: Verify policy definition deployment after update**


### **Update custom policy set definition & assignment**

**Steps**

* [Step 1: Update policy set definition & assignment](#step-1-update-policy-set-definition--assignment)
* [Step 2: Verify policy set definition & assignment after update](#step-2-verify-policy-set-definition--assignment-after-update)

#### **Step 1: Update policy set definition & assignment**
#### **Step 2: Verify policy set definition & assignment after update**
