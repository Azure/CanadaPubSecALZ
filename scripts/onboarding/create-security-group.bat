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
echo Create an Azure security group in the context of:
echo.
echo   DEVOPS_SG_NAME  = %DEVOPS_SG_NAME%
echo.
echo If these settings are not correct, please exit, update/run the set-variables.[YourEnv].bat script, and re-run this script
echo.
choice /C YN /M "Do you want to proceed?"
if errorlevel 2 exit /b 0

set DEVOPS_SG_ID=

REM Find existing Azure security group id by name (if it exists)
for /f usebackq %%G in (`call az ad group list --filter "displayname eq '%DEVOPS_SG_NAME%'" --query "[].objectId" -o tsv`) do set DEVOPS_SG_ID=%%G

REM Create Azure security group if not exist and get its id
if defined DEVOPS_SG_ID (
  echo Located existing Azure security group [%DEVOPS_SG_NAME%]
) else (
  echo Creating Azure security group [%DEVOPS_SG_NAME%]
  for /f usebackq %%G in (`call az ad group create --display-name %DEVOPS_SG_NAME% --mail-nickname %DEVOPS_SG_NAME% --query "objectId" -o tsv`) do set DEVOPS_SG_ID=%%G
)

echo Azure security group id: %DEVOPS_SG_ID%
echo Save the security group id for later use in the environment (YAML)
echo   and subscription (JSON) configuration files.
