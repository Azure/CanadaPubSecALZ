#Requires -Modules powershell-yaml

. ".\functions\Set-EnvironmentContext.ps1"

function DeployRoles {
  param (
    [Parameter(Mandatory = $true)]
    [String] $Environment,

    [Parameter(Mandatory = $true)]
    [String] $WorkingDirectory
  )

  # Working Directory
  $RolesDirectory = "$WorkingDirectory/roles"

  # Set Context
  Set-EnvironmentContext -Environment $Environment -WorkingDirectory $WorkingDirectory

  # Deployment
  Write-Output "Using top level management group: $global:TopLevelManagementGroupId"
  Write-Output "Deploying role definitions from $global:RolesDirectory"

  foreach ($roleDefinition in Get-ChildItem -Path $RolesDirectory) {
    Write-Output "Deploying $($roleDefinition.name)"

    # TODO: Add Azure PS deployment command
  }
}

DeployRoles -WorkingDirectory "../../" -Environment "CanadaESLZ-main"