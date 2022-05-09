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

Write-Output "DeploySubscriptionIds count: $DeploySubscriptionIds.Count"
foreach ($subscription in $DeploySubscriptionIds) {
  Write-Output "Deploying to subscription $subscription"
}