// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('Azure Automation Account name.')
param automationAccountName string

@description('Key/Value pair of tags.')
param tags object = {}

resource automationAccount 'Microsoft.Automation/automationAccounts@2015-10-31' = {
  name: automationAccountName
  tags: tags
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}

output automationAccountId string = automationAccount.id
