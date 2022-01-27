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
echo Creating Azure DevOps pipelines in the context of:
echo.
echo   DevOps Organization:   %DEVOPS_ORG%
echo   DevOps Project:        %DEVOPS_PROJECT_NAME%
echo   Repository Name/URL:   %DEVOPS_REPO_NAME_OR_URL%
echo   Repository Type:       %DEVOPS_REPO_TYPE%
echo   Repository Branch:     %DEVOPS_REPO_BRANCH%
echo   Azure Pipeline Suffix: %DEVOPS_PIPELINE_NAME_SUFFIX%
echo.
choice /C YN /M "Do you want to proceed?"
if errorlevel 2 exit /b 0

REM Process all pipeline definitions
for %%N in (management-groups roles platform-logging policy platform-connectivity-hub-nva platform-connectivity-hub-azfw platform-connectivity-hub-azfw-policy subscriptions) do (

    REM Check for pipeline existence
    set FOUND=
    for /f usebackq %%F in (`call az pipelines list -o tsv --query="[?name=='%%N-%DEVOPS_PIPELINE_NAME_SUFFIX%'].name | [0]"`) do set FOUND=true

    REM Only create Azure DevOps pipeline if it does *not* already exist
    if not defined FOUND (
        echo Creating pipeline [%%N%DEVOPS_PIPELINE_NAME_SUFFIX%]...
        call az pipelines create --name "%%N%DEVOPS_PIPELINE_NAME_SUFFIX%" --repository %DEVOPS_REPO_NAME_OR_URL% --repository-type %DEVOPS_REPO_TYPE% --branch %DEVOPS_REPO_BRANCH% --skip-first-run --yaml-path "/.pipelines/%%N.yml" --org %DEVOPS_ORG% --project %DEVOPS_PROJECT_NAME%
    ) else (
        echo Pipeline [%%N%DEVOPS_PIPELINE_NAME_SUFFIX%] already exists. Skipping creation.
    )
)
