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
    This script connects to Azure using a service principal stored in a credential file, a service principal stored in a SecureString, or interactively.

  .DESCRIPTION
    This script connects to Azure using a service principal stored in a credential file, a service principal stored in a SecureString, or interactively.

  .PARAMETER CredentialFile
    The path to the credential file to use for login.

  .PARAMETER SecureServicePrincipal
    The service principal to use for login.

  .PARAMETER TenantId
    The tenant ID to use for interactive login.

  .EXAMPLE
    PS> .\Connect-AlzCredential.ps1 -CredentialFile '$HOME/CanadaALZ.json'

  .EXAMPLE
    PS> .\Connect-AlzCredential.ps1 -SecureServicePrincipal $SecureSP

  .EXAMPLE
    PS> .\Connect-AlzCredential.ps1 -TenantId '00000000-0000-0000-0000-000000000000'
#>

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true, ParameterSetName = "CredentialFile")]
  [string]$CredentialFile,

  [Parameter(Mandatory = $true, ParameterSetName = "ServicePrincipal")]
  [SecureString]$SecureServicePrincipal,

  [Parameter(Mandatory = $true, ParameterSetName = "Interactive")]
  [string]$TenantId
)

switch ($PSCmdlet.ParameterSetName) {
  "CredentialFile" {
    $ServicePrincipalCredentials = Get-Content -Raw -Path $CredentialFile
    $SecureSP = ConvertTo-SecureString -String $ServicePrincipalCredentials -AsPlainText -Force
    .\Connect-AlzCredential.ps1 -SecureServicePrincipal $SecureSP
  }
  "ServicePrincipal" {
    Write-Output "Logging in to Azure using service principal..."
    $ServicePrincipal = ($SecureServicePrincipal | ConvertFrom-SecureString -AsPlainText) | ConvertFrom-Json
    $Password = ConvertTo-SecureString $ServicePrincipal.password -AsPlainText -Force
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ServicePrincipal.appId, $Password
    Connect-AzAccount -ServicePrincipal -TenantId $ServicePrincipal.tenant -Credential $Credential
  }
  "Interactive" {
    $context = Get-AzContext
    if ($context -eq $null) {
      Write-Output "Logging in to Azure using interactive login..."
      Connect-AzAccount -Tenant $TenantId
    }
  }
}
