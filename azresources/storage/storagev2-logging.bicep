// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

// param storageLoggingName string

// resource storageLogging 'Microsoft.Storage/storageAccounts@2019-06-01' = {
//   location: resourceGroup().location
//   name: storageLoggingName
//   kind: 'StorageV2'
//   sku: {
//     name: 'Standard_LRS'
//   }
//   properties: {
//     minimumTlsVersion: 'TLS1_2'
//   }
// }

// output saLoggingId string = storageLogging.id
// output storagePath string = storageLogging.properties.primaryEndpoints.blob
