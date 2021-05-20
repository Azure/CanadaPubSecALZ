#!/bin/sh

# ----------------------------------------------------------------------------------
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
# OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# ----------------------------------------------------------------------------------

# -------------
# TO BE DELETED
# -------------
# This file can be deleted once the changes that use the new
# version in 'pipelines/scripts/add-scope-management-groups.sh'
# have been verified.
#

# Required until https://github.com/Azure/bicep/issues/1691 is fixed
sed -i 's/\"type\"\: \"Microsoft.Management\/managementGroups"/\"type\"\: \"Microsoft.Management\/managementGroups\"\, \"scope\": \"\/\"/g' structure.json