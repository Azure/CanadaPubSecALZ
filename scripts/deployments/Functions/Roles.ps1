<#
----------------------------------------------------------------------------------
Copyright (c) Microsoft Corporation.
Licensed under the MIT license.

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
----------------------------------------------------------------------------------
#>

function Set-Roles {
  param (
    [Parameter(Mandatory = $true)]
    $Context,

    [Parameter(Mandatory = $true)]
    [String] $RolesDirectory,

    [Parameter(Mandatory = $true)]
    [String] $ManagementGroupId
  )

  # Deployment
  Write-Output "Deploying roles to management group: $ManagementGroupId"
  Write-Output "Deploying role definitions from $RolesDirectory"

  $DeploymentParameters = @{
    assignableMgId = $ManagementGroupId
  }

  foreach ($roleDefinition in Get-ChildItem -Path $RolesDirectory) {
    Write-Output "Deploying $($roleDefinition.FullName)"
    
    New-AzManagementGroupDeployment `
      -ManagementGroupId $ManagementGroupId `
      -Location $Context.DeploymentRegion `
      -TemplateFile $roleDefinition.FullName `
      -TemplateParameterObject $DeploymentParameters
  }
}