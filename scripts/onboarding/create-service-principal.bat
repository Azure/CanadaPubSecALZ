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
echo Create an Azure service principal in the context of:
echo.
echo   DEVOPS_OUTPUT_DIR  = %DEVOPS_OUTPUT_DIR%
echo   DEVOPS_SP_NAME     = %DEVOPS_SP_NAME%
echo.
echo If these settings are not correct, please exit, update/run the set-variables.[YourEnv].bat script, and re-run this script
echo.
choice /C YN /M "Do you want to proceed?"
if errorlevel 2 exit /b 0

REM Check output directory exists
if not exist %DEVOPS_OUTPUT_DIR% (
    echo Creating output directory [%DEVOPS_OUTPUT_DIR%]...
    md %DEVOPS_OUTPUT_DIR%
)

REM Create an Azure AD service principal
echo Creating Azure AD service principal named [%DEVOPS_SP_NAME%] with Owner role at tenant root scope...
call az ad sp create-for-rbac --name "%DEVOPS_SP_NAME%" --role "Owner" --scopes "/" >%DEVOPS_OUTPUT_DIR%\%DEVOPS_SP_NAME%.out

if not errorlevel 1 (
    echo Azure AD service principal created and information stored in file: %DEVOPS_OUTPUT_DIR%\%DEVOPS_SP_NAME%.out
    echo.
    echo NOTE: Keep this file secure as it contains ID and password for the service principal.
    echo.
)
