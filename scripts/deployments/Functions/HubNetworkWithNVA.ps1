<#
----------------------------------------------------------------------------------
Copyright (c) Microsoft Corporation.
Licensed under the MIT license.

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
----------------------------------------------------------------------------------
#>
function Set-HubNetwork-With-NVA {
  param (
    [Parameter(Mandatory = $true)]
    $Context,

    [Parameter(Mandatory = $true)]
    [String]$Region,

    [Parameter(Mandatory = $true)]
    [String]$ManagementGroupId,

    [Parameter(Mandatory = $true)]
    [String]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [String]$ConfigurationFilePath,

    [Parameter(Mandatory = $true)]
    [String]$LogAnalyticsWorkspaceResourceId,

    [Parameter(Mandatory = $false)]
    [String]$NvaUsername = $null,

    [Parameter(Mandatory = $false)]
    [String]$NvaPassword = $null
  )

  Set-AzContext -Subscription $SubscriptionId

  $SchemaFilePath = "$($Context.SchemaDirectory)/landingzones/lz-platform-connectivity-hub-nva.json"
  
  Write-Output "Validation JSON parameter configuration using $SchemaFilePath"
  Get-Content -Raw $ConfigurationFilePath | Test-Json -SchemaFile $SchemaFilePath

  # Load networking configuration
  $Configuration = Get-Content $ConfigurationFilePath | ConvertFrom-Json -Depth 100

  #region Check if Log Analytics Workspace Id is provided.  Otherwise set it.

  $LogAnalyticsWorkspaceResourceIdInFile = $Configuration.parameters | Get-Member -Name logAnalyticsWorkspaceResourceId
 
  if ($null -eq $LogAnalyticsWorkspaceResourceIdInFile -or $Configuration.parameters.logAnalyticsWorkspaceResourceId.value -eq "") {
    Write-Output "Log Analytics Workspace Resource Id is not provided in the configuration file.  Setting it to the default value."
    $LogAnalyticsWorkspaceIdElement = @{
      logAnalyticsWorkspaceResourceId = @{
        value = $LogAnalyticsWorkspaceResourceId
      }
    }
    $Configuration.parameters | Add-Member $LogAnalyticsWorkspaceIdElement -Force
  }
  
  #endregion

  #region Check if NVA username and password are provided.

  if (-not [string]::IsNullOrEmpty($NvaUsername)) {
    Write-Output "NVA username is provided.  Setting NVA username in configuration."
    $NvaUsernameElement = @{
      fwUsername = @{
        value = $NvaUsername
      }
    }
    $Configuration.parameters | Add-Member $NvaUsernameElement -Force
  }

  if (-not [string]::IsNullOrEmpty($NvaPassword)) {
    Write-Output "NVA password is provided.  Setting NVA password in configuration."
    $NvaPasswordElement = @{
      fwPassword = @{
        value = $NvaPassword
      }
    }
    $Configuration.parameters | Add-Member $NvaPasswordElement -Force
  }

  #endregion

  $PopulatedParametersFilePath = $ConfigurationFilePath.Split('.')[0] + '-populated.json'

  Write-Output "Creating new file with runtime populated parameters: $PopulatedParametersFilePath"
  $Configuration | ConvertTo-Json -Depth 100 | Set-Content $PopulatedParametersFilePath

  Write-Output "Moving Subscription ($SubscriptionId) to Management Group ($ManagementGroupId)"
  New-AzManagementGroupDeployment `
    -ManagementGroupId $ManagementGroupId `
    -Location $Context.DeploymentRegion `
    -TemplateFile "$($Context.WorkingDirectory)/landingzones/utils/mg-move/move-subscription.bicep" `
    -TemplateParameterObject @{
      managementGroupId = $ManagementGroupId
      subscriptionId = $SubscriptionId
    }

  Write-Output "Deploying $PopulatedParametersFilePath to $SubscriptionId in $Region"
  New-AzSubscriptionDeployment `
    -Name "main-$Region" `
    -Location $Region `
    -TemplateFile "$($Context.WorkingDirectory)/landingzones/lz-platform-connectivity-hub-nva/main.bicep" `
    -TemplateParameterFile $PopulatedParametersFilePath `
    -Verbose

  #region Check if Private DNS Zones are managed in the Hub.  If so, enable Private DNS Zones policy assignment
  if ($Configuration.parameters.privateDnsZones.value.enabled -eq $true) {
    $PolicyAssignmentFilePath = "$($Context.PolicySetCustomAssignmentsDirectory)/DNSPrivateEndpoints.bicep"

    Write-Output "Hub Network will manage private dns zones, creating Azure Policy assignment to automatically create Private Endpoint DNS Zones."
    Write-Output "Deploying policy assignment using $PolicyAssignmentFilePath"

    $Parameters = @{
      policyAssignmentManagementGroupId = $Context.TopLevelManagementGroupId
      policyDefinitionManagementGroupId = $Context.TopLevelManagementGroupId
      privateDNSZoneSubscriptionId = $SubscriptionId
      privateDNSZoneResourceGroupName = $Configuration.parameters.privateDnsZones.value.resourceGroupName
    }

    New-AzManagementGroupDeployment `
      -ManagementGroupId $Context.TopLevelManagementGroupId `
      -Location $Context.DeploymentRegion `
      -TemplateFile $PolicyAssignmentFilePath `
      -TemplateParameterObject $Parameters
  }
  else {
    Write-Output "Hub Network will not manage private dns zones.  Azure Policy assignment will be skipped."
  }
  #endregion

  #region Check if DDOS Standard is deployed in the Hub.  If so, enable DDOS Standard policy assignment
  if ($Configuration.parameters.ddosStandard.value.enabled -eq $true) {
    $DDoSPlan = Get-AzDdosProtectionPlan `
      -ResourceGroupName $Configuration.parameters.ddosStandard.value.resourceGroupName `
      -Name $Configuration.parameters.ddosStandard.value.planName

    $PolicyAssignmentFilePath = "$($Context.PolicySetCustomAssignmentsDirectory)/DDoS.bicep"

    Write-Output "DDoS Standard is enabled, creating Azure Policy assignment to protect for all Virtual Networks in '$($Context.TopLevelManagementGroupId)' management group."
    Write-Output "Deploying policy assignment using $PolicyAssignmentFilePath"

    $Parameters = @{
      policyAssignmentManagementGroupId = $Context.TopLevelManagementGroupId
      policyDefinitionManagementGroupId = $Context.TopLevelManagementGroupId
      ddosStandardPlanId = $DDoSPlan.Id
    }

    New-AzManagementGroupDeployment `
      -ManagementGroupId $Context.TopLevelManagementGroupId `
      -Location $Context.DeploymentRegion `
      -TemplateFile $PolicyAssignmentFilePath `
      -TemplateParameterObject $Parameters
  }
  else {
    Write-Output "DDoS Standard is not enabled.  Azure Policy assignment will be skipped."
  }
  #endregion

  Remove-Item $PopulatedParametersFilePath
}