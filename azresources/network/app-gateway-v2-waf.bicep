// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

param name string
param subnetId string

@allowed([
  'Detection'
  'Prevention'
])
param firewallMode string = 'Prevention'

@allowed([
  '3.2'
  '3.1'
  '3.0'
  '2.2.9'
])
param owaspRuleSetVersion string = '3.0'

@allowed([
  'AppGwSslPolicy20150501'
  'AppGwSslPolicy20170401'
  'AppGwSslPolicy20170401S'
])
param sslPredefinedPolicyName string = 'AppGwSslPolicy20170401'

param autoScaleMinCapacity int = 1
param autoScaleMaxCapacity int = 2

param enableHttp2 bool = true

resource appgwPublicIp 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: '${name}PublicIp'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource appgw 'Microsoft.Network/applicationGateways@2020-07-01' = {
  name: name
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    sslPolicy: {
      policyType: 'Predefined'
      policyName: sslPredefinedPolicyName
    }
    gatewayIPConfigurations: [
      {
        properties: {
          subnet: {
            id: subnetId
          }
        }
        name: 'gatewayIpConfig'
      }
    ]
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: firewallMode
      ruleSetType: 'OWASP'
      ruleSetVersion: owaspRuleSetVersion
      requestBodyCheck: true
    }
    enableHttp2: enableHttp2
    autoscaleConfiguration: {
      minCapacity: autoScaleMinCapacity
      maxCapacity: autoScaleMaxCapacity
    }
    frontendIPConfigurations: [
      {
        name: 'frontendPublicIpConfig'
        properties: {
          publicIPAddress: {
            id: appgwPublicIp.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'placeholder_frontendport_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'placeholder_backendpool'
        properties: {
          backendAddresses: [
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'placeholder_backendhttpSettings'
        properties: {
         port: 80 
        }
      }
    ]
    httpListeners: [
      {
        name: 'placeholder_httplistener'
        properties: {
          protocol: 'Http'
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', name, 'placeholder_frontendport_80')
          }
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', name, 'frontendPublicIpConfig')
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'placeholder_routingrule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', name, 'placeholder_httplistener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', name, 'placeholder_backendpool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', name, 'placeholder_backendhttpSettings')
          }
        }
      }
    ]
  }
  zones: [
    '1'
    '2'
    '3'
  ]
}
