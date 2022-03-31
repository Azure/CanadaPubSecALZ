@echo off
REM // ----------------------------------------------------------------------------------
REM // Copyright (c) Microsoft Corporation.
REM // Licensed under the MIT license.
REM //
REM // THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
REM // EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
REM // OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
REM // ----------------------------------------------------------------------------------

REM Need delayed expansion to process !var! environment variables
setlocal EnableDelayedExpansion

REM Environment variables local to this script
set MGMT_GROUP_HIERARCHY_FILE=management-groups.txt
set MGMT_GROUP_ROOT_ID=%DEVOPS_TENANT_ID%
if not "%1" == "" set MGMT_GROUP_ROOT_ID=%1

echo.
echo This script will remove all management groups below level: [%MGMT_GROUP_ROOT_ID%].
echo If the specific level is not the Tenant Root Group, it will be removed also.
echo.
echo   DEVOPS_OUTPUT_DIR       = %DEVOPS_OUTPUT_DIR%
echo   DEVOPS_TENANT_ID        = %DEVOPS_TENANT_ID%
echo.
echo   Target Management Group = %MGMT_GROUP_ROOT_ID%
echo.
echo If these settings are not correct, please exit, update/run the set-variables.[YourEnv].bat script, and re-run this script
echo.
choice /C YN /M "Do you want to proceed?"
if errorlevel 2 exit /b 0

REM Check output directory exists
if not exist %DEVOPS_OUTPUT_DIR% (
    echo Intermediate output directory does not exist. Creating it at [%DEVOPS_OUTPUT_DIR%]
    md %DEVOPS_OUTPUT_DIR%
)

REM Get the current management group hierarchy
echo.
echo Retrieving management group hierarchy, starting at [%MGMT_GROUP_ROOT_ID%], and storing in: %DEVOPS_OUTPUT_DIR%\%MGMT_GROUP_HIERARCHY_FILE%
call az account management-group show --only-show-errors --name %MGMT_GROUP_ROOT_ID% -e -r | jq -r "recurse | [.id] + [.name] + [.displayName] + [.type | match(\"^^.*/(managementGroups^|subscriptions)$\"; \"g\").captures[0].string] + ( .children?[]? | [.id] + [.name] + [.displayName] + [.type | match(\"^^.*/(managementGroups^|subscriptions)$\"; \"g\").captures[0].string] ) | @tsv" >%DEVOPS_OUTPUT_DIR%\%MGMT_GROUP_HIERARCHY_FILE%

REM Check that some results were returned, i.e. the management group is valid
for %%R in (%DEVOPS_OUTPUT_DIR%\%MGMT_GROUP_HIERARCHY_FILE%) do (
  if %%~zR EQU 0 (
    echo Unable to locate management group [%MGMT_GROUP_ROOT_ID%]
    echo Exiting script
    exit /b 1
  )
)

echo.
echo ------------	-----------
echo Parent Group	Child Group
echo ------------	-----------
cat %DEVOPS_OUTPUT_DIR%\%MGMT_GROUP_HIERARCHY_FILE% | cut -f 2,6
echo ------------	-----------

echo.
echo WARNING:
echo -------------------------------------------------------------------------------
echo Continuing this script will delete these listed management groups, and will
echo also disassociate any subscriptions associated with each management group.
echo Subscriptions associated with a management group that is being deleted will
echo be re-parented to the tenant root scope. Any custom role definitions that
echo have names starting with "Custom - " may also be affected. Any custom role
echo assignments at an included subscription scope will be removed, and any
echo custom role definitions scoped to an included management group will be deleted.
echo.
echo Ensure you understand the implications of using this script before proceeding.
echo If you're not 100%% certain, then select "N" at the following prompt.
echo -------------------------------------------------------------------------------
echo.
choice /C YN /M "Do you want to proceed?"
if errorlevel 2 exit /b 0
echo.

REM Process the management group hierarchy (in reverse order)
echo Processing management group hierarchy, starting at management group node [%MGMT_GROUP_ROOT_ID%]

REM Note: The 'delims=' contains a TAB character (<Alt> <Numpad: 0 0 9>). If you or your text editor convert this TAB to a SPACE, this script will no longer function as expected. Also, pay attention to DOS escape characters documented here: https://www.robvanderwoude.com/escapechars.php
for /f "usebackq tokens=1-8 delims=	" %%A in (`cat %DEVOPS_OUTPUT_DIR%\%MGMT_GROUP_HIERARCHY_FILE% ^| tac`) do (
  REM Capture parent element attributes
  set P_ID=%%A
  set P_NAME=%%B
  set P_DISPLAY=%%C
  set P_TYPE=%%D
  REM Capture child element attributes
  set C_ID=%%E
  set C_NAME=%%F
  set C_DISPLAY=%%G
  set C_TYPE=%%H

  if "!C_TYPE!" == "subscriptions" (
    if "!P_NAME!" NEQ "%DEVOPS_TENANT_ID%" (
      REM Remove custom role assignments from subscription
      for /f "usebackq" %%R in (`call az role assignment list --only-show-errors --all --subscription "!C_NAME!" --query "[? contains(roleDefinitionName, 'Custom - ')]" ^| jq -r ".[].id"`) do (
          echo Removing custom role assignment from subscription [!C_DISPLAY!] [!C_NAME!] role id: [%%R]
          call az role assignment delete --only-show-errors --ids "%%R"
      )
      REM Remove subscription from management group
      echo Removing subscription [!C_DISPLAY!] [!C_NAME!] from management group [!P_DISPLAY!] [!P_NAME!]
      call az account management-group subscription remove --only-show-errors --name "!P_NAME!" --subscription "!C_DISPLAY!"
    ) else (
      echo Subscription [!C_DISPLAY!] [!C_NAME!] is already parented by Tenant Root Group. No further action required.
    )
  ) else (
    if "!C_TYPE!" == "managementGroups" (
      REM Delete custom role definitions at management group scope
      for /f "usebackq delims=" %%L in (`call az role definition list --only-show-errors --custom-role-only true --scope "!C_ID!" --query "[? contains(assignableScopes, '!C_ID!')]" ^| jq -r ".[].roleName"`) do (
        echo Deleting custom role definition [%%L] at management group [!C_DISPLAY!] [!C_NAME!] scope
        call az role definition delete --only-show-errors --custom-role-only true --scope "!C_ID!" --name "%%L"
      )
      REM Delete management group
      echo Deleting management group [!C_DISPLAY!] [!C_NAME!]
      call az account management-group delete --only-show-errors --name "!C_NAME!"
    ) else (
      echo.
      echo ***ERROR*** in 'az account management-group show' output
      echo   Unable to find '/managementGroups' or '/subscriptions' resource type for element with identifier [!C_ID!]
      echo   Check intermediate output file: %DEVOPS_OUTPUT_DIR%\%MGMT_GROUP_HIERARCHY_FILE%
      echo.
    )
  )
)

REM If the top level management group is not the Tenant Root Group,
REM then perform the same management group erasure steps at that level.
if "%MGMT_GROUP_ROOT_ID%" NEQ "%DEVOPS_TENANT_ID%" (
  REM Capture element attributes
  echo Retrieving details for management group node [%MGMT_GROUP_ROOT_ID%]
  REM Note: The 'delims=' contains a TAB character (<Alt> <Numpad: 0 0 9>). If you or your text editor convert this TAB to a SPACE, this script will no longer function as expected. Also, pay attention to DOS escape characters documented here: https://www.robvanderwoude.com/escapechars.php
  for /f "usebackq tokens=1-3 delims=	" %%A in (`call az account management-group show --only-show-errors --name %MGMT_GROUP_ROOT_ID% ^| jq -r "[.id]+[.name]+[.displayName] | @tsv"`) do (
    set C_ID=%%A
    set C_NAME=%%B
    set C_DISPLAY=%%C
  )
  REM Delete custom role definitions at management group scope
  echo Deleting custom role definitions, if any, at management group [!C_DISPLAY!] [!C_NAME!] scope:
  for /f "usebackq delims=" %%L in (`call az role definition list --only-show-errors --custom-role-only true --scope "!C_ID!" --query "[? contains(assignableScopes, '!C_ID!')]" ^| jq -r ".[].roleName"`) do (
    echo   Deleting custom role definition [%%L]
    call az role definition delete --only-show-errors --custom-role-only true --scope "!C_ID!" --name "%%L"
  )
  REM Delete management group
  echo Deleting management group [!C_DISPLAY!] [!C_NAME!]
  call az account management-group delete --only-show-errors --name "!C_NAME!"
)
