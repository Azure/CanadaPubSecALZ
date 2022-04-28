Import-Module powershell-yaml

# Configuration
$WorkingDirectory = "../../"
$Environment = "CanadaESLZ-main"
$EnvironmentConfigurationYamlFilePath = "$WorkingDirectory/config/variables/$Environment.yml"

# Deployment
$EnvironmentConfiguration = Get-Content $EnvironmentConfigurationYamlFilePath  | ConvertFrom-Yaml
$ManagementGroupHierarchy = $EnvironmentConfiguration.variables['var-managementgroup-hierarchy'] | ConvertFrom-Json

function ProcessManagementGroupHierarchy {
  param (
    $parentNode
  )

  foreach ($childNode in $parentNode.children) {
    $parentManagementGroupId = $parentNode.id
    $childManagementGroupId = $childNode.id
    $childManagementGroupName = $childNode.name
    
    Write-Output "Creating $childManagementGroupName [$childManagementGroupId] under $parentManagementGroupId"

    # Add Azure PS deployment command

    ProcessManagementGroupHierarchy($childNode)
  }
}

ProcessManagementGroupHierarchy($ManagementGroupHierarchy)