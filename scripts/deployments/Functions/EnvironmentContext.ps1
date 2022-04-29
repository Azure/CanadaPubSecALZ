#Requires -Modules powershell-yaml
 
Import-Module powershell-yaml

function New-EnvironmentContext {
  param (
    [Parameter(Mandatory = $true)]
    [string] $WorkingDirectory,

    [Parameter(Mandatory = $true)]
    [string] $Environment
  )

  $EnvironmentConfigurationYamlFilePath = "$WorkingDirectory/config/variables/$Environment.yml"

  # Load main environment variables file as YAML
  $EnvironmentConfiguration = Get-Content $EnvironmentConfigurationYamlFilePath  | ConvertFrom-Yaml
  $Variables = $EnvironmentConfiguration.variables

  # Retrieve the management group hierarchy variable as JSON
  $ManagementGroupHierarchy = $Variables['var-managementgroup-hierarchy'] | ConvertFrom-Json

  $PolicyDirectory = "$WorkingDirectory/policy"

  # Create a new context object
  return [PSCustomObject]@{
    WorkingDirectory = $WorkingDirectory

    RolesDirectory = "$WorkingDirectory/roles"
   
    PolicyCustomDefinitionDirectory = "$PolicyDirectory/custom/definitions/policy"
    PolicySetCustomDefinitionDirectory = "$PolicyDirectory/custom/definitions/policyset"
    PolicySetCustomAssignmentsDirectory = "$PolicyDirectory/custom/assignments"
    PolicySetBuiltInAssignmentsDirectory = "$PolicyDirectory/builtin/assignments"
      
    LoggingDirectory = "$WorkingDirectory/config/logging/$Environment"
    NetworkingDirectory = "$WorkingDirectory/config/networking/$Environment"
    SubscriptionsDirectory = "$WorkingDirectory/config/subscriptions/$Environment"
  
    Variables = $Variables
    ManagementGroupHierarchy = $ManagementGroupHierarchy

    # Identify the top level management group (the first child underneath Tenant Root Group)
    TopLevelManagementGroupId = $ManagementGroupHierarchy.children[0].id

    # Retreive default deployment region
    DeploymentRegion = $Variables['deploymentRegion']
  }
}