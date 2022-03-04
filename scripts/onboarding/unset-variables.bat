@echo off
REM // ----------------------------------------------------------------------------------
REM // Copyright (c) Microsoft Corporation.
REM // Licensed under the MIT license.
REM //
REM // THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
REM // EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
REM // OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
REM // ----------------------------------------------------------------------------------

REM echo Enter pattern for environment variable match:
REM set /p ENV_VAR_PATTERN=""

set ENV_VAR_PATTERN="DEVOPS_"

echo.
echo Your environment variables matching [%ENV_VAR_PATTERN%] are:
echo.
set %ENV_VAR_PATTERN%
echo.

choice /C "YN" /M "Do you want to clear all of these environment variables?"
if errorlevel 2 exit /b 0

REM Unset environment variables
for /f "usebackq delims==" %%A in (`set %ENV_VAR_PATTERN%`) do set %%A=
echo.
echo environment variables matching [%ENV_VAR_PATTERN%] have been cleared!
echo.
