Import-Module powershell-yaml

# Configuration
$WorkingDirectory = "../../"
$Environment = "CanadaESLZ-main"

$LoggingDirectory = "$WorkingDirectory/config/logging/$Environment/"
$NetworkingDirectory = "$WorkingDirectory/config/networking/$Environment/"

$EnvironmentConfigurationYamlFilePath = "$WorkingDirectory/config/variables/$Environment.yml"

# Deployment
$EnvironmentConfiguration = Get-Content $EnvironmentConfigurationYamlFilePath  | ConvertFrom-Yaml

$DeploymentRegion = $EnvironmentConfiguration.variables['var-hubnetwork-region']
$DeploymentManagementGroup = $EnvironmentConfiguration.variables['var-hubnetwork-managementGroupId']
$DeploymentSubscription = $EnvironmentConfiguration.variables['var-hubnetwork-subscriptionId']
$DeploymentConfigurationFileName = $EnvironmentConfiguration.variables['var-hubnetwork-nva-configurationFileName']

$LoggingSubscription = $EnvironmentConfiguration.variables['var-logging-subscriptionId']
$LoggingConfigurationFileName = $EnvironmentConfiguration.variables['var-logging-configurationFileName']
$LoggingConfigurationFilePath = "$LoggingDirectory/$LoggingConfigurationFileName"

# TODO: Load logging configuration

# TODO: Load networking configuration and check if Log Analytics Workspace Id is provided.  Otherwise set it.

Write-Output "Moving Subscription ($DeploymentSubscription) to Management Group ($DeploymentManagementGroup)"
# TODO: Add Azure PS deployment command

Write-Output "Deploying $NetworkingDirectory/$DeploymentConfigurationFileName to $DeploymentSubscription in $DeploymentRegion"
# TODO: Add Azure PS deployment command