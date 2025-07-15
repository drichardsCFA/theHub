@echo off
REM CFAi Hub - Server Statistics Update Script
REM This batch file runs the PowerShell statistics connector

setlocal enabledelayedexpansion

REM Set paths
set "SCRIPT_DIR=%~dp0"
set "POWERSHELL_SCRIPT=%SCRIPT_DIR%server-stats.ps1"
set "OUTPUT_DIR=%SCRIPT_DIR%..\data"
set "LOG_FILE=%SCRIPT_DIR%..\logs\stats-update.log"

REM Create output and log directories
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if not exist "%SCRIPT_DIR%..\logs" mkdir "%SCRIPT_DIR%..\logs"

REM Get current timestamp
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YEAR=%dt:~2,2%"
set "MONTH=%dt:~4,2%"
set "DAY=%dt:~6,2%"
set "HOUR=%dt:~8,2%"
set "MINUTE=%dt:~10,2%"
set "SECOND=%dt:~12,2%"
set "TIMESTAMP=%YEAR%-%MONTH%-%DAY% %HOUR%:%MINUTE%:%SECOND%"

REM Log start of execution
echo [%TIMESTAMP%] Starting CFAi Hub statistics update >> "%LOG_FILE%"

REM Check if PowerShell script exists
if not exist "%POWERSHELL_SCRIPT%" (
    echo [%TIMESTAMP%] ERROR: PowerShell script not found at %POWERSHELL_SCRIPT% >> "%LOG_FILE%"
    exit /b 1
)

REM Run PowerShell script with execution policy bypass
powershell.exe -ExecutionPolicy Bypass -File "%POWERSHELL_SCRIPT%" -Verbose 2>&1

REM Check exit code
if %ERRORLEVEL% EQU 0 (
    echo [%TIMESTAMP%] Statistics update completed successfully >> "%LOG_FILE%"
    exit /b 0
) else (
    echo [%TIMESTAMP%] ERROR: Statistics update failed with exit code %ERRORLEVEL% >> "%LOG_FILE%"
    exit /b %ERRORLEVEL%
) 