#!/bin/sh

# ----------------------------------------------------------------------------------
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
# OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# ----------------------------------------------------------------------------------

# Required until https://github.com/Azure/bicep/issues/1691 is fixed
echo "Adding scope to bicep-generated ARM template for subscriptions..."
sed -i 's/\"type\"\: \"Microsoft.Management\/managementGroups\/subscriptions"/\"type\"\: \"Microsoft.Management\/managementGroups\/subscriptions\"\, \"scope\": \"\/\"/g' $1