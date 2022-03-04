@echo off
REM // ----------------------------------------------------------------------------------
REM // Copyright (c) Microsoft Corporation.
REM // Licensed under the MIT license.
REM //
REM // THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
REM // EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
REM // OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
REM // ----------------------------------------------------------------------------------

if '%1' == 'true' goto SkipPrompt
if '%1' == 'false' goto SkipPrompt

echo.
echo Updating Azure DevOps variable group in the context of:
echo.
echo   DevOps Organization:          %DEVOPS_ORG%
echo   DevOps Project:               %DEVOPS_PROJECT_NAME%
echo   DevOps Variable Group:        %DEVOPS_VARIABLES_GROUP_NAME%
echo   DevOps Variables are Secret:  %DEVOPS_VARIABLES_ARE_SECRET%
echo.
choice /C YN /M "Is this correct?"
if errorlevel 2 exit /b 0

:SkipPrompt

REM Update secret setting for variables in the variable group
:CheckAgain
echo Looking up ID for variable group [%DEVOPS_VARIABLES_GROUP_NAME%]...
for /f "usebackq delims=" %%I in (`call az pipelines variable-group list -o tsv --query "[?name=='%DEVOPS_VARIABLES_GROUP_NAME%'].id | [0]"`) do set ID=%%I
if not defined ID goto CheckAgain

echo Found ID [%ID%] for variable group [%DEVOPS_VARIABLES_GROUP_NAME%]
echo Updating all variables in this group to mark as secret=%DEVOPS_VARIABLES_ARE_SECRET%:

for /f "usebackq delims=" %%V in (`call az pipelines variable-group variable list --group-id %ID% --org %DEVOPS_ORG% --project %DEVOPS_PROJECT_NAME% --query "[keys(@)][]" -o tsv`) do (

    echo Marking variable [%%V] as secret=%DEVOPS_VARIABLES_ARE_SECRET%...
    call az pipelines variable-group variable update --group-id %ID% --name %%V --secret %DEVOPS_VARIABLES_ARE_SECRET% --org %DEVOPS_ORG% --project %DEVOPS_PROJECT_NAME%
)
