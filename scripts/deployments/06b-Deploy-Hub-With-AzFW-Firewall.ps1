. ".\helpers\Set-EnvironmentContext.ps1"

# Working Directory
$WorkingDirectory = "../.."

# Set Context
Set-EnvironmentContext -Environment "CanadaESLZ-main" -WorkingDirectory $WorkingDirectory

$LoggingSubscription = $global:EnvironmentConfiguration.variables['var-logging-subscriptionId']
$LoggingConfigurationFileName = $global:EnvironmentConfiguration.variables['var-logging-configurationFileName']
$LoggingConfigurationFilePath = "$global:LoggingDirectory/$LoggingConfigurationFileName"

$DeploymentRegion = $global:EnvironmentConfiguration.variables['var-hubnetwork-region']
$DeploymentManagementGroup = $global:EnvironmentConfiguration.variables['var-hubnetwork-managementGroupId']
$DeploymentSubscription = $global:EnvironmentConfiguration.variables['var-hubnetwork-subscriptionId']
$DeploymentConfigurationFileName = $global:EnvironmentConfiguration.variables['var-hubnetwork-azfw-configurationFileName']
$FirewallPolicyConfigurationFileName = $global:EnvironmentConfiguration.variables['var-hubnetwork-azfwPolicy-configurationFileName']

# Deployment

# TODO: Load logging configuration

# TODO: Load networking configuration and check if Log Analytics Workspace Id is provided.  Otherwise set it.

# TODO: Load networking configuration and check if Firewall Policy is provided.  Otherwise set it.

Write-Output "Moving Subscription ($DeploymentSubscription) to Management Group ($DeploymentManagementGroup)"
# TODO: Add Azure PS deployment command

Write-Output "Deploying $global:NetworkingDirectory/$DeploymentConfigurationFileName to $DeploymentSubscription in $DeploymentRegion"
# TODO: Add Azure PS deployment command