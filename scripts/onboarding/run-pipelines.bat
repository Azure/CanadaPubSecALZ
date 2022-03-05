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
echo Runn Azure DevOps pipelines in the context of:
echo.
echo   DevOps Organization:   %DEVOPS_ORG%
echo   DevOps Project:        %DEVOPS_PROJECT_NAME%
echo   Repository Branch:     %DEVOPS_REPO_BRANCH%
echo   Azure Pipeline Suffix: %DEVOPS_PIPELINE_NAME_SUFFIX%
echo.
choice /C YN /M "Do you want to proceed?"
if errorlevel 2 exit /b 0

REM The [S] option to run the subscriptions pipeline is commented-out as
REM it requires one or more GUIDs or partial GUIDs that are unique for
REM identifying subscription configuration (JSON) files to operate upon.
REM Additional work on this script is required to enable this capability.

:Prompt
echo.
echo Options:
echo   [M] management-groups
echo   [R] roles
echo   [L] platform-logging
echo   [P] policy
echo   [N] platform-connectivity-hub-nva
echo   [Y] platform-connectivity-hub-azfw
echo   [Z] platform-connectivity-hub-azfw-policy
echo   [S] subscriptions
echo   [X] exit
echo.
choice /C MRLPNYZSX /M "Select option?"
goto case_%errorlevel%

:case_1
set PIPELINE=management-groups%DEVOPS_PIPELINE_NAME_SUFFIX%
goto :RunPipeline

:case_2
set PIPELINE=roles-ci
goto :RunPipeline

:case_3
set PIPELINE=platform-logging%DEVOPS_PIPELINE_NAME_SUFFIX%
goto :RunPipeline

:case_4
set PIPELINE=policy-ci
goto :RunPipeline

:case_5
set PIPELINE=platform-connectivity-hub-nva%DEVOPS_PIPELINE_NAME_SUFFIX%
goto :RunPipeline

:case_6
set PIPELINE=platform-connectivity-hub-azfw%DEVOPS_PIPELINE_NAME_SUFFIX%
goto :RunPipeline

:case_7
set PIPELINE=platform-connectivity-hub-azfw-policy%DEVOPS_PIPELINE_NAME_SUFFIX%
goto :RunPipeline

:case_8
set PIPELINE=subscription%DEVOPS_PIPELINE_NAME_SUFFIX%
echo.
echo Running the [%PIPELINE%] pipeline from this script is not supported at this time.
goto :Prompt

:case_9
exit /b 0

:RunPipeline
echo.
echo Running pipeline: %PIPELINE%...
echo.
call az pipelines run --name %PIPELINE% --branch %DEVOPS_REPO_BRANCH% --org %DEVOPS_ORG% --project %DEVOPS_PROJECT_NAME% --open
echo.
goto Prompt
