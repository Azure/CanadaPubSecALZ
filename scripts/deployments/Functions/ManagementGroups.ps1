function Deploy-ManagementGroups {
  param (
    [Parameter(Mandatory = $true)]
    $ManagementGroupHierarchy
  )
  function Process-ManagementGroup-Hierarchy {
    param (
      [Parameter(Mandatory = $true)]
      $ParentNode
    )

    foreach ($childNode in $ParentNode.children) {
      $parentManagementGroupId = $ParentNode.id
      $childManagementGroupId = $childNode.id
      $childManagementGroupName = $childNode.name
      
      Write-Output "Creating $childManagementGroupName [$childManagementGroupId] under $parentManagementGroupId"

      # TODO: Add Azure PS deployment command

      Process-ManagementGroup-Hierarchy($childNode)
    }
  }

  Process-ManagementGroup-Hierarchy($ManagementGroupHierarchy)
}