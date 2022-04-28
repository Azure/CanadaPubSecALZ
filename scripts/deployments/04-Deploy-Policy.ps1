. ".\functions\Set-EnvironmentContext.ps1"

# Working Directory
$WorkingDirectory = "../.."

# Set Context
Set-EnvironmentContext -Environment "CanadaESLZ-main" -WorkingDirectory $WorkingDirectory

$PolicyRootDirectory = "$WorkingDirectory/policy"

$LoggingSubscription = $global:EnvironmentConfiguration.variables['var-logging-subscriptionId']
$LoggingConfigurationFileName = $global:EnvironmentConfiguration.variables['var-logging-configurationFileName']

#region Policy definition & assignment configuration
$BuiltInPolicySetAssignmentScopes = $(
  [PSCustomObject]@{
    ManagementGroupId = $global:TopLevelManagementGroupId
    Policies = $(
      'asb',
      'nist80053r4',
      'nist80053r5',
      'pbmm',
      'cis-msft-130',
      'fedramp-moderate',
      'hitrust-hipaa',
      'location'
    )
    LoggingSubscriptionId = $LoggingSubscription
    LoggingConfigurationFilePath = "$global:LoggingDirectory/$LoggingConfigurationFileName"
  }
)

$CustomPolicySetDefinitions = $(
  'AKS',
  'DefenderForCloud',
  'LogAnalytics',
  'Network',
  'DNSPrivateEndpoints',
  'Tags'
)

$CustomPolicySetAssignmentScopes = $(
  [PSCustomObject]@{
    ManagementGroupId = $global:TopLevelManagementGroupId
    Policies = $(
      'AKS',
      'DefenderForCloud',
      'LogAnalytics',
      'Network',
      'Tags'
    )
    LoggingSubscriptionId = $LoggingSubscription
    LoggingConfigurationFilePath = "$global:LoggingDirectory/$LoggingConfigurationFileName"
  }
)
#endregion

#region Enumerate and deploy built-in policy assignments
$BuiltInPolicySetAssignmentsDirectory = "$PolicyRootDirectory/builtin/assignments"

foreach ($assignmentScope in $BuiltInPolicySetAssignmentScopes) {
 Write-Output "Assignment scope: $($assignmentScope.ManagementGroupId)"
 Write-Output "Logging Subscription: $($assignmentScope.LoggingSubscriptionId)"
 Write-Output "Logging Configuration: $($assignmentScope.LoggingConfigurationFilePath)"
  
  foreach ($policy in $assignmentScope.Policies) {
    Write-Output "Policy: $policy"

    $DefaultPolicyParameterFilePath = "$BuiltInPolicySetAssignmentsDirectory/$policy.parameters.json"
    $AssignmentScopeParameterFilePath = "$BuiltInPolicySetAssignmentsDirectory/$policy-$($assignmentScope.ManagementGroupId).parameters.json"

    # Check if there is an assignment scope specific parameter file.
    # The file will have the syntax <Policy>-<Management Group Id>.parameters.json
    # If not found, then use the default parameter file with syntax <Policy>.parameters.json
    if (Test-Path $AssignmentScopeParameterFilePath -PathType Leaf) {
      $PolicyParameterFilePath = $AssignmentScopeParameterFilePath
    } else {
      $PolicyParameterFilePath = $DefaultPolicyParameterFilePath
    }

    Write-Output "Policy: $policy"
    Write-Output "- Definition: $BuiltInPolicySetAssignmentsDirectory/$policy.bicep"
    Write-Output "- Parameters: $PolicyParameterFilePath"

    # TODO: Add logic to replace templated parameters

    # TODO: Add Azure PS deployment command

  }
}
#endregion

#region Enumerate and deploy the custom policy definitions
$CustomPolicyDefinitionDirectory = "$PolicyRootDirectory/custom/definitions/policy"

Get-ChildItem -Directory -Path $CustomPolicyDefinitionDirectory |
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
#endregion

#region Enumerate and deploy custom policy set definitions
$CustomPolicySetDefinitionsDirectory = "$PolicyRootDirectory/custom/definitions/policyset"

foreach ($policySetDefinitionName in $CustomPolicySetDefinitions) {
  Write-Output "Policy set definition: $policySetDefinitionName"

  $PolicySetDefinitionFilePath = "$($CustomPolicySetDefinitionsDirectory)/$($policySetDefinitionName).bicep"
  $PolicySetDefinitionParametersFilePath = "$($CustomPolicySetDefinitionsDirectory)/$($policySetDefinitionName).parameters.json"

  Write-Output "Policy Set: $policySetDefinitionName"
  Write-Output "- Definition: $PolicySetDefinitionFilePath"
  Write-Output "- Parameters: $PolicySetDefinitionParametersFilePath"

  # TODO: Add logic to load logging configuration

  # TODO: Add logic to replace templated parameters

  # TODO: Add Azure PS deployment command
}
#endregion

#region Enumerate and deploy custom policy assignments
$CustomPolicySetAssignmentsDirectory = "$PolicyRootDirectory/custom/assignments/policyset"

foreach ($assignmentScope in $CustomPolicySetAssignmentScopes) {
 Write-Output "Assignment scope: $($assignmentScope.ManagementGroupId)"
 Write-Output "Logging Subscription: $($assignmentScope.LoggingSubscriptionId)"
 Write-Output "Logging Configuration: $($assignmentScope.LoggingConfigurationFilePath)"
  
  foreach ($policy in $assignmentScope.Policies) {
    Write-Output "Policy: $policy"

    $DefaultPolicyParameterFilePath = "$CustomPolicySetAssignmentsDirectory/$policy.parameters.json"
    $AssignmentScopeParameterFilePath = "$CustomPolicySetAssignmentsDirectory/$policy-$($assignmentScope.ManagementGroupId).parameters.json"

    # Check if there is an assignment scope specific parameter file.
    # The file will have the syntax <Policy>-<Management Group Id>.parameters.json
    # If not found, then use the default parameter file with syntax <Policy>.parameters.json
    if (Test-Path $AssignmentScopeParameterFilePath -PathType Leaf) {
      $PolicyParameterFilePath = $AssignmentScopeParameterFilePath
    } else {
      $PolicyParameterFilePath = $DefaultPolicyParameterFilePath
    }

    Write-Output "Policy: $policy"
    Write-Output "- Definition: $CustomPolicySetAssignmentsDirectory/$policy.bicep"
    Write-Output "- Parameters: $PolicyParameterFilePath"

    # TODO: Add logic to load logging configuration

    # TODO: Add logic to replace templated parameters

    # TODO: Add Azure PS deployment command

  }
}
#endregion