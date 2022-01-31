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
echo Deleting Azure DevOps service endpoint (aka service connection) in the context of:
echo.
echo   DevOps Organization      = %DEVOPS_ORG%
echo   DevOps Project           = %DEVOPS_PROJECT_NAME%
echo   DevOps Service Endpoint  = %DEVOPS_SE_NAME%
echo.
choice /C YN /M "Do you want to proceed?"
if errorlevel 2 exit /b 0

REM Delete Azure DevOps service endpoint
echo Deleting Azure DevOps service endpoint %DEVOPS_SE_NAME%...
call az devops service-endpoint list --query "[?name == '%DEVOPS_SE_NAME%'].id" -o tsv | call az devops service-endpoint delete --yes --id @-
echo.
