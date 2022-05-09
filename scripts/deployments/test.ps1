[CmdletBinding()]
Param(
  # What to deploy
  [switch]$DeployManagementGroups,
  [switch]$DeployRoles,
  [switch]$DeployLogging,
  [switch]$DeployPolicy,
  [switch]$DeployHubNetworkWithNVA,
  [switch]$DeployHubNetworkWithAzureFirewall,
  [string[]]$DeploySubscriptionIds=@(),

  # How to deploy
  [string]$EnvironmentName="",
  [string]$GitHubRepo=$null,
  [string]$GitHubRef=$null,
  [string]$LoginInteractiveTenantId=$null,
  [SecureString]$LoginServicePrincipalJson=$null,
  [string]$WorkingDirectory=(Resolve-Path "../.."),
  [SecureString]$NvaUsername=$null,
  [SecureString]$NvaPassword=$null
)

$count = $DeploySubscriptionIds.Count
Write-Output "DeploySubscriptionIds count: $count"
foreach ($subscription in $DeploySubscriptionIds) {
  Write-Output "Deploying to subscription $subscription"
}