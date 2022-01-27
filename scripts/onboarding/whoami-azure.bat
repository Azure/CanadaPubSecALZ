@echo off
REM // ----------------------------------------------------------------------------------
REM // Copyright (c) Microsoft Corporation.
REM // Licensed under the MIT license.
REM //
REM // THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
REM // EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
REM // OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
REM // ----------------------------------------------------------------------------------

for /f "usebackq delims=" %%W in (`call az ad signed-in-user show --query "userPrincipalName"`) do set WHOAMI_AZURE=%%~W

echo.
echo Currently signed-in user is:
echo.
echo %WHOAMI_AZURE%
echo.
