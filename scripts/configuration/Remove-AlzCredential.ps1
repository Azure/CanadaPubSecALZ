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
    Removes a Service Principal for the specified environment.

  .DESCRIPTION
    Removes a Service Principal for the specified environment.

  .PARAMETER Environment
    The name of the environment. This is typically the repo/org name.

  .PARAMETER RootPath
    The root path for the log, credential, and configuration files. Defaults to $HOME.

  .PARAMETER LogsPath
    The path for the log files. Defaults to $UserRootPath/ALZ/logs.

  .PARAMETER CredsPath
    The path for the credential files. Defaults to $UserRootPath/ALZ/credentials.

  .PARAMETER ConfigPath
    The path for the configuration files. Defaults to $UserRootPath/ALZ/config.

  .EXAMPLE
    PS> .\Remove-AlzCredential.ps1 -Environment 'CanadaALZ'

  .EXAMPLE
    PS> .\Remove-AlzCredential.ps1 -Environment 'CanadaALZ' -UserRootPath 'C:\Users\me\ALZ'

  .EXAMPLE
    PS> .\Remove-AlzCredential.ps1 -Environment 'CanadaALZ' -UserLogsPath 'C:\Users\me\ALZ\logs'

  .EXAMPLE
    PS> .\Remove-AlzCredential.ps1 -Environment 'CanadaALZ' -UserCredsPath 'C:\Users\me\ALZ\credentials'

  .EXAMPLE
    PS> .\Remove-AlzCredential.ps1 -Environment 'CanadaALZ' -UserConfigPath 'C:\Users\me\ALZ\config'
#>

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)]
  [string]$Environment,

  [string]$UserRootPath = "$HOME",

  [string]$UserLogsPath = "$UserRootPath/ALZ/logs",

  [string]$UserCredsPath = "$UserRootPath/ALZ/credentials",

  [string]$UserConfigPath = "$UserRootPath/ALZ/config"
)

$ErrorActionPreference = "Stop"

function RemoveServicePrincipal {
  param(
    [string]$Environment = $Environment,
    [string]$UserCredsPath = $UserCredsPath
  )

  $credentialFile = "$UserCredsPath/$Environment.json"
  if (!(Test-Path -Path $credentialFile)) {
    throw "Service principal file ($credentialFile) does not exist."
  }

  $context = Get-AzContext
  if ($context -eq $null) {
    throw "You must be logged in to Azure via Azure PowerShell to remove a service principal."
  }

  try {
    $sp = (Get-Content -Raw -Path $credentialFile | ConvertFrom-Json -Depth 100)
    Write-Output "Removing Service Principal ($($sp.displayName)) for environment ($Environment) from tenant ($($sp.tenant))))"
    Remove-AzADServicePrincipal -ApplicationId $sp.appId
    Remove-AzADApplication -DisplayName $sp.displayName
  } catch {
    throw "Failed to remove Service Principal ($($sp.displayName)) for environment ($Environment) from tenant ($($sp.tenant))): $($_.Exception.Message)"
  }

  Write-Output "Removing Service Principal file ($credentialFile)"
  Remove-Item -Path $credentialFile -Force
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

# Create the service principal
try {
  $stopWatch.Restart()
  RemoveServicePrincipal -Environment $Environment -CredsPath $UserCredsPath `
    | Tee-Object -FilePath $logFile -Append
} catch {
  Write-Output $_ | Tee-Object -FilePath $logFile -Append
  Write-Output $_.Exception | Tee-Object -FilePath $logFile -Append
  throw
} finally {
  Write-Output "Elapsed time: $($stopWatch.Elapsed)" `
    | Tee-Object -FilePath $logFile -Append
}
