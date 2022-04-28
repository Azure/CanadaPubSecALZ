function Deploy-Subscriptions {
  param (
    [Parameter(Mandatory = $true)]
    [String]$Region,
    
    [Parameter(Mandatory = $true)]
    [String[]] $SubscriptionIds,

    [Parameter(Mandatory = $true)]
    [String] $LogAnalyticsWorkspaceResourceId
  )

  foreach ($subscriptionId in $SubscriptionIds) {
    Write-Output "Deploying Subscription: $subscriptionId"

    # TODO: Find the ARM JSON parameters

    # TODO: Ensure there's only 1 parameters file for each subscription

    # TODO: Parse the file name to determine archetype, region and subscription id

    # TODO: Load networking configuration and check if Log Analytics Workspace Id is provided.  Otherwise set it.

    # TODO: Add Azure PS deployment command
  }
}