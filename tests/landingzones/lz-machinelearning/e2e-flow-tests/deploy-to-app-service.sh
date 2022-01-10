# ----------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
#
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
# OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# ----------------------------------------------------------------------------------

az login

az account set -s <subscription>

# deploy model in ACR to App Service using ACR private endpoint
az webapp config appsettings set --resource-group <rg> --name <unique-app-service-name> --settings 'WEBSITE_PULL_IMAGE_OVER_VNET=true'

az webapp config set --resource-group <rg> --name <unique-app-service-name> --linux-fx-version 'DOCKER|<container-registry-name>.azurecr.io/test_image:<date_time_tag>'
az resource update --resource-group <rg> --name <unique-app-service-name>/config/web --set properties.acrUseManagedIdentityCreds=true --resource-type 'Microsoft.Web/sites/config'

