Import-Module powershell-yaml
function Set-EnvironmentContext {
  param (
    [string] $WorkingDirectory,
    [string] $Environment
  )

  $global:EnvironmentConfigurationYamlFilePath = "$WorkingDirectory/config/variables/$Environment.yml"

  $global:LoggingDirectory = "$WorkingDirectory/config/logging/$Environment"
  $global:NetworkingDirectory = "$WorkingDirectory/config/networking/$Environment"

 
  $global:EnvironmentConfiguration = Get-Content $EnvironmentConfigurationYamlFilePath  | ConvertFrom-Yaml
  $global:ManagementGroupHierarchy = $EnvironmentConfiguration.variables['var-managementgroup-hierarchy'] | ConvertFrom-Json
  $global:TopLevelManagementGroupId = $ManagementGroupHierarchy.children[0].id
}