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
    Tests a Service Principal for the specified environment.

  .DESCRIPTION
    Tests a Service Principal for the specified environment.

  .PARAMETER Environment
    The name of the environment. This is typically the repo/org name.

  .PARAMETER UserRootPath
    The root path for the log, credential, and configuration files. Defaults to $HOME.

  .PARAMETER UserLogsPath
    The path for the log files. Defaults to $UserRootPath/ALZ/logs.

  .PARAMETER UserCredsPath
    The path for the credential files. Defaults to $UserRootPath/ALZ/credentials.

  .PARAMETER UserConfigPath
    The path for the configuration files. Defaults to $UserRootPath/ALZ/config.

  .EXAMPLE
    PS> .\Test-AlzCredential.ps1 -Environment 'CanadaALZ'

  .EXAMPLE
    PS> .\Test-AlzCredential.ps1 -Environment 'CanadaALZ' -UserRootPath 'C:\Users\me\ALZ'

  .EXAMPLE
    PS> .\Test-AlzCredential.ps1 -Environment 'CanadaALZ' -UserLogsPath 'C:\Users\me\ALZ\logs'

  .EXAMPLE
    PS> .\Test-AlzCredential.ps1 -Environment 'CanadaALZ' -UserCredsPath 'C:\Users\me\ALZ\credentials'

  .EXAMPLE
    PS> .\Test-AlzCredential.ps1 -Environment 'CanadaALZ' -UserConfigPath 'C:\Users\me\ALZ\config'
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

#Requires -Modules Az

$ErrorActionPreference = "Stop"

function TestServicePrincipal {
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
    throw "You must be logged in to Azure via Azure PowerShell to test a service principal."
  }

  $sp = (Get-Content -Raw -Path $credentialFile | ConvertFrom-Json -Depth 100)

  $role = Get-AzRoleAssignment -ServicePrincipalName $sp.appId

  Write-Output ""
  if (($role | where { $_.RoleDefinitionName -eq 'Owner' -and $_.Scope -eq '/' }).Count -lt 1) {
    throw "Service Principal ($($sp.displayName)) for environment ($Environment) from tenant ($($sp.tenant)) is not an Owner of the tenant."
  } else {
    Write-Output "Service Principal ($($sp.displayName)) for environment ($Environment) from tenant ($($sp.tenant)) is an Owner of the tenant."
  }

  try {
    Write-Output ""
    Write-Output "Current Azure context:"
    Get-AzContext
    .\Connect-AlzCredential.ps1 -CredentialFile $credentialFile
    Write-Output ""
    Write-Output "Service Principal Azure context:"
    Get-AzContext
    Disconnect-AzAccount
    Write-Output ""
    Write-Output "Original Azure context:"
    Get-AzContext
  } catch {
    throw
  }
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
  TestServicePrincipal -Environment $Environment -CredsPath $UserCredsPath `
    | Tee-Object -FilePath $logFile -Append
} catch {
  Write-Output $_ | Tee-Object -FilePath $logFile -Append
  Write-Output $_.Exception | Tee-Object -FilePath $logFile -Append
  throw
} finally {
  Write-Output "Elapsed time: $($stopWatch.Elapsed)" `
    | Tee-Object -FilePath $logFile -Append
}
