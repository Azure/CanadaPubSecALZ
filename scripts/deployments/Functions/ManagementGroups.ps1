function Set-ManagementGroups {
  param (
    [Parameter(Mandatory = $true)]
    $ManagementGroupHierarchy
  )
  function Set-ChildManagementGroups {
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

      Set-ChildManagementGroups($childNode)
    }
  }

  Set-ChildManagementGroups($ManagementGroupHierarchy)
}