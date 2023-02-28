<#
----------------------------------------------------------------------------------
Copyright (c) Microsoft Corporation.
Licensed under the MIT license.

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
----------------------------------------------------------------------------------
#>

function Set-Identity {
    param (
        [Parameter(Mandatory = $true)]
        $Context,

        [Parameter(Mandatory = $true)]
        [String]$Region,

        [Parameter(Mandatory = $true)]
        [String]$ManagementGroupId,

        [Parameter(Mandatory = $true)]
        [String]$SubscriptionId,

        [Parameter(Mandatory = $true)]
        [String]$ConfigurationFilePath,

        [Parameter(Mandatory = $true)]
        [String]$LogAnalyticsWorkspaceResourceId
    )

    Set-AzContext -Subscription $SubscriptionId

    $SchemaFilePath = "$($Context.SchemaDirectory)/landingzones/lz-platform-identity.json"
    
    Write-Output "Validation JSON parameter configuration using $SchemaFilePath"
    Get-Content -Raw $ConfigurationFilePath | Test-Json -SchemaFile $SchemaFilePath

    # Load networking configuration
    $Configuration = Get-Content $ConfigurationFilePath | ConvertFrom-Json -Depth 100

    #region Check if Log Analytics Workspace Id is provided.  Otherwise set it.
    $LogAnalyticsWorkspaceResourceIdInFile = $Configuration.parameters | Get-Member -Name logAnalyticsWorkspaceResourceId
    
    if ($null -eq $LogAnalyticsWorkspaceResourceIdInFile -or $Configuration.parameters.logAnalyticsWorkspaceResourceId.value -eq "") {
        $LogAnalyticsWorkspaceIdElement = @{
        logAnalyticsWorkspaceResourceId = @{
            value = $LogAnalyticsWorkspaceResourceId
        }
        }

        $Configuration.parameters | Add-Member $LogAnalyticsWorkspaceIdElement -Force
    }
    #endregion

    Write-Output "Moving Subscription ($SubscriptionId) to Management Group ($ManagementGroupId)"
    New-AzManagementGroupDeployment `
        -ManagementGroupId $ManagementGroupId `
        -Location $Context.DeploymentRegion `
        -TemplateFile "$($Context.WorkingDirectory)/landingzones/utils/mg-move/move-subscription.bicep" `
        -TemplateParameterObject @{
            managementGroupId = $ManagementGroupId
            subscriptionId = $SubscriptionId
        } `
        -Verbose
        
    Write-Output "Deploying Logging to $SubscriptionId in $Region with $ConfigurationFilePath"
    New-AzSubscriptionDeployment `
        -Name "main-$Region" `
        -Location $Region `
        -TemplateFile "$($Context.WorkingDirectory)/landingzones/lz-platform-identity/main.bicep" `
        -TemplateParameterFile $ConfigurationFilePath `
        -Verbose

}