#Requires -Modules powershell-yaml

. ".\Functions\EnvironmentContext.ps1"
. ".\Functions\ManagementGroups.ps1"
. ".\Functions\Roles.ps1"
. ".\Functions\Logging.ps1"
. ".\Functions\Policy.ps1"
. ".\Functions\HubNetworkWithNVA.ps1"
. ".\Functions\HubNetworkWithAzureFirewall.ps1"
. ".\Functions\Subscriptions.ps1"

$EnvironmentName = "CanadaESLZ-main"
$WorkingDirectory = "../.."

# Az Login
# TODO:  Login

# Set Azure Landing Zones Context
$Context = New-EnvironmentContext -Environment $EnvironmentName -WorkingDirectory $WorkingDirectory

# Deploy Management Groups
Set-ManagementGroups `
  -ManagementGroupHierarchy $Context.ManagementGroupHierarchy

# Deploy Roles
Set-Roles `
  -RolesDirectory $Context.RolesDirectory `
  -ManagementGroupId $Context.TopLevelManagementGroupId

# Deploy Logging
Set-Logging `
  -Region $Context.Variables['var-logging-region'] `
  -ManagementGroupId $Context.Variables['var-logging-managementGroupId'] `
  -SubscriptionId $Context.Variables['var-logging-subscriptionId'] `
  -ConfigurationFilePath "$($Context.LoggingDirectory)/$($Context.Variables['var-logging-configurationFileName'])"

# Get Logging Configuration using logging configuration file & Azure environment
$LoggingConfiguration = Get-LoggingConfiguration `
  -ConfigurationFilePath "$($Context.LoggingDirectory)/$($Context.Variables['var-logging-configurationFileName'])" `
  -SubscriptionId $Context.Variables['var-logging-subscriptionId']

# Deploy Policies

## Custom Policy Definitions
Set-Policy-Definitions `
  -PolicyDefinitionsDirectory $Context.PolicyCustomDefinitionDirectory `
  -ManagementGroupId $Context.TopLevelManagementGroupId

## Custom Policy Set Definitions
Set-PolicySet-Defintions `
  -PolicySetDefinitionsDirectory $Context.PolicySetCustomDefinitionDirectory `
  -ManagementGroupId $Context.TopLevelManagementGroupId `
  -PolicySetDefinitionNames $('AKS', 'DefenderForCloud', 'LogAnalytics', 'Network', 'DNSPrivateEndpoints', 'Tags')

## Built In Policy Set Assignments
Set-PolicySet-Assignments `
  -PolicySetAssignmentsDirectory $Context.PolicySetBuiltInAssignmentsDirectory `
  -PolicySetAssignmentManagementGroupId $Context.TopLevelManagementGroupId `
  -PolicySetAssignmentNames $('asb', 'nist80053r4', 'nist80053r5', 'pbmm', 'cis-msft-130', 'fedramp-moderate', 'hitrust-hipaa', 'location') `
  -LogAnalyticsWorkspaceResourceId $LoggingConfiguration.LogAnalyticsWorkspaceResourceId `
  -LogAnalyticsWorkspaceId $LoggingConfiguration.LogAnalyticsWorkspaceId `
  -LogAnalyticsWorkspaceRetentionInDays $LoggingConfiguration.LogRetentionInDays

#Custom Policy Sets Assignments
Set-PolicySet-Assignments `
  -PolicySetAssignmentsDirectory $Context.PolicySetCustomAssignmentsDirectory `
  -PolicySetAssignmentManagementGroupId $Context.TopLevelManagementGroupId `
  -PolicySetAssignmentNames $('AKS', 'DefenderForCloud', 'LogAnalytics', 'Network', 'Tags') `
  -LogAnalyticsWorkspaceResourceId $LoggingConfiguration.LogAnalyticsWorkspaceResourceId `
  -LogAnalyticsWorkspaceId $LoggingConfiguration.LogAnalyticsWorkspaceId `
  -LogAnalyticsWorkspaceRetentionInDays $LoggingConfiguration.LogRetentionInDays

# Hub Networking with NVA
Set-HubNetwork-With-NVA `
  -Region $Context.Variables['var-hubnetwork-region'] `
  -ManagementGroupId $Context.Variables['var-hubnetwork-managementGroupId'] `
  -SubscriptionId $Context.Variables['var-hubnetwork-subscriptionId'] `
  -ConfigurationFilePath "$($Context.NetworkingDirectory)/$($Context.Variables['var-hubnetwork-nva-configurationFileName'])" `
  -LogAnalyticsWorkspaceResourceId $LoggingConfiguration.LogAnalyticsWorkspaceResourceId

# Hub Networking with Azure Firewall
Set-AzureFirewallPolicy `
  -Region $Context.Variables['var-hubnetwork-region'] `
  -SubscriptionId $Context.Variables['var-hubnetwork-subscriptionId'] `
  -ConfigurationFilePath "$($Context.NetworkingDirectory)/$($Context.Variables['var-hubnetwork-azfwPolicy-configurationFileName'])"

# Retrieve Azure Firewall Configuration
$AzureFirewallConfiguration = Get-AzureFirewallPolicy `
  -SubscriptionId $Context.Variables['var-hubnetwork-subscriptionId'] `
  -ConfigurationFilePath "$($Context.NetworkingDirectory)/$($Context.Variables['var-hubnetwork-azfwPolicy-configurationFileName'])"

Set-HubNetwork-With-AzureFirewall `
  -Region $Context.Variables['var-hubnetwork-region'] `
  -ManagementGroupId $Context.Variables['var-hubnetwork-managementGroupId'] `
  -SubscriptionId $Context.Variables['var-hubnetwork-subscriptionId'] `
  -ConfigurationFilePath "$($Context.NetworkingDirectory)/$($Context.Variables['var-hubnetwork-azfw-configurationFileName'])" `
  -AzureFirewallPolicyResourceId $AzureFirewallConfiguration.AzureFirewallPolicyResourceId `
  -LogAnalyticsWorkspaceResourceId $LoggingConfiguration.LogAnalyticsWorkspaceResourceId

# Subscriptions
Set-Subscriptions `
  -Region "canadacentral" `
  -SubscriptionIds $("4f9", "ec6") `
  -LogAnalyticsWorkspaceResourceId $LoggingConfiguration.LogAnalyticsWorkspaceResourceId