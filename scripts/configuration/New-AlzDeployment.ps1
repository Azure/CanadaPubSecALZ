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
    This script creates a CanadaPubSecALZ deployment, based on information present in the configuration files.

  .DESCRIPTION
    This script creates a CanadaPubSecALZ deployment, based on information present in the configuration files.

  .PARAMETER Environment
    The name of the environment to deploy.

  .PARAMETER NetworkType
    The type of network to deploy. Valid values are "AzFW" and "NVA". Default is "AzFW".

  .PARAMETER CredentialFile
    The path to the credential file to use for login.

  .PARAMETER SecureServicePrincipal
    The service principal to use for login.

  .PARAMETER TenantId
    The tenant ID to use for interactive login.

  .PARAMETER RepoRootPath
    The path to the repository directory.

  .PARAMETER UserRootPath
    The path to the user directory.

  .PARAMETER UserLogsPath
    The path to the user logs directory.

  .PARAMETER UserCredsPath
    The path to the user credentials directory.

  .PARAMETER UserConfigPath
    The path to the user configuration directory.

  .EXAMPLE
    PS> .\New-AlzDeployment.ps1 -Environment 'CanadaALZ-main' -CredentialFile 'CanadaALZ' -NetworkType 'AzFW'

    Deploy the CanadaALZ-main environment with Azure Firewall hub network using a credential file.

  .EXAMPLE
    PS> .\New-AlzDeployment.ps1 -Environment 'CanadaALZ-main' -SecureServicePrincipal $SecureSP -NetworkType 'NVA'

    Deploy the CanadaALZ-main environment with NVA hub network using a service principal.
#>

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)]
  [string]$Environment,

  [Parameter(Mandatory = $true)]
  [ValidateSet("AzFW", "NVA")]
  [string]$NetworkType,

  [Parameter(Mandatory = $true, ParameterSetName = "CredentialFile")]
  [string]$CredentialFile,

  [Parameter(Mandatory = $true, ParameterSetName = "ServicePrincipal")]
  [SecureString]$SecureServicePrincipal,

  [Parameter(Mandatory = $true, ParameterSetName = "Interactive")]
  [string]$TenantId,

  [string]$RepoRootPath = "../..",

  [string]$UserRootPath = "$HOME",

  [string]$UserLogsPath = "$UserRootPath/ALZ/logs",

  [string]$UserCredsPath = "$UserRootPath/ALZ/credentials",

  [string]$UserConfigPath = "$UserRootPath/ALZ/config"
)

#Requires -Modules Az, powershell-yaml, PSPasswordGenerator

$ErrorActionPreference = "Stop"

#region Functions

function CreateDeployment {
  param(
    [string]$Environment,
    [string]$RepoRootPath,
    [string]$NetworkType,
    [string[]]$SubscriptionIds
  )
  try {
    Push-Location -Path "$RepoRootPath/scripts/deployments"
    if ($NetworkType -ieq "AzFW") {
      Write-Output "Deploying environment ($Environment) with Azure Firewall"
      .\RunWorkflows.ps1 `
        -EnvironmentName $Environment `
        -DeployManagementGroups `
        -DeployRoles `
        -DeployLogging `
        -DeployCustomPolicyDefinitions `
        -DeployCustomPolicySetDefinitions `
        -DeployCustomPolicySetAssignments `
        -DeployBuiltinPolicySetAssignments `
        -DeployAzureFirewallPolicy `
        -DeployHubNetworkWithAzureFirewall `
        -DeployIdentity `
        -DeploySubscriptionIds $SubscriptionIds
    } elseif ($NetworkType -ieq "NVA") {
      Write-Output "Generating temporary NVA credentials"
      $nvaUsername = ConvertTo-SecureString -String ($env:USER ?? $env:USERNAME) -AsPlainText
      $nvaPassword = Get-RandomPassword -Length 16 -StartWithLetter

      Write-Output "Deploying environment ($Environment) with NVA firewall"
      Write-Output "NVA credentials (save these in a secure location"
      Write-Output "  Username: $(ConvertFrom-SecureString -SecureString $nvaUsername -AsPlainText)"
      Write-Output "  Password: $(ConvertFrom-SecureString -SecureString $nvaPassword -AsPlainText)"

      .\RunWorkflows.ps1 `
        -EnvironmentName $Environment `
        -DeployManagementGroups `
        -DeployRoles `
        -DeployLogging `
        -DeployCustomPolicyDefinitions `
        -DeployCustomPolicySetDefinitions `
        -DeployCustomPolicySetAssignments `
        -DeployBuiltinPolicySetAssignments `
        -DeployHubNetworkWithNVA `
        -NvaUserName $nvaUsername `
        -NvaPassword $nvaPassword `
        -DeployIdentity `
        -DeploySubscriptionIds $SubscriptionIds

    } else {
      throw "Invalid network type ($NetworkType)"
    }
  } catch {
    throw
  } finally {
    Pop-Location
  }
}

#endregion Functions

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
  Write-Output "This script creates a new deployment, using an existing CanadaPubSecALZ configuration ($Environment)." | Tee-Object -FilePath $logFile -Append
  Write-Output "" | Tee-Object -FilePath $logFile -Append

  $ConfigVariablesYaml = @{}
  .\Get-AlzConfiguration.ps1 -Environment $Environment -RepoRootPath $RepoRootPath -ConfigVariablesByRef ([ref]$ConfigVariablesYaml) `
    | Tee-Object -FilePath $logFile -Append

  $mgh = ($ConfigVariablesYaml.variables['var-managementgroup-hierarchy'] | ConvertFrom-Json)

  switch ($PSCmdlet.ParameterSetName) {
    "CredentialFile" {
      .\Connect-AlzCredential.ps1 -CredentialFile "$UserCredsPath/$CredentialFile.json" `
        | Tee-Object -FilePath $logFile -Append
    }
    "ServicePrincipal" {
      .\Connect-AlzCredential.ps1 -SecureServicePrincipal $SecureServicePrincipal `
        | Tee-Object -FilePath $logFile -Append
    }
    "Interactive" {
      .\Connect-AlzCredential.ps1 -TenantId $mgh.id `
        | Tee-Object -FilePath $logFile -Append
    }
  }

  $context = Get-AzContext
  if ($context.Tenant.Id -ne $mgh.id) {
    throw "You are not logged in to the correct tenant. You are logged in to $($context.Tenant.Id), but you should be logged in to $($mgh.id)."
  }

  $SubscriptionIds = @()
  .\Get-AlzSubscriptions.ps1 -Environment $Environment -RepoRootPath $RepoRootPath -SubscriptionIdsByRef ([ref]$SubscriptionIds) `
    | Tee-Object -FilePath $logFile -Append

  CreateDeployment -Environment $Environment -RepoRootPath $RepoRootPath -NetworkType $NetworkType -SubscriptionIds $SubscriptionIds `
    | Tee-Object -FilePath $logFile -Append

} catch {
  Write-Output $_ | Tee-Object -FilePath $logFile -Append
  Write-Output $_.Exception | Tee-Object -FilePath $logFile -Append
  throw
} finally {
  Write-Output "Elapsed time: $($stopWatch.Elapsed)" `
    | Tee-Object -FilePath $logFile -Append
}
