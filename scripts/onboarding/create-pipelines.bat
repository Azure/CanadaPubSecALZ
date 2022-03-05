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
echo   DevOps Organization:              %DEVOPS_ORG%
echo   DevOps Project:                   %DEVOPS_PROJECT_NAME%
echo   Repository Name/URL:              %DEVOPS_REPO_NAME_OR_URL%
echo   Repository Type:                  %DEVOPS_REPO_TYPE%
echo   Repository Branch ^& Environment:  %DEVOPS_REPO_BRANCH%
echo   Azure Pipeline Suffix:            %DEVOPS_PIPELINE_NAME_SUFFIX%
echo.
choice /C YN /M "Do you want to proceed?"
if errorlevel 2 exit /b 0

REM Process all pipeline definitions
for %%N in (management-groups roles platform-logging policy platform-connectivity-hub-nva platform-connectivity-hub-azfw platform-connectivity-hub-azfw-policy subscription) do (

    REM Check for pipeline existence
    set FOUND=
    for /f usebackq %%F in (`call az pipelines list -o tsv --query="[?name=='%%N%DEVOPS_PIPELINE_NAME_SUFFIX%'].name | [0]"`) do set FOUND=true

    REM Only create Azure DevOps pipeline if it does *not* already exist
    if not defined FOUND (
        echo Creating pipeline [%%N%DEVOPS_PIPELINE_NAME_SUFFIX%]...
        call az pipelines create --name "%%N%DEVOPS_PIPELINE_NAME_SUFFIX%" --repository %DEVOPS_REPO_NAME_OR_URL% --repository-type %DEVOPS_REPO_TYPE% --branch %DEVOPS_REPO_BRANCH% --skip-first-run --yaml-path "/.pipelines/%%N.yml" --org %DEVOPS_ORG% --project %DEVOPS_PROJECT_NAME%
    ) else (
        echo Pipeline [%%N%DEVOPS_PIPELINE_NAME_SUFFIX%] already exists. Skipping creation.
    )
)

REM Get environments in the project
echo.
echo Retrieving list of environments for project [%DEVOPS_PROJECT_NAME%]..
call az devops invoke --organization "%DEVOPS_ORG%" --route-parameters project="%DEVOPS_PROJECT_NAME%" --http-method GET --api-version 6.0 --area distributedtask --resource environments -o json >%DEVOPS_OUTPUT_DIR%\environment.json

REM Check if environment matching repository branch name exists
set ENVIRONMENT=
echo Checking project for existing environment [%DEVOPS_REPO_BRANCH%]...
for /f "usebackq delims=" %%E in (`jq ".value[] | select(.name == \"%DEVOPS_REPO_BRANCH%\") | .name" %DEVOPS_OUTPUT_DIR%\environment.json`) do set ENVIRONMENT=%%~E

REM Create environment if it doesn't already exist
if not defined ENVIRONMENT (
    echo Creating environment [%DEVOPS_REPO_BRANCH%]...
    echo { "name": "%DEVOPS_REPO_BRANCH%" } >%DEVOPS_OUTPUT_DIR%\environment-body.json
    call az devops invoke --organization "%DEVOPS_ORG%" --route-parameters project="%DEVOPS_PROJECT_NAME%" --http-method POST --api-version 6.0 --area distributedtask --resource environments --in-file %DEVOPS_OUTPUT_DIR%\environment-body.json >nul
) else (
    echo Environment [%DEVOPS_REPO_BRANCH%] already exists. Skipping creation.
)

echo.
echo Now that an environment exists for the repository branch [%DEVOPS_REPO_BRANCH%],
echo learn more about configuring approvals and checks for deployments associated with this
echo environment by reviewing the following documentation:
echo    * https://docs.microsoft.com/azure/devops/pipelines/process/approvals
echo.
