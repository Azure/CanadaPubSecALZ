# GC Cloud Guardrails

- [GC Cloud Guardrails](#gc-cloud-guardrails)
  - [Overview](#overview)
  - [Azure Active Directory Required Configuration](#azure-active-directory-required-configuration)
    - [Azure AD Logging and Monitoring](#azure-ad-logging-and-monitoring)
    - [ALZCPS Identity Management Policies](#alzcps-identity-management-policies)
  - [Guardrails](#guardrails)
    - [1. Protect Root / Global Admins Account](#1-protect-root--global-admins-account)
    - [2. Management of Administrative Privileges](#2-management-of-administrative-privileges)
    - [3. Cloud Console Access](#3-cloud-console-access)
    - [4. Enterprise Monitoring Accounts](#4-enterprise-monitoring-accounts)
    - [5. Data Location](#5-data-location)
    - [6. Protection of Data-at-Rest](#6-protection-of-data-at-rest)
    - [7. Protection of Data-in-Transit](#7-protection-of-data-in-transit)
    - [8. Segment and Separate](#8-segment-and-separate)
    - [9. Network Security Services](#9-network-security-services)
    - [10. Cyber Defense Services](#10-cyber-defense-services)
    - [11. Logging and Monitoring](#11-logging-and-monitoring)
    - [12. Configuration of Cloud Marketplaces](#12-configuration-of-cloud-marketplaces)

---

## Overview

As part of the Government of Canada (GC) Cloud Operationalization Framework, the GC has provided a set of minimum guardrails to be implemented within the first 30-days of standing up a cloud environment. From the [GC Cloud Guardrails](https://github.com/canada-ca/cloud-guardrails) repository:

> The purpose of the guardrails is to ensure that departments and agencies are implementing a preliminary baseline set of controls within their cloud-based environments. These minimum guardrails are to be implemented within the GC-specified initial period (e.g. 30 days) upon receipt of an enrollment under the GC Cloud Services Framework Agreement.

This document identifies the key considerations as part of each guardrail and provides information on how an Azure Landing Zones for Canadian Public Sector (ALZCPS) deployment meets (or could meet) each consideration.

## Azure Active Directory Required Configuration

Many of the guardrails contain identity and access management requirements. However, configuration of Azure Active Directory (Azure AD) is a prerequisite to deploying a landing zone using the ALZCPS project. Key configuration information is contained within our [architecture documentation](./architecture.md#4-identity). 

> When Azure AD is configured appropriately, 34% of the guardrail considerations are covered.

### Azure AD Logging and Monitoring

When configuring your Azure AD tenant, ensure that:
- [Sign-in logs are being sent to Log Analytics](https://docs.microsoft.com/azure/active-directory/reports-monitoring/concept-activity-logs-azure-monitor)
- [Sign-in logs are being sent to Microsoft Sentinel](https://docs.microsoft.com/azure/sentinel/data-connectors-reference#azure-active-directory)
- [Azure AD Identity Protection alerts are configured](https://docs.microsoft.com/azure/active-directory/identity-protection/howto-identity-protection-configure-notifications)
- [Azure AD Identity Protection logs are being sent to Log Analytics](https://docs.microsoft.com/azure/active-directory/identity-protection/howto-export-risk-data) 
- [Azure AD Identity Protection logs are being sent to Microsoft Sentinel](https://docs.microsoft.com/azure/sentinel/data-connectors-reference#azure-active-directory-identity-protection).
- [Privileged Identity Management (PIM) is deployed](https://docs.microsoft.com/azure/active-directory/privileged-identity-management/pim-deployment-plan)
- [Privileged Identity Management alerts are configured](https://docs.microsoft.com/azure/active-directory/privileged-identity-management/pim-how-to-configure-security-alerts)

Within Microsoft Sentinel, it is recommended that organizations leverage [User and Entity Behavioral Analytics](https://docs.microsoft.com/azure/sentinel/identify-threats-with-entity-behavior-analytics) to enhance anomalous entity detection.

### ALZCPS Identity Management Policies

The following policies related to identity management are enabled by default in ALZCPS deployments:
- [Azure Policy - NIST SP 800-53 Rev. 5 AC-2: Account Management](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#account-management)
- [Azure Policy - NIST SP 800-53 Rev. 5 AC-2 (1): Automated System Account Management](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#automated-system-account-management)
- [Azure Policy - NIST SP 800-53 Rev. 5 AC-3: Access Enforcement](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#access-enforcement)
- [Azure Policy - NIST SP 800-53 Rev. 5 AC-5: Separation of Duties](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#separation-of-duties)
- [Azure Policy - NIST SP 800-53 Rev. 5 AC-6: Least Privilege](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#least-privilege)
- [Azure Policy - NIST SP 800-53 Rev. 4 AC-6 (5): Account Management](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#account-management)
- [Azure Policy - NIST SP 800-53 Rev. 4 AC-6 (10): Prohibit Non-privileged Users from Executing Privileged Functions](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#prohibit-non-privileged-users-from-executing-privileged-functions)
- [Azure Policy - NIST SP 800-53 Rev. 4 AC-7: Unsuccessful Logon Attempts](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#unsuccessful-logon-attempts)
- [Azure Policy - NIST SP 800-53 Rev. 4 AC-19: Access Control for Mobile Devices](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#access-control-for-mobile-devices)
- [Azure Policy - NIST SP 800-53 Rev. 5 IA-2: Identification and Authentication (organizational Users)](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#identification-and-authentication-organizational-users)
- [Azure Policy - NIST SP 800-53 Rev. 5 IA-2 (1): Multi-factor Authentication to Privileged Accounts](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#access-control-for-mobile-devices)
- [Azure Policy - NIST SP 800-53 Rev. 5 IA-2 (2): Multi-factor Authentication to Non-privileged Accounts](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#multi-factor-authentication-to-non-privileged-accounts)
- [Azure Policy - NIST SP 800-53 Rev. 4 IA-2 (11): Remote Access - Separate Device](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#remote-access---separate-device)
- [Azure Policy - NIST SP 800-53 Rev. 5 IA-4: Identifier Management](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#identifier-management)
- [Azure Policy - NIST SP 800-53 Rev. 5 IA-5: Authenticator Management](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#authenticator-management)
- [Azure Policy - NIST SP 800-53 Rev. 5 IA-5 (1): Password-based Authentication](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#password-based-authentication)
- [Azure Policy - NIST SP 800-53 Rev. 4 IA-5 (7): No Embedded Unencrypted Static Authenticators](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#no-embedded-unencrypted-static-authenticators)
- [Azure Policy - NIST SP 800-53 Rev. 4 IA-5 (13): Expiration of Cached Authenticators](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#expiration-of-cached-authenticators)
- [Azure Policy - NIST SP 800-53 Rev. 4 IA-6: Authenticator Feedback](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#authenticator-feedback)
- [Azure Policy - NIST SP 800-53 Rev. 4 IA-8: Identification and Authentication (non-organizational Users)](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#identification-and-authentication-non-organizational-users)

## Guardrails

### 1. Protect Root / Global Admins Account

[GC Guardrail Documentation](https://canada-ca.github.io/cloud-guardrails/EN/01_Protect-Root-Account.html)

#### 1.1 Implement multi-factor authentication (MFA) mechanism for root/master account.

This consideration can be met by appropriately configuring your Azure AD instance. Multi-factor authentication controls are implemented as listed in [ALZCPS Identity Management Policies](#alzcps-identity-management-policies).

Relevant Links:
- [Tutorial: Secure user sign-in events with Azure AD Multi-Factor Authentication](https://docs.microsoft.com/azure/active-directory/authentication/tutorial-enable-azure-mfa)
- [Conditional Access: Require MFA for administrators](https://docs.microsoft.com/azure/active-directory/conditional-access/howto-conditional-access-policy-admin-mfa)

#### 1.2 Document a break glass emergency account management procedure. Including names of users with root or master account access.

Documentation exercises are out of scope. GC intranet users can reference the [break-glass emergency account procedure document](https://gcconnex.gc.ca/file/view/55010566/break-glass-emergency-account-procedure-departments-can-use-to-develop-their-emergency-access-management-controls-for-cloud?language=en).

Relevant Links:
- [Manage emergency access accounts in Azure AD](https://docs.microsoft.com/azure/active-directory/roles/security-emergency-access)

#### 1.3 Obtain signature from Departmental Chief Information Officer (CIO) and Chief Security Officer (CSO) to confirm acknowledgement and approval of the break glass emergency account management procedures.

Documentation exercises are out of scope. GC intranet users can reference the [break-glass emergency account procedure document](https://gcconnex.gc.ca/file/view/55010566/break-glass-emergency-account-procedure-departments-can-use-to-develop-their-emergency-access-management-controls-for-cloud?language=en).

Relevant Links:
- [Manage emergency access accounts in Azure AD](https://docs.microsoft.com/azure/active-directory/roles/security-emergency-access)

#### 1.4 Implement a mechanism for enforcing access authorizations.

This consideration can be met by appropriately configuring your Azure AD instance. Specifically, creating and assigning users to appropriate Azure AD groups and then granting permissions to those groups. Access authorization controls are implemented as listed in [ALZCPS Identity Management Policies](#alzcps-identity-management-policies).

Relevant Links:
- [Authorization with Azure AD](https://docs.microsoft.com/azure/architecture/framework/security/design-identity-authorization)
- [What is Azure role-based access control (Azure RBAC)?](https://docs.microsoft.com/azure/role-based-access-control/overview)
- [Steps to assign an Azure role](https://docs.microsoft.com/azure/role-based-access-control/role-assignments-steps)

#### 1.5 Configure appropriate alerts on root/master accounts to detect a potential compromise, in accordance with the GC Event Logging Guidance.

This consideration can be met by appropriately configuring your Azure AD instance. See [Azure AD Logging and Monitoring](#azure-ad-logging-and-monitoring)

GC intranet users can reference the [GC Event Logging Guidance](https://www.gcpedia.gc.ca/gcwiki/images/e/e3/GC_Event_Logging_Strategy.pdf).

Relevant Links:

- [What is Identity Protection?](https://docs.microsoft.com/azure/active-directory/identity-protection/overview-identity-protection)
- [What is Azure AD Privileged Identity Management?](https://docs.microsoft.com/azure/active-directory/privileged-identity-management/pim-configure)
- [What is User and Entity Behavior Analytics (UEBA)?](https://docs.microsoft.com/azure/sentinel/identify-threats-with-entity-behavior-analytics#what-is-user-and-entity-behavior-analytics-ueba)

---

### 2. Management of Administrative Privileges

[GC Guardrail Documentation](https://canada-ca.github.io/cloud-guardrails/EN/02_Management-Admin-Privileges.html)

#### 2.1 Document a process for managing accounts, access privileges, and access credentials for organizational users, non-organizational users (if required), and processes based on the principles of separation of duties and least privilege (for example, operational procedures and active directory).

Documentation exercises are out of scope.

Relevant Links:
- [SPIN 2017-01 Subsection 6.2.3](https://www.canada.ca/en/government/system/digital-government/digital-government-innovations/cloud-services/direction-secure-use-commercial-cloud-services-spin.html#toc6-2-3)
- [Enhance security with the principle of least privilege](https://docs.microsoft.com/azure/active-directory/develop/secure-least-privileged-access)

#### 2.2 Implement a mechanism for enforcing access authorizations.

This consideration can be met by appropriately configuring your Azure AD instance. Specifically, creating and assigning users to appropriate Azure AD groups and then granting permissions to those groups. Access authorization controls are implemented as listed in [ALZCPS Identity Management Policies](#alzcps-identity-management-policies).

Relevant Links:
- [Authorization with Azure AD](https://docs.microsoft.com/azure/architecture/framework/security/design-identity-authorization)
- [What is Azure role-based access control (Azure RBAC)?](https://docs.microsoft.com/azure/role-based-access-control/overview)
- [Steps to assign an Azure role](https://docs.microsoft.com/azure/role-based-access-control/role-assignments-steps)

#### 2.3 Implement a mechanism for uniquely identifying and authenticating organizational users, non-organizational users (if applicable), and processes (for example, username and password).

This consideration can be met by appropriately configuring your Azure AD instance. Controls for authenticating organizational users, non-organizational users, and processes re implemented as listed in [ALZCPS Identity Management Policies](#alzcps-identity-management-policies).

Relevant Links:
- [Azure Active Directory Authentication management operations reference guide](https://docs.microsoft.com/azure/active-directory/fundamentals/active-directory-ops-guide-auth)
- [B2B collaboration overview](https://docs.microsoft.com/azure/active-directory/external-identities/what-is-b2b) (Guest Accounts)
- [Application and service principal objects in Azure Active Directory](https://docs.microsoft.com/azure/active-directory/develop/app-objects-and-service-principals) (Apps)

#### 2.4 Implement a multi-factor authentication mechanism for privileged accounts (for example, username, password and one-time password) and for external facing interfaces.

This consideration can be met by appropriately configuring your Azure AD instance. Multi-factor authentication controls are implemented as listed in [ALZCPS Identity Management Policies](#alzcps-identity-management-policies).

Relevant Links:
- [Tutorial: Secure user sign-in events with Azure AD Multi-Factor Authentication](https://docs.microsoft.com/azure/active-directory/authentication/tutorial-enable-azure-mfa)
- [Plan a Conditional Access deployment](https://docs.microsoft.com/azure/active-directory/conditional-access/plan-conditional-access)

#### 2.5 Change default passwords.

This consideration can be met by appropriately configuring your Azure AD instance. Password controls are implemented as listed in [ALZCPS Identity Management Policies](#alzcps-identity-management-policies).

Relevant Links:
- [Combined password policy and weak password check in Azure Active Directory](https://docs.microsoft.com/azure/active-directory/authentication/concept-password-ban-bad-combined-policy)

#### 2.6 Ensure that no custom subscription owner roles are created.

As described in the [Microsoft Cloud Adoption Framework design recommendations](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-area/identity-access#prerequisites-for-a-landing-zonedesign-recommendations), there is one custom owner role created: 
- Custom - Landing Zone Subscription Owner

However, this is not truly a "subscription owner", as it has limited permissions and is unable to manage RBAC and networking.

Role-related controls are implemented as listed in [ALZCPS Identity Management Policies](#alzcps-identity-management-policies).


#### 2.7 Configure password policy in accordance with GC Password Guidance.

This consideration can be met by appropriately configuring your Azure AD instance. Password controls are implemented as listed in [ALZCPS Identity Management Policies](#alzcps-identity-management-policies).

Relevant Links:
- [GC Password Guidance](https://www.canada.ca/en/government/system/digital-government/online-security-privacy/password-guidance.html)
- [Password policies and account restrictions in Azure Active Directory](https://docs.microsoft.com/azure/active-directory/authentication/concept-sspr-policy)

#### 2.8 Minimize number of guest users; add only if needed.

Out of scope.

Relevant Links: 
- [B2B collaboration overview](https://docs.microsoft.com/azure/active-directory/external-identities/what-is-b2b) (Guest Accounts)

#### 2.9 Determine access restrictions and configuration requirements for GC-issued endpoint devices, including those of non-privileged and privileged users, and configure access restrictions for endpoint devices accordingly. Note: Some service providers may offer configuration options to restrict endpoint device access. Alternatively, organizational policy and procedural instruments can be implemented to restrict access.

This consideration can be met by appropriately configuring your Azure AD instance. Specifically, deployment of [Azure AD Conditional Access](https://docs.microsoft.com/azure/active-directory/conditional-access/plan-conditional-access) which provides the ability to restrict endpoint device access. Access restriction controls are implemented as listed in [ALZCPS Identity Management Policies](#alzcps-identity-management-policies).

Relevant Links:
- [What is Conditional Access?](https://docs.microsoft.com/azure/active-directory/conditional-access/overview)
- [Conditional Access: Require compliant or hybrid Azure AD joined device](https://docs.microsoft.com/azure/active-directory/conditional-access/howto-conditional-access-policy-compliant-device)

---

### 3. Cloud Console Access

[GC Guardrail Documentation](https://canada-ca.github.io/cloud-guardrails/EN/03_Cloud-Console-Access.html)

#### 3.1 Implement multi-factor authentication mechanism for privileged accounts and remote network (cloud) access.

This consideration can be met by appropriately configuring your Azure AD instance. Multi-factor authentication controls are implemented as listed in [ALZCPS Identity Management Policies](#alzcps-identity-management-policies).

Relevant Links:
- [Tutorial: Secure user sign-in events with Azure AD Multi-Factor Authentication](https://docs.microsoft.com/azure/active-directory/authentication/tutorial-enable-azure-mfa)
- [Plan a Conditional Access deployment](https://docs.microsoft.com/azure/active-directory/conditional-access/plan-conditional-access)
- [Conditional Access: Require MFA for administrators](https://docs.microsoft.com/azure/active-directory/conditional-access/howto-conditional-access-policy-admin-mfa)

#### 3.2 Determine access restrictions and configuration requirements for GC managed devices, including those of non-privileged and privileged users, and configure access restrictions for endpoint devices accordingly.

This consideration can be met by appropriately configuring your Azure AD instance. Access restriction controls are implemented as listed in [ALZCPS Identity Management Policies](#alzcps-identity-management-policies).

Relevant Links:
- [Plan a Conditional Access deployment](https://docs.microsoft.com/azure/active-directory/conditional-access/plan-conditional-access)
- [Conditional Access: Require compliant or hybrid Azure AD joined device](https://docs.microsoft.com/azure/active-directory/conditional-access/howto-conditional-access-policy-compliant-device)

#### 3.3 Ensure that administrative actions are performed by authorized users following a process approved by Chief Security Officer (CSO) (or delegate) and designated official for cyber security. This process should incorporate the use of trusted devices and a risk-based conditional access control policy with appropriate logging and monitoring enabled.

Conditional access control policies, including device compliance requirements, can be configured within your Azure AD instance. For logging and monitoring requirements, see [Azure AD Logging and Monitoring](#azure-ad-logging-and-monitoring). Access-control controls are implemented as listed in [ALZCPS Identity Management Policies](#alzcps-identity-management-policies).

Relevant Links:
- [Plan a Conditional Access deployment](https://docs.microsoft.com/azure/active-directory/conditional-access/plan-conditional-access)
- [Conditional Access: Require compliant or hybrid Azure AD joined device](https://docs.microsoft.com/azure/active-directory/conditional-access/howto-conditional-access-policy-compliant-device)

#### 3.4 Implement a mechanism for enforcing access authorizations.

This consideration can be met by appropriately configuring your Azure AD instance. Specifically, creating and assigning users to appropriate Azure AD groups and then granting permissions to those groups. Access authorization controls are implemented as listed in [ALZCPS Identity Management Policies](#alzcps-identity-management-policies).

Relevant Links:
- [Authorization with Azure AD](https://docs.microsoft.com/azure/architecture/framework/security/design-identity-authorization)
- [What is Azure role-based access control (Azure RBAC)?](https://docs.microsoft.com/azure/role-based-access-control/overview)
- [Steps to assign an Azure role](https://docs.microsoft.com/azure/role-based-access-control/role-assignments-steps)

#### 3.5 Implement password protection mechanisms to protect against password brute force attacks.

This consideration can be met by appropriately configuring your Azure AD instance. Specifically, [configuring Azure AD smart lockout](https://docs.microsoft.com/azure/active-directory/authentication/howto-password-smart-lockout) or, ideally, implementing a [passwordless authentication deployment](https://docs.microsoft.com/azure/active-directory/authentication/howto-authentication-passwordless-deployment). Password controls are implemented as listed in [ALZCPS Identity Management Policies](#alzcps-identity-management-policies).

Relevant Links:
- [What authentication and verification methods are available in Azure Active Directory?](https://docs.microsoft.com/azure/active-directory/authentication/concept-authentication-methods)
- [Forget passwords, go passwordless](https://www.microsoft.com/security/business/identity-access-management/passwordless-authentication)
- [Plan and deploy on-premises Azure Active Directory Password Protection](https://docs.microsoft.com/azure/active-directory/authentication/howto-password-ban-bad-on-premises-deploy)
- [Combined password policy and weak password check in Azure Active Directory](https://docs.microsoft.com/azure/active-directory/authentication/concept-password-ban-bad-combined-policy)

---

### 4. Enterprise Monitoring Accounts

[GC Guardrail Documentation](https://canada-ca.github.io/cloud-guardrails/EN/04_Enterprise-Monitoring-Accounts.html)

#### 4.1 Assign roles to approved GC stakeholders to enable enterprise visibility. Roles include billing reader, policy contributor/reader, security reader, and global reader.

This consideration can be met by appropriately configuring your Azure AD instance. Specifically, by assigning the appropriate [RBAC roles](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles). Role-related controls are implemented as listed in [ALZCPS Identity Management Policies](#alzcps-identity-management-policies).

Relevant Links:
- [Steps to assign an Azure role](https://docs.microsoft.com/azure/role-based-access-control/role-assignments-steps)

#### 4.2 Ensure that multi-factor authentication mechanism for enterprise monitoring accounts is enabled.

This consideration can be met by appropriately configuring your Azure AD instance. 

Relevant Links:
- [Tutorial: Secure user sign-in events with Azure AD Multi-Factor Authentication](https://docs.microsoft.com/azure/active-directory/authentication/tutorial-enable-azure-mfa)

---

### 5. Data Location

[GC Guardrail Documentation](https://canada-ca.github.io/cloud-guardrails/EN/05_Data-Location.html)

#### 5.1 As per the Directive on Service and Digital "Ensuring computing facilities located within the geographic boundaries of Canada or within the premises of a Government of Canada department located abroad, such as a diplomatic or consular mission, be identified and evaluated as a principal delivery option for all sensitive electronic information and data under government control that has been categorized as Protected B, Protected C or is Classified."

ALZCPS deployments restrict resource deployments by default to the locations "canadacentral" or "canadaeast".

The following policies related to data location are enabled by default in ALZCPS deployments:
- [Azure Policy - Built-in: Allowed locations](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/General/AllowedLocations_Deny.json)

Relevant Links:
- [ALZCPS location parameters](../policy/builtin/assignments/location.parameters.json)
- [Azure built-in policies](https://docs.microsoft.com/azure/governance/policy/samples/built-in-policies)
  - [General built-in policies](https://docs.microsoft.com/azure/governance/policy/samples/built-in-policies#general)

---

### 6. Protection of Data-at-Rest

[GC Guardrail Documentation](https://canada-ca.github.io/cloud-guardrails/EN/06_Protect-Data-at-Rest.html)

#### 6.1 Seek guidance from privacy and access to information officials within institutions before storing personal information in cloud-based environments.

Institutional policy guidance exercises are out of scope.

#### 6.2 Implement an encryption mechanism to protect the confidentiality and integrity of data when data are at rest in your solution's storage.

[Most Azure services that support encryption at rest](https://docs.microsoft.com/azure/security/fundamentals/encryption-models#supporting-services) typically support offloading the management of encryption keys to Azure. The Azure resource provider creates the keys, places them in secure storage, and retrieves them when needed. This means that the service has full access to the keys and the service has full control over the credential lifecycle management. However, there are various supported encryption models, including:

- [Server-side encryption using Service-Managed keys](https://docs.microsoft.com/azure/security/fundamentals/encryption-models#server-side-encryption-using-service-managed-keys)
- [Server-side encryption using customer-managed keys in Azure Key Vault](https://docs.microsoft.com/azure/security/fundamentals/encryption-models#server-side-encryption-using-customer-managed-keys-in-azure-key-vault)
- [Server-side encryption using customer-managed keys in customer-controlled hardware](https://docs.microsoft.com/azure/security/fundamentals/encryption-models#server-side-encryption-using-customer-managed-keys-in-customer-controlled-hardware)
- [Client-side encryption](https://docs.microsoft.com/azure/security/fundamentals/encryption-models#client-encryption-model)

Refer to [this list](https://docs.microsoft.com/azure/security/fundamentals/encryption-models#client-encryption-model) to see encryption models are supported by each service.

The following policies related to protection of information at rest are enabled by default in ALZCPS deployments:
- [Azure Policy - NIST SP 800-53 Rev. 5 SC-28: Protection of Information at Rest](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#protection-of-information-at-rest)

Relevant Links:
- [Azure encryption overview](https://docs.microsoft.com/azure/security/fundamentals/encryption-overview)
- [Azure Data Encryption at rest](https://docs.microsoft.com/azure/security/fundamentals/encryption-atrest)
- [Azure Storage encryption for data at rest](https://docs.microsoft.com/azure/storage/common/storage-service-encryption)
- [Data encryption models](https://docs.microsoft.com/azure/security/fundamentals/encryption-models)
- [Azure data security and encryption best practices](https://docs.microsoft.com/azure/security/fundamentals/data-encryption-best-practices)

#### 6.3 Use CSE-approved cryptographic algorithms and protocols, in accordance with ITSP.40.111 and ITSP.40.062.

Azure provides the ability to use CSE-approved algorithms and protocols. However, _policy enforcement_ is not possible across all use-cases as it is dependant upon the individual application architecture. For example, the [default certificate signing algorithm within Azure AD](https://docs.microsoft.com/azure/active-directory/manage-apps/certificate-signing-options#certificate-signing-algorithms) is SHA-256. However, if an application only supports SHA-1, Azure AD can be manually configured to sign SAML responses using SHA-1 for that application. 

The following policies related to approved cryptographic algorithms are enabled by default in ALZCPS deployments:
- [Azure Policy - NIST SP 800-53 Rev. 4 SC-13: Cryptographic Protection](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#cryptographic-protection-3)
- [Azure Policy - NIST SP 800-53 Rev. 5 SC-28 (1): Cryptographic Protection](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#cryptographic-protection-1)

Relevant Links:
- [ITSP.40.111: Cryptographic Algorithms for UNCLASSIFIED, PROTECTED A, and PROTECTED B Information](https://cyber.gc.ca/en/guidance/cryptographic-algorithms-unclassified-protected-and-protected-b-information-itsp40111)
- [ITSP.40.062: Guidance on Securely Configuring Network Protocols](https://cyber.gc.ca/en/guidance/guidance-securely-configuring-network-protocols-itsp40062)
- [Azure encryption overview](https://docs.microsoft.com/azure/security/fundamentals/encryption-overview)

#### 6.4 Implement key management procedures.

[Most Azure services that support encryption at rest](https://docs.microsoft.com/azure/security/fundamentals/encryption-models#supporting-services) typically support offloading the management of encryption keys to Azure. The Azure resource provider creates the keys, places them in secure storage, and retrieves them when needed. This means that the service has full access to the keys and the service has full control over the credential lifecycle management. [Customer-managed key](https://docs.microsoft.com/azure/security/fundamentals/encryption-models#server-side-encryption-using-customer-managed-keys-in-azure-key-vault) scenarios are supported within ALZCPS in the [Healthcare](./archetypes/healthcare.md) and [Machine Learning](./docs/archetypes/machinelearning.md) archetypes. See [Key management in Azure](https://docs.microsoft.com/azure/security/fundamentals/key-management) for more details on platform-managed and customer-managed keys.

The following policies related to key management are enabled by default in ALZCPS deployments:
- [Azure Policy - NIST SP 800-53 Rev. 5 SC-12: Cryptographic Key Establishment and Management](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#cryptographic-key-establishment-and-management)
- [Azure Policy - NIST SP 800-53 Rev. 4 SC-17: Public Key Infrastructure Certificates](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#public-key-infrastructure-certificates)

Relevant Links:
- [Government of Canada Considerations for the Use of Cryptography in Commercial Cloud Services: Key Management](https://www.canada.ca/en/government/system/digital-government/digital-government-innovations/cloud-services/government-canada-consideration-use-cryptography-in-cloud.html#toc3)
- [Key management in Azure](https://docs.microsoft.com/azure/security/fundamentals/key-management)
- [Data encryption models](https://docs.microsoft.com/azure/security/fundamentals/encryption-models)
- [About Azure Key Vault](https://docs.microsoft.com/azure/key-vault/general/overview)

---

### 7. Protection of Data-in-Transit

[GC Guardrail Documentation](https://canada-ca.github.io/cloud-guardrails/EN/07_Protect-Data-in-Transit.html)

#### 7.1 Implement an encryption mechanism to protect the confidentiality and integrity of data when data are in transit to and from your solution.

For client applications, this is specific to the application architecture and determined risk profiles. Azure PaaS services can be audited for compliance via Azure Policy. [Azure offers many mechanisms for keeping data private as it moves from one location to another.](https://docs.microsoft.com/azure/security/fundamentals/encryption-overview#encryption-of-data-in-transit).

The following policies related to protection of data in transit are enabled by default in ALZCPS deployments:
- [Azure Policy - NIST SP 800-53 Rev. 5 SC-8: Transmission Confidentiality and Integrity](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#transmission-confidentiality-and-integrity)

Relevant Links:
- [Azure encryption overview](https://docs.microsoft.com/azure/security/fundamentals/encryption-overview)
- [Encryption of data in transit](https://docs.microsoft.com/azure/security/fundamentals/encryption-overview#encryption-of-data-in-transit)
- [Data encryption models](https://docs.microsoft.com/azure/security/fundamentals/encryption-models)
- [Azure data security and encryption best practices](https://docs.microsoft.com/azure/security/fundamentals/data-encryption-best-practices)


#### 7.2 Use CSE-approved cryptographic algorithms and protocols.

Azure provides the ability to use CSE-approved algorithms and protocols. However, _policy enforcement_ is not possible across all use-cases as it is dependant upon the individual application architecture. For example, the [default certificate signing algorithm within Azure AD](https://docs.microsoft.com/azure/active-directory/manage-apps/certificate-signing-options#certificate-signing-algorithms) is SHA-256. However, if an application only supports SHA-1, Azure AD can be manually configured to sign SAML responses using SHA-1 for that application. 

The following policies related to approved cryptographic algorithms are enabled by default in ALZCPS deployments:
- [Azure Policy - NIST SP 800-53 Rev. 4 SC-13: Cryptographic Protection](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#cryptographic-protection-3)
- [Azure Policy - NIST SP 800-53 Rev. 5 SC-28 (1): Cryptographic Protection](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#cryptographic-protection-1)

Relevant Links:
- [Azure encryption overview](https://docs.microsoft.com/azure/security/fundamentals/encryption-overview)

#### 7.3 Encryption of data in transit by default (e.g. TLS v1.2, etc.) for all publicly accessible sites and external communications as per the direction on Implementing HTTPS for Secure Web Connections (ITPIN 2018-01).

TLS 1.2 is set as the minimum TLS version in the following deployed resources:
- AppService
- SQL Database
- Storage

The following policies related to encryption of data in transit for publicly accessible sites and external communications are enabled by default in ALZCPS deployments:
- [Canada Federal PBMM SC8(1): Transmission Confidentiality and Integrity | Cryptographic or Alternate Physical Protection](https://docs.microsoft.com/azure/governance/policy/samples/canada-federal-pbmm#transmission-confidentiality-and-integrity--cryptographic-or-alternate-physical-protection)

Relevant Links:
- [ITPIN 2018-01: Implementing HTTPS for Secure Web Connections](https://www.canada.ca/en/government/system/digital-government/modern-emerging-technologies/policy-implementation-notices/implementing-https-secure-web-connections-itpin.html)
- [Azure encryption overview](https://docs.microsoft.com/azure/security/fundamentals/encryption-overview)
- [Encryption of data in transit](https://docs.microsoft.com/azure/security/fundamentals/encryption-overview#encryption-of-data-in-transit)


#### 7.4 Encryption for all access to cloud services (e.g. Cloud storage, Key Management systems, etc.).

The following policies related to encryption for access to cloud services are enabled by default in ALZCPS deployments:
- [Azure Policy - Canada Federal PBMM SC8(1): Transmission Confidentiality and Integrity | Cryptographic or Alternate Physical Protection](https://docs.microsoft.com/azure/governance/policy/samples/canada-federal-pbmm#transmission-confidentiality-and-integrity--cryptographic-or-alternate-physical-protection)
- [Azure Policy - NIST SP 800-53 Rev. 5 SC-8(1): Cryptographic Protection](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#cryptographic-protection)

Relevant Links:
- [Azure encryption overview](https://docs.microsoft.com/azure/security/fundamentals/encryption-overview)

#### 7.5 Consider encryption for internal zone communication in the cloud based on risk profile and as per the direction in CCCS network security zoning guidance in ITSG-22 and ITSG-38.

For client applications, this is specific to the application architecture and determined risk profiles. Azure PaaS services can be audited for compliance via Azure Policy. [Azure offers many mechanisms for keeping data private as it moves from one location to another.](https://docs.microsoft.com/azure/security/fundamentals/encryption-overview#encryption-of-data-in-transit). 

As an additional layer of protection, [Azure Private Link](https://docs.microsoft.com/azure/private-link/private-link-overview) enables access to Azure PaaS Services (for example, Azure Storage and SQL Database) and Azure hosted customer-owned/partner services over a private endpoint in your virtual network. Azure Private Link is enabled on all supported PaaS services in an ALZCPS deployment.

The following policies related to information flow enforcement are enabled by default in ALZCPS deployments:
- [Azure Policy - NIST SP 800-53 Rev. 5 AC-4: Information Flow Enforcement](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#information-flow-enforcement)
- [Azure Policy - NIST SP 800-53 Rev. 5 SC-28 (1): Cryptographic Protection](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#cryptographic-protection-1)

Relevant Links:
- [ITSG-22: Baseline Security Requirements for Network Security Zones in the Government of Canada](https://www.cyber.gc.ca/sites/default/files/publications/itsg-22-eng.pdf)
- [ITSG-38: Network Security Zoning - Design Considerations for Placement of Services within Zones](https://cyber.gc.ca/en/guidance/network-security-zoning-design-considerations-placement-services-within-zones-itsg-38)
- [What is Azure Private Link?](https://docs.microsoft.com/azure/private-link/private-link-overview)

#### 7.6 Implement key management procedures.

See [Key management in Azure](https://docs.microsoft.com/azure/security/fundamentals/key-management) for details on platform-managed and customer-managed keys.

The following policies related to key management are enabled by default in ALZCPS deployments:
- [Azure Policy - NIST SP 800-53 Rev. 5 SC-12: Cryptographic Key Establishment and Management](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#cryptographic-key-establishment-and-management)
- [Azure Policy - NIST SP 800-53 Rev. 4 SC-17: Public Key Infrastructure Certificates](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#public-key-infrastructure-certificates)

Relevant Links:
- [Government of Canada Considerations for the Use of Cryptography in Commercial Cloud Services: Key Management](https://www.canada.ca/en/government/system/digital-government/digital-government-innovations/cloud-services/government-canada-consideration-use-cryptography-in-cloud.html#toc3)
- [Data encryption models](https://docs.microsoft.com/azure/security/fundamentals/encryption-models)
- [About Azure Key Vault](https://docs.microsoft.com/azure/key-vault/general/overview)

---

### 8. Segment and Separate

[GC Guardrail Documentation](https://canada-ca.github.io/cloud-guardrails/EN/08_Segmentation.html)

#### 8.1 Develop a target network security design that considers segmentation via network security zones, in alignment with ITSG-22 and ITSG-38.

The [ALZCPS network design](./architecture.md#5-network) implements separate hub virtual networks that allow for segmenting management operations. However, it is up to the implementer to determine how these networks should be enhanced to meet their specific security needs.

The following policies related to network security are enabled by default in ALZCPS deployments:
- [Azure Policy - NIST SP 800-53 Rev. 5 AC-4: Information Flow Enforcement](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#information-flow-enforcement)
- [Azure Policy - NIST SP 800-53 Rev. 5 SC-7: Boundary Protection](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#boundary-protection)
- [Azure Policy - NIST SP 800-53 Rev. 4 SC-7 (5): Deny by Default / Allow by Exception](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#deny-by-default--allow-by-exception)

Relevant Links:
- [ITSG-22: Baseline Security Requirements for Network Security Zones in the Government of Canada](https://www.cyber.gc.ca/sites/default/files/publications/itsg-22-eng.pdf)
- [ITSG-38: Network Security Zoning - Design Considerations for Placement of Services within Zones](https://cyber.gc.ca/en/guidance/network-security-zoning-design-considerations-placement-services-within-zones-itsg-38)
 - [Archetype: Hub Networking with Azure Firewall](./archetypes/hubnetwork-azfw.md)
 - [Archetype: Hub Networking with Fortigate Firewalls](./archetypes/hubnetwork-nva-fortigate.md)

#### 8.2 Implement increased levels of protection for management interfaces.

ALZCPS adheres to boundary protection policies for management interfaces. This includes the use of [Azure Private Link](https://docs.microsoft.com/azure/private-link/private-link-overview), routing traffic to a [deployed firewall](./architecture.md#topology), and disabling public network access to sensitive resources.

For custom applications, it is up to the implementer to identify management interfaces which may need increased levels of protection.

The following policies related to protection for management interfaces are enabled by default in ALZCPS deployments:
- [Azure Policy - NIST SP 800-53 Rev. 5 SC-7: Boundary Protection](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#boundary-protection)

---

### 9. Network Security Services

[GC Guardrail Documentation](https://canada-ca.github.io/cloud-guardrails/EN/09_Network-Security-Services.html)

#### 9.1 Ensure that egress/ingress points to and from GC cloud-based environments are managed and monitored. Use centrally provisioned network security services where available.

ALZCPS provides two default firewall configurations:
-  [Azure Firewall](./archetypes/hubnetwork-azfw.md), which is pre-configured with firewall rules, DNS proxy and forced-tunneling mode.
- [Fortigate Network Virtual Appliance (NVA) Firewall](./archetypes/hubnetwork-nva-fortigate.md), which requires additional configuration.

For logging and monitoring, review the [Azure Firewall Archetype Log Analytics Integration documentation](./archetypes/hubnetwork-azfw.md#log-analytics-integration).


The following policies related to boundary protection are enabled by default in ALZCPS deployments:
- [Azure Policy - NIST SP 800-53 Rev. 5 SC-7: Boundary Protection](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#boundary-protection)

Relevant Links:
- [What is Azure Firewall?](https://docs.microsoft.com/azure/firewall/overview)
- [Monitor Azure Firewall logs and metrics](https://docs.microsoft.com/azure/firewall/firewall-diagnostics)
- [Azure Firewall Premium features](https://docs.microsoft.com/azure/firewall/premium-features)
- [Monitor logs using Azure Firewall Workbook](https://docs.microsoft.com/azure/firewall/firewall-workbook)

#### 9.2 Implement network boundary protection mechanisms for all external facing interfaces that enforce a deny-all or allow-by-exception policy.

When using the Azure Firewall Archetype, please review the pre-configured [Azure Firewall Rules](./archetypes/hubnetwork-azfw.md#azure-firewall-rules).

The following policies related to boundary protection are enabled by default in ALZCPS deployments:
- [Azure Policy - NIST SP 800-53 Rev. 5 SC-7: Boundary Protection](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#boundary-protection)

#### 9.3 Perimeter security services such as boundary protection, intrusion prevention services, proxy services, TLS traffic inspection, etc. must be enabled based on risk profile, in alignment with GC Secure Connectivity Requirements and ITSG-22 and ITSG-38.

The required/available security services will depend on the deployed workload, such as the firewall used, and any additional requirements of the workload based on risk profile. When deploying using ALZCPS:

- Microsoft Defender for Cloud is enabled [via a custom policy](../policy/custom/definitions/policyset/DefenderForCloud.bicep) on all supported resources.
- Microsoft Sentinel is enabled, but requires further [configuration and management](https://docs.microsoft.com/azure/sentinel/best-practices).
- Azure Private DNS Zones [are used to enable Private Link](./architecture.md#private-dns-zones) for Azure PaaS services.
- Azure DDoS Standard can optionally be enabled during [hub networking configuration](./onboarding/azure-devops-pipelines.md#step-7---configure-hub-networking).
- [TLS Inspection](https://docs.microsoft.com/azure/firewall/premium-features#tls-inspection) can be enabled on Azure Firewall Premium.

The following policies related to perimeter security services are enabled by default in ALZCPS deployments:
- [Azure Policy - NIST SP 800-53 Rev. 5 SC-5: Denial-of-service Protection](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#denial-of-service-protection)
- [Azure Policy - NIST SP 800-53 Rev. 5 SC-7: Boundary Protection](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#boundary-protection)
- [Azure Policy - NIST SP 800-53 Rev. 5 SI-3: Malicious Code Protection](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#malicious-code-protection)
- [Azure Policy - NIST SP 800-53 Rev. 4 SI-3 (7): Nonsignature-based Detection](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#nonsignature-based-detection)
- [Azure Policy - NIST SP 800-53 Rev. 4 SI-4: System Monitoring](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#system-monitoring)

Relevant Links:
- [ITSG-22: Baseline Security Requirements for Network Security Zones in the Government of Canada](https://www.cyber.gc.ca/sites/default/files/publications/itsg-22-eng.pdf)
- [ITSG-38: Network Security Zoning - Design Considerations for Placement of Services within Zones](https://cyber.gc.ca/en/guidance/network-security-zoning-design-considerations-placement-services-within-zones-itsg-38)
- [What is Microsoft Defender for Cloud?](https://docs.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction)
- [What is Microsoft Sentinel?](https://docs.microsoft.com/azure/sentinel/overview)
- [Azure DDoS Protection Standard overview](https://docs.microsoft.com/azure/ddos-protection/ddos-protection-overview)
- [Azure Firewall Premium features](https://docs.microsoft.com/azure/firewall/premium-features)

#### 9.4 Ensure that access to cloud storage services is protected and restricted to authorized users and services.

For the archetypes provided in ALZCPS, we provide Private Endpoints for storage accounts. Further controls may be required to limit access to specific users and groups as needed.

The following policies related to access to cloud storage services are enabled by default in ALZCPS deployments:
- [Azure Policy - NIST SP 800-53 Rev. 5 AC-4: Information Flow Enforcement](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#information-flow-enforcement)

Relevant Links:
- [Authorize access to data in Azure Storage](https://docs.microsoft.com/azure/storage/common/authorize-data-access)

---

### 10. Cyber Defense Services

[GC Guardrail Documentation](https://canada-ca.github.io/cloud-guardrails/EN/09_Network-Security-Services.html)

#### 10.1 Sign an MOU with CCCS.

This is out of scope.

Relevant Links:
- [CCCS - Contact Us](https://www.cyber.gc.ca/en/contact-us)

#### 10.2 Implement cyber defense services where available.

The required/available cyber defense services will depend on the deployed workload, such as the firewall used, and any additional requirements of the workload based on risk profile. When deploying using ALZCPS:

- Microsoft Defender for Cloud is enabled [via a custom policy](../policy/custom/definitions/policyset/DefenderForCloud.bicep) on all supported resources.
- Microsoft Sentinel is enabled, but requires further [configuration and management](https://docs.microsoft.com/azure/sentinel/best-practices).
- Azure DDoS Standard can optionally be enabled during [hub networking configuration](./onboarding/azure-devops-pipelines.md#step-7---configure-hub-networking).
- [TLS Inspection](https://docs.microsoft.com/azure/firewall/premium-features#tls-inspection) can be enabled on Azure Firewall Premium.

The following policies related to to cyber defense services are enabled by default in ALZCPS deployments:
- [Azure Policy - NIST SP 800-53 Rev. 4 SI-2: Flaw Remediation](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#flaw-remediation)
- [Azure Policy - NIST SP 800-53 Rev. 5 SI-4: System Monitoring](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#system-monitoring)

Relevant Links:
- [What is Microsoft Defender for Cloud?](https://docs.microsoft.com/azure/defender-for-cloud/defender-for-cloud-introduction)
- [What is Microsoft Sentinel?](https://docs.microsoft.com/azure/sentinel/overview)
- [Azure DDoS Protection Standard overview](https://docs.microsoft.com/azure/ddos-protection/ddos-protection-overview)
- [Azure Firewall Premium features](https://docs.microsoft.com/azure/firewall/premium-features)

---

### 11. Logging and Monitoring

[GC Guardrail Documentation](https://canada-ca.github.io/cloud-guardrails/EN/11_Logging-and-Monitoring.html)

#### 11.1 Implement adequate level of logging and reporting, including a security audit log function in all information systems.

In ALZCPS deployments, the default configuration collects logs from VMs and PaaS services into a central Log Analytics Workspace. 

The included Log Analytics Workspace solutions include:
- AgentHealthAssessment
- AntiMalware
- AzureActivity
- ChangeTracking
- Security
- SecurityInsights
- ServiceMap
- SQLAssessment
- Updates
- VMInsights

For VMs, diagnostic logs are collected using the Microsoft Monitoring Agent which is deployed by default via Azure Policy.

For PaaS services, diagnostics settings are turned on.

The following policies related to to logging and reporting are enabled by default in ALZCPS deployments:
- [Azure Policy - NIST SP 800-53 Rev. 4 AU-2: Audit Events](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#audit-events) 
- [Azure Policy - NIST SP 800-53 Rev. 4 AU-3: Audit Events](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#content-of-audit-records)
- [Azure Policy - NIST SP 800-53 Rev. 5 AU-6: Audit Record Review, Analysis, and Reporting](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#audit-record-review-analysis-and-reporting)
- [Azure Policy - NIST SP 800-53 Rev. 4 AU-9: Protection of Audit Information](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#protection-of-audit-information)
- [Azure Policy - NIST SP 800-53 Rev. 4 AU-9 (4): Access by Subset of Privileged Users](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#access-by-subset-of-privileged-users)
- [Azure Policy - NIST SP 800-53 Rev. 5 AU-12: Audit Record Generation](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#audit-record-generation)
- [Azure Policy - NIST SP 800-53 Rev. 5 SI-4: System Monitoring](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#system-monitoring)

Relevant Links:
- [Azure Monitor: Log Analytics workspaces](https://docs.microsoft.com/azure/azure-monitor/logs/data-platform-logs#log-analytics-workspaces)
- [Monitoring solutions in Azure Monitor](https://docs.microsoft.com/azure/azure-monitor/insights/solutions)

#### 11.2 Identify the events within the solution that must be audited in accordance with GC Event Logging.

Review [GC Event Logging](https://www.canada.ca/en/government/system/digital-government/online-security-privacy/event-logging-guidance.html).

#### 11.3 Configure alerts and notifications to be sent to the appropriate contact/team in the organization.

ALZCPS sets up email notifications for the following alerts by default:
- Service Health Alerts
- Subscription Budget Alerts

Further configuration is required to set up appropriate alerts and notifications for any deployment.

Relevant Links:
- [Microsoft Defender for Cloud: Configure email notifications for security alerts](https://docs.microsoft.com/azure/defender-for-cloud/configure-email-notifications)
- [Microsoft Sentinel: Automate incident handling in Microsoft Sentinel with automation rules](https://docs.microsoft.com/azure/sentinel/automate-incident-handling-with-automation-rules)

#### 11.4 Configure or use an authoritative time source for the time-stamp of the audit records generated by your solution components.

Azure PaaS Services and Azure Marketplace Windows VMs use _time.windows.com_ as the default authoritative time source. 

Since early 2021, Azure Marketplace Linux VMs use the _chronyd_ service to synchronize with the host time (_time.windows.com_).

There are two standard time-stamp columns within Azure Monitor logs:
- [TimeGenerated](https://docs.microsoft.com/azure/azure-monitor/logs/log-standard-columns#timegenerated), which contains the date and time that the record was created by the data source.
- [_TimeReceived](https://docs.microsoft.com/azure/azure-monitor/logs/log-standard-columns#_timereceived), which contains the date and time that the record was received by the Azure Monitor ingestion point in the Azure cloud.

The following policies related to to time stamps are enabled by default in ALZCPS deployments:
- [Azure Policy - NIST SP 800-53 Rev. 4 AU-8: Time Stamps](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#time-stamps)

Relevant Links:
- [Time sync for Linux VMs in Azure](https://docs.microsoft.com/azure/virtual-machines/linux/time-sync)
- [Time sync for Windows VMs in Azure](https://docs.microsoft.com/azure/virtual-machines/windows/time-sync)

#### 11.5 Continuously monitor system events and performance.

In ALZCPS deployments, the default configuration collects logs from VMs and PaaS services into a central Log Analytics Workspace. 

The included Log Analytics Workspace solutions include:
- AgentHealthAssessment
- AntiMalware
- AzureActivity
- ChangeTracking
- Security
- SecurityInsights
- ServiceMap
- SQLAssessment
- Updates
- VMInsights

For VMs, diagnostic logs are collected using the Microsoft Monitoring Agent which is deployed by default via Azure Policy.

For PaaS services, diagnostics settings are turned on.

Additionally, Microsoft Defender for Cloud is enabled by default on all supported solutions.

The following policies related to to logging and reporting are enabled by default in ALZCPS deployments:
- [Azure Policy - NIST SP 800-53 Rev. 4 AU-2: Audit Events](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#audit-events) 
- [Azure Policy - NIST SP 800-53 Rev. 4 AU-3: Audit Events](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#content-of-audit-records)
- [Azure Policy - NIST SP 800-53 Rev. 5 AU-6: Audit Record Review, Analysis, and Reporting](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#audit-record-review-analysis-and-reporting)
- [Azure Policy - NIST SP 800-53 Rev. 4 AU-9: Protection of Audit Information](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#protection-of-audit-information)
- [Azure Policy - NIST SP 800-53 Rev. 4 AU-9 (4): Access by Subset of Privileged Users](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4#access-by-subset-of-privileged-users)
- [Azure Policy - NIST SP 800-53 Rev. 5 AU-12: Audit Record Generation](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#audit-record-generation)
- [Azure Policy - NIST SP 800-53 Rev. 5 SI-4: System Monitoring](https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5#system-monitoring)

Relevant Links:
- [Azure Monitor: Log Analytics workspaces](https://docs.microsoft.com/azure/azure-monitor/logs/data-platform-logs#log-analytics-workspaces)
- [Monitoring solutions in Azure Monitor](https://docs.microsoft.com/azure/azure-monitor/insights/solutions)
- [What is Microsoft Defender for Cloud?](https://docs.microsoft.com/azure/defender-for-cloud/defender-for-cloud-introduction)

---

### 12. Configuration of Cloud Marketplaces

[GC Guardrail Documentation](https://canada-ca.github.io/cloud-guardrails/EN/12_Cloud-Marketplace-Config.html)

#### 12.1 Only GC approved cloud marketplace products are to be consumed. Turning on the commercial marketplace is prohibited.

The private marketplace is not enabled by default. Once enabled, only approved public marketplace offerings are allowed.

Relevant Links:
- [Create and manage Private Azure Marketplace collections in the Azure portal](https://docs.microsoft.com/marketplace/create-manage-private-azure-marketplace-new)

#### 12.2 Submit requests to add third-party products to marketplace to SSC Cloud Broker.

This is out of scope.

Relevant Links:
- [GC Cloud Services](https://gc-cloud-services.canada.ca/s)
