function Set-HubNetwork-With-NVA {
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
    [String]$LogAnalyticsWorkspaceResourceId
  )

  # TODO: Load networking configuration and check if Log Analytics Workspace Id is provided.  Otherwise set it.

  # TODO: Add Azure PS deployment command
  Write-Output "Moving Subscription ($SubscriptionId) to Management Group ($ManagementGroupId)"

  # TODO: Add Azure PS deployment command
  Write-Output "Deploying $ConfigurationFilePath to $SubscriptionId in $Region"
 
  # TODO:  Check if Private DNS Zones are managed in the Hub.  If so, enable Private DNS Zones policy assignment

  # TODO:  Check if DDOS Standard is deployed in the Hub.  If so, enable DDOS Standard policy assignment
}