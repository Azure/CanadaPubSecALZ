Import-Module powershell-yaml

# Configuration
$WorkingDirectory = "../../"
$LoggingDirectory = "$WorkingDirectory/config/logging"
$Environment = "CanadaESLZ-main"
$EnvironmentConfigurationYamlFilePath = "$WorkingDirectory/config/variables/$Environment.yml"

# Deployment
$EnvironmentConfiguration = Get-Content $EnvironmentConfigurationYamlFilePath  | ConvertFrom-Yaml

$DeploymentRegion = $EnvironmentConfiguration.variables['var-logging-region']
$DeploymentManagementGroup = $EnvironmentConfiguration.variables['var-logging-managementGroupId']
$DeploymentSubscription = $EnvironmentConfiguration.variables['var-logging-subscriptionId']
$DeploymentConfigurationFileName = $EnvironmentConfiguration.variables['var-logging-configurationFileName']

Write-Output "Moving Subscription ($DeploymentSubscription) to Management Group ($DeploymentManagementGroup)"
# TODO: Add Azure PS deployment command

Write-Output "Deploying $LoggingDirectory/$DeploymentConfigurationFileName to $DeploymentSubscription in $DeploymentRegion"
# TODO: Add Azure PS deployment command