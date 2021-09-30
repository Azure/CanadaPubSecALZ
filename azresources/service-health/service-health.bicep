// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

// PARAMETERS

@description('An array of zero or more Incident Type elements')
@allowed([
  'Maintenance'
  'Informational'
  'ActionRequired'
  'Incident'
  'Security'
])
param incidentTypes array = [
  'Incident'
  'Security'
]

@description('An array of zero or more Region Names')
param regions array = [
  'Global'
  'Canada East'
  'Canada Central'
]

@description('An object containing arrays for \'app\', \'email\', \'sms\', and \'voice\' receivers. \'app\' and \'email\' are arrays of string values representing email addresses. \'sms\' and \'voice\' are arrays of objects with JSON structure: { "countryCode": "<value>", "phoneNumber": "<value>" }.')
param receivers object = {
  app: []
  email: []
  sms: []
  voice: []
}

@description('Action group name.')
param actionGroupName string = 'ALZ action group'

@description('Action group short name. Maximum 12 character length.')
@maxLength(12)
param actionGroupShortName string = substring(actionGroupName, 0, max(length(actionGroupName),12))

@description('Alert rule name.')
param alertRuleName string = 'ALZ alert rule'

@description('Alert rule description.')
param alertRuleDescription string = 'Alert rule for Azure Landing Zone'


// VARIABLES

var incidentTypesProperty = [for incidentType in incidentTypes: {
  field: 'properties.incidentType'
  equals: incidentType
}]

var regionsProperty = regions

var appReceiversProperty = [for app in receivers.app: {
  name: 'app-receivers-${uniqueString(resourceGroup().id, app)}'
  emailAddress: app
}]

var emailReceiversProperty = [for email in receivers.email: {
  name: 'email-receivers-${uniqueString(resourceGroup().id, email)}'
  emailAddress: email
  useCommonAlertSchema: true
}]

var smsReceiversProperty = [for sms in receivers.sms: {
  name: 'sms-receivers-${uniqueString(resourceGroup().id, concat(sms.countryCode, sms.phoneNumber))}'
  countryCode: sms.countryCode
  phoneNumber: sms.phoneNumber
}]

var voiceReceiversProperty = [for voice in receivers.voice: {
  name: 'voice-receivers-${uniqueString(resourceGroup().id, concat(voice.countryCode, voice.phoneNumber))}'
  countryCode: voice.countryCode
  phoneNumber: voice.phoneNumber
}]

// RESOURCES

resource actionGroup 'microsoft.insights/actionGroups@2019-06-01' = {
  name: actionGroupName
  location: 'Global'
  properties: {
    groupShortName: actionGroupShortName
    enabled: true
    emailReceivers: emailReceiversProperty
    smsReceivers: smsReceiversProperty
    webhookReceivers: []
    itsmReceivers: []
    azureAppPushReceivers: appReceiversProperty
    automationRunbookReceivers: []
    voiceReceivers: voiceReceiversProperty
    logicAppReceivers: []
    azureFunctionReceivers: []
    armRoleReceivers: []
  }
}

resource alertRule 'microsoft.insights/activityLogAlerts@2020-10-01' = {
  name: alertRuleName
  location: 'Global'
  properties: {
    description: alertRuleDescription
    enabled: true
    scopes: [
      subscription().id
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'ServiceHealth'
        }
        {
          anyOf: incidentTypesProperty
        }
        {
          field: 'properties.impactedServices[*].ImpactedRegions[*].RegionName'
          containsAny: regionsProperty
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroup.id
          webhookProperties: {}
        }
      ]
    }
  }
}
