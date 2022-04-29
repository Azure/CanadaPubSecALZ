function Get-AzureFirewallPolicy {
  param (
    [Parameter(Mandatory = $true)]
    [String]$ConfigurationFilePath,

    [Parameter(Mandatory = $true)]
    [String]$SubscriptionId
  )

  $Configuration = Get-Content $ConfigurationFilePath | ConvertFrom-Json

  # TODO:  Retreive Azure Firewall Policy Id

  return [PSCustomObject]@{
    AzureFirewallPolicyResourceId = "TODO"
  }
}

function Set-AzureFirewallPolicy {
  param (
    [Parameter(Mandatory = $true)]
    [String]$Region,

    [Parameter(Mandatory = $true)]
    [String]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [String]$ConfigurationFilePath
  )

  # TODO: Add Azure PS deployment command
  Write-Output "Deploying $ConfigurationFilePath to $SubscriptionId in $Region"
}

function Set-HubNetwork-With-AzureFirewall {
  param (
    [Parameter(Mandatory = $true)]
    [String]$Region,

    [Parameter(Mandatory = $true)]
    [String]$ManagementGroupId,

    [Parameter(Mandatory = $true)]
    [String]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [String]$ConfigurationFilePath,

    [Parameter(Mandatory = $true)]
    [String]$AzureFirewallPolicyResourceId,

    [Parameter(Mandatory = $true)]
    [String]$LogAnalyticsWorkspaceResourceId
  )

  # TODO: Load networking configuration and check if Log Analytics Workspace Id is provided.  Otherwise set it.

  # TODO: Load networking configuration and check if Firewall Policy is provided.  Otherwise set it.

  # TODO: Add Azure PS deployment command
  Write-Output "Moving Subscription ($SubscriptionId) to Management Group ($ManagementGroupId)"

  # TODO: Add Azure PS deployment command
  Write-Output "Deploying $ConfigurationFilePath to $SubscriptionId in $Region"

  # TODO:  Check if Private DNS Zones are managed in the Hub.  If so, enable Private DNS Zones policy assignment

  # TODO:  Check if DDOS Standard is deployed in the Hub.  If so, enable DDOS Standard policy assignment
}