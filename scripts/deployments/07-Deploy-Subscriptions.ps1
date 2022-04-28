. ".\functions\Set-EnvironmentContext.ps1"

# Working Directory
$WorkingDirectory = "../.."

# Set Context
Set-EnvironmentContext -Environment "CanadaESLZ-main" -WorkingDirectory $WorkingDirectory

$Subscriptions = $()

foreach ($subscription in $subscriptions) {
  # TODO: Find the ARM JSON parameters

  # TODO: Ensure there's only 1 parameters file for each subscription

  # TODO: Parse the file name to determine archetype, region and subscription id

  # TODO: Load networking configuration and check if Log Analytics Workspace Id is provided.  Otherwise set it.

  # TODO: Add Azure PS deployment command
}