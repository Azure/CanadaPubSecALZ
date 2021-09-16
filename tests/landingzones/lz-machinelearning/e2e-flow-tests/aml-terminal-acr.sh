# ----------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
#
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
# OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# ----------------------------------------------------------------------------------

az upgrade
az login
az acr login --name <acrname>
docker pull hello-world
docker run hello-world
docker tag hello-world <acrname>.azurecr.io/hello-world:v1
docker push <acrname>.azurecr.io/hello-world:v1