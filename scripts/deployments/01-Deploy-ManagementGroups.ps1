#Requires -Modules powershell-yaml

. ".\functions\Set-EnvironmentContext.ps1"

# Working Directory
$WorkingDirectory = "../.."

# Set Context
Set-EnvironmentContext -Environment "CanadaESLZ-main" -WorkingDirectory $WorkingDirectory

# Deployment
function ProcessManagementGroupHierarchy {
  param (
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