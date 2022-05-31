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
echo Create an Azure DevOps variable group in the context of:
echo.
echo   DevOps Organization:          %DEVOPS_ORG%
echo   DevOps Project:               %DEVOPS_PROJECT_NAME%
echo   DevOps Variable Group:        %DEVOPS_VARIABLES_GROUP_NAME%
echo   DevOps Variables are Secret:  %DEVOPS_VARIABLES_ARE_SECRET%
echo.
choice /C YN /M "Do you want to proceed?"
if errorlevel 2 exit /b 0

set ID=
REM Check whether variable group exists (get ID)
for /f usebackq %%V in (`call az pipelines variable-group list -o tsv --query "[?name=='%DEVOPS_VARIABLES_GROUP_NAME%'].id | [0]"`) do set ID=%%V

REM Delete variable group if it already exists
if defined ID (
    choice /C YN /M "Variable group [%DEVOPS_VARIABLES_GROUP_NAME%] exists with ID [%ID%]. Do you want to delete and re-create it?"
    if errorlevel 2 exit /b 0
    echo Deleting variable group [%DEVOPS_VARIABLES_GROUP_NAME%]...
    call az pipelines variable-group delete --id %ID% --yes --org %DEVOPS_ORG% --project %DEVOPS_PROJECT_NAME%
)

REM Create the variable group
echo Enter NVA username and password to set variables in DevOps variable group [%DEVOPS_VARIABLES_GROUP_NAME%]
echo.
echo **********************************************************************
echo  CAUTION: your input is not masked, i.e. it will be visible on-screen
echo **********************************************************************
echo.
set /P NVA_USERNAME=Enter the user name for the NVA firewall: 
set /P NVA_PASSWORD=Enter the password for the NVA firewall: 
echo.

echo Creating variable group [%DEVOPS_VARIABLES_GROUP_NAME%]...
call az pipelines variable-group create --name %DEVOPS_VARIABLES_GROUP_NAME% --authorize true --query "[?name=='%DEVOPS_VARIABLES_GROUP_NAME%'].id | [0]" -o tsv --org %DEVOPS_ORG% --project %DEVOPS_PROJECT_NAME% --variables var-hubnetwork-nva-fwUsername=%NVA_USERNAME% var-hubnetwork-nva-fwPassword=%NVA_PASSWORD%
echo.
echo Variable group [%DEVOPS_VARIABLES_GROUP_NAME%] has been created.
echo.
echo NOTE that this variable group is accessible from all pipelines.
echo.
echo RECOMMENDED that you use the Azure DevOps portal to restrict access to this
echo   variable group to only the `platform-connectivity-hub-nva` pipeline.
echo.

REM Set variables as secret in Azure DevOps if requested
if "%DEVOPS_VARIABLES_ARE_SECRET%" == "true" (
    echo.
    echo Setting variables in Azure DevOps variable group [%DEVOPS_VARIABLES_GROUP_NAME%] as secret...
    echo.
    call update-variable-group.bat true
) else (
    echo.
    echo **************************************************************************
    echo  WARNING: NVA firewall variables are not marked as secret in Azure DevOps
    echo **************************************************************************
    echo.
)
