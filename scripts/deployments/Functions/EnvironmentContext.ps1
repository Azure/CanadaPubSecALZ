<#
----------------------------------------------------------------------------------
Copyright (c) Microsoft Corporation.
Licensed under the MIT license.

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
----------------------------------------------------------------------------------
#>
 
Import-Module powershell-yaml

function New-EnvironmentContext {
  param (
    [Parameter(Mandatory = $true)]
    [string] $WorkingDirectory,

    [Parameter(Mandatory = $true)]
    [string] $Environment
  )

  $EnvironmentConfigurationYamlFilePath = (Resolve-Path -Path "$WorkingDirectory/config/variables/$Environment.yml").Path

  # Load main environment variables file as YAML
  $EnvironmentConfiguration = Get-Content $EnvironmentConfigurationYamlFilePath  | ConvertFrom-Yaml
  $Variables = $EnvironmentConfiguration.variables

  # Retrieve the management group hierarchy variable as JSON
  $ManagementGroupHierarchy = $Variables['var-managementgroup-hierarchy'] | ConvertFrom-Json

  $PolicyDirectory = (Resolve-Path -Path "$WorkingDirectory/policy").Path

  # Create a new context object
  return [PSCustomObject]@{
    WorkingDirectory = (Resolve-Path -Path $WorkingDirectory).Path

    RolesDirectory = (Resolve-Path -Path "$WorkingDirectory/roles").Path

    PolicyCustomDefinitionDirectory = (Resolve-Path -Path "$PolicyDirectory/custom/definitions/policy").Path
    PolicySetCustomDefinitionDirectory = (Resolve-Path -Path "$PolicyDirectory/custom/definitions/policyset").Path
    PolicySetCustomAssignmentsDirectory = (Resolve-Path -Path "$PolicyDirectory/custom/assignments").Path
    PolicySetBuiltInAssignmentsDirectory = (Resolve-Path -Path "$PolicyDirectory/builtin/assignments").Path

    SchemaDirectory = (Resolve-Path -Path "$WorkingDirectory/schemas/latest").Path

    LoggingDirectory = (Resolve-Path -Path "$WorkingDirectory/config/logging/$Environment").Path
    NetworkingDirectory = (Resolve-Path -Path "$WorkingDirectory/config/networking/$Environment").Path
    SubscriptionsDirectory = (Resolve-Path -Path "$WorkingDirectory/config/subscriptions/$Environment").Path
    IdentityDirectory = (Resolve-Path -Path "$WorkingDirectory/config/identity/$Environment").Path

    Variables = $Variables
    ManagementGroupHierarchy = $ManagementGroupHierarchy

    # Identify the top level management group (the first child underneath Tenant Root Group)
    TopLevelManagementGroupId = $ManagementGroupHierarchy.children[0].id

    # Retreive default deployment region
    DeploymentRegion = $Variables['deploymentRegion']
  }
}