<#
----------------------------------------------------------------------------------
Copyright (c) Microsoft Corporation.
Licensed under the MIT license.

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
----------------------------------------------------------------------------------
#>

<#
  .SYNOPSIS
    Runs CanadaPubSecALZ workflows.

  .DESCRIPTION
    This script is used to run one or more workflows for management groups, roles,
    logging, policies, networking, and subscriptions.

  .PARAMETER DeployManagementGroups
    If true, run the management group workflow.

  .PARAMETER DeployRoles
    If true, run the role workflow.

  .PARAMETER DeployLogging
    If true, run the logging workflow.

  .PARAMETER DeployPolicy
    If true, run the policy workflow.

  .PARAMETER DeployHubNetworkWithAzureFirewall
    If true, run the Azure Firewall hub network workflow.

  .PARAMETER DeployHubNetworkWithNVA
    If true, run the NVA hub network workflow.

  .PARAMETER DeploySubscriptionIds
    Comma separated list of subscription ids to run the subscription workflow against.

  .PARAMETER EnvironmentName
    The name of the environment to run the workflow against.
    Used primarily for running interactively.

  .PARAMETER GitHubRepo
    The GitHub repo to use for the workflow.

  .PARAMETER GitHubRef
    The GitHub ref to use for the workflow.

  .PARAMETER LoginInteractiveTenantId
    If set, prompt for credentials and login to the specified tenant.

  .PARAMETER LoginServicePrincipalJson
    If set, login using the JSON credentials for the specified service principal.

  .PARAMETER WorkingDirectory
    The directory to use for the workflow.

  .PARAMETER NvaUsername
    The firewall username to use for the Hub network with NVA workflow.

  .PARAMETER NvaPassword
    The firewall password to use for the Hub Network with NVA workflow.

  .EXAMPLE
    PS> .\RunWorkflows.ps1 -EnvironmentName CanadaESLZ-main -LoginInteractiveTenantId '8188040d-6c67-4c5c-b112-36a304b66dad' -DeployManagementGroups

    Deploy management groups interactively.

  .EXAMPLE
    PS> .\RunWorkflows.ps1 -EnvironmentName CanadaESLZ-main -LoginInteractiveTenantId '8188040d-6c67-4c5c-b112-36a304b66dad' -DeployManagementGroups -DeployRoles -DeployLogging -DeployPolicies -DeployHubNetworkWithAzureFirewall

    Deploy all platform components interactively, with Azure Firewall.

  .EXAMPLE
    PS> .\RunWorkflows.ps1 -EnvironmentName CanadaESLZ-main -LoginInteractiveTenantId '8188040d-6c67-4c5c-b112-36a304b66dad' -DeploySubscriptionIds 'a188040e-6c67-4c5c-b112-36a304b66dad,7188030d-6c67-4c5c-b112-36a304b66dac'

    Deploy 2 subscriptions interactively.

  .EXAMPLE
    PS> .\RunWorkflows.ps1 -GitHubRepo 'Azure/CanadaPubSecALZ' -GitHubRef 'refs/head/main' -LoginServicePrincipalJson '<output from: az ad sp create-for-rbac>' -DeployManagementGroups

    Deploy management groups using service principal authentication.

    The action in the GitHub workflow could look like this:

    - name: Deploy Management Groups
      run: |
        ./RunWorkflows.ps1 `
          -DeployManagementGroups `
          -LoginServicePrincipalJson '${{secrets.ALZ_CREDENTIALS}}' `
          -GitHubRepo ${env:GITHUB_REPOSITORY} `
          -GitHubRef ${env:GITHUB_REF}
#>

[CmdletBinding()]
Param(
  # What to deploy
  [switch]$DeployManagementGroups,
  [switch]$DeployRoles,
  [switch]$DeployLogging,
  [switch]$DeployPolicy,
  [switch]$DeployHubNetworkWithNVA,
  [switch]$DeployHubNetworkWithAzureFirewall,
  [string[]]$DeploySubscriptionIds=@(),

  # How to deploy
  [string]$EnvironmentName="CanadaESLZ-main",
  [string]$GitHubRepo=$null,
  [string]$GitHubRef=$null,
  [string]$LoginInteractiveTenantId=$null,
  [string]$LoginServicePrincipalJson=$null,
  [string]$WorkingDirectory=(Resolve-Path "../.."),
  [string]$NvaUsername=$null,
  [string]$NvaPassword=$null
)

#Requires -Modules Az, powershell-yaml

$ErrorActionPreference = "Stop"

# In order to use this End to End script, you must configure ARM template configurations for Logging, Networking and Subscriptions.
# Please follow the instructions on https://github.com/Azure/CanadaPubSecALZ/blob/main/docs/onboarding/azure-devops-pipelines.md
# to setup the configuration files.  Once the configuration files are setup, you can choose to run this script or use Azure DevOps.

# Construct environment name from GitHub repo and ref (result: <repo>-<branch>)
if ((-not [string]::IsNullOrEmpty($GitHubRepo)) -and (-not [string]::IsNullOrEmpty($GitHubRef))) {
  $EnvironmentName = `
    $GitHubRepo.Split('/')[1] + '-' + `
    $GitHubRef.Split('/')[$GitHubRef.Split('/').Count-1]
  Write-Host "Environment name: $EnvironmentName"
}

# Construct environment name from Azure DevOps (result: <repo>-<branch>)
<#
  TO BE IMPLEMENTED
#>

# Load functions
Write-Host "Loading functions..."
. ".\Functions\EnvironmentContext.ps1"
. ".\Functions\ManagementGroups.ps1"
. ".\Functions\Roles.ps1"
. ".\Functions\Logging.ps1"
. ".\Functions\Policy.ps1"
. ".\Functions\HubNetworkWithNVA.ps1"
. ".\Functions\HubNetworkWithAzureFirewall.ps1"
. ".\Functions\Subscriptions.ps1"

# Az Login interactively
if (-not [string]::IsNullOrEmpty($LoginInteractiveTenantId)) {
  Write-Host "Logging in to Azure interactively..."
  Connect-AzAccount `
    -UseDeviceAuthentication `
    -TenantId $LoginInteractiveTenantId
}

# Az Login via Service Principal
if (-not [string]::IsNullOrEmpty($LoginServicePrincipalJson)) {
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
if ($DeployManagementGroups) {
  Write-Host "Deploying Management Groups..."
  Set-ManagementGroups `
    -Context $Context `
    -ManagementGroupHierarchy $Context.ManagementGroupHierarchy
}

# Deploy Roles
if ($DeployRoles) {
  Write-Host "Deploying Roles..."
  Set-Roles `
    -Context $Context `
    -RolesDirectory $Context.RolesDirectory `
    -ManagementGroupId $Context.TopLevelManagementGroupId
}

# Deploy Logging
if ($DeployLogging) {
  Write-Host "Deploying Logging..."
  Set-Logging `
    -Context $Context `
    -Region $Context.Variables['var-logging-region'] `
    -ManagementGroupId $Context.Variables['var-logging-managementGroupId'] `
    -SubscriptionId $Context.Variables['var-logging-subscriptionId'] `
    -ConfigurationFilePath "$($Context.LoggingDirectory)/$($Context.Variables['var-logging-configurationFileName'])"
}

# Deploy Policy
if ($DeployPolicy) {
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
if ($DeployHubNetworkWithNVA) {
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
    -LogAnalyticsWorkspaceResourceId $LoggingConfiguration.LogAnalyticsWorkspaceResourceId `
    -NvaUsername $NvaUsername `
    -NvaPassword $NvaPassword
}

# Hub Networking with Azure Firewall
if ($DeployHubNetworkWithAzureFirewall) {
  Write-Host "Deploying Hub Networking with Azure Firewall..."
  # Get Logging information using logging config file
  $LoggingConfiguration = Get-LoggingConfiguration `
    -ConfigurationFilePath "$($Context.LoggingDirectory)/$($Context.Variables['var-logging-configurationFileName'])" `
    -SubscriptionId $Context.Variables['var-logging-subscriptionId']

  # Create Azure Firewall Policy
  Set-AzureFirewallPolicy `
    -Context $Context `
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
if ($DeploySubscriptionIds.Count -gt 0) {
  Write-Host "Deploying Subscriptions..."
  # Get Logging information using logging config file
  $LoggingConfiguration = Get-LoggingConfiguration `
    -ConfigurationFilePath "$($Context.LoggingDirectory)/$($Context.Variables['var-logging-configurationFileName'])" `
    -SubscriptionId $Context.Variables['var-logging-subscriptionId']

  # Deploy archetypes
  # Replace subscription id example below with your subscription ids
  Set-Subscriptions `
    -Context $Context `
    -Region $Context.DeploymentRegion `
    -SubscriptionIds $DeploySubscriptionIds `
    -LogAnalyticsWorkspaceResourceId $LoggingConfiguration.LogAnalyticsWorkspaceResourceId
}