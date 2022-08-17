@description('Location for the deployment.')
param location string = resourceGroup().location

@description('Name of the data collection rule')
param name string

@description('Windows Event Logs data source configuration.')
param windowsEventLogs array

@description('syslog data source configuration.')
param syslog array

@description('Log Analytics Workspace Id')
param logAnalyticsWorkspaceId string

resource dcr 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  name: name
  location: location
  properties: {
    dataSources: {
      windowsEventLogs: windowsEventLogs
      syslog: syslog
    }
    destinations: {
      logAnalytics: [
        {
          name: 'logAnalytics'
          workspaceResourceId: logAnalyticsWorkspaceId
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Event'
          'Microsoft-Syslog'
        ]
        destinations: [
          'logAnalytics'
        ]
      }
    ]
  }
}

output dcrId string = dcr.id
