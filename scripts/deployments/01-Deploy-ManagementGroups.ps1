#Requires -Modules powershell-yaml

. ".\functions\Set-EnvironmentContext.ps1"
function DeployManagementGroups {
  param (
    [Parameter(Mandatory = $true)]
    [String] $Environment,

    [Parameter(Mandatory = $true)]
    [String] $WorkingDirectory
  )

  # Set Context
  Set-EnvironmentContext -Environment $Environment -WorkingDirectory $WorkingDirectory

  # Deployment
  function ProcessManagementGroupHierarchy {
    param (
      [Parameter(Mandatory = $true)]
      $parentNode
    )

    foreach ($childNode in $parentNode.children) {
      $parentManagementGroupId = $parentNode.id
      $childManagementGroupId = $childNode.id
      $childManagementGroupName = $childNode.name
      
      Write-Output "Creating $childManagementGroupName [$childManagementGroupId] under $parentManagementGroupId"

      # TODO: Add Azure PS deployment command

      ProcessManagementGroupHierarchy($childNode)
    }
  }

  ProcessManagementGroupHierarchy($global:ManagementGroupHierarchy)
}

DeployManagementGroups -WorkingDirectory "../../" -Environment "CanadaESLZ-main"