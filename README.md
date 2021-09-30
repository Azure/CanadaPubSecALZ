# Azure Landing Zones Reference Implementation for Canadian Public Sector

## Introduction

The purpose of the reference implementation is to guide Canadian Public Sector customers on building Landing Zones in their Azure environment.  The reference implementation is based on [Cloud Adoption Framework for Azure](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/) and provides an opininated implementation that enables ITSG-33 regulatory compliance by using [NIST SP 800-53 Rev. 4](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4) and [Canada Federal PBMM](https://docs.microsoft.com/azure/governance/policy/samples/canada-federal-pbmm) Regulatory Compliance Policy Sets.

Architecture supported up to Treasury Board of Canada Secretariat (TBS) Cloud Profile 3 - Cloud Only Applications.  This proflie is applicable to Infrastructure as a Service (IaaS) and Platform as a Service (PaaS) with [characteristics](https://github.com/canada-ca/cloud-guardrails/blob/master/EN/00_Applicable-Scope.md):

* Cloud-based services hosting sensitive (up to Protected B) information
* No direct system to system network interconnections required with GC data centers

### Automation

The automation is built with [Project Bicep](https://github.com/Azure/bicep/blob/main/README.md) and Azure Resource Manager template.

This project provides 6 modules that can be further customized based on requirements:

1. Management Groups
2. Centralized Logging
3. Azure Policies (built-in & custom Azure Policies)
4. Custom Roles
5. Hub Network Design based on Hub/Spoke topology
6. Subscription Archetypes (Generic Subscription, Machine Learning & Healthcare)

Deployment to Azure is supported using Azure DevOps Pipelines and can be adopted for other automated deployment systems like GitHub Actions, Jenkins, etc.


## Goals

* Support Treasury Board of Canada Secretariat (TBS) Cloud Profile 3 - Cloud Only Applications

* Secure environment capable for Protected B workloads.

* Accelerate the use of Azure in Public Sector through onboarding 
multiple types of workloads including App Dev and Data & AI.

* Simplify compliance management through a single source of compliance, audit reporting and auto remediation.

* Deployment of DevOps frameworks & business processes to improve agility.

## Non-Goals

* Automation does not configure firewalls deployed as Network Virtual Appliance (NVA).  In this reference implementation, Fortinet firewalls can be deployed but customer is expected to configure and manage upon deployment.

* Automatic approval for Canada Federal PBMM nor Authority to Operate (ATO).  Customers must collect evidence, customize to meet their departmental requirements and submit for Authority to Operate based on their risk profile, requirements and process.

* Compliant on all Azure Policies when the reference implementation is deployed.  This is due to the shared responsibility of cloud and customers can choose the Azure Policies to exclude.  For example, using Azure Firewall is an Azure Policy that will be non-compliant since majority of the Public Sector customers use Network Virtual Appliances such as Fortinet.  Customers must review [Azure Security Center Regulatory Compliance dashboard](https://docs.microsoft.com/azure/security-center/update-regulatory-compliance-packages) and apply appropriate exemptions.

## Contributing

See [Contributing Reference Implementation](CONTRIBUTING.md) for information on building/running the code, contributing code, contributing examples and contributing feature requests or bug reports.

## Telemetry

This reference implementation does not collect any telemetry.  However, Project Bicep [collects telemetry in some scenarios](https://github.com/Azure/bicep/blob/main/README.md#telemetry) as part of improving the product.


## License

All files except for [Super-Linter](https://github.com/github/super-linter) in the repository are subject to the MIT license.

Super-Linter in this project is provided as an example for enabling source code linting capabilities.  [It is subjected to the license based on it's repository](https://github.com/github/super-linter).

## Trademark

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks). Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party’s policies.
