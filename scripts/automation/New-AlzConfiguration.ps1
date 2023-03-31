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
    Creates a new configuration for the CanadaPubSecALZ deployment.

  .DESCRIPTION
    This script creates a new set of configuration files, using an existing CanadaPubSecALZ configuration. Select configuration elements are replaced with values specific to the target environment.

  .PARAMETER Environment
    The base name of the YAML environment configuration file.

  .PARAMETER SourceEnvironment
    The name of the source environment. If not specified, the source environment attribute in the environment configuration file is used. If the environment configuration file does not specify a source environment, the environment configuration file base name is used.

  .PARAMETER TargetEnvironment
    The name of the target environment. If not specified, the target environment attribute in the environment configuration file is used. If the environment configuration file does not specify a target environment, the environment configuration file base name is used.

  .PARAMETER RepoRootPath
    The path to the repository directory. Defaults to ../..

  .PARAMETER Force
    If specified, the script will overwrite existing configuration files.

  .PARAMETER UserRootPath
    The path to the user directory. Defaults to $HOME.

  .PARAMETER UserLogsPath
    The path to the user logs directory. Defaults to $UserRootPath/ALZ/logs.

  .PARAMETER UserCredsPath
    The path to the user credentials directory. Defaults to $UserRootPath/ALZ/credentials.

  .PARAMETER UserConfigPath
    The path to the user configuration directory. Defaults to $UserRootPath/ALZ/config.

  .EXAMPLE
    PS> .\New-AlzConfiguration.ps1 -Environment 'CanadaALZ-main'

  .EXAMPLE
    PS> .\New-AlzConfiguration.ps1 -Environment 'CanadaALZ-main' -Force
#>

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)]
  [string]$Environment,

  [string]$SourceEnvironment = $null,

  [string]$TargetEnvironment = $null,

  [string]$RepoRootPath = "../..",

  [switch]$Force = $false,

  [string]$UserRootPath = "$HOME",

  [string]$UserLogsPath = "$UserRootPath/ALZ/logs",

  [string]$UserCredsPath = "$UserRootPath/ALZ/credentials",

  [string]$UserConfigPath = "$UserRootPath/ALZ/config"
)

#Requires -Modules powershell-yaml

$ErrorActionPreference = "Stop"

function ValidateParameters {
  param (
    [Parameter(Mandatory = $true)]
    [object]$Parameters
  )
  Write-Output "Checking configuration path ($RepoConfigPath)"
  if (-not (Test-Path -PathType Container -Path $RepoConfigPath)) {
    throw "Configuration path does not exist."
  }

  # How we determine the source environment name:
  #  1. Use the '$SourceEnvironment' parameter if specified
  #  2. Otherwise, use the 'Environment.Source' attribute in the parameter file if specified
  #  3. Otherwise, use the parameter file (base) name
  if (-not ([string]::IsNullOrEmpty($SourceEnvironment))) {
    $Parameters.Environment.Source = $SourceEnvironment
  } elseif (-not ([string]::IsNullOrEmpty($Parameters.Environment.Source))) {
    $Parameters.Environment.Source = $Parameters.Environment.Source
  } else {
    $Parameters.Environment.Source = $ParameterFile | Split-Path -LeafBase
  }

  # How we determine the target environment name:
  #  1. Use the '$TargetEnvironment' parameter if specified
  #  2. Otherwise, use the 'Environment.Target' attribute in the parameter file if specified
  #  3. Otherwise, use the parameter file (base) name
  if (-not ([string]::IsNullOrEmpty($TargetEnvironment))) {
    $Parameters.Environment.Target = $TargetEnvironment
  } elseif (-not ([string]::IsNullOrEmpty($Parameters.Environment.Target))) {
    $Parameters.Environment.Target = $Parameters.Environment.Target
  } else {
    $Parameters.Environment.Target = $ParameterFile | Split-Path -LeafBase
  }

  if ($Parameters.Environment.Source -eq $Parameters.Environment.Target) {
    throw "Source ($Parameters.Environment.Source) and target ($Parameters.Environment.Target) environments cannot be the same."
  }

  if (-not (Test-Path -PathType Leaf -Path "$RepoConfigPath/variables/$($Parameters.Environment.Source).yml")) {
    throw "Source environment does not exist ($($Parameters.Environment.Source))"
  }

  if (Test-Path -PathType Leaf -Path "$RepoConfigPath/variables/$($Parameters.Environment.Target).yml") {
    if (-not $Force) {
      throw "Target environment already exists ($($Parameters.Environment.Target)). Use the '-Force' parameter to overwrite it."
    }
  }
}

function VariablesConfiguration {
  param (
    [Parameter(Mandatory = $true)]
    [object]$Parameters,
    [ref]$ConfigVariablesByRef
  )
  Write-Output ""
  Write-Output "Generating Variables configurations"
  Write-Output ""

  $file = "$RepoConfigPath/variables/$($Parameters.Environment.Source).yml"
  if (Test-Path -PathType Leaf -Path $file) {
    $ConfigVariablesByRef.value = Get-Content -Path $file -Raw | ConvertFrom-Yaml
  } else {
    throw "Source environment file not found ($file)"
  }

  Write-Output "  Updating variables configuration"

  # Deployment variables
  $ConfigVariablesByRef.value.variables['deploymentRegion'] = $Parameters.DeployRegion ?? $ConfigVariablesByRef.value.variables['deploymentRegion']

  # Management Group Hierarchy variables
  $ConfigVariablesByRef.value.variables['var-managementgroup-hierarchy'] = ($Parameters.ManagementGroupHierarchy | ConvertTo-Json -Depth 100) ?? $ConfigVariablesByRef.value.variables['var-managementgroup-hierarchy']

  # Logging variables
  $ConfigVariablesByRef.value.variables['var-logging-region'] = $Parameters.DeployRegion ?? $ConfigVariablesByRef.value.variables['var-logging-region']
  $ConfigVariablesByRef.value.variables['var-logging-managementGroupId'] = $Parameters.Logging.ManagementGroupId ?? $ConfigVariablesByRef.value.variables['var-logging-managementGroupId']
  $ConfigVariablesByRef.value.variables['var-logging-subscriptionId'] = $Parameters.Logging.SubscriptionId ?? $ConfigVariablesByRef.value.variables['var-logging-subscriptionId']
  $ConfigVariablesByRef.value.variables['var-logging-diagnosticSettingsforNetworkSecurityGroupsStoragePrefix'] = $Parameters.ManagementGroupHierarchy.children[0].id + 'nsg'

  # Identity variables
  $ConfigVariablesByRef.value.variables['var-identity-region'] = $Parameters.DeployRegion ?? $ConfigVariablesByRef.value.variables['var-identity-region']
  $ConfigVariablesByRef.value.variables['var-identity-managementGroupId'] = $Parameters.Identity.ManagementGroupId ?? $ConfigVariablesByRef.value.variables['var-identity-managementGroupId']
  $ConfigVariablesByRef.value.variables['var-identity-subscriptionId'] = $Parameters.Identity.SubscriptionId ?? $ConfigVariablesByRef.value.variables['var-identity-subscriptionId']

  # Hub Network variables
  $ConfigVariablesByRef.value.variables['var-hubnetwork-region'] = $Parameters.DeployRegion ?? $ConfigVariablesByRef.value.variables['var-hubnetwork-region']
  $ConfigVariablesByRef.value.variables['var-hubnetwork-managementGroupId'] = $Parameters.HubNetwork.ManagementGroupId ?? $ConfigVariablesByRef.value.variables['var-hubnetwork-managementGroupId']
  $ConfigVariablesByRef.value.variables['var-hubnetwork-subscriptionId'] = $Parameters.HubNetwork.SubscriptionId ?? $ConfigVariablesByRef.value.variables['var-hubnetwork-subscriptionId']

  # Write the variables configuration file
  $ConfigVariablesFile = "$RepoConfigPath/variables/$($Parameters.Environment.Target).yml"
  Write-Output "  Writing variables configuration file: $ConfigVariablesFile"
  New-Item -ItemType Directory -Path (Split-Path -Parent -Path $ConfigVariablesFile) -Force | Out-Null
  $ConfigVariablesYaml | ConvertTo-Yaml | Set-Content -Path $ConfigVariablesFile | Out-Null
}

function LoggingConfiguration {
  param (
    [Parameter(Mandatory = $true)]
    [object]$Parameters,
    [Parameter(Mandatory = $true)]
    [object]$ConfigVariablesYaml
  )
  Write-Output ""
  Write-Output "Generating Logging configurations"
  Write-Output ""

  $file = "$RepoConfigPath/logging/$($Parameters.Environment.Source)/$($ConfigVariablesYaml.variables['var-logging-configurationFileName'])"
  if (Test-Path -PathType Leaf -Path $file) {
    Write-Output "  Reading source environment logging configuration file: $file"
    $ConfigLoggingJson = Get-Content -Path $file -Raw | ConvertFrom-Json

    Write-Output "  Updating logging configuration"
    $ConfigLoggingJson.{$schema} = 'https://raw.githubusercontent.com/Azure/CanadaPubSecALZ/main/schemas/latest/landingzones/lz-platform-logging.json#'
    $ConfigLoggingJson.parameters.securityCenter.value = $Parameters.Logging.SecurityCenter ?? $ConfigLoggingJson.parameters.securityCenter.value
    $ConfigLoggingJson.parameters.serviceHealthAlerts.value = $Parameters.Logging.ServiceHealthAlerts ?? $ConfigLoggingJson.parameters.serviceHealthAlerts.value
    $ConfigLoggingJson.parameters.subscriptionRoleAssignments.value = $Parameters.Logging.RoleAssignments ?? $ConfigLoggingJson.parameters.subscriptionRoleAssignments.value
    $ConfigLoggingJson.parameters.subscriptionTags.value = $Parameters.values.Logging.SubscriptionTags ?? $ConfigLoggingJson.parameters.subscriptionTags.value
    $ConfigLoggingJson.parameters.resourceTags.value = $Parameters.values.Logging.ResourceTags ?? $ConfigLoggingJson.parameters.resourceTags.value
    $ConfigLoggingJson.parameters.dataCollectionRule.value.enabled = $Parameters.Logging.DataCollectionRule.Enabled ?? $ConfigLoggingJson.parameters.dataCollectionRule.value.enabled

    $ConfigLoggingFile = "$RepoConfigPath/logging/$($Parameters.Environment.Target)/$($ConfigVariablesYaml.variables['var-logging-configurationFileName'])"
    Write-Output "  Writing logging configuration file: $ConfigLoggingFile"
    New-Item -ItemType Directory -Path (Split-Path -Parent -Path $ConfigLoggingFile) -Force | Out-Null
    $ConfigLoggingJson | ConvertTo-Json -Depth 100 | Set-Content -Path $ConfigLoggingFile | Out-Null
  } else {
    Write-Output "  Source environment logging configuration file not found: $file"
  }
}

function IdentityConfiguration {
  param (
    [Parameter(Mandatory = $true)]
    [object]$Parameters,
    [Parameter(Mandatory = $true)]
    [object]$ConfigVariablesYaml
  )
  Write-Output ""
  Write-Output "Generating Identity configurations"
  Write-Output ""

  $file = "$RepoConfigPath/identity/$($Parameters.Environment.Source)/$($ConfigVariablesYaml.variables['var-identity-configurationFileName'])"
  if (Test-Path -PathType Leaf -Path $file) {
    Write-Output "  Reading source environment identity configuration file: $file"
    $ConfigIdentityJson = Get-Content -Path $file -Raw | ConvertFrom-Json

    Write-Output "  Updating identity configuration"
    $ConfigIdentityJson.{$schema} = 'https://raw.githubusercontent.com/Azure/CanadaPubSecALZ/main/schemas/latest/landingzones/lz-platform-identity.json#'
    $ConfigIdentityJson.parameters.securityCenter.value = $Parameters.Identity.SecurityCenter ?? $ConfigIdentityJson.parameters.securityCenter.value
    $ConfigIdentityJson.parameters.serviceHealthAlerts.value = $Parameters.Identity.ServiceHealthAlerts ?? $ConfigIdentityJson.parameters.serviceHealthAlerts.value
    $ConfigIdentityJson.parameters.subscriptionRoleAssignments.value = $Parameters.Identity.RoleAssignments ?? $ConfigIdentityJson.parameters.subscriptionRoleAssignments.value
    $ConfigIdentityJson.parameters.subscriptionTags.value = $Parameters.values.Identity.SubscriptionTags ?? $ConfigIdentityJson.parameters.subscriptionTags.value
    $ConfigIdentityJson.parameters.resourceTags.value = $Parameters.values.Identity.ResourceTags ?? $ConfigIdentityJson.parameters.resourceTags.value

    $ConfigIdentityFile = "$RepoConfigPath/identity/$($Parameters.Environment.Target)/$($ConfigVariablesYaml.variables['var-identity-configurationFileName'])"
    Write-Output "  Writing identity configuration file: $ConfigIdentityFile"
    New-Item -ItemType Directory -Path (Split-Path -Parent -Path $ConfigIdentityFile) -Force | Out-Null
    $ConfigIdentityJson | ConvertTo-Json -Depth 100 | Set-Content -Path $ConfigIdentityFile | Out-Null
  } else {
    Write-Output "  Source environment identity configuration file not found: $file"
  }
}

function NetworkAzfwConfiguration {
  param (
    [Parameter(Mandatory = $true)]
    [object]$Parameters,
    [Parameter(Mandatory = $true)]
    [object]$ConfigVariablesYaml,
    [ref]$ConfigNetworkAzfwByRef
  )
  Write-Output ""
  Write-Output "Generating Network Azure Firewall configurations"
  Write-Output ""

  $file = "$RepoConfigPath/networking/$($Parameters.Environment.Source)/$($ConfigVariablesYaml.variables['var-hubnetwork-azfw-configurationFileName'])"
  if (Test-Path -PathType Leaf -Path $file) {
    Write-Output "  Reading source environment network Azure Firewall configuration file: $file"
    $ConfigNetworkAzfwByRef.value = Get-Content -Path $file -Raw | ConvertFrom-Json

    Write-Output "  Updating network Azure Firewall configuration"
    $ConfigNetworkAzfwByRef.value.{$schema} = 'https://raw.githubusercontent.com/Azure/CanadaPubSecALZ/main/schemas/latest/landingzones/lz-platform-connectivity-hub-azfw.json#'
    $ConfigNetworkAzfwByRef.value.parameters.securityCenter.value = $Parameters.HubNetwork.SecurityCenter ?? $ConfigNetworkAzfwByRef.value.parameters.securityCenter.value
    $ConfigNetworkAzfwByRef.value.parameters.serviceHealthAlerts.value = $Parameters.HubNetwork.ServiceHealthAlerts ?? $ConfigNetworkAzfwByRef.value.parameters.serviceHealthAlerts.value
    $ConfigNetworkAzfwByRef.value.parameters.subscriptionRoleAssignments.value = $Parameters.HubNetwork.RoleAssignments ?? $ConfigNetworkAzfwByRef.value.parameters.subscriptionRoleAssignments.value
    $ConfigNetworkAzfwByRef.value.parameters.subscriptionTags.value = $Parameters.values.HubNetwork.SubscriptionTags ?? $ConfigNetworkAzfwByRef.value.parameters.subscriptionTags.value
    $ConfigNetworkAzfwByRef.value.parameters.resourceTags.value = $Parameters.values.HubNetwork.ResourceTags ?? $ConfigNetworkAzfwByRef.value.parameters.resourceTags.value
    $ConfigNetworkAzfwByRef.value.parameters.privateDnsZones.value = $Parameters.HubNetwork.PrivateDNS ?? $ConfigNetworkAzfwByRef.value.parameters.privateDnsZones.value
    $ConfigNetworkAzfwByRef.value.parameters.ddosStandard.value = $Parameters.HubNetwork.DDoS ?? $ConfigNetworkAzfwByRef.value.parameters.ddosStandard.value

    $ConfigNetworkAzfwFile = "$RepoConfigPath/networking/$($Parameters.Environment.Target)/$($ConfigVariablesYaml.variables['var-hubnetwork-azfw-configurationFileName'])"
    Write-Output "  Writing network Azure Firewall configuration file: $ConfigNetworkAzfwFile"
    New-Item -ItemType Directory -Path (Split-Path -Parent -Path $ConfigNetworkAzfwFile) -Force | Out-Null
    $ConfigNetworkAzfwByRef.value | ConvertTo-Json -Depth 100 | Set-Content -Path $ConfigNetworkAzfwFile | Out-Null
  } else {
    Write-Output "  Source environment network Azure Firewall configuration file not found: $file"
  }
}

function NetworkAzfwPolicyConfiguration {
  param (
    [Parameter(Mandatory = $true)]
    [object]$Parameters,
    [Parameter(Mandatory = $true)]
    [object]$ConfigVariablesYaml
  )
  Write-Output ""
  Write-Output "Generating Network Azure Firewall Policy configurations"
  Write-Output ""

  $file = "$RepoConfigPath/networking/$($Parameters.Environment.Source)/$($ConfigVariablesYaml.variables['var-hubnetwork-azfwPolicy-configurationFileName'])"
  if (Test-Path -PathType Leaf -Path $file) {
    Write-Output "  Reading source environment network Azure Firewall Policy configuration file: $file"
    $ConfigNetworkAzfwPolicyJson = Get-Content -Path $file -Raw | ConvertFrom-Json

    Write-Output "  Updating network Azure Firewall Policy configuration"
    $ConfigNetworkAzfwPolicyJson.{$schema} = 'https://raw.githubusercontent.com/Azure/CanadaPubSecALZ/main/schemas/latest/landingzones/lz-platform-connectivity-hub-azfw-policy.json#'
    $ConfigNetworkAzfwPolicyJson.parameters.resourceTags.value = $Parameters.values.HubNetwork.ResourceTags ?? $ConfigNetworkAzfwPolicyJson.parameters.resourceTags.value

    $ConfigNetworkAzfwPolicyFile = "$RepoConfigPath/networking/$($Parameters.Environment.Target)/$($ConfigVariablesYaml.variables['var-hubnetwork-azfwPolicy-configurationFileName'])"
    Write-Output "  Writing network Azure Firewall Policy configuration file: $ConfigNetworkAzfwPolicyFile"
    New-Item -ItemType Directory -Path (Split-Path -Parent -Path $ConfigNetworkAzfwPolicyFile) -Force | Out-Null
    $ConfigNetworkAzfwPolicyJson | ConvertTo-Json -Depth 100 | Set-Content -Path $ConfigNetworkAzfwPolicyFile | Out-Null
  } else {
    Write-Output "  Source environment network Azure Firewall Policy configuration file not found: $file"
  }
}

function NetworkNvaConfiguration {
  param (
    [Parameter(Mandatory = $true)]
    [object]$Parameters,
    [Parameter(Mandatory = $true)]
    [object]$ConfigVariablesYaml
  )
  Write-Output ""
  Write-Output "Generating Network NVA configurations"
  Write-Output ""

  $file = "$RepoConfigPath/networking/$($Parameters.Environment.Source)/$($ConfigVariablesYaml.variables['var-hubnetwork-nva-configurationFileName'])"
  if (Test-Path -PathType Leaf -Path $file) {
    Write-Output "  Reading source environment network NVA configuration file: $file"
    $ConfigNetworkNvaJson = Get-Content -Path $file -Raw | ConvertFrom-Json

    Write-Output "  Updating network NVA configuration"
    $ConfigNetworkNvaJson.{$schema} = 'https://raw.githubusercontent.com/Azure/CanadaPubSecALZ/main/schemas/latest/landingzones/lz-platform-connectivity-hub-nva.json#'
    $ConfigNetworkNvaJson.parameters.securityCenter.value = $Parameters.HubNetwork.SecurityCenter ?? $ConfigNetworkNvaJson.parameters.securityCenter.value
    $ConfigNetworkNvaJson.parameters.serviceHealthAlerts.value = $Parameters.HubNetwork.ServiceHealthAlerts ?? $ConfigNetworkNvaJson.parameters.serviceHealthAlerts.value
    $ConfigNetworkNvaJson.parameters.subscriptionRoleAssignments.value = $Parameters.HubNetwork.RoleAssignments ?? $ConfigNetworkNvaJson.parameters.subscriptionRoleAssignments.value
    $ConfigNetworkNvaJson.parameters.subscriptionTags.value = $Parameters.values.HubNetwork.SubscriptionTags ?? $ConfigNetworkNvaJson.parameters.subscriptionTags.value
    $ConfigNetworkNvaJson.parameters.resourceTags.value = $Parameters.values.HubNetwork.ResourceTags ?? $ConfigNetworkNvaJson.parameters.resourceTags.value
    $ConfigNetworkNvaJson.parameters.privateDnsZones.value = $Parameters.HubNetwork.PrivateDNS ?? $ConfigNetworkNvaJson.parameters.privateDnsZones.value
    $ConfigNetworkNvaJson.parameters.ddosStandard.value = $Parameters.HubNetwork.DDoS ?? $ConfigNetworkNvaJson.parameters.ddosStandard.value

    $ConfigNetworkNvaFile = "$RepoConfigPath/networking/$($Parameters.Environment.Target)/$($ConfigVariablesYaml.variables['var-hubnetwork-nva-configurationFileName'])"
    Write-Output "  Writing network NVA configuration file: $ConfigNetworkNvaFile"
    New-Item -ItemType Directory -Path (Split-Path -Parent -Path $ConfigNetworkNvaFile) -Force | Out-Null
    $ConfigNetworkNvaJson | ConvertTo-Json -Depth 100 | Set-Content -Path $ConfigNetworkNvaFile | Out-Null
  } else {
    Write-Output "  Source environment network NVA configuration file not found: $file"
  }
}

function SubscriptionConfiguration {
  param (
    [Parameter(Mandatory = $true)]
    [object]$Parameters,
    [object]$ConfigNetworkAzfwJson
  )
  Write-Output ""
  Write-Output "Generating subscription configurations"

  foreach ($subscription in $Parameters.Subscriptions) {
    $pattern = $subscription.keys[0]

    Write-Output ""
    Write-Output "  Looking for source environment subscription configuration file(s) matching specified pattern ($pattern)"
    $templates = @(Get-ChildItem -Path "$RepoConfigPath/subscriptions/$($Parameters.Environment.Source)/*" -File -Recurse | ? { $_.Name -match $pattern })
    if ($templates.Count -gt 0) {
      if ($templates.Count -gt 1) {
        Write-Output "  More than 1 source environment subscription configuration file(s) matching specified pattern found ($pattern); using the first one found"
      }
      $ConfigSubscriptionFile = $templates[0]
      Write-Output "  Reading subscription configuration ($($ConfigSubscriptionFile.Name))"
      $ConfigSubscriptionJson = Get-Content -Path $ConfigSubscriptionFile.FullName -Raw | ConvertFrom-Json
    } else {
      Write-Output "  Source environment subscription configuration file(s) matching specified pattern not found ($pattern)"
      continue
    }

    Write-Output "  Updating subscription configuration"
    $ConfigSubscriptionArchetype = $ConfigSubscriptionFile.Name.Split('_')[1]
    $ConfigSubscriptionJson.{$schema} = "https://raw.githubusercontent.com/Azure/CanadaPubSecALZ/main/schemas/latest/landingzones/lz-$($ConfigSubscriptionArchetype).json#"
    # Not all subscription configuration files have a location parameter
    if ($ConfigSubscriptionJson.parameters.location -ne $null) {
      $ConfigSubscriptionJson.parameters.location.value = $subscription.values.Location ?? $ConfigSubscriptionJson.parameters.location.value
    }
    # Not all subscription configuration files have a privateDnsManagedByHub parameter
    if ($ConfigSubscriptionJson.parameters.hubNetwork.value.privateDnsManagedByHub -ne $null) {
      $ConfigSubscriptionJson.parameters.hubNetwork.value.privateDnsManagedByHub = $Parameters.HubNetwork.PrivateDNS.Enabled ?? $ConfigSubscriptionJson.parameters.hubNetwork.value.privateDnsManagedByHub
    }
    # Not all subscription configuration files have a privateDnsManagedByHubSubscriptionId parameter
    if ($ConfigSubscriptionJson.parameters.hubNetwork.value.privateDnsManagedByHubSubscriptionId -ne $null) {
      $ConfigSubscriptionJson.parameters.hubNetwork.value.privateDnsManagedByHubSubscriptionId = $Parameters.HubNetwork.SubscriptionId ?? $ConfigSubscriptionJson.parameters.hubNetwork.value.privateDnsManagedByHubSubscriptionId
    }
    # Not all subscription configuration files have a privateDnsManagedByHub parameter
    if ($ConfigSubscriptionJson.parameters.hubNetwork.value.privateDnsManagedByHubResourceGroupName -ne $null) {
      $ConfigSubscriptionJson.parameters.hubNetwork.value.privateDnsManagedByHubResourceGroupName = $Parameters.HubNetwork.PrivateDNS.ResourceGroupName ?? $ConfigSubscriptionJson.parameters.hubNetwork.value.privateDnsManagedByHubResourceGroupName
    }
    # All subscription configuration files have the following parameters
    $ConfigSubscriptionJson.parameters.securityCenter.value = $subscription.values.SecurityCenter ?? $ConfigSubscriptionJson.parameters.securityCenter.value
    $ConfigSubscriptionJson.parameters.serviceHealthAlerts.value = $subscription.values.ServiceHealthAlerts ?? $ConfigSubscriptionJson.parameters.serviceHealthAlerts.value
    $ConfigSubscriptionJson.parameters.subscriptionRoleAssignments.value = $subscription.values.RoleAssignments ?? $ConfigSubscriptionJson.parameters.subscriptionRoleAssignments.value
    $ConfigSubscriptionJson.parameters.subscriptionTags.value = $subscription.values.SubscriptionTags ?? $ConfigSubscriptionJson.parameters.subscriptionTags.value
    $ConfigSubscriptionJson.parameters.resourceTags.value = $subscription.values.ResourceTags ?? $ConfigSubscriptionJson.parameters.resourceTags.value
    $ConfigSubscriptionJson.parameters.hubNetwork.value.virtualNetworkId = "/subscriptions/$($ConfigVariablesYaml.variables['var-hubnetwork-subscriptionId'])/resourceGroups/$($ConfigNetworkAzfwJson.parameters.hub.value.resourceGroupName)/providers/Microsoft.Network/virtualNetworks/$($ConfigNetworkAzfwJson.parameters.hub.value.network.name)"

    $NewConfigSubscriptionFile = "$RepoConfigPath/subscriptions/$($Parameters.Environment.Target)/$($subscription.values.ManagementGroupId)/$($subscription.values.SubscriptionId)_$($ConfigSubscriptionArchetype)_$($subscription.values.Location).json"
    Write-Output "  Writing new subscription configuration ($($NewConfigSubscriptionFile))"
    New-Item -ItemType Directory -Path (Split-Path -Parent -Path $NewConfigSubscriptionFile) -Force | Out-Null
    $ConfigSubscriptionJson | ConvertTo-Json -Depth 100 | Set-Content -Path $NewConfigSubscriptionFile | Out-Null
  }

  Write-Output ""
}

# Set script variables
$RepoConfigPath = (Resolve-Path -Path "$RepoRootPath/config").Path
$ParameterFile = (Resolve-Path -Path "$UserConfigPath/$Environment.yml").Path

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
  Write-Output "This script creates a new set of configuration files, using an existing CanadaPubSecALZ configuration. Select configuration elements are replaced with values specific to the target environment." | Tee-Object -FilePath $logFile -Append
  Write-Output "" | Tee-Object -FilePath $logFile -Append

  Write-Output "Reading parameters from file ($ParameterFile)"
  if (-not (Test-Path $ParameterFile)) {
    throw "Parameter file '$ParameterFile' does not exist."
  }
  $Parameters = Get-Content $ParameterFile -Raw | ConvertFrom-Yaml

  ValidateParameters -Parameters $Parameters `
    | Tee-Object -FilePath $logFile -Append

  $ConfigVariablesYaml = @{}
  VariablesConfiguration -Parameters $Parameters -ConfigVariablesByRef ([ref]$ConfigVariablesYaml) `
    | Tee-Object -FilePath $logFile -Append

  LoggingConfiguration -Parameters $Parameters -ConfigVariablesYaml $ConfigVariablesYaml `
    | Tee-Object -FilePath $logFile -Append

  IdentityConfiguration -Parameters $Parameters -ConfigVariablesYaml $ConfigVariablesYaml `
  | Tee-Object -FilePath $logFile -Append

  $ConfigNetworkAzfwJson = @{}
  NetworkAzfwConfiguration -Parameters $Parameters -ConfigVariablesYaml $ConfigVariablesYaml -ConfigNetworkAzfwByRef ([ref]$ConfigNetworkAzfwJson) `
    | Tee-Object -FilePath $logFile -Append

  NetworkAzfwPolicyConfiguration -Parameters $Parameters -ConfigVariablesYaml $ConfigVariablesYaml `
    | Tee-Object -FilePath $logFile -Append

  NetworkNvaConfiguration -Parameters $Parameters -ConfigVariablesYaml $ConfigVariablesYaml `
    | Tee-Object -FilePath $logFile -Append

  SubscriptionConfiguration -Parameters $Parameters -ConfigNetworkAzfwJson $ConfigNetworkAzfwJson `
    | Tee-Object -FilePath $logFile -Append

} catch {
  Write-Output $_ | Tee-Object -FilePath $logFile -Append
  Write-Output $_.Exception | Tee-Object -FilePath $logFile -Append
  throw
} finally {
  Write-Output "Elapsed time: $($stopWatch.Elapsed)" `
    | Tee-Object -FilePath $logFile -Append
}
