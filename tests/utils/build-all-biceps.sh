# ----------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
#
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
# OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# ----------------------------------------------------------------------------------

#!/bin/sh

mkdir -p /tmp/bicepbuild

find $1 -type f -name '*.bicep' | xargs -tn1 az bicep build --outdir /tmp/bicepbuild -f 

rm -rf /tmp/bicepbuild