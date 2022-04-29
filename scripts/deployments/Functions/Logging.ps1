function Get-LoggingConfiguration {
  param (
    [Parameter(Mandatory = $true)]
    [String]$ConfigurationFilePath,

    [Parameter(Mandatory = $true)]
    [String]$SubscriptionId
  )

  $Configuration = Get-Content $ConfigurationFilePath | ConvertFrom-Json

  # TODO:  Retreive Log Analytics Workspace Resource Id & Workspace Id

  return [PSCustomObject]@{
    ResourceGroup = $Configuration.parameters.logAnalyticsResourceGroupName.value
    LogAnalyticsWorkspaceName = $Configuration.parameters.logAnalyticsWorkspaceName.value
    LogRetentionInDays = $Configuration.parameters.logAnalyticsRetentionInDays.value
    LogAnalyticsWorkspaceResourceId = "TODO"
    LogAnalyticsWorkspaceId = "TODO"
  }
}

function Set-Logging {
  param (
    [Parameter(Mandatory = $true)]
    [String]$Region,

    [Parameter(Mandatory = $true)]
    [String]$ManagementGroupId,

    [Parameter(Mandatory = $true)]
    [String]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [String]$ConfigurationFilePath
  )

  Set-AzContext -Subscription $SubscriptionId

  Write-Output "Moving Subscription ($SubscriptionId) to Management Group ($ManagementGroupId)"
  New-AzManagementGroupDeployment `
    -ManagementGroupId $ManagementGroupId `
    -Location $Context.DeploymentRegion `
    -TemplateFile "$($Context.WorkingDirectory)/landingzones/utils/mg-move/move-subscription.bicep" `
    -TemplateParameterObject @{
      managementGroupId = $ManagementGroupId
      subscriptionId = $SubscriptionId
    }

  Write-Output "Deploying Logging to $SubscriptionId in $Region with $ConfigurationFilePath"
  New-AzSubscriptionDeployment `
    -Name "main-$Region" `
    -Location $Region `
    -TemplateFile "$($Context.WorkingDirectory)/landingzones/lz-platform-logging/main.bicep" `
    -TemplateParameterFile $ConfigurationFilePath
}