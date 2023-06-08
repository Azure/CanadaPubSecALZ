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
    Removes an existing environment configuration for a CanadaPubSecALZ deployment.

  .DESCRIPTION
    This script removes an existing set of environment configuration files.

  .PARAMETER Environment
    The name of the environment to remove.

  .PARAMETER RepoRootPath
    The path to the repository directory. Defaults to ..\..

  .PARAMETER UserRootPath
    The path to the user directory. Defaults to $HOME.

  .PARAMETER UserLogsPath
    The path to the user logs directory. Defaults to $UserRootPath/ALZ/logs.

  .PARAMETER UserCredsPath
    The path to the user credentials directory. Defaults to $UserRootPath/ALZ/credentials.

  .PARAMETER UserConfigPath
    The path to the user configuration directory. Defaults to $UserRootPath/ALZ/config.

  .EXAMPLE
    PS> .\Remove-AlzConfiguration.ps1 -Environment 'DevOpsOrg-branch'
#>

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)]
  [string]$Environment,

  [string]$RepoRootPath = "../..",

  [string]$UserRootPath = "$HOME",

  [string]$UserLogsPath = "$UserRootPath/ALZ/logs",

  [string]$UserCredsPath = "$UserRootPath/ALZ/credentials",

  [string]$UserConfigPath = "$UserRootPath/ALZ/config"
)

$ErrorActionPreference = "Stop"

function RemovePaths {
  param(
    [string]$Environment,
    [string]$RepoRootPath
  )
  # Validate Parameters
  $RepoConfigPath = (Resolve-Path -Path "$RepoRootPath/config").Path
  Write-Output "Checking configuration path ($RepoConfigPath)"
  if (-not (Test-Path -PathType Container -Path $RepoConfigPath)) {
    throw "Configuration path does not exist."
  }

  # Remove variables configuration file
  $path = "$RepoConfigPath/variables/$Environment.yml"
  if (Test-Path -PathType Leaf -Path $path) {
    Write-Output "Removing variables configuration file: $path"
    Remove-Item -Path $path
  } else {
    Write-Output "Variables configuration file not found ($path)"
  }

  # Remove logging configuration file(s)
  $path = "$RepoConfigPath/logging/$Environment"
  if (Test-Path -PathType Container -Path $path) {
    Write-Output "Removing logging configuration directory: $path"
    Remove-Item -Path $path -Recurse
  } else {
    Write-Output "Logging configuration directory not found ($path)"
  }

  # Remove identity configuration file(s)
  $path = "$RepoConfigPath/identity/$Environment"
  if (Test-Path -PathType Container -Path $path) {
    Write-Output "Removing identity configuration directory: $path"
    Remove-Item -Path $path -Recurse
  } else {
    Write-Output "Identity configuration directory not found ($path)"
  }

  # Remove network configuration file(s)
  $path = "$RepoConfigPath/networking/$Environment"
  if (Test-Path -PathType Container -Path $path) {
    Write-Output "Removing network configuration directory: $path"
    Remove-Item -Path $path -Recurse
  } else {
    Write-Output "Network configuration directory not found ($path)"
  }

  # Remove subscription configuration file(s)
  $path = "$RepoConfigPath/subscriptions/$Environment"
  if (Test-Path -PathType Container -Path $path) {
    Write-Output "Removing subscription configuration directory: $path"
    Remove-Item -Path $path -Recurse
  } else {
    Write-Output "Subscription configuration directory not found ($path)"
  }

  Write-Output ""
}

# Ensure paths exist and are normalized to the OS path format
New-Item -ItemType Directory -Path $UserCredsPath -Force | Out-Null
$UserCredsPath = (Resolve-Path -Path $UserCredsPath).Path
New-Item -ItemType Directory -Path $UserLogsPath -Force | Out-Null
$UserLogsPath = (Resolve-Path -Path $UserLogsPath).Path
New-Item -ItemType Directory -Path $UserConfigPath -Force | Out-Null
$UserConfigPath = (Resolve-Path -Path $UserConfigPath).Path

# Local variables
$date = Get-Date -Format "yyMMdd-HHmmss-fff"
$script = $(Split-Path -Path $PSCommandPath -LeafBase)
$logFile = "$UserLogsPath/$date-$script-$Environment.log"
$stopWatch = [System.Diagnostics.Stopwatch]::New()

try {
  $stopWatch.Restart()

  Write-Output "" | Tee-Object -FilePath $logFile -Append
  Write-Output "This script removes an existing set of configuration files." | Tee-Object -FilePath $logFile -Append
  Write-Output "" | Tee-Object -FilePath $logFile -Append

  RemovePaths -Environment $Environment -RepoRootPath $RepoRootPath `
    | Tee-Object -FilePath $logFile -Append

} catch {
  Write-Output $_ | Tee-Object -FilePath $logFile -Append
  Write-Output $_.Exception | Tee-Object -FilePath $logFile -Append
  throw
} finally {
  Write-Output "Elapsed time: $($stopWatch.Elapsed)" `
    | Tee-Object -FilePath $logFile -Append
}
