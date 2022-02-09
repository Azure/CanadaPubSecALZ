@echo off
REM // ----------------------------------------------------------------------------------
REM // Copyright (c) Microsoft Corporation.
REM // Licensed under the MIT license.
REM //
REM // THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
REM // EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
REM // OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
REM // ----------------------------------------------------------------------------------

if '%1' == '' goto Usage

echo.
echo Removing user [%1] from elevated "User Access Administrator" role at tenant root scope...
echo.
choice /C YN /M "Do you want to proceed?"
if errorlevel 2 exit /b 0

call az role assignment delete --assignee %1 --role "User Access Administrator" --scope "/"

goto :EOF

:Usage
echo.
echo Missing parameter. Specify a user (UPN) to remove from the elevated "User Access Administrator" role at root scope of the tenant for the currently signed-in user.
echo.
