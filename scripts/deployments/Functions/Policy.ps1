function Set-Policy-Definitions {
  param(
    [Parameter(Mandatory = $true)]
    [String] $PolicyDefinitionsDirectory,

    [Parameter(Mandatory = $true)]
    [PSCustomObject] $ManagementGroupId
  )
  Get-ChildItem -Directory -Path $PolicyDefinitionsDirectory |
    Foreach-Object {
      $PolicyDefinitionName = $_.Name
      $PolicyConfigFilePath = "$($_.FullName)/azurepolicy.config.json"
      $PolicyRuleFilePath = "$($_.FullName)/azurepolicy.rules.json"
      $PolicyParametersFilePath = "$($_.FullName)/azurepolicy.parameters.json"

      Write-Output "Policy: $PolicyDefinitionName"
      Write-Output "- Rule: $PolicyRuleFilePath"
      Write-Output "- Parameters: $PolicyParametersFilePath"
      Write-Output "- Config: $PolicyConfigFilePath"

      # TODO: Add Azure PS deployment command
    }
}

function Set-PolicySet-Defintions {
  param(
    [Parameter(Mandatory = $true)]
    [String] $PolicySetDefinitionsDirectory,

    [Parameter(Mandatory = $true)]
    [String[]] $PolicySetDefinitionNames,

    [Parameter(Mandatory = $true)]
    [PSCustomObject] $ManagementGroupId
  )

  foreach ($policySetDefinitionName in $PolicySetDefinitionNames) {
    Write-Output "Policy set definition: $policySetDefinitionName"

    $PolicySetDefinitionFilePath = "$($PolicySetDefinitionsDirectory)/$($policySetDefinitionName).bicep"
    $PolicySetDefinitionParametersFilePath = "$($PolicySetDefinitionsDirectory)/$($policySetDefinitionName).parameters.json"

    Write-Output "Policy Set: $policySetDefinitionName"
    Write-Output "- Definition: $PolicySetDefinitionFilePath"
    Write-Output "- Parameters: $PolicySetDefinitionParametersFilePath"

    # TODO: Add logic to load logging configuration

    # TODO: Add logic to replace templated parameters

    # TODO: Add Azure PS deployment command
  }
}

function Set-PolicySet-Assignments {
  param(
    [Parameter(Mandatory = $true)]
    [String] $PolicySetAssignmentsDirectory,

    [Parameter(Mandatory = $true)]
    [String] $PolicySetAssignmentManagementGroupId,

    [Parameter(Mandatory = $true)]
    [String[]] $PolicySetAssignmentNames,

    [Parameter(Mandatory = $true)]
    [String] $LogAnalyticsWorkspaceResourceId,

    [Parameter(Mandatory = $true)]
    [String] $LogAnalyticsWorkspaceId,

    [Parameter(Mandatory = $true)]
    [Int32] $LogAnalyticsWorkspaceRetentionInDays
  )

  foreach ($policySetAssignmentName in $PolicySetAssignmentNames) {
    Write-Output "Policy Set assignment Name: $($policySetAssignmentName)"

    $DefaultPolicyParameterFilePath = "$PolicySetAssignmentsDirectory/$policySetAssignmentName.parameters.json"
    $AssignmentScopeParameterFilePath = "$PolicySetAssignmentsDirectory/$policySetAssignmentName-$PolicySetAssignmentManagementGroupId.parameters.json"

    # Check if there is an assignment scope specific parameter file.
    # The file will have the syntax <Policy>-<Management Group Id>.parameters.json
    # If not found, then use the default parameter file with syntax <Policy>.parameters.json
    if (Test-Path $AssignmentScopeParameterFilePath -PathType Leaf) {
      $PolicySetParameterFilePath = $AssignmentScopeParameterFilePath
    } else {
      $PolicySetParameterFilePath = $DefaultPolicyParameterFilePath
    }

    Write-Output "Policy: $policy"
    Write-Output "- Definition: $PolicySetAssignmentsDirectory/$policySetAssignmentName.bicep"
    Write-Output "- Parameters: $PolicySetParameterFilePath"

    # TODO: Add logic to replace templated parameters

    # TODO: Add Azure PS deployment command

  }
}
