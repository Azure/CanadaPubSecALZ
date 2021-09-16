// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'subscription'

param budgetName string
param budgetAmount int

@allowed([
  'Monthly'
  'Quarterly'
  'Annually'
])
param timeGrain string = 'Monthly'
param startDate string = utcNow('yyyy-MM-01')
param notificationEmailAddress string

resource budget 'Microsoft.Consumption/budgets@2019-10-01' = {
  name: budgetName
  properties: {
    category: 'Cost'
    amount: budgetAmount
    timeGrain: timeGrain
    timePeriod: {
      startDate: startDate
    }
    notifications: {
      Notification1: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 25
        contactEmails: [
          notificationEmailAddress
        ]
      }
      Notification2: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 50
        contactEmails: [
          notificationEmailAddress
        ]
      }
      Notification3: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 75
        contactEmails: [
          notificationEmailAddress
        ]
      }
    }
  }
}
