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
echo Deleting Azure service principal in the context of:
echo.
echo   DEVOPS_SP_NAME  = %DEVOPS_SP_NAME%
echo.
choice /C YN /M "Do you want to proceed?"
if errorlevel 2 exit /b 0

REM Delete service principal
echo Deleting service principal: %DEVOPS_SP_NAME%...
call az ad sp list --display-name "%DEVOPS_SP_NAME%" --query "[0].objectId" -o tsv | call az ad sp delete --id @-
