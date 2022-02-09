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
echo Share the Azure DevOps service endpoint (aka service connection) with all pipelines in the context of:
echo.
echo   DEVOPS_ORG              = %DEVOPS_ORG%
echo   DEVOPS_PROJECT_NAME     = %DEVOPS_PROJECT_NAME%
echo   DEVOPS_SE_NAME          = %DEVOPS_SE_NAME%
echo.
echo If these settings are not correct, please exit, update/run the set-variables.[YourEnv].bat script, and re-run this script
echo.
choice /C YN /M "Do you want to proceed?"
if errorlevel 2 exit /b 0

echo.
echo Configure existing Azure DevOps service endpoint to share with all pipelines in the project
echo.

REM Set DEVOPS_SE_ID env var based on lookup by DEVOPS_SE_NAME
echo Performing lookup of Azure DevOps service endpoint ID by name...
for /f "usebackq delims=" %%I in (`call az devops service-endpoint list --org %DEVOPS_ORG% --project %DEVOPS_PROJECT_NAME% --query "[?name == '%DEVOPS_SE_NAME%'].id | [0]"`) do set DEVOPS_SE_ID=%%I
if not defined DEVOPS_SE_ID (
    echo.
    echo Error on lookup of DEVOPS_SE_ID by DEVOPS_SE_NAME [%DEVOPS_SE_NAME%]
    echo.
    exit /b 1
)

REM Update the Service Endpoint properties to allow it to be used by all pipelines in the project
echo Updating the Azure DevOps service endpoint [%DEVOPS_SE_NAME%] to allow it to be used by all pipelines in the project [%DEVOPS_PROJECT_NAME%]...
call az devops service-endpoint update --id %DEVOPS_SE_ID% --enable-for-all --org %DEVOPS_ORG% --project %DEVOPS_PROJECT_NAME%

echo.
echo RECOMMENDED: Navigate to the Azure DevOps project settings, select "Service connections", select the "%DEVOPS_SE_NAME%" service endpoint, select "Security", and review the assigned project and pipeline access permissions.
echo.
echo If you have more pipelines than just the landing zone pipelines defined in your project,
echo it is recommended that you restrict access to this service endpoint to only the landing
echo zone pipelines that require access to it.
echo.
