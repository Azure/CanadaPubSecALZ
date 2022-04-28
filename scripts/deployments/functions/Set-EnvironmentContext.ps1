#Requires -Modules powershell-yaml
 
Import-Module powershell-yaml

function Set-EnvironmentContext {
  param (
    [Parameter(Mandatory = $true)]
    [string] $WorkingDirectory,

    [Parameter(Mandatory = $true)]
    [string] $Environment
  )

  $global:EnvironmentConfigurationYamlFilePath = "$WorkingDirectory/config/variables/$Environment.yml"

  $global:LoggingDirectory = "$WorkingDirectory/config/logging/$Environment"
  $global:NetworkingDirectory = "$WorkingDirectory/config/networking/$Environment"

 
  # Load main environment variables file as YAML
  $global:EnvironmentConfiguration = Get-Content $EnvironmentConfigurationYamlFilePath  | ConvertFrom-Yaml

  # Retrieve the management group hierarchy variable as JSON
  $global:ManagementGroupHierarchy = $EnvironmentConfiguration.variables['var-managementgroup-hierarchy'] | ConvertFrom-Json

  # Identify the top level management group (the first child underneath Tenant Root Group)
  $global:TopLevelManagementGroupId = $ManagementGroupHierarchy.children[0].id
}