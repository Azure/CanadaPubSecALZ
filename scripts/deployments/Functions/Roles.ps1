function Deploy-Roles {
  param (
    [Parameter(Mandatory = $true)]
    [String] $RolesDirectory,

    [Parameter(Mandatory = $true)]
    [String] $ManagementGroupId
  )

  # Deployment
  Write-Output "Deploying roles to management group: $ManagementGroupId"
  Write-Output "Deploying role definitions from $RolesDirectory"

  foreach ($roleDefinition in Get-ChildItem -Path $RolesDirectory) {
    Write-Output "Deploying $($roleDefinition.name)"

    # TODO: Add Azure PS deployment command
  }
}