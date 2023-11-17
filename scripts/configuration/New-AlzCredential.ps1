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
    Creates a Service Principal for the specified environment.

  .DESCRIPTION
    Creates a Service Principal for the specified environment.

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
    PS> .\New-AlzCredential.ps1 -Environment 'CanadaALZ'

  .EXAMPLE
    PS> .\New-AlzCredential.ps1 -Environment 'CanadaALZ' -UserRootPath 'C:\Users\me\ALZ'

  .EXAMPLE
    PS> .\New-AlzCredential.ps1 -Environment 'CanadaALZ' -UserLogsPath 'C:\Users\me\ALZ\logs'

  .EXAMPLE
    PS> .\New-AlzCredential.ps1 -Environment 'CanadaALZ' -UserCredsPath 'C:\Users\me\ALZ\credentials'

  .EXAMPLE
    PS> .\New-AlzCredential.ps1 -Environment 'CanadaALZ' -UserConfigPath 'C:\Users\me\ALZ\config'
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

function CreateServicePrincipal {
  param(
    [string]$Environment = $Environment,
    [string]$UserCredsPath = $UserCredsPath
  )
  <# Create JSON representation of the service principal using the Azure CLI
    if ((az account show) -eq $null) {
      throw "You must be logged in to Azure via the Azure CLI to create a service principal."
    }
    $json = (az ad sp create-for-rbac --name $Environment --role "Owner" --scopes "/")
  #>
  
  # Create JSON representation of the service principal using Azure PowerShell
  $context = Get-AzContext
  if ($context -eq $null) {
    throw "You must be logged in to Azure via Azure PowerShell to create a service principal."
  }

  $tenant = Get-AzTenant -TenantId $context.Tenant.Id
  Write-Output "Creating Service Principal for environment ($Environment) in tenant ($($tenant.DefaultDomain)))"
  $sp = New-AzADServicePrincipal -DisplayName $Environment -Role Owner -Scope "/"
  Write-Output "  appId: $($sp.AppId)"
  Write-Output "  displayName: $($sp.DisplayName)"
  Write-Output "  password: **********"
  Write-Output "  tenant: $($context.Tenant.Id)"
  $json = @{
    appId = $sp.AppId
    displayName = $sp.DisplayName
    password = $sp.PasswordCredentials.SecretText
    tenant = $context.Tenant.Id
  } | ConvertTo-Json
  
  # Save the service principal to a file
  $credentialFile = "$UserCredsPath/$Environment.json"
  Write-Output "Saving Service Principal to file ($credentialFile)"
  Set-Content -Value $json -Path $credentialFile
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
  CreateServicePrincipal -Environment $Environment -CredsPath $UserCredsPath `
    | Tee-Object -FilePath $logFile -Append
} catch {
  Write-Output $_ | Tee-Object -FilePath $logFile -Append
  Write-Output $_.Exception | Tee-Object -FilePath $logFile -Append
  throw
} finally {
  Write-Output "Elapsed time: $($stopWatch.Elapsed)" `
    | Tee-Object -FilePath $logFile -Append
}
