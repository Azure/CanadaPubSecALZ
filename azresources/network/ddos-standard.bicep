// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param ddosPlanName string

resource ddosPlan 'Microsoft.Network/ddosProtectionPlans@2020-07-01' = {
  name: ddosPlanName
  location: resourceGroup().location
  properties: {}
}
