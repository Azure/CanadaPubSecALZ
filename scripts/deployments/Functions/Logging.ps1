function Deploy-Logging {
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