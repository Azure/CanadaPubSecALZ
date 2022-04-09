@echo off
REM // ----------------------------------------------------------------------------------
REM // Copyright (c) Microsoft Corporation.
REM // Licensed under the MIT license.
REM //
REM // THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
REM // EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
REM // OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
REM // ----------------------------------------------------------------------------------

echo.
echo Create an Azure DevOps service endpoint (aka service connection) in the context of:
echo.
echo   DEVOPS_OUTPUT_DIR       = %DEVOPS_OUTPUT_DIR%
echo   DEVOPS_TENANT_ID        = %DEVOPS_TENANT_ID%
echo   DEVOPS_MGMT_GROUP_NAME  = %DEVOPS_MGMT_GROUP_NAME%
echo   DEVOPS_ORG              = %DEVOPS_ORG%
echo   DEVOPS_PROJECT_NAME     = %DEVOPS_PROJECT_NAME%
echo   DEVOPS_SE_NAME          = %DEVOPS_SE_NAME%
echo   DEVOPS_SE_TEMPLATE      = %DEVOPS_SE_TEMPLATE%
echo   DEVOPS_SP_NAME          = %DEVOPS_SP_NAME%
echo.
echo If these settings are not correct, please exit, update/run the set-variables.[YourEnv].bat script, and re-run this script
echo.
choice /C YN /M "Do you want to proceed?"
if errorlevel 2 exit /b 0

REM Check output directory exists
if not exist %DEVOPS_OUTPUT_DIR% (
    echo Output directory [%DEVOPS_OUTPUT_DIR%] does not exist; creating it now...
    md %DEVOPS_OUTPUT_DIR%
)

REM Set DEVOPS_SP_ID and DEVOPS_SP_PW environment variables
if exist %DEVOPS_OUTPUT_DIR%\%DEVOPS_SP_NAME%.out (
    echo Setting DEVOPS_SP_ID and DEVOPS_SP_PW based on file output from 'create-service-principal.bat' that was stored in [%DEVOPS_OUTPUT_DIR%\%DEVOPS_SP_NAME%.out]...
    for /f "usebackq delims=" %%I in (`jq "".appId"" %DEVOPS_OUTPUT_DIR%\%DEVOPS_SP_NAME%.out`) do set DEVOPS_SP_ID=%%~I
    for /f "usebackq delims=" %%I in (`jq "".password"" %DEVOPS_OUTPUT_DIR%\%DEVOPS_SP_NAME%.out`) do set DEVOPS_SP_PW=%%~I
    echo Service principal ID and KEY are located in file [%DEVOPS_OUTPUT_DIR%\%DEVOPS_SP_NAME%.out]
)

REM Get the Service Principal key if not already present
if defined DEVOPS_SP_PW goto SkipServicePrincipalPrompt
echo.
choice /C YN /M "The service principal key must be entered/pasted here. Do you have it ready?"
if errorlevel 2 exit /b 0
echo.
echo Enter or paste the service principal key here:
set /p DEVOPS_SP_PW=""
if not defined DEVOPS_SP_PW (
    echo.
    echo The service principal key is *not* defined in environment variable DEVOPS_SP_PW
    echo Exiting the script; please re-run and provide the Service Principal key when prompted
    echo.
    goto :EOF
)
:SkipServicePrincipalPrompt

REM Set DEVOPS_MGMT_GROUP_ID env var based on lookup by DEVOPS_MGMT_GROUP_NAME
echo Performing lookup of AAD root management group ID by name...
for /f "usebackq delims=" %%I in (`call az account management-group list --query "[?displayName == '%DEVOPS_MGMT_GROUP_NAME%'].name | [0]"`) do set DEVOPS_MGMT_GROUP_ID=%%I
if not defined DEVOPS_MGMT_GROUP_ID (
    echo.
    echo Error on lookup of DEVOPS_MGMT_GROUP_ID by DEVOPS_MGMT_GROUP_NAME [%DEVOPS_MGMT_GROUP_NAME%]
    echo.
    goto :EOF
)

REM Set DEVOPS_SP_ID env var based on lookup by DEVOPS_SP_NAME
echo Performing lookup of AAD service principal ID by name...
for /f "usebackq delims=" %%I in (`call az ad sp list --filter "DisplayName eq '%DEVOPS_SP_NAME%'" --query "[0].appId"`) do set DEVOPS_SP_ID=%%I
if not defined DEVOPS_SP_ID (
    echo.
    echo Error on lookup of DEVOPS_SP_ID by DEVOPS_SP_NAME [%DEVOPS_SP_NAME%]
    echo.
    goto :EOF
)

REM Set DEVOPS_PROJECT_ID env var based on lookup by DEVOPS_PROJECT_NAME
echo Performing lookup of Azure DevOps project ID by name...
for /f "usebackq delims=" %%I in (`call az devops project show --org %DEVOPS_ORG% --project %DEVOPS_PROJECT_NAME% --query "id"`) do set DEVOPS_PROJECT_ID=%%I
if not defined DEVOPS_PROJECT_ID (
    echo.
    echo Error on lookup of DEVOPS_PROJECT_ID by DEVOPS_PROJECT_NAME [%DEVOPS_PROJECT_NAME%]
    echo.
    goto :EOF
)

REM Create service endpoint definition file
echo Creating a service endpoint definition file...
jq "(.name, .serviceEndpointProjectReferences[0].name) |= \"%DEVOPS_SE_NAME%\" | (.authorization.parameters.serviceprincipalid) |= \"%DEVOPS_SP_ID%\" | (.authorization.parameters.serviceprincipalkey) |= \"%DEVOPS_SP_PW%\" | (.authorization.parameters.tenantid) |= \"%DEVOPS_TENANT_ID%\" | (.data.managementGroupId) |= \"%DEVOPS_MGMT_GROUP_ID%\" | (.data.managementGroupName) |= \"%DEVOPS_MGMT_GROUP_NAME%\" | (.serviceEndpointProjectReferences[0].projectReference.id) |= \"%DEVOPS_PROJECT_ID%\" | (.serviceEndpointProjectReferences[0].projectReference.name) |= \"%DEVOPS_PROJECT_NAME%\"" .\service-endpoint.template.json >%DEVOPS_OUTPUT_DIR%\%DEVOPS_SE_TEMPLATE%

REM Create the Service Endpoint
echo Creating the Azure DevOps service endpoint using existing Azure service principal and generated template...
call az devops service-endpoint create --service-endpoint-configuration %DEVOPS_OUTPUT_DIR%\%DEVOPS_SE_TEMPLATE% --org %DEVOPS_ORG% --project %DEVOPS_PROJECT_NAME%
