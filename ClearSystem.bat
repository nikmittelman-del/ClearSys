@echo off
title Professional System Cleaner - Full Safe Version
color 0A
setlocal enabledelayedexpansion

:: =========================================
::   CHECK ADMIN RIGHTS
:: =========================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Please run this script as Administrator.
    pause
    exit /b
)

:: =========================================
::   INITIAL SETUP
:: =========================================
set LOGFILE=%~dp0SystemCleaner.log
set BEFORE=%temp%\disk_before.txt
set AFTER=%temp%\disk_after.txt
echo Cleanup started on %date% at %time% > "%LOGFILE%"

:: Measure free space before cleanup
wmic logicaldisk get size,freespace,caption > "%BEFORE%"

echo ========================================
echo     STARTING FULL SYSTEM CLEANUP...
echo ========================================
echo.

:: =========================================
::   CLEAN BROWSER CACHES
:: =========================================
for /d %%i in (C:\Users\*) do (
    set USERNAME=%%~nxi
    echo ---------------------------------------- >> "%LOGFILE%"
    echo Cleaning data for user: !USERNAME! >> "%LOGFILE%"
    
    :: Microsoft Edge
    if exist "%%i\AppData\Local\Microsoft\Edge\User Data\Default\Cache" (
        echo [OK] Cleaning Edge cache for: !USERNAME!
        rmdir /s /q "%%i\AppData\Local\Microsoft\Edge\User Data\Default\Cache" >> "%LOGFILE%" 2>&1
    )

    :: Google Chrome
    if exist "%%i\AppData\Local\Google\Chrome\User Data\Default\Cache" (
        echo [OK] Cleaning Chrome cache for: !USERNAME!
        rmdir /s /q "%%i\AppData\Local\Google\Chrome\User Data\Default\Cache" >> "%LOGFILE%" 2>&1
    )

    :: Mozilla Firefox
    if exist "%%i\AppData\Local\Mozilla\Firefox\Profiles" (
        for /d %%p in ("%%i\AppData\Local\Mozilla\Firefox\Profiles\*") do (
            if exist "%%p\cache2" (
                echo [OK] Cleaning Firefox cache for: !USERNAME!
                rmdir /s /q "%%p\cache2" >> "%LOGFILE%" 2>&1
            )
        )
    )

    :: Brave Browser
    if exist "%%i\AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\Cache" (
        echo [OK] Cleaning Brave cache for: !USERNAME!
        rmdir /s /q "%%i\AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\Cache" >> "%LOGFILE%" 2>&1
    )
)

:: =========================================
::   CLEAN SYSTEM TEMP FILES
:: =========================================
echo.
echo Cleaning System Temp Files...
for %%T in ("%temp%" "C:\Windows\Temp") do (
    if exist "%%~T" (
        echo [OK] Cleaning %%~T
        rmdir /s /q "%%~T" >> "%LOGFILE%" 2>&1
        mkdir "%%~T" >nul 2>&1
    )
)

:: =========================================
::   CLEAN PREFETCH
:: =========================================
echo.
echo Cleaning Prefetch...
if exist "C:\Windows\Prefetch" (
    rmdir /s /q "C:\Windows\Prefetch" >> "%LOGFILE%" 2>&1
    mkdir "C:\Windows\Prefetch" >nul 2>&1
)

:: =========================================
::   CLEAR EVENT LOGS
:: =========================================
echo.
echo Clearing Windows Event Logs...
for /f "tokens=*" %%a in ('wevtutil el') do (
    echo [OK] Clearing log: %%a
    wevtutil cl "%%a" >> "%LOGFILE%" 2>&1
)

:: =========================================
::   EMPTY RECYCLE BIN
:: =========================================
echo.
echo Emptying Recycle Bin...
powershell.exe -command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >> "%LOGFILE%" 2>&1

:: =========================================
::   CLEAN WINDOWS UPDATE CACHE
:: =========================================
echo.
echo Cleaning Windows Update cache...
net stop wuauserv >nul 2>&1
rmdir /s /q C:\Windows\SoftwareDistribution\Download >> "%LOGFILE%" 2>&1
net start wuauserv >nul 2>&1

:: =========================================
::   REPORT DISK SPACE FREED
:: =========================================
wmic logicaldisk get size,freespace,caption > "%AFTER%"
echo. >> "%LOGFILE%"
echo ========================================= >> "%LOGFILE%"
echo Cleanup completed on %date% at %time% >> "%LOGFILE%"
echo ========================================= >> "%LOGFILE%"

echo.
echo ========================================
echo     CLEANUP COMPLETED SUCCESSFULLY!
echo ========================================
echo Log saved to: %LOGFILE%
echo.

timeout /t 5
exit /b
