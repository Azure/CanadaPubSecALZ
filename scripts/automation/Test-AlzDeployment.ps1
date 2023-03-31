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
    This script creates and removes a CanadaPubSecALZ deployment for each of the two hub network types, AzFW and NVA.

  .DESCRIPTION
    This script creates and removes a CanadaPubSecALZ deployment for each of the two hub network types, AzFW and NVA.

  .PARAMETER Environment
    The name of the environment to test deployment.

  .PARAMETER CredentialFile
    The path to the credential file to use for login.

  .EXAMPLE
    PS> .\New-AlzDeployment.ps1 -Environment 'CanadaALZ-main' -CredentialFile 'CanadaALZ'
#>

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)]
  [string]$Environment,

  [Parameter(Mandatory = $true, ParameterSetName = "CredentialFile")]
  [string]$CredentialFile
)

#Requires -Modules Az, powershell-yaml, PSPasswordGenerator

$ErrorActionPreference = "Stop"

foreach ($NetworkType in @( "NVA", "AzFW" )) {
    .\New-AlzDeployment.ps1 -Environment mcap873443-generic -CredentialFile mcap873443 -NetworkType NVA
    .\Remove-AlzDeployment.ps1 -Environment mcap873443-generic -CredentialFile mcap873443 -Force
}
