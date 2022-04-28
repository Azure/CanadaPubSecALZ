Import-Module powershell-yaml

# Configuration
$WorkingDirectory = "../../"
$Environment = "CanadaESLZ-main"

$NetworkingDirectory = "$WorkingDirectory/config/networking/$Environment/"

$EnvironmentConfigurationYamlFilePath = "$WorkingDirectory/config/variables/$Environment.yml"

# Deployment
$EnvironmentConfiguration = Get-Content $EnvironmentConfigurationYamlFilePath  | ConvertFrom-Yaml

$DeploymentRegion = $EnvironmentConfiguration.variables['var-hubnetwork-region']
$DeploymentSubscription = $EnvironmentConfiguration.variables['var-hubnetwork-subscriptionId']
$DeploymentConfigurationFileName = $EnvironmentConfiguration.variables['var-hubnetwork-azfwPolicy-configurationFileName']

Write-Output "Deploying $NetworkingDirectory/$DeploymentConfigurationFileName to $DeploymentSubscription in $DeploymentRegion"
# TODO: Add Azure PS deployment command