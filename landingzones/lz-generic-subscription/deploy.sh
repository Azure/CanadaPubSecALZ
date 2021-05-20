#!/bin/sh

# ----------------------------------------------------------------------------------
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
# OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# ----------------------------------------------------------------------------------

# This is an example deployment steps that will be converted to Azure DevOps Pipeline.

spokeSubscriptionId='34b63c8f-1782-42e6-8fb9-ba6ee8b99735'
parametersFile='main.parameters-sample.json'

# AzDo Pipeline Step - Deploy landing zone
az deployment sub create \
    --subscription $spokeSubscriptionId \
    -l canadacentral \
    --template-file main.bicep \
    --parameters @$parametersFile

# AzDo Pipeline Step - Configure Hub to Spoke VNET Peering
hubVnetId=`jq -r .parameters.hubVnetId.value "$parametersFile"`

if [ -n "$hubVnetId" ]; then
    hubSubscriptionId=`echo $hubVnetId | cut -d '/' -f 3`
    spokeRgName=`jq -r .parameters.rgVnetName.value "$parametersFile"`
    spokeVnetName=`jq -r .parameters.vnetName.value "$parametersFile"`

    az deployment sub create \
        -l canadacentral \
        --subscription $hubSubscriptionId \
        --template-file ../utils/network/peer-to-hub.bicep \
        --parameters \
            hubVnetId=$hubVnetId \
            spokeSubId=$spokeSubscriptionId \
            spokeRgName=$spokeRgName \
            spokeVnetName=$spokeVnetName
else
    echo "Hub Virtual Network ResourceId not specified.  VNET Peering from Hub to Spoke will be skipped."
fi