#Requires -Modules powershell-yaml

. ".\functions\Set-EnvironmentContext.ps1"

# Working Directory
$WorkingDirectory = "../.."

# Set Context
Set-EnvironmentContext -Environment "CanadaESLZ-main" -WorkingDirectory $WorkingDirectory

# Deployment
$DeploymentRegion = $global:EnvironmentConfiguration.variables['var-hubnetwork-region']
$DeploymentManagementGroup = $global:EnvironmentConfiguration.variables['var-hubnetwork-managementGroupId']
$DeploymentSubscription = $global:EnvironmentConfiguration.variables['var-hubnetwork-subscriptionId']
$DeploymentConfigurationFileName = $global:EnvironmentConfiguration.variables['var-hubnetwork-nva-configurationFileName']

$LoggingSubscription = $global:EnvironmentConfiguration.variables['var-logging-subscriptionId']
$LoggingConfigurationFileName = $global:EnvironmentConfiguration.variables['var-logging-configurationFileName']
$LoggingConfigurationFilePath = "$global:LoggingDirectory/$LoggingConfigurationFileName"

# TODO: Load logging configuration

# TODO: Load networking configuration and check if Log Analytics Workspace Id is provided.  Otherwise set it.

Write-Output "Moving Subscription ($DeploymentSubscription) to Management Group ($DeploymentManagementGroup)"
# TODO: Add Azure PS deployment command

Write-Output "Deploying $global:NetworkingDirectory/$DeploymentConfigurationFileName to $DeploymentSubscription in $DeploymentRegion"
# TODO: Add Azure PS deployment command

# TODO:  Check if Private DNS Zones are managed in the Hub.  If so, enable Private DNS Zones policy assignment

# TODO:  Check if DDOS Standard is deployed in the Hub.  If so, enable DDOS Standard policy assignment