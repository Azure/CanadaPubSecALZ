// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

@description('ADLS Gen2 Storage Account Name')
param adlsName string

@description('Filesystem name')
param fsName string

resource fs 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  name: '${adlsName}/default/${fsName}'
}
