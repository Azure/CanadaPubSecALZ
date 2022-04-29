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

  # TODO: Add Azure PS deployment command
  Write-Output "Moving Subscription ($SubscriptionId) to Management Group ($ManagementGroupId)"

  # TODO: Add Azure PS deployment command
  Write-Output "Deploying $ConfigurationFilePath to $SubscriptionId in $Region"
}