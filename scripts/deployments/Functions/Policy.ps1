<#
----------------------------------------------------------------------------------
Copyright (c) Microsoft Corporation.
Licensed under the MIT license.

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
----------------------------------------------------------------------------------
#>

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

      $PolicyConfig = Get-Content $PolicyConfigFilePath | ConvertFrom-Json

      Write-Output "Policy: $PolicyDefinitionName"
      Write-Output "   - Rule: $PolicyRuleFilePath"
      Write-Output "   - Parameters: $PolicyParametersFilePath"
      Write-Output "   - Id: $PolicyDefinitionName"
      Write-Output "   - Display Name: $($PolicyConfig.name)"
      Write-Output "   - Mode: $($PolicyConfig.mode)"

      New-AzPolicyDefinition `
        -ManagementGroupName $ManagementGroupId `
        -Name $PolicyDefinitionName `
        -DisplayName $($PolicyConfig.name) `
        -Mode $PolicyConfig.mode `
        -Policy $PolicyRuleFilePath `
        -Parameter $PolicyParametersFilePath
    }
}

function Set-PolicySet-Defintions {
  param(
    [Parameter(Mandatory = $true)]
    $Context, 

    [Parameter(Mandatory = $true)]
    [String] $PolicySetDefinitionsDirectory,

    [Parameter(Mandatory = $true)]
    [String[]] $PolicySetDefinitionNames,

    [Parameter(Mandatory = $true)]
    [PSCustomObject] $ManagementGroupId
  )

  foreach ($policySetDefinitionName in $PolicySetDefinitionNames) {
    $PolicySetDefinitionFilePath = "$($PolicySetDefinitionsDirectory)/$($policySetDefinitionName).bicep"
    $PolicySetDefinitionParametersFilePath = "$($PolicySetDefinitionsDirectory)/$($policySetDefinitionName).parameters.json"

    # Replace templated parameters & create temp file for deployment
    $ParametersContent = Get-Content $PolicySetDefinitionParametersFilePath
    $ParametersContent = $ParametersContent -Replace '{{var-topLevelManagementGroupName}}', $ManagementGroupId

    $PopulatedParametersFilePath = "$($PolicySetDefinitionsDirectory)/$($policySetDefinitionName)-populated.parameters.json"
    $ParametersContent | Set-Content -Path $PopulatedParametersFilePath

    Write-Output "Policy Set: $policySetDefinitionName"
    Write-Output "   - Management Group Id: $ManagementGroupId"
    Write-Output "   - Definition: $PolicySetDefinitionFilePath"
    Write-Output "   - Parameters: $PolicySetDefinitionParametersFilePath"
    Write-Output "   - Populated (temp): $PopulatedParametersFilePath"

    # Deploy Policy Set
    New-AzManagementGroupDeployment `
      -ManagementGroupId $ManagementGroupId `
      -Location $Context.DeploymentRegion `
      -TemplateFile $PolicySetDefinitionFilePath `
      -TemplateParameterFile $PopulatedParametersFilePath

    # Remove temporary file
    Remove-Item $PopulatedParametersFilePath
  }
}

function Set-PolicySet-Assignments {
  param(
    [Parameter(Mandatory = $true)]
    $Context,

    [Parameter(Mandatory = $true)]
    [String] $PolicySetAssignmentsDirectory,

    [Parameter(Mandatory = $true)]
    [String] $PolicySetAssignmentManagementGroupId,

    [Parameter(Mandatory = $true)]
    [String[]] $PolicySetAssignmentNames,

    [Parameter(Mandatory = $true)]
    [String] $LogAnalyticsWorkspaceResourceGroupName,

    [Parameter(Mandatory = $true)]
    [String] $LogAnalyticsWorkspaceResourceId,

    [Parameter(Mandatory = $true)]
    [String] $LogAnalyticsWorkspaceId,

    [Parameter(Mandatory = $true)]
    [Int32] $LogAnalyticsWorkspaceRetentionInDays
  )

  foreach ($policySetAssignmentName in $PolicySetAssignmentNames) {
    Write-Output "Policy Set assignment Name: $($policySetAssignmentName)"

    $PolicySetAssignmentFilePath = "$($PolicySetAssignmentsDirectory)/$($policySetAssignmentName).bicep"

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

    # Replace templated parameters & create temp file for deployment
    $ParametersContent = Get-Content $PolicySetParameterFilePath
    $ParametersContent = $ParametersContent -Replace '{{var-topLevelManagementGroupName}}', $Context.TopLevelManagementGroupId
    $ParametersContent = $ParametersContent -Replace '{{var-logging-logAnalyticsWorkspaceResourceId}}', $LogAnalyticsWorkspaceResourceId
    $ParametersContent = $ParametersContent -Replace '{{var-logging-logAnalyticsWorkspaceId}}', $LogAnalyticsWorkspaceId
    $ParametersContent = $ParametersContent -Replace '{{var-logging-logAnalyticsResourceGroupName}}', $LogAnalyticsWorkspaceResourceGroupName
    $ParametersContent = $ParametersContent -Replace '{{var-logging-logAnalyticsRetentionInDays}}', $LogAnalyticsWorkspaceRetentionInDays
    $ParametersContent = $ParametersContent -Replace '{{var-policyAssignmentManagementGroupId}}', $PolicySetAssignmentManagementGroupId
    $ParametersContent = $ParametersContent -Replace '{{var-logging-diagnosticSettingsforNetworkSecurityGroupsStoragePrefix}}', $Context.Variables['var-logging-diagnosticSettingsforNetworkSecurityGroupsStoragePrefix']

    $PopulatedParametersFilePath = "$($PolicySetAssignmentsDirectory)/$($policySetAssignmentName)-populated.parameters.json"
    $ParametersContent | Set-Content -Path $PopulatedParametersFilePath

    Write-Output "Policy: $policy"
    Write-Output "   - Management Group Id: $PolicySetAssignmentManagementGroupId"
    Write-Output "   - Definition: $PolicySetAssignmentFilePath"
    Write-Output "   - Parameters: $PolicySetParameterFilePath"
    Write-Output "   - Populated (temp): $PopulatedParametersFilePath"

    # Deploy Policy Set
    New-AzManagementGroupDeployment `
      -ManagementGroupId $PolicySetAssignmentManagementGroupId `
      -Location $Context.DeploymentRegion `
      -TemplateFile $PolicySetAssignmentFilePath `
      -TemplateParameterFile $PopulatedParametersFilePath

    # Remove temporary file
    Remove-Item $PopulatedParametersFilePath
  }
}
