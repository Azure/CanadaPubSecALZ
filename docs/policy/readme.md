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
        policyAssignmentManagementGroupScope: $(var-topLevelManagementGroupName)
        workingDir: $(System.DefaultWorkingDirectory)/policy/builtin/assignments
```

All policy set assignments are at the `pubsec` top level management group.  This top level management group is retrieved from configuration parameter `var-topLevelManagementGroupName`.  See the [Azure DevOps Pipelines](../onboarding/azure-devops-pipelines.md) onboarding guide for instructions to setting up management groups & policy pipeline.

| Policy Set | Description | Deployment Template | Configuration |
| --- | --- | --- | --- |
| [Canada Federal PBMM][pbmmPolicySet] | This initiative includes audit and virtual machine extension deployment policies that address a subset of Canada Federal PBMM controls. | [pbmm.bicep](../../policy/builtin/assignments/pbmm.bicep) | [pbmm.parameters.json](../../policy/builtin/assignments/pbmm.parameters.json) |
| [NIST SP 800-53 Revision 4][nist80053R4policySet] | This initiative includes policies that address a subset of NIST SP 800-53 Rev. 4 controls. | [nist80053r4.bicep](../../policy/builtin/assignments/nist80053r4.bicep) | [nist80053r4.parameters.json](../../policy/builtin/assignments/nist80053r4.parameters.json) |
| [NIST SP 800-53 Revision 5][nist80053R5policySet] | This initiative includes policies that address a subset of NIST SP 800-53 Rev. 5 controls. | [nist80053r5.bicep](../../policy/builtin/assignments/nist80053r5.bicep) | [nist80053r5.parameters.json](../../policy/builtin/assignments/nist80053r5.parameters.json) |
| [Azure Security Benchmark][asbPolicySet] | The Azure Security Benchmark initiative represents the policies and controls implementing security recommendations defined in Azure Security Benchmark, see https://aka.ms/azsecbm. This also serves as the Microsoft Defender for Cloud default policy initiative. | [asb.bicep](../../policy/builtin/assignments/asb.bicep) | [asb.parameters.json](../../policy/builtin/assignments/asb.parameters.json) |
| [CIS Microsoft Azure Foundations Benchmark 1.3.0][cisMicrosoftAzureFoundationPolicySet] | This initiative includes policies that address a subset of CIS Microsoft Azure Foundations Benchmark recommendations. | [cis-msft-130.bicep](../../policy/builtin/assignments/cis-msft-130.bicep) | [cis-msft-130.parameters.json](../../policy/builtin/assignments/cis-msft-130.parameters.json) |
|  [FedRAMP Moderate][fedrampmPolicySet] | This initiative includes policies that address a subset of FedRAMP Moderate controls. | [fedramp-moderate.bicep](../../policy/builtin/assignments/fedramp-moderate.bicep) | [fedramp-moderate.parameters.json](../../policy/builtin/assignments/fedramp-moderate.parameters.json) |
| [HIPAA / HITRUST 9.2][hipaaHitrustPolicySet] | This initiative includes audit and virtual machine extension deployment policies that address a subset of HITRUST/HIPAA controls. | [hitrust-hipaa.bicep](../../policy/builtin/assignments/hitrust-hipaa.bicep) | [hitrust-hipaa.parameters.json](../../policy/builtin/assignments/hitrust-hipaa.parameters.json)
| Location | Restrict deployments to Canadian regions. | [location.bicep](../../policy/builtin/assignments/location.bicep) | [location.parameters.json](../../policy/builtin/assignments/location.parameters.json) |


---

## Custom Policies and Policy Sets

> **Note**: The custom policies & policy sets are used when built-in alternative does not exist.  Automation is regularly revised to use built-in policies and policy sets as new options are made available.

All policies and policy set definitions & assignments are at the `pubsec` top level management group.  This top level management group is retrieved from configuration parameter `var-topLevelManagementGroupName`.  See the [Azure DevOps Pipelines](../onboarding/azure-devops-pipelines.md) onboarding guide for instructions to setting up management groups & policy pipeline.

### Custom Policy Definitions

All custom policy definitions are located in [policy/custom/definitions/policy](../../policy/custom/definitions/policy) folder.

Each policy is organized into it's own folder.  The folder name must not have any spaces nor special characters.  Each folder contains 3 files:

1. azurepolicy.config.json - metadata used by Azure DevOps Pipeline to configure the policy.
2. azurepolicy.parameters.json - contains parameters used in the policy.
3. azurepolicy.rules.json - the policy rule definition.

See [step-by-step instructions on Azure Policy Authoring Guide](authoring-guide.md) for more information.

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
        deployTemplates: [AKS, DefenderForCloud, LogAnalytics, Network, DNSPrivateEndpoints, Tags]
        deployOperation: ${{ variables['deployOperation'] }}
        policyAssignmentManagementGroupScope: $(var-topLevelManagementGroupName)
        workingDir: $(System.DefaultWorkingDirectory)/policy/custom/definitions/policyset
```

| Policy Set | Description | Deployment Template | Configuration |
| --- | --- | --- | --- |
| Azure Kubernetes Service | Azure Policy Add-on to Azure Kubernetes Service clusters & Pod Security. | [AKS.bicep](../../policy/custom/definitions/policyset/AKS.bicep) | [AKS.parameters.json](../../policy/custom/definitions/policyset/AKS.parameters.json)
| Microsoft Defender for Cloud | Configures Microsoft Defender for Cloud, including Azure Defender for subscription and resources. | [DefenderForCloud.bicep](../../policy/custom/definitions/policyset/DefenderForCloud.bicep) | [DefenderForCloud.parameters.json](../../policy/custom/definitions/policyset/DefenderForCloud.parameters.json)
| Private DNS Zones for Private Endpoints | Policies to configure DNS zone records for private endpoints.  Policy set is assigned through deployment pipeline when private endpoint DNS zones are managed in the Hub Network. | [DNSPrivateEndpoints.bicep](../../policy/custom/definitions/policyset/DNSPrivateEndpoints.bicep) | [DNSPrivateEndpoints.parameters.json](../../policy/custom/definitions/policyset/DNSPrivateEndpoints.parameters.json)
| Log Analytics for Azure Services (IaaS and PaaS) | Configures monitoring agents for IaaS and diagnostic settings for PaaS to send logs to a central Log Analytics Workspace. | [LogAnalytics.bicep](../../policy/custom/definitions/policyset/LogAnalytics.bicep) | [LogAnalytics.parameters.json](../../policy/custom/definitions/policyset/LogAnalytics.parameters.json)
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
        deployTemplates: [AKS, DefenderForCloud, LogAnalytics, Network, Tags]
        deployOperation: ${{ variables['deployOperation'] }}
        policyAssignmentManagementGroupScope: $(var-topLevelManagementGroupName)
        workingDir: $(System.DefaultWorkingDirectory)/policy/custom/assignments
```

| Policy Set | Description | Deployment Template | Configuration |
| --- | --- | --- | --- |
| Azure Kubernetes Service | Azure Policy Add-on to Azure Kubernetes Service clusters & Pod Security. | [AKS.bicep](../../policy/custom/assignments/AKS.bicep) | [AKS.parameters.json](../../policy/custom/assignments/AKS.parameters.json)
| Microsoft Defender for Cloud | Configures Microsoft Defender for Cloud, including Azure Defender for subscription and resources. | [DefenderForCloud.bicep](../../policy/custom/assignments/DefenderForCloud.bicep) | [DefenderForCloud.parameters.json](../../policy/custom/assignments/DefenderForCloud.parameters.json)
| Azure DDoS | Configures policy to automatically protect virtual networks with public IP addresses.  Policy set is assigned through deployment pipeline when DDoS Standard is configured. | [DDoS.bicep](../../policy/custom/assignments/DDoS.bicep) | [DDoS.parameters.json](../../policy/custom/assignments/DDoS.parameters.json)
| Private DNS Zones for Private Endpoints | Policies to configure DNS zone records for private endpoints.  Policy set is assigned through deployment pipeline when private endpoint DNS zones are managed in the Hub Network. | [DNSPrivateEndpoints.bicep](../../policy/custom/assignments/DNSPrivateEndpoints.bicep) | [DNSPrivateEndpoints.parameters.json](../../policy/custom/assignments/DNSPrivateEndpoints.parameters.json)
| Log Analytics for Azure Services (IaaS and PaaS) | Configures monitoring agents for IaaS and diagnostic settings for PaaS to send logs to a central Log Analytics Workspace. | [LogAnalytics.bicep](../../policy/custom/assignments/LogAnalytics.bicep) | [LogAnalytics.parameters.json](../../policy/custom/assignments/LogAnalytics.parameters.json)
| Networking | Configures policies for network resources. | [Network.bicep](../../policy/custom/assignments/Network.bicep) | [Network.parameters.json](../../policy/custom/assignments/Network.parameters.json)
| Tag Governance | Configures required tags and tag propagation from resource groups to resources. | [Tags.bicep](../../policy/custom/assignments/Tags.bicep) | [Tags.parameters.json](../../policy/custom/assignments/Tags.parameters.json)

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
| {{var-policyAssignmentManagementGroupId}} | The management group scope for policy assignment. | `pubsec`

---

## Authoring Guide

See [Azure Policy Authoring Guide](authoring-guide.md) for step-by-step instructions.



[nist80053r4Policyset]: https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4
[nist80053r5Policyset]: https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5
[pbmmPolicyset]: https://docs.microsoft.com/azure/governance/policy/samples/canada-federal-pbmm
[asbPolicySet]: https://docs.microsoft.com/security/benchmark/azure/overview
[cisMicrosoftAzureFoundationPolicySet]: https://docs.microsoft.com/azure/governance/policy/samples/cis-azure-1-3-0
[fedrampmPolicySet]: https://docs.microsoft.com/azure/governance/policy/samples/fedramp-moderate
[hipaaHitrustPolicySet]: https://docs.microsoft.com/azure/governance/policy/samples/hipaa-hitrust-9-2
