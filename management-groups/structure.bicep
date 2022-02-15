// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

@description('Top Level Management Group Name')
@minLength(2)
@maxLength(10)
param topLevelManagementGroupName string

@description('Top Level Management Group Display Name')
@maxLength(50)
param topLevelManagementGroupDisplayName string = ''

@description('Parent Management Group used to create all management groups, including Top Level Management Group.')
param parentManagementGroupId string

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../config/telemetry.json'))
module telemetryCustomerUsageAttribution '../azresources/telemetry/customer-usage-attribution-management-group.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.managementGroups}'
}

// Level 1
resource topLevel 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: topLevelManagementGroupName
  scope: tenant()
  properties: {
    displayName: topLevelManagementGroupDisplayName
    details: {
      parent: {
        id: tenantResourceId('Microsoft.Management/managementGroups', parentManagementGroupId)
      }
    }
  }
}

// Level 2
resource platform 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: '${topLevel.name}Platform'
  scope: tenant()
  properties: {
    displayName: 'Platform'
    details: {
      parent: {
        id: topLevel.id
      }
    }
  }
}

resource landingzones 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: '${topLevel.name}LandingZones'
  scope: tenant()
  properties: {
    displayName: 'Landing Zones'
    details: {
      parent: {
        id: topLevel.id
      }
    }
  }
}

resource sandbox 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: '${topLevel.name}Sandbox'
  scope: tenant()
  properties: {
    displayName: 'Sandbox'
    details: {
      parent: {
        id: topLevel.id
      }
    }
  }
}

// Level 3 - Platform
resource platformConnectivity 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: '${platform.name}Connectivity'
  scope: tenant()
  properties: {
    displayName: 'Connectivity'
    details: {
      parent: {
        id: platform.id
      }
    }
  }
}

resource platformIdentity 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: '${platform.name}Identity'
  scope: tenant()
  properties: {
    displayName: 'Identity'
    details: {
      parent: {
        id: platform.id
      }
    }
  }
}

resource platformManagement 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: '${platform.name}Management'
  scope: tenant()
  properties: {
    displayName: 'Management'
    details: {
      parent: {
        id: platform.id
      }
    }
  }
}

// Level 3 - Landing Zones

resource devtest 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: '${landingzones.name}DevTest'
  scope: tenant()
  properties: {
    displayName: 'Dev/Test'
    details: {
      parent: {
        id: landingzones.id
      }
    }
  }
}

resource qa 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: '${landingzones.name}QA'
  scope: tenant()
  properties: {
    displayName: 'QA'
    details: {
      parent: {
        id: landingzones.id
      }
    }
  }
}

resource prod 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: '${landingzones.name}Prod'
  scope: tenant()
  properties: {
    displayName: 'Production'
    details: {
      parent: {
        id: landingzones.id
      }
    }
  }
}
