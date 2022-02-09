@echo off
REM // ----------------------------------------------------------------------------------
REM // Copyright (c) Microsoft Corporation.
REM // Licensed under the MIT license.
REM //
REM // THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
REM // EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
REM // OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
REM // ----------------------------------------------------------------------------------

REM Azure AD tenant GUID
set DEVOPS_TENANT_ID=

REM Azure AD tenant root management group name
set DEVOPS_MGMT_GROUP_NAME=Tenant Root Group

REM Azure service principal name for 'Owner' RBAC at tenant root scope
set DEVOPS_SP_NAME=spn-azure-platform-ops

REM Azure security group name for 'Owner` RBAC subscription, network, and logging
set DEVOPS_SG_NAME=alz-owners

REM Azure DevOps organization URL
set DEVOPS_ORG=

REM Azure DevOps project name (prefer no spaces)
set DEVOPS_PROJECT_NAME=

REM Repository name or URL
set DEVOPS_REPO_NAME_OR_URL=

REM Repository type: 'tfsgit' or 'github'
set DEVOPS_REPO_TYPE=tfsgit

REM Repository branch name (default)
set DEVOPS_REPO_BRANCH=main

REM Azure DevOps pipeline name suffix (default)
set DEVOPS_PIPELINE_NAME_SUFFIX=-ci

REM Azure DevOps service endpoint name (service connection in project settings)
set DEVOPS_SE_NAME=spn-azure-platform-ops

REM Azure DevOps service endpoint template file (generated)
set DEVOPS_SE_TEMPLATE=service-endpoint.DEVOPS-ORG-NAME.json

REM Do not change this value (hard-coded in YAML pipeline definition)
set DEVOPS_VARIABLES_GROUP_NAME=firewall-secrets

REM Variables is a space-delimited key=value string. Provide values for
REM 'var-hubnetwork-nva-fwUsername' and 'var-hubnetwork-nva-fwPassword'.
set DEVOPS_VARIABLES_VALUES=var-hubnetwork-nva-fwUsername=YourUserName var-hubnetwork-nva-fwPassword=YourPassword

REM Are variables in the firewall-secrets group marked as secret? 'true' or 'false'.
set DEVOPS_VARIABLES_ARE_SECRET=true

REM Folder path for generated output files
set DEVOPS_OUTPUT_DIR=.\output
