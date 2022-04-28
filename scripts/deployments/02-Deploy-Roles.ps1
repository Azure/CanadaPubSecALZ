. ".\functions\Set-EnvironmentContext.ps1"

# Working Directory
$WorkingDirectory = "../.."
$RolesDirectory = "$WorkingDirectory/roles"

# Set Context
Set-EnvironmentContext -Environment "CanadaESLZ-main" -WorkingDirectory $WorkingDirectory

# Deployment
Write-Output "Using top level management group: $global:TopLevelManagementGroupId"
Write-Output "Deploying role definitions from $global:RolesDirectory"

foreach ($roleDefinition in Get-ChildItem -Path $RolesDirectory) {
  Write-Output "Deploying $($roleDefinition.name)"

  # TODO: Add Azure PS deployment command
}
