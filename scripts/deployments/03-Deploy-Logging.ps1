#Requires -Modules powershell-yaml

. ".\functions\Set-EnvironmentContext.ps1"

# Working Directory
$WorkingDirectory = "../.."

# Set Context
Set-EnvironmentContext -Environment "CanadaESLZ-main" -WorkingDirectory $WorkingDirectory

# Deployment
$DeploymentRegion = $global:EnvironmentConfiguration.variables['var-logging-region']
$DeploymentManagementGroup = $global:EnvironmentConfiguration.variables['var-logging-managementGroupId']
$DeploymentSubscription = $global:EnvironmentConfiguration.variables['var-logging-subscriptionId']
$DeploymentConfigurationFileName = $global:EnvironmentConfiguration.variables['var-logging-configurationFileName']

Write-Output "Moving Subscription ($DeploymentSubscription) to Management Group ($DeploymentManagementGroup)"
# TODO: Add Azure PS deployment command

Write-Output "Deploying $global:LoggingDirectory/$DeploymentConfigurationFileName to $DeploymentSubscription in $DeploymentRegion"
# TODO: Add Azure PS deployment command