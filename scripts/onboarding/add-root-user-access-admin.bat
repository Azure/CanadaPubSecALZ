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
echo Elevating the currently signed-in user to "User Access Administrator" role...
echo.
choice /C YN /M "Do you want to proceed?"
if errorlevel 2 exit /b 0

call az rest --method post --url "/providers/Microsoft.Authorization/elevateAccess?api-version=2016-07-01"
