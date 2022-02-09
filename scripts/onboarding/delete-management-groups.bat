@echo off
REM // ----------------------------------------------------------------------------------
REM // Copyright (c) Microsoft Corporation.
REM // Licensed under the MIT license.
REM //
REM // THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
REM // EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
REM // OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
REM // ----------------------------------------------------------------------------------

set TMPFILE=management-groups.txt

REM Get currently signed-in user identity
echo.
echo Getting currently signed-in user identity...
echo.
call az ad signed-in-user show --query "userPrincipalName"

REM Get default subscription information
echo.
echo Getting default subscription information...
echo.
call az account list --query "[?isDefault].{Name:name, Id:id, AAD:homeTenantId, User:user.name}" -o table

REM Get list of management groups in reverse order
echo.
echo Getting list of all management groups...
echo.
call az account management-group list -o tsv | sed "/Tenant Root Group/d" | cut -f 1 - | sort -k 1r - >%TMPFILE%

REM Show user all management groups found
echo.
echo Management groups
echo -----------------
cat %TMPFILE%
echo.

REM Prompt user confirmation to delete all management groups
echo.
echo WARNING:
echo -------------------------------------------------------------------
echo Continuing this script will delete the listed management groups,
echo which will also disassociate any subscriptions associated with each
echo management group. Subscriptions associated with a management group
echo that is being deleted will be re-parented to the tenant root scope.
echo.
echo Also note that this script will delete **all** management groups
echo defined in the current tenant, whether or not they were created for
echo your `CanadaPubSecALZ` work or by some other means.
echo.
echo Be sure you understand the implications of continuing this script
echo before proceeding. If you're not 100% certain, then select "N" at
echo the following prompt.
echo -------------------------------------------------------------------
echo.
choice /C YN /M "Do you want to proceed?"
if errorlevel 2 exit /b 0
echo.

REM Delete all management groups (in hierarchy reverse order)
for /f usebackq %%m in (`cat %TMPFILE%`) do (

    REM Check for subscriptions that need to be removed from management group
    echo Checking management group [%%m] for subscriptions that need to be removed first...
    for /f "usebackq delims=" %%s in (
        `call az account management-group show --name "%%m" --expand --query "children[?type=='/subscriptions'].{Name:displayName}" -o tsv`
    ) do (
        echo    removing subscription [%%s] from management group [%%m]...
        call az account management-group subscription remove --name "%%m" --subscription "%%s"
    )
    echo Deleting management group: %%m
    call az account management-group delete --name %%m
)

REM Remove %TMPFILE% temporary file
if exist %TMPFILE% (
    echo Deleting temporary file '%TMPFILE%'
    erase %TMPFILE%
)
