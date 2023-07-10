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

  .PARAMETER ConfigVariablesByRef
    The reference to the configuration variables hashtable.

  .EXAMPLE
    PS> $ConfigVariablesYaml = @{}
    PS> .\Get-AlzConfiguration.ps1 -Environment 'CanadaALZ-main' -ConfigVariablesByRef ([ref]$ConfigVariablesYaml)
#>

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)]
  [string]$Environment,

  [string]$RepoRootPath = "../..",

  [ref]$ConfigVariablesByRef
)

#Requires -Modules powershell-yaml

$ErrorActionPreference = "Stop"

$RepoConfigPath = (Resolve-Path -Path "$RepoRootPath/config/variables/$Environment.yml").Path

Write-Output "Getting environment configuration ($RepoConfigPath)"

if (Test-Path -PathType Leaf -Path $RepoConfigPath) {
  $ConfigVariablesByRef.value = Get-Content -Path $RepoConfigPath -Raw | ConvertFrom-Yaml
} else {
  throw "Environment file not found ($RepoConfigPath)"
}
