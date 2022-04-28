function Deploy-Policy-Definitions {
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

function Deploy-PolicySet-Defintions {
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

function Deploy-PolicySet-Assignments {
  param(
    [Parameter(Mandatory = $true)]
    [String] $PolicySetAssignmentsDirectory,

    [Parameter(Mandatory = $true)]
    [PSCustomObject] $AssignmentScopes
  )

  foreach ($assignmentScope in $AssignmentScopes) {
    Write-Output "Assignment scope: $($assignmentScope.ManagementGroupId)"
    
    foreach ($policy in $assignmentScope.Policies) {
      Write-Output "Policy: $policy"

      $DefaultPolicyParameterFilePath = "$PolicySetAssignmentsDirectory/$policy.parameters.json"
      $AssignmentScopeParameterFilePath = "$PolicySetAssignmentsDirectory/$policy-$($assignmentScope.ManagementGroupId).parameters.json"

      # Check if there is an assignment scope specific parameter file.
      # The file will have the syntax <Policy>-<Management Group Id>.parameters.json
      # If not found, then use the default parameter file with syntax <Policy>.parameters.json
      if (Test-Path $AssignmentScopeParameterFilePath -PathType Leaf) {
        $PolicyParameterFilePath = $AssignmentScopeParameterFilePath
      } else {
        $PolicyParameterFilePath = $DefaultPolicyParameterFilePath
      }

      Write-Output "Policy: $policy"
      Write-Output "- Definition: $PolicySetAssignmentsDirectory/$policy.bicep"
      Write-Output "- Parameters: $PolicyParameterFilePath"

      # TODO: Add logic to replace templated parameters

      # TODO: Add Azure PS deployment command

    }
  }
}
