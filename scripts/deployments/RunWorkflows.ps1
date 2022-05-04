<#
----------------------------------------------------------------------------------
Copyright (c) Microsoft Corporation.
Licensed under the MIT license.

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
----------------------------------------------------------------------------------
#>
[CmdletBinding()]
Param(
  [string]$EnvironmentName="CanadaESLZ-main",
  [string]$WorkingDirectory=(Resolve-Path "../.."),
  [string]$LoginInteractiveTenantId = $null,
  [string]$LoginServicePrincipalJson = $null,
  [switch]$DeployManagementGroups,
  [switch]$DeployRoles,
  [switch]$DeployLogging,
  [switch]$DeployPolicy,
  [switch]$DeployHubNetworkWithNVA,
  [switch]$DeployHubNetworkWithAzureFirewall,
  [switch]$DeploySubscriptions,
  [array]$SubscriptionIds=@()
)

#Requires -Modules Az, powershell-yaml

# In order to use this End to End script, you must configure ARM template configurations for Logging, Networking and Subscriptions.
# Please follow the instructions on https://github.com/Azure/CanadaPubSecALZ/blob/main/docs/onboarding/azure-devops-pipelines.md
# to setup the configuration files.  Once the configuration files are setup, you can choose to run this script or use Azure DevOps.

. ".\Functions\EnvironmentContext.ps1"
. ".\Functions\ManagementGroups.ps1"
. ".\Functions\Roles.ps1"
. ".\Functions\Logging.ps1"
. ".\Functions\Policy.ps1"
. ".\Functions\HubNetworkWithNVA.ps1"
. ".\Functions\HubNetworkWithAzureFirewall.ps1"
. ".\Functions\Subscriptions.ps1"

# Az Login interactively
if ($LoginInteractiveTenantId) {
  Write-Host "Logging in to Azure interactively..."
  Connect-AzAccount `
    -UseDeviceAuthentication `
    -TenantId $AzureADTenantId
}

# Az Login via Service Principal
if ($LoginServicePrincipalJson) {
  Write-Host "Logging in to Azure using service principal..."
  $ServicePrincipal = $LoginServicePrincipalJson | ConvertFrom-Json
  $Password = ConvertTo-SecureString $ServicePrincipal.password -AsPlainText -Force
  $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ServicePrincipal.appId, $Password
  Connect-AzAccount -ServicePrincipal -TenantId $ServicePrincipal.tenant -Credential $Credential
}

# Set Azure Landing Zones Context
Write-Host "Setting Azure Landing Zones Context..."
$Context = New-EnvironmentContext -Environment $EnvironmentName -WorkingDirectory $WorkingDirectory

# Deploy Management Groups
if ($Features.DeployManagementGroups) {
  Write-Host "Deploying Management Groups..."
  Set-ManagementGroups `
    -Context $Context `
    -ManagementGroupHierarchy $Context.ManagementGroupHierarchy
}

# Deploy Roles
if ($Features.DeployRoles) {
  Write-Host "Deploying Roles..."
  Set-Roles `
    -Context $Context `
    -RolesDirectory $Context.RolesDirectory `
    -ManagementGroupId $Context.TopLevelManagementGroupId
}

# Deploy Logging
if ($Features.DeployLogging) {
  Write-Host "Deploying Logging..."
  Set-Logging `
    -Region $Context.Variables['var-logging-region'] `
    -ManagementGroupId $Context.Variables['var-logging-managementGroupId'] `
    -SubscriptionId $Context.Variables['var-logging-subscriptionId'] `
    -ConfigurationFilePath "$($Context.LoggingDirectory)/$($Context.Variables['var-logging-configurationFileName'])"
}

# Deploy Policy
if ($Features.DeployPolicy) {
  Write-Host "Deploying Policy..."
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

# Deploy Hub Networking with NVA
if ($Features.DeployHubNetworkWithNVA) {
  Write-Host "Deploying Hub Networking with NVA..."
  # Get Logging information using logging config file
  $LoggingConfiguration = Get-LoggingConfiguration `
    -ConfigurationFilePath "$($Context.LoggingDirectory)/$($Context.Variables['var-logging-configurationFileName'])" `
    -SubscriptionId $Context.Variables['var-logging-subscriptionId']

  Set-HubNetwork-With-NVA `
    -Context $Context `
    -Region $Context.Variables['var-hubnetwork-region'] `
    -ManagementGroupId $Context.Variables['var-hubnetwork-managementGroupId'] `
    -SubscriptionId $Context.Variables['var-hubnetwork-subscriptionId'] `
    -ConfigurationFilePath "$($Context.NetworkingDirectory)/$($Context.Variables['var-hubnetwork-nva-configurationFileName'])" `
    -LogAnalyticsWorkspaceResourceId $LoggingConfiguration.LogAnalyticsWorkspaceResourceId
}

# Hub Networking with Azure Firewall
if ($Features.DeployHubNetworkWithAzureFirewall) {
  Write-Host "Deploying Hub Networking with Azure Firewall..."
  # Get Logging information using logging config file
  $LoggingConfiguration = Get-LoggingConfiguration `
    -ConfigurationFilePath "$($Context.LoggingDirectory)/$($Context.Variables['var-logging-configurationFileName'])" `
    -SubscriptionId $Context.Variables['var-logging-subscriptionId']

  # Create Azure Firewall Policy
  Set-AzureFirewallPolicy `
    -Region $Context.Variables['var-hubnetwork-region'] `
    -SubscriptionId $Context.Variables['var-hubnetwork-subscriptionId'] `
    -ConfigurationFilePath "$($Context.NetworkingDirectory)/$($Context.Variables['var-hubnetwork-azfwPolicy-configurationFileName'])"
  
  # Retrieve Azure Firewall Policy
  $AzureFirewallPolicyConfiguration = Get-AzureFirewallPolicy `
    -SubscriptionId $Context.Variables['var-hubnetwork-subscriptionId'] `
    -ConfigurationFilePath "$($Context.NetworkingDirectory)/$($Context.Variables['var-hubnetwork-azfwPolicy-configurationFileName'])"

  # Create Hub Networking with Azure Firewall
  Set-HubNetwork-With-AzureFirewall `
    -Context $Context `
    -Region $Context.Variables['var-hubnetwork-region'] `
    -ManagementGroupId $Context.Variables['var-hubnetwork-managementGroupId'] `
    -SubscriptionId $Context.Variables['var-hubnetwork-subscriptionId'] `
    -ConfigurationFilePath "$($Context.NetworkingDirectory)/$($Context.Variables['var-hubnetwork-azfw-configurationFileName'])" `
    -AzureFirewallPolicyResourceId $AzureFirewallPolicyConfiguration.AzureFirewallPolicyResourceId `
    -LogAnalyticsWorkspaceResourceId $LoggingConfiguration.LogAnalyticsWorkspaceResourceId
}

# Deploy Subscription archetypes
if ($Features.DeploySubscriptions) {
  Write-Host "Deploying Subscriptions..."
  # Get Logging information using logging config file
  $LoggingConfiguration = Get-LoggingConfiguration `
    -ConfigurationFilePath "$($Context.LoggingDirectory)/$($Context.Variables['var-logging-configurationFileName'])" `
    -SubscriptionId $Context.Variables['var-logging-subscriptionId']

  # Deploy archetypes
  # Replace subscription id example below with your subscription ids
  Set-Subscriptions `
    -Context $Context `
    -Region "canadacentral" `
    -SubscriptionIds $("4f9f8765-911a-4a6d-af60-4bc0473268c0") `
    -LogAnalyticsWorkspaceResourceId $LoggingConfiguration.LogAnalyticsWorkspaceResourceId
}