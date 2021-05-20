// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'tenant'

@minLength(2)
@maxLength(10)
param topLevelManagementGroupName string

param parentManagementGroupId string

// Level 1
resource topLevel 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: topLevelManagementGroupName
  properties: {
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
  properties: {
    details: {
      parent: {
        id: topLevel.id
      }
    }
  }
}

resource landingzones 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: '${topLevel.name}LandingZones'
  properties: {
    details: {
      parent: {
        id: topLevel.id
      }
    }
  }
}

resource sandbox 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: '${topLevel.name}Sandbox'
  properties: {
    details: {
      parent: {
        id: topLevel.id
      }
    }
  }
}

// Level 3 - Landing Zones

resource devtest 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: '${landingzones.name}DevTest'
  properties: {
    details: {
      parent: {
        id: landingzones.id
      }
    }
  }
}

resource qa 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: '${landingzones.name}QA'
  properties: {
    details: {
      parent: {
        id: landingzones.id
      }
    }
  }
}

resource prod 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: '${landingzones.name}Prod'
  properties: {
    details: {
      parent: {
        id: landingzones.id
      }
    }
  }
}
