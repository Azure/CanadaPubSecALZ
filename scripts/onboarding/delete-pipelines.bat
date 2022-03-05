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
echo Deleting Azure DevOps pipelines in the context of:
echo.
echo   DevOps Organization:   %DEVOPS_ORG%
echo   DevOps Project:        %DEVOPS_PROJECT_NAME%
echo   Azure Pipeline Suffix: %DEVOPS_PIPELINE_NAME_SUFFIX%
echo.
choice /C YN /M "Do you want to proceed?"
if errorlevel 2 exit /b 0

REM Process all pipeline definitions
for %%N in (management-groups roles platform-logging policy platform-connectivity-hub-nva platform-connectivity-hub-azfw platform-connectivity-hub-azfw-policy subscription) do (
    echo.
    echo Deleting pipeline [%%N]...
    echo.
    call az pipelines list -o tsv --query "[?name == '%%N%DEVOPS_PIPELINE_NAME_SUFFIX%'].id" -o tsv | call az pipelines delete --id @- --yes --org %DEVOPS_ORG% --project %DEVOPS_PROJECT_NAME%
)
