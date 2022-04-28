Import-Module powershell-yaml

# Configuration
$WorkingDirectory = "../../"
$Environment = "CanadaESLZ-main"
$EnvironmentConfigurationYamlFilePath = "$WorkingDirectory/config/variables/$Environment.yml"
$RolesDirectory = "$WorkingDirectory/roles"

# Deployment
$EnvironmentConfiguration = Get-Content $EnvironmentConfigurationYamlFilePath  | ConvertFrom-Yaml
$ManagementGroupHierarchy = $EnvironmentConfiguration.variables['var-managementgroup-hierarchy'] | ConvertFrom-Json

$TopLevelManagementGroup = $ManagementGroupHierarchy.children[0]

Write-Output "Using top level management group: $($TopLevelManagementGroup.id)"
Write-Output "Deploying role definitions from $RolesDirectory"

foreach ($roleDefinition in Get-ChildItem -Path $RolesDirectory) {
  Write-Output "Deploying $($roleDefinition.name)"

  # TODO: Add Azure PS deployment command
}

