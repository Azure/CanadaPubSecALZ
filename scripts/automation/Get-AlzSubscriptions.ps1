<#
----------------------------------------------------------------------------------
Copyright (c) Microsoft Corporation.
Licensed under the MIT license.

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
----------------------------------------------------------------------------------
#>

<#
  .SYNOPSIS
    This script gets the main YAML configuration for a CanadaPubSecALZ deployment.

  .DESCRIPTION
    This script gets the main YAML configuration for a CanadaPubSecALZ deployment.

  .PARAMETER Environment
    The name of the environment.

  .PARAMETER RepoRootPath
    The path to the repository directory.

  .PARAMETER SubscriptionIdsByRef
    The reference to the subscription IDs array.

  .EXAMPLE
    PS> $SubscriptionIds = @()
    PS> .\Get-AlzSubscriptions.ps1 -Environment 'CanadaALZ-main' -SubscriptionIdsByRef ([ref]$SubscriptionIds)
#>

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)]
  [string]$Environment,

  [string]$RepoRootPath = "../..",

  [ref]$SubscriptionIdsByRef
)

$ErrorActionPreference = "Stop"

Write-Output "Getting subscription configurations for environment ($Environment)"

$SubscriptionIdsByRef.value = @()

$Pattern = "^[\da-fA-F]{8}-[\da-fA-F]{4}-[\da-fA-F]{4}-[\da-fA-F]{4}-[\da-fA-F]{12}(_.*)(_.*)?\.json"

$Subscriptions = @(Get-ChildItem -Path "$RepoRootPath/config/subscriptions/$Environment" -File -Recurse | ? { $_.Name -match $Pattern })

foreach ($Subscription in $Subscriptions) {
  $SubscriptionIdsByRef.value += $Subscription.Name.Split('_')[0]
}
