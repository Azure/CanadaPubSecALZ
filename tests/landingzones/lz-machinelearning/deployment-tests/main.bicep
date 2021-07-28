targetScope = 'subscription'

var testScenarios = [
  {
    enabled: true
    deploySQLDB: true
    deploySQLMI: false
    useCMK: false
  }
  {
    enabled: true
    deploySQLDB: true
    deploySQLMI: false
    useCMK: true
  }
  {
    enabled: false
    deploySQLDB: false
    deploySQLMI: true
    useCMK: false
  }
  {
    enabled: false
    deploySQLDB: false
    deploySQLMI: true
    useCMK: true
  }
  {
    enabled: false
    deploySQLDB: true
    deploySQLMI: true
    useCMK: false
  }
  {
    enabled: false
    deploySQLDB: true
    deploySQLMI: true
    useCMK: true
  }
]

var tags = {
  ClientOrganization: 'tbd'
  CostCenter: 'tbd'
  DataSensitivity: 'tbd'
  ProjectContact: 'tbd'
  ProjectName: 'tbd'
  TechnicalContact: 'tbd'
}

resource rgTestHarnessInfraAssets 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'test-harness-infra-assets'
  location: deployment().location
  tags: tags
}

resource rgTestHarnessSupportingAssets 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'test-harness-supporting-assets'
  location: deployment().location
  tags: tags
}

module rgTestHarnessManagedIdentity '../../../../azresources/iam/user-assigned-identity.bicep' = {
  scope: rgTestHarnessInfraAssets
  name: 'deploy-test-harness-managed-identity'
  params: {
    name: 'test-harness-machine-learning-lz-managed-identity'
  }
}

module rgTestHarnessManagedIdentityRBAC '../../../../azresources/iam/subscription/role-assignment-to-sp.bicep' = {
  name: 'rbac-ds-${rgTestHarnessSupportingAssets.name}'
  params: {
     // Owner - this role is cleaned up as part of this deployment
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
    resourceSPObjectIds: array(rgTestHarnessManagedIdentity.outputs.identityPrincipalId)
  }
}


module logAnalyticsWorkspace '../../../../azresources/monitor/log-analytics.bicep' = {
  scope: rgTestHarnessSupportingAssets
  name: 'deploy-test-harness-log-analytics-workspace'
  params: {
    tags: tags
  }
}

@batchSize(1)
module runner 'test-runner.bicep' =  [for (scenario, i) in testScenarios: if (scenario.enabled) {
  dependsOn: [
    rgTestHarnessManagedIdentityRBAC
  ]

  name: 'execute-runner-scenario-${i + 1}'
  scope: subscription()
  params: {
    deploymentScriptIdentityId: rgTestHarnessManagedIdentity.outputs.identityId
    deploymentScriptResourceGroupName: rgTestHarnessInfraAssets.name

    hubVnetId: ''
    egressVirtualApplianceIp: '10.18.0.36'
    hubRFC1918IPRange: '10.18.0.0/22'
    hubCGNATIPRange: '100.60.0.0/16'

    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.outputs.workspaceResourceId

    deploySQLDB: scenario.deploySQLDB
    deploySQLMI: scenario.deploySQLMI
    useCMK: scenario.useCMK

    testRunnerCleanupAfterDeployment: true
  }
}]

var cleanUpScript = '''
  az account set -s {0}

  echo 'Delete Test Harness Supporting Assets'
  az group delete --name {1} --yes

  echo 'Delete Role Assignment for Test Harness Managed Identity'
  az role assignment delete --assignee {2} --scope {3}
'''

module harnessCleanup '../../../../azresources/util/deploymentScript.bicep' = {
  dependsOn: [
    rgTestHarnessManagedIdentityRBAC
    runner
  ]

  scope: rgTestHarnessInfraAssets 
  name: 'cleanup-test-harness'
  params: {
    deploymentScript: format(cleanUpScript, subscription().subscriptionId, rgTestHarnessSupportingAssets.name, rgTestHarnessManagedIdentity.outputs.identityPrincipalId, subscription().id)
    deploymentScriptName: 'cleanup-test-harness'
    deploymentScriptIdentityId: rgTestHarnessManagedIdentity.outputs.identityId
  }
}
