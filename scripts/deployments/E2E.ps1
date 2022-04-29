#Requires -Modules Az, powershell-yaml

. ".\Functions\EnvironmentContext.ps1"
. ".\Functions\ManagementGroups.ps1"
. ".\Functions\Roles.ps1"
. ".\Functions\Logging.ps1"
. ".\Functions\Policy.ps1"
. ".\Functions\HubNetworkWithNVA.ps1"
. ".\Functions\HubNetworkWithAzureFirewall.ps1"
. ".\Functions\Subscriptions.ps1"

$EnvironmentName = "CanadaESLZ-main"
$WorkingDirectory = Resolve-Path "../.."

# Replace the Tenant ID with the GUID for your Azure Active Directory instance.
# It can be found through https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Overview
$AzureADTenantId = "343ddfdb-bef5-46d9-99cf-ed67d5948783"

$Features = @{
  PromptForLogin = $false
  DeployManagementGroups = $false
  DeployRoles = $false
  DeployLogging = $false
  DeployPolicy = $false
}

Write-Output "Features configured for deployment:"
$Features

# Az Login
if ($Features.PromptForLogin) {
  Connect-AzAccount `
    -UseDeviceAuthentication `
    -TenantId $AzureADTenantId
}

# Set Azure Landing Zones Context
$Context = New-EnvironmentContext -Environment $EnvironmentName -WorkingDirectory $WorkingDirectory

# Deploy Management Groups
if ($Features.DeployManagementGroups) {
  Set-ManagementGroups `
    -Context $Context `
    -ManagementGroupHierarchy $Context.ManagementGroupHierarchy
}

# Deploy Roles
if ($Features.DeployRoles) {
  Set-Roles `
    -Context $Context `
    -RolesDirectory $Context.RolesDirectory `
    -ManagementGroupId $Context.TopLevelManagementGroupId
}

# Deploy Logging
if ($Features.DeployLogging) {
  Set-Logging `
    -Region $Context.Variables['var-logging-region'] `
    -ManagementGroupId $Context.Variables['var-logging-managementGroupId'] `
    -SubscriptionId $Context.Variables['var-logging-subscriptionId'] `
    -ConfigurationFilePath "$($Context.LoggingDirectory)/$($Context.Variables['var-logging-configurationFileName'])"
}

if ($Features.DeployPolicy) {
  # Get Logging information using logging config file
  $LoggingConfiguration = Get-LoggingConfiguration `
    -ConfigurationFilePath "$($Context.LoggingDirectory)/$($Context.Variables['var-logging-configurationFileName'])" `
    -SubscriptionId $Context.Variables['var-logging-subscriptionId']

  # Custom Policy Definitions
  Set-Policy-Definitions `
    -PolicyDefinitionsDirectory $Context.PolicyCustomDefinitionDirectory `
    -ManagementGroupId $Context.TopLevelManagementGroupId

  # Custom Policy Set Definitions
  Set-PolicySet-Defintions `
    -Context $Context `
    -PolicySetDefinitionsDirectory $Context.PolicySetCustomDefinitionDirectory `
    -ManagementGroupId $Context.TopLevelManagementGroupId `
    -PolicySetDefinitionNames $('AKS', 'DefenderForCloud', 'LogAnalytics', 'Network', 'DNSPrivateEndpoints', 'Tags')

  # Built In Policy Set Assignments
  Set-PolicySet-Assignments `
    -Context $Context `
    -PolicySetAssignmentsDirectory $Context.PolicySetBuiltInAssignmentsDirectory `
    -PolicySetAssignmentManagementGroupId $Context.TopLevelManagementGroupId `
    -PolicySetAssignmentNames $('asb', 'nist80053r4', 'nist80053r5', 'pbmm', 'cis-msft-130', 'fedramp-moderate', 'hitrust-hipaa', 'location') `
    -LogAnalyticsWorkspaceResourceGroupName $LoggingConfiguration.ResourceGroupName `
    -LogAnalyticsWorkspaceResourceId $LoggingConfiguration.LogAnalyticsWorkspaceResourceId `
    -LogAnalyticsWorkspaceId $LoggingConfiguration.LogAnalyticsWorkspaceId `
    -LogAnalyticsWorkspaceRetentionInDays $LoggingConfiguration.LogRetentionInDays

  # Custom Policy Sets Assignments
  Set-PolicySet-Assignments `
    -Context $Context `
    -PolicySetAssignmentsDirectory $Context.PolicySetCustomAssignmentsDirectory `
    -PolicySetAssignmentManagementGroupId $Context.TopLevelManagementGroupId `
    -PolicySetAssignmentNames $('AKS', 'DefenderForCloud', 'LogAnalytics', 'Network', 'Tags') `
    -LogAnalyticsWorkspaceResourceGroupName $LoggingConfiguration.ResourceGroupName `
    -LogAnalyticsWorkspaceResourceId $LoggingConfiguration.LogAnalyticsWorkspaceResourceId `
    -LogAnalyticsWorkspaceId $LoggingConfiguration.LogAnalyticsWorkspaceId `
    -LogAnalyticsWorkspaceRetentionInDays $LoggingConfiguration.LogRetentionInDays
}

<#



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

#>