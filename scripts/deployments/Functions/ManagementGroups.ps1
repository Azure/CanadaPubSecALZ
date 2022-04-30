<#
----------------------------------------------------------------------------------
Copyright (c) Microsoft Corporation.
Licensed under the MIT license.

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
----------------------------------------------------------------------------------
#>

function Set-ManagementGroups {
  param (
    [Parameter(Mandatory = $true)]
    $Context, 

    [Parameter(Mandatory = $true)]
    $ManagementGroupHierarchy
  )

  function Set-ChildManagementGroups {
    param (
      [Parameter(Mandatory = $true)]
      $Context, 
      
      [Parameter(Mandatory = $true)]
      $RootManagementGroupId,

      [Parameter(Mandatory = $true)]
      $ParentNode
    )

    ForEach ($childNode in $ParentNode.children) {
      $parentManagementGroupId = $ParentNode.id
      $childManagementGroupId = $childNode.id
      $childManagementGroupName = $childNode.name

      $DeploymentParameters = @{
        topLevelManagementGroupName = $RootManagementGroupId
        parentManagementGroupId = $parentManagementGroupId
        childManagementGroupId = $childManagementGroupId
        childManagementGroupName = $childManagementGroupName
      }
     
      Write-Output "Creating $childManagementGroupName [$childManagementGroupId] under $parentManagementGroupId"

      New-AzManagementGroupDeployment `
        -ManagementGroupId $parentManagementGroupId `
        -Location $Context.DeploymentRegion `
        -TemplateFile "$($Context.WorkingDirectory)/management-groups/structure-v2.bicep" `
        -TemplateParameterObject $DeploymentParameters

      Set-ChildManagementGroups `
        -Context $Context `
        -RootManagementGroupId $RootManagementGroupId `
        -ParentNode $childNode
    }
  }

  Set-ChildManagementGroups `
    -Context $Context `
    -RootManagementGroupId $ManagementGroupHierarchy.id `
    -ParentNode $ManagementGroupHierarchy
}