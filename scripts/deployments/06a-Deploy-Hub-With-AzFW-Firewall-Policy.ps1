#Requires -Modules powershell-yaml

. ".\functions\Set-EnvironmentContext.ps1"

# Working Directory
$WorkingDirectory = "../.."

# Set Context
Set-EnvironmentContext -Environment "CanadaESLZ-main" -WorkingDirectory $WorkingDirectory

# Deployment
$DeploymentRegion = $global:EnvironmentConfiguration.variables['var-hubnetwork-region']
$DeploymentSubscription = $global:EnvironmentConfiguration.variables['var-hubnetwork-subscriptionId']
$DeploymentConfigurationFileName = $global:EnvironmentConfiguration.variables['var-hubnetwork-azfwPolicy-configurationFileName']

Write-Output "Deploying $global:NetworkingDirectory/$DeploymentConfigurationFileName to $DeploymentSubscription in $DeploymentRegion"
# TODO: Add Azure PS deployment command