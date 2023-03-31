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
    Removes a CanadaPubSecALZ deployment in its entirety, based on information present in the configuration files.

  .DESCRIPTION
    This script removes (destroys) a CanadaPubSecALZ deployment, using an existing CanadaPubSecALZ configuration.

  .PARAMETER Environment
    The name of the environment to deploy.

  .PARAMETER CredentialFile
    The path to the credential file to use for login.

  .PARAMETER SecureServicePrincipal
    The service principal to use for login.

  .PARAMETER TenantId
    The tenant ID to use for interactive login.

  .PARAMETER Force
    Prompt for confirmation before removing the deployment.

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
    PS> .\Remove-AlzDeployment.ps1 -Environment 'CanadaALZ-main' -CredentialFile 'CanadaALZ'

    Remove the CanadaALZ-main deployment using a credential file.

  .EXAMPLE
    PS> .\Remove-AlzDeployment.ps1 -Environment 'CanadaALZ-main' -SecureServicePrincipal $SecureSP

    Remove the CanadaALZ-main deployment using a service principal.
#>

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)]
  [string]$Environment,
  
  [Parameter(Mandatory = $true, ParameterSetName = "CredentialFile")]
  [string]$CredentialFile,

  [Parameter(Mandatory = $true, ParameterSetName = "ServicePrincipal")]
  [SecureString]$SecureServicePrincipal,

  [Parameter(Mandatory = $true, ParameterSetName = "Interactive")]
  [string]$TenantId,

  [string]$RepoRootPath = "../..",

  [switch]$Force = $false,

  [string]$UserRootPath = "$HOME",

  [string]$UserLogsPath = "$UserRootPath/ALZ/logs",

  [string]$UserCredsPath = "$UserRootPath/ALZ/credentials",

  [string]$UserConfigPath = "$UserRootPath/ALZ/config"
)

#Requires -Modules Az, powershell-yaml

$ErrorActionPreference = "Stop"

#region Functions

function Remove-ResourceGroupLocks {
  param(
    [string]$ResourceGroupName
  )
  (Get-PSCallStack).ForEach({Write-Debug "  ** $($_.FunctionName) $($_.Arguments) $($_.Location)"})

  Write-Verbose "Checking resource group locks for resource group ($ResourceGroupName)"
  $locks = Get-AzResourceLock -ResourceGroupName $ResourceGroupName

  foreach ($lock in $locks) {
    Write-Output "Removing resource group lock ($($lock.Name)) from resource group ($ResourceGroupName)"
    Remove-AzResourceLock -Name $lock.Name -ResourceGroupName $ResourceGroupName -Force
  }
}

function Remove-SubnetDelegations {
  param(
    [string]$VirtualNetworkName,
    [string]$ResourceGroupName
  )
  (Get-PSCallStack).ForEach({Write-Debug "  ** $($_.FunctionName) $($_.Arguments) $($_.Location)"})

  Write-Verbose "Checking subnet delegations for virtual network ($VirtualNetworkName) in resource group ($ResourceGroupName)"
  $network = @{
    Name = $VirtualNetworkName
    ResourceGroupName = $ResourceGroupName
  }
  $vnet = Get-AzVirtualNetwork @network
  $subnets = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet
  foreach ($subnet in $subnets) {
    foreach ($delegation in $subnet.Delegations) {
      Write-Output "Removing subnet delegation ($($delegation.Name)) from subnet ($($subnet.Name)) of virtual network ($VirtualNetworkName) in resource group ($ResourceGroupName)"
      Remove-AzDelegation -Name $delegation.Name -Subnet $subnet
      $vnet | Set-AzVirtualNetwork
    }
  }
}

function Remove-SubnetsNetworkPoliciesAndDelegations {
  param(
    [string]$VirtualNetworkName,
    [string]$ResourceGroupName
  )
  (Get-PSCallStack).ForEach({Write-Debug "  ** $($_.FunctionName) $($_.Arguments) $($_.Location)"})

  Write-Verbose "Checking subnets network policies and delegations for virtual network ($VirtualNetworkName) in resource group ($ResourceGroupName)"
  $network = @{
    Name = $VirtualNetworkName
    ResourceGroupName = $ResourceGroupName
  }
  $vnet = Get-AzVirtualNetwork @network
  $subnets = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet
  foreach ($subnet in $subnets) {
    Write-Verbose "Checking subnet ($($subnet.Name)) of virtual network ($VirtualNetworkName) in resource group ($ResourceGroupName) for network policies and delegations"

    if ($subnet.PrivateEndpointNetworkPolicies -eq "Disabled" -and $subnet.PrivateLinkServiceNetworkPolicies -eq "Disabled" -and $subnet.Delegations.Count -eq 0) {
      Write-Verbose "Skipping subnet ($($subnet.Name)) of virtual network ($VirtualNetworkName) in resource group ($ResourceGroupName) because it has no network policies or delegations"
      continue
    }
    
    # Remove all delegations
    $delegationNames = $subnet.Delegations.Name
    foreach ($delegationName in $delegationNames) {
      Write-Output "Removing subnet delegation ($delegationName) from subnet ($($subnet.Name)) of virtual network ($VirtualNetworkName) in resource group ($ResourceGroupName)"
      Remove-AzDelegation -Name $delegationName -Subnet $subnet
    }

    # Disable network policies
    $config = @{
      Name = $subnet.Name
      VirtualNetwork = $vnet
      AddressPrefix = $subnet.AddressPrefix
      PrivateEndpointNetworkPolicies = "Disabled"   # Maybe add "Flag" to name?
      PrivateLinkServiceNetworkPolicies = "Disabled"  # Maybe add "Flag" to name?
    }
    Write-Output "Disabling network policies in subnet ($($subnet.Name)) of virtual network ($VirtualNetworkName) in resource group ($ResourceGroupName)"
    Set-AzVirtualNetworkSubnetConfig @config
    
    $vnet | Set-AzVirtualNetwork

    #region SERVICE ASSOCIATION LINK related error
    <#
      If you get the following error, it is because the subnet has a service association link, which is created when the private endpoint was originally deployed. As a result, the removal of all delegations (equivalent to setting to `None`) is not allowed. You must first remove the service association link, then remove the delegations, then remove the subnet.

        Failed to save subnet 'webapp'. Error: 'Subnet health-network/providers/Microsoft.Network/virtualNetworks/health-vnet/subnets/webapp'>health-vnet/webapp requires any of the following delegation(s) [Microsoft.Web/serverFarms] to reference service association link /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/health-network/providers/Microsoft.Network/virtualNetworks/health-vnet/subnets/webapp/serviceAssociationLinks/AppServiceLink.'

      Here are some web links that may help:
        * https://learn.microsoft.com/en-us/answers/questions/140197/unable-to-delete-vnet-due-to-serviceassociationlin.html
        * https://github.com/Azure/azure-cli/issues/21637
        * https://github.com/MicrosoftDocs/azure-docs/issues/48902
      
      Once you disconnect the vnet from app service via the Azure Portal, you should be able to set the delegation back to None and unselect the service endpoint and finally be able to delete the subnet respectively.
    #>
    #endregion
  }
}

function Remove-ResourceGroup {
  param(
    [string]$ResourceGroupName
  )
  (Get-PSCallStack).ForEach({Write-Debug "  ** $($_.FunctionName) $($_.Arguments) $($_.Location)"})

  Remove-ResourceGroupLocks -ResourceGroupName $ResourceGroupName

  #region Remove all route tables in this resource group from all subnets, otherwise the resource group cannot be deleted if there are subnets in another resource group that are associated with these route tables.
  # https://github.com/HarvestingClouds/PowerShellSamples/blob/master/Scripts/User%20Defined%20Routes%20(UDRs)%20or%20Route%20Tables%20Related%20Scripts/Disassociate-SubnetsFromUDRs.ps1
  Write-Verbose "Checking for route tables in resource group ($ResourceGroupName) in all subnets"
  $routeTables = Get-AzRouteTable -ResourceGroupName $ResourceGroupName
  foreach ($routeTable in $routeTables) {
    foreach ($routeSubnet in $routeTable.Subnets) {
      $parts = $routeSubnet.Id.Split('/')
      $subscriptionId = $parts[2]
      $vNetResourceGroupName = $parts[4]
      $virtualNetworkName = $parts[8]
      $routeSubnetName = $parts[10]

      Remove-SubnetsNetworkPoliciesAndDelegations -VirtualNetworkName $virtualNetworkName -ResourceGroupName $vNetResourceGroupName
      # Remove-SubnetDelegations -VirtualNetworkName $virtualNetworkName -ResourceGroupName $vNetResourceGroupName

      $virtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $vNetResourceGroupName -Name $virtualNetworkName
      $subnet = $virtualNetwork.Subnets | ? { $_.Name -eq $routeSubnetName }
      $subnet.RouteTable = $null
      Write-Output "Removing route table from subnet ($routeSubnetName) in virtual network ($virtualNetworkName) in resource group ($vNetResourceGroupName)"
      # Set-AzVirtualNetworkSubnetConfig -Name $routeSubnetName -VirtualNetwork $virtualNetwork -AddressPrefix $subnet.AddressPrefix -RouteTable $null | Set-AzVirtualNetwork
      $subnetConfig = @{
        Name = $routeSubnetName
        VirtualNetwork = $virtualNetwork
        AddressPrefix = $subnet.AddressPrefix
        RouteTable = $null
        # PrivateEndpointNetworkPoliciesFlag = "Disabled"
        # PrivateLinkServiceNetworkPoliciesFlag = "Disabled"
      }
      Set-AzVirtualNetworkSubnetConfig @subnetConfig | Set-AzVirtualNetwork
    }
  }
  #endregion

  #region Disassociate all network security groups in this resource group from all subnets, otherwise the resource group cannot be deleted.
  # https://learn.microsoft.com/en-us/azure/virtual-network/manage-network-security-group?tabs=network-security-group-powershell#associate-or-dissociate-a-network-security-group-to-or-from-a-subnet
  Write-Verbose "Checking for network security group associations in resource group ($ResourceGroupName) in all subnets"
  $nsgs = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName
  foreach ($nsg in $nsgs) {
    foreach ($nsgSubnet in $nsg.Subnets) {
      $parts = $nsgSubnet.Id.Split('/')
      $subscriptionId = $parts[2]
      $vNetResourceGroupName = $parts[4]
      $virtualNetworkName = $parts[8]
      $nsgSubnetName = $parts[10]

      Remove-SubnetsNetworkPoliciesAndDelegations -VirtualNetworkName $virtualNetworkName -ResourceGroupName $vNetResourceGroupName
      # Remove-SubnetDelegations -VirtualNetworkName $virtualNetworkName -ResourceGroupName $vNetResourceGroupName

      $virtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $vNetResourceGroupName -Name $virtualNetworkName
      $subnet = $virtualNetwork.Subnets | ? { $_.Name -eq $nsgSubnetName }
      $subnet.NetworkSecurityGroup = $null
      Write-Output "Removing network security group from subnet ($nsgSubnetName) in virtual network ($virtualNetworkName) in resource group ($vNetResourceGroupName)"
      # Set-AzVirtualNetworkSubnetConfig -Name $nsgSubnetName -VirtualNetwork $virtualNetwork -AddressPrefix $subnet.AddressPrefix -NetworkSecurityGroup $null | Set-AzVirtualNetwork
      $subnetConfig = @{
        Name = $nsgSubnetName
        VirtualNetwork = $virtualNetwork
        AddressPrefix = $subnet.AddressPrefix
        RouteTable = $null
        # PrivateEndpointNetworkPoliciesFlag = "Disabled"
        # PrivateLinkServiceNetworkPoliciesFlag = "Disabled"
      }
      Set-AzVirtualNetworkSubnetConfig @subnetConfig | Set-AzVirtualNetwork
    }
  }
  #endregion

  #region Disassociate all network interface associations to network security groups in this resource group from all network interfaces, otherwise the resource group cannot be deleted.
  # https://learn.microsoft.com/en-us/powershell/module/az.network/set-aznetworkinterface?view=azps-9.2.0#example-5-associate-dissociate-a-network-security-group-to-a-network-interface
  Write-Verbose "Checking for network security group associations in resource group ($ResourceGroupName) in all network interfaces"
  $nics = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName
  foreach ($nic in $nics) {
    if ($nic.NetworkSecurityGroup -ne $null) {
      $nic.NetworkSecurityGroup = $null
      Write-Output "Removing network security group from network interface ($($nic.Name)) in resource group ($ResourceGroupName)"
      $nic | Set-AzNetworkInterface
    }
  }
  #endregion

  #region Remove private endpoints associated with subnets in this resource group, otherwise the resource group cannot be deleted.
  Write-Verbose "Checking for private endpoints associated with subnets in resource group ($ResourceGroupName)"
  $subnets = (Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName).Subnets
  foreach ($subnet in $subnets) {
    $privateEndpoints = $subnet.PrivateEndpoints
    foreach ($privateEndpoint in $privateEndpoints) {
      $parts = $privateEndpoint.Id.Split('/')
      $subscriptionId = $parts[2]
      $privateEndpointResourceGroupName = $parts[4]
      $privateEndpointName = $parts[8]
      Write-Output "Removing private endpoint ($privateEndpointName) in resource group ($privateEndpointResourceGroupName)"
      Remove-AzPrivateEndpoint -Name $privateEndpointName -ResourceGroupName $privateEndpointResourceGroupName -Force
    }
  }
  #endregion

  #region Remove (any remaining) network interface associations to subnets in this resource group, otherwise the resource group cannot be deleted. Do this *after* the private endpoints are removed, since any network interfaces associated with private endpoints will be removed when the private endpoints are removed.
  Write-Verbose "Checking for any remaining network interface associations to subnets in resource group ($ResourceGroupName)"
  $subnets = (Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName).Subnets
  foreach ($subnet in $subnets) {
    $ipConfigurations = $subnet.IpConfigurations
    foreach ($ipConfiguration in $ipConfigurations) {
      $parts = $ipConfiguration.Id.Split('/')
      $subscriptionId = $parts[2]
      $nicResourceGroupName = $parts[4]
      $networkInterfaceName = $parts[8]
      $ipConfigurationName = $parts[10]
      try {
        $networkInterface = Get-AzNetworkInterface -ResourceGroupName $nicResourceGroupName -Name $networkInterfaceName
        $ipConfiguration = $networkInterface.IpConfigurations | ? { $_.Name -eq $ipConfigurationName }
        $ipConfiguration.Subnet = $null
        Write-Output "Removing subnet from network interface ($networkInterfaceName) in resource group ($nicResourceGroupName)"
        $networkInterface | Set-AzNetworkInterface
      } catch {
        Write-Output "Error removing subnet from network interface ($networkInterfaceName) in resource group ($nicResourceGroupName): $($_.Exception.Message)"
        Write-Output "This is expected if the network interface was associated with a private endpoint that has already been removed."
      }
    }
  }
  #endregion

  # Finally, remove the resource group
  Write-Output "Removing resource group ($ResourceGroupName)"
  Remove-AzResourceGroup -Name $ResourceGroupName -Force
}

function Remove-RoleAssignments {
  param(
    [string]$Scope
  )
  (Get-PSCallStack).ForEach({Write-Debug "  ** $($_.FunctionName) $($_.Arguments) $($_.Location)"})

  Write-Verbose "Checking role assignments for scope ($Scope)"
  $roles = Get-AzRoleDefinition -Custom
  foreach ($role in $roles) {
    $assignments = Get-AzRoleAssignment -RoleDefinitionName $role.Name | ? { $_.Scope -eq $Scope }
    foreach ($assignment in $assignments) {
      Write-Output "Removing role assignment ($($assignment.RoleDefinitionName)) at scope  ($Scope)"
      Remove-AzRoleAssignment -ObjectId $assignment.ObjectId -RoleDefinitionName $assignment.RoleDefinitionName
    }
  }
}

function Remove-PolicyAssignments {
  param(
    [string]$Scope
  )
  (Get-PSCallStack).ForEach({Write-Debug "  ** $($_.FunctionName) $($_.Arguments) $($_.Location)"})

  Write-Verbose "Checking policy assignments for scope ($Scope)"
  $assignments = Get-AzPolicyAssignment -Scope $Scope | ? { $_.Properties.Scope -eq $Scope }
  foreach ($assignment in $assignments) {
    Write-Output "Removing policy assignment ($($assignment.Name)) for policy ($($assignment.Properties.PolicyDefinitionId))"
    $assignment | Remove-AzPolicyAssignment
  }
}

function Remove-Subscription {
  param(
    [string]$SubscriptionId
  )
  (Get-PSCallStack).ForEach({Write-Debug "  ** $($_.FunctionName) $($_.Arguments) $($_.Location)"})

  Write-Verbose "Removing subscription resources ($SubscriptionId)"
  Set-AzContext -Subscription $SubscriptionId

  Remove-RoleAssignments -Scope "/subscriptions/$subscriptionId"

  Remove-PolicyAssignments -Scope "/subscriptions/$subscriptionId"

  foreach ($resourceGroup in @(Get-AzResourceGroup)) {
    Write-Output "Removing resource group ($($resourceGroup.ResourceGroupName))"
    Remove-ResourceGroup -ResourceGroupName $resourceGroup.ResourceGroupName
  }
}

function Remove-Firewall {
  param(
    [string]$SubscriptionId
  )
  (Get-PSCallStack).ForEach({Write-Debug "  ** $($_.FunctionName) $($_.Arguments) $($_.Location)"})

  Write-Verbose "Removing firewalls in subscription ($SubscriptionId)"
  Set-AzContext -Subscription $SubscriptionId

  Write-Output "Getting firewalls in subscription ($SubscriptionId)"
  $firewalls = Get-AzFirewall | ? { $_.Id.StartsWith("/subscriptions/$SubscriptionId") }

  foreach ($firewall in $firewalls) {
    $policy = $firewall.FirewallPolicy
    if ($policy -ne $null) {
      Remove-ResourceGroupLocks -ResourceGroupName $firewall.ResourceGroupName

      Write-Output "Removing firewall ($($firewall.Name)) in resource group ($($firewall.ResourceGroupName))"
      Remove-AzFirewall -Name $firewall.Name -ResourceGroupName $firewall.ResourceGroupName -Force

      Write-Output "Removing firewall policy ($($policy.Name))"
      Remove-AzFirewallPolicy -ResourceId $policy.Id -Force
    }
  }
}

function Remove-ManagementGroup {
  param(
    [object]$ManagementGroupNode,
    [object]$ManagementGroupRoot
  )
  (Get-PSCallStack).ForEach({Write-Debug "  ** $($_.FunctionName) $($_.Arguments) $($_.Location)"})

  foreach ($child in $ManagementGroupNode.children) {
    Remove-ManagementGroup -ManagementGroupNode $child -ManagementGroupRoot $ManagementGroupRoot
  }
  try {
    Write-Verbose "Checking management group ($($ManagementGroupNode.name))"
    $managementGroup = Get-AzManagementGroup -GroupId $ManagementGroupNode.id
  } catch {
    Write-Verbose "Management group ($($ManagementGroupNode.name)) not found"
    return
  }
  try {
    Write-Verbose "Checking subscriptions in management group ($($ManagementGroupNode.name))"
    $subscriptions = Get-AzManagementGroupSubscription -GroupId $ManagementGroupNode.id
  } catch {
    Write-Verbose "No subscriptions found in management group ($($ManagementGroupNode.name))"
    $subscriptions = @()
  }
  foreach ($subscription in $subscriptions) {
    $parts = $subscription.Id.Split('/')
    $subscriptionId = $parts[$parts.Count - 1]

    Write-Verbose "Setting context to subscription ($subscriptionId)"
    Set-AzContext -Subscription $subscriptionId

    Remove-RoleAssignments -Scope "/subscriptions/$subscriptionId"

    Remove-PolicyAssignments -Scope "/subscriptions/$subscriptionId"

    # ------------------------------------------------------------
    # Either remove the subscription from the management group or move it to the root management group
    # ------------------------------------------------------------
    
    # Move the subscription to the root management group
    # https://docs.microsoft.com/en-us/azure/governance/management-groups/overview#move-subscriptions-between-management-groups
    # Write-Output "Moving subscription ($subscriptionId) from management group ($($ManagementGroupNode.name)) to management group ($($ManagementGroupRoot.name))"
    # New-AzManagementGroupSubscription -GroupId $ManagementGroupRoot.id -SubscriptionId $subscriptionId

    # ------------------------------------------------------------

    # Remove the subscription from the management group
    # https://docs.microsoft.com/en-us/azure/governance/management-groups/overview#remove-subscriptions-from-a-management-group
    Write-Output "Removing subscription ($subscriptionId) from management group ($($ManagementGroupNode.name))"
    Remove-AzManagementGroupSubscription -GroupId $ManagementGroupNode.id -SubscriptionId $subscriptionId

    # ------------------------------------------------------------
  }

  Remove-PolicyAssignments -Scope "/providers/Microsoft.Management/managementGroups/$($ManagementGroupNode.id)"

  Remove-RoleAssignments -Scope "/providers/Microsoft.Management/managementGroups/$($ManagementGroupNode.id)"

  Write-Output "Removing management group ($($ManagementGroupNode.name))"
  Remove-AzManagementGroup -GroupId $ManagementGroupNode.id
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

  Write-Output "" `
    | Tee-Object -FilePath $logFile -Append
  Write-Output "This script removes a CanadaPubSecALZ deployment, using an existing CanadaPubSecALZ configuration ($Environment)" `
    | Tee-Object -FilePath $logFile -Append
  Write-Output "" `
    | Tee-Object -FilePath $logFile -Append
  Write-Output "NOTE: the following resources in the Azure deployment will be removed:" `
    | Tee-Object -FilePath $logFile -Append
  Write-Output "  * resources in the logging subscription" `
    | Tee-Object -FilePath $logFile -Append
  Write-Output "  * resources in the hub network subscription" `
    | Tee-Object -FilePath $logFile -Append
  Write-Output "  * resources in the archetype subscription(s)" `
    | Tee-Object -FilePath $logFile -Append
  Write-Output "  * policy assignments" `
    | Tee-Object -FilePath $logFile -Append
  Write-Output "  * custom role assignments" `
    | Tee-Object -FilePath $logFile -Append
  Write-Output "  * management groups" `
    | Tee-Object -FilePath $logFile -Append
  Write-Output "" `
    | Tee-Object -FilePath $logFile -Append

  if (-not $Force) {
    if ((Read-Host -Prompt "Are you sure you want to continue? (y/N)") -ine "y") {
      exit
    }
  }

  $ConfigVariablesYaml = @{}
  .\Get-AlzConfiguration.ps1 -Environment $Environment -RepoRootPath $RepoRootPath -ConfigVariablesByRef ([ref]$ConfigVariablesYaml)

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

  # Ensure the user is logged in to the correct tenant
  $context = Get-AzContext
  if ($context.Tenant.Id -ne $mgh.id) {
    throw "You are not logged in to the correct tenant. You are logged in to $($context.Tenant.Id), but you should be logged in to $($mgh.id)."
  }

  # Remove policies at the management group level
  Remove-PolicyAssignments -Scope "/providers/Microsoft.Management/managementGroups/$($mgh.children.id)" `
    | Tee-Object -FilePath $logFile -Append

  # Remove the archetype subscriptions
  Write-Output "" | Tee-Object -FilePath $logFile -Append
  Write-Output "Removing archetype subscriptions..." `
    | Tee-Object -FilePath $logFile -Append
  $SubscriptionIds = @()
  .\Get-AlzSubscriptions.ps1 -Environment $Environment -RepoRootPath $RepoRootPath -SubscriptionIdsByRef ([ref]$SubscriptionIds) `
    | Tee-Object -FilePath $logFile -Append
  foreach ($SubscriptionId in $SubscriptionIds) {
    Remove-Subscription -SubscriptionId $SubscriptionId `
      | Tee-Object -FilePath $logFile -Append
  }

  # Remove firewall
  Write-Output "" | Tee-Object -FilePath $logFile -Append
  Write-Output "Removing firewall..." `
    | Tee-Object -FilePath $logFile -Append
  $networkingSubscriptionId = $ConfigVariablesYaml.variables['var-hubnetwork-subscriptionId']
  Remove-Firewall -SubscriptionId $networkingSubscriptionId `
    | Tee-Object -FilePath $logFile -Append

  # Remove the hub network subscription
  Write-Output "" | Tee-Object -FilePath $logFile -Append
  Write-Output "Removing hub network subscription..." `
    | Tee-Object -FilePath $logFile -Append
  $networkingSubscriptionId = $ConfigVariablesYaml.variables['var-hubnetwork-subscriptionId']
  Remove-Subscription -SubscriptionId $networkingSubscriptionId `
    | Tee-Object -FilePath $logFile -Append

  # Remove the logging subscription
  Write-Output "" | Tee-Object -FilePath $logFile -Append
  Write-Output "Removing logging subscription..." `
    | Tee-Object -FilePath $logFile -Append
  $loggingSubscriptionId = $ConfigVariablesYaml.variables['var-logging-subscriptionId']
  Remove-Subscription -SubscriptionId $loggingSubscriptionId `
    | Tee-Object -FilePath $logFile -Append

  # Remove the management groups
  Write-Output "" | Tee-Object -FilePath $logFile -Append
  Write-Output "Removing management groups..." `
    | Tee-Object -FilePath $logFile -Append
  Remove-ManagementGroup -ManagementGroupNode $mgh.children -ManagementGroupRoot $mgh `
    | Tee-Object -FilePath $logFile -Append
} catch {
  Write-Output $_ | Tee-Object -FilePath $logFile -Append
  Write-Output $_.Exception | Tee-Object -FilePath $logFile -Append
  throw
} finally {
  Write-Output "Elapsed time: $($stopWatch.Elapsed)" `
    | Tee-Object -FilePath $logFile -Append
}
