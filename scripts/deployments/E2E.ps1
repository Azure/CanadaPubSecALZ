#Requires -Modules powershell-yaml

. ".\functions\SetEnvironmentContext.ps1"
. ".\functions\ManagementGroups.ps1"
. ".\functions\Roles.ps1"
. ".\functions\Logging.ps1"
. ".\functions\Policy.ps1"
. ".\functions\HubNetworkWithNVA.ps1"
. ".\functions\HubNetworkWithAzureFirewall.ps1"
. ".\functions\Subscriptions.ps1"

$Environment = "CanadaESLZ-main"
$WorkingDirectory = "../.."

$RolesDirectory = "$WorkingDirectory/roles"
$PolicyDirectory = "$WorkingDirectory/policy"

# Az Login
# TODO:  Login

# Set Context
Set-EnvironmentContext -Environment $Environment -WorkingDirectory $WorkingDirectory

# Deploy Management Groups
Deploy-ManagementGroups `
  -ManagementGroupHierarchy $global:ManagementGroupHierarchy

# Deploy Roles
Deploy-Roles `
  -RolesDirectory $RolesDirectory `
  -ManagementGroupId $global:TopLevelManagementGroupId

# Deploy Logging
Deploy-Logging `
  -Region $global:EnvironmentConfiguration.variables['var-logging-region'] `
  -ManagementGroupId $global:EnvironmentConfiguration.variables['var-logging-managementGroupId'] `
  -SubscriptionId $global:EnvironmentConfiguration.variables['var-logging-subscriptionId'] `
  -ConfigurationFilePath "$global:LoggingDirectory/$($global:EnvironmentConfiguration.variables['var-logging-configurationFileName'])"

# Deploy Policies
$LoggingSubscription = $global:EnvironmentConfiguration.variables['var-logging-subscriptionId']
$LoggingConfigurationFileName = "$global:LoggingDirectory/$global:EnvironmentConfiguration.variables['var-logging-configurationFileName']"

#Custom Policy Definitions
Deploy-Policy-Definitions `
  -PolicyDefinitionsDirectory "$PolicyDirectory/custom/definitions/policy" `
  -ManagementGroupId $global:TopLevelManagementGroupId

#Custom Policy Set Definitions
Deploy-PolicySet-Defintions `
  -PolicySetDefinitionsDirectory "$PolicyDirectory/custom/definitions/policyset" `
  -ManagementGroupId $global:TopLevelManagementGroupId `
  -PolicySetDefinitionNames $('AKS', 'DefenderForCloud', 'LogAnalytics', 'Network', 'DNSPrivateEndpoints', 'Tags')

#Built In Policy Set Assignments
$BuiltInPolicySetAssignmentScopes = $(
  [PSCustomObject]@{
    ManagementGroupId = $global:TopLevelManagementGroupId
    Policies = $(
      'asb',
      'nist80053r4',
      'nist80053r5',
      'pbmm',
      'cis-msft-130',
      'fedramp-moderate',
      'hitrust-hipaa',
      'location'
    )
    LogAnalyticsWorkspaceResourceId = "TODO:  SET Dynamically"
    LogAnalyticsWorkspaceId = "TODO:  SET Dynamically"
    LogAnalyticsWorkspaceRetentionInDays = "TODO:  SET Dynamically"
  }
)

Deploy-PolicySet-Assignments `
  -PolicySetAssignmentsDirectory "$PolicyDirectory/builtin/assignments" `
  -AssignmentScopes $BuiltInPolicySetAssignmentScopes

#Custom Policy Sets Assignments
$CustomPolicySetAssignmentScopes = $(
  [PSCustomObject]@{
    ManagementGroupId = $global:TopLevelManagementGroupId
    Policies = $(
      'AKS',
      'DefenderForCloud',
      'LogAnalytics',
      'Network',
      'Tags'
    )
    LogAnalyticsWorkspaceId = "TODO:  SET Dynamically"
    LogAnalyticsWorkspaceRetentionInDays = "TODO:  SET Dynamically"
  }
)

Deploy-PolicySet-Assignments `
  -PolicySetAssignmentsDirectory "$PolicyDirectory/custom/assignments/policyset" `
  -AssignmentScopes $CustomPolicySetAssignmentScopes

# Hub Networking with NVA
Deploy-HubNetwork-With-NVA `
  -Region $global:EnvironmentConfiguration.variables['var-hubnetwork-region'] `
  -ManagementGroupId $global:EnvironmentConfiguration.variables['var-hubnetwork-managementGroupId'] `
  -SubscriptionId $global:EnvironmentConfiguration.variables['var-hubnetwork-subscriptionId'] `
  -ConfigurationFilePath "$global:NetworkingDirectory/$($global:EnvironmentConfiguration.variables['var-hubnetwork-nva-configurationFileName'])" `
  -LogAnalyticsWorkspaceResourceId "TODO:  SET Dynamically"


# Hub Networking with Azure Firewall
Deploy-AzureFirewall-Policy `
  -Region $global:EnvironmentConfiguration.variables['var-hubnetwork-region'] `
  -SubscriptionId $global:EnvironmentConfiguration.variables['var-hubnetwork-subscriptionId'] `
  -ConfigurationFilePath "$global:NetworkingDirectory/$($global:EnvironmentConfiguration.variables['var-hubnetwork-azfwPolicy-configurationFileName'])"

Deploy-HubNetwork-With-AzureFirewall `
  -Region $global:EnvironmentConfiguration.variables['var-hubnetwork-region'] `
  -ManagementGroupId $global:EnvironmentConfiguration.variables['var-hubnetwork-managementGroupId'] `
  -SubscriptionId $global:EnvironmentConfiguration.variables['var-hubnetwork-subscriptionId'] `
  -ConfigurationFilePath "$global:NetworkingDirectory/$($global:EnvironmentConfiguration.variables['var-hubnetwork-azfw-configurationFileName'])" `
  -AzureFirewallPolicyResourceId "TODO:  SET Dynamically" `
  -LogAnalyticsWorkspaceResourceId "TODO:  SET Dynamically"

# Subscriptions
Deploy-Subscriptions `
  -Region "canadacentral" `
  -SubscriptionIds $("4f9", "ec6") `
  -LogAnalyticsWorkspaceResourceId "TODO:  SET Dynamically"
