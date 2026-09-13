@echo off
setlocal EnableExtensions

REM Wyckoff VSA Performance Runtime v0.2 - Fast Scanner installer
REM Right-click -> Run as administrator.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator rights...
    powershell -NoProfile -Command "Start-Process -Verb RunAs -FilePath '%~f0'"
    exit /b
)

set "INCLUDE=C:\Program Files (x86)\AmiBroker\Formulas\Include"
set "FORMULA=C:\Program Files (x86)\AmiBroker\Formulas\afl"
set "RAW=https://raw.githubusercontent.com/hoangvanthiet86-sketch/Phan-tich-Wickoff-VSA/feature/performance-runtime-v0.2"

echo.
echo Installing Wyckoff VSA Fast Scanner v0.2...
echo Include: %INCLUDE%
echo Formula: %FORMULA%
echo.

if not exist "%INCLUDE%" (
    echo ERROR: AmiBroker Include directory not found.
    goto :fail
)
if not exist "%FORMULA%" mkdir "%FORMULA%"

REM The Daily Snapshot contract and Runtime configuration must already exist.
if not exist "%INCLUDE%\WyckoffVSA_RuntimeConfig_v0.2.afl" goto :missingstack
if not exist "%INCLUDE%\WyckoffVSA_DailySnapshotContract_v0.2.afl" goto :missingstack
if not exist "%INCLUDE%\WyckoffVSA_OperationalClock_v0.1.afl" goto :missingstack

curl.exe -L --fail --silent --show-error "%RAW%/afl/WyckoffVSA_DailySnapshotConsumer_v0.2.afl" -o "%INCLUDE%\WyckoffVSA_DailySnapshotConsumer_v0.2.afl"
if errorlevel 1 goto :fail

curl.exe -L --fail --silent --show-error "%RAW%/afl/WyckoffVSA_FastScanner_v0.2.afl" -o "%FORMULA%\WyckoffVSA_FastScanner_v0.2.afl"
if errorlevel 1 goto :fail

findstr /C:"Headless Daily Stock Snapshot Consumer" "%INCLUDE%\WyckoffVSA_DailySnapshotConsumer_v0.2.afl" >nul || goto :fail
findstr /C:"FAST_SCANNER_V02_20260913_A" "%FORMULA%\WyckoffVSA_FastScanner_v0.2.afl" >nul || goto :fail

echo INSTALLED: WyckoffVSA_DailySnapshotConsumer_v0.2.afl
echo INSTALLED: WyckoffVSA_FastScanner_v0.2.afl
echo.
echo INSTALL COMPLETED SUCCESSFULLY.
echo.
echo Native checkpoint:
echo   1. Keep the DTP snapshot already published and VALID.
echo   2. Open Analysis and select WyckoffVSA_FastScanner_v0.2.afl.
echo   3. Symbol DTP, Daily, Current / 1 recent bar, Explore.
echo   4. For the first checkpoint set 1.2 Production Filter = 3 Review.
echo   5. Expected DTP: Snapshot Status=1, Candidate Class=9, Stage=1,
echo      Scanner Review=1, Method Block Mask=1031, Range Position about -2.3027.
echo.
echo Opening the formula folder so the installed AFL is easy to locate...
start "" explorer.exe "%FORMULA%"
echo.
pause
exit /b 0

:missingstack
echo ERROR: Required Runtime/Daily Snapshot Include files are missing.
echo Install/run the validated Daily Snapshot v0.2.7 package first.
goto :fail

:fail
echo.
echo INSTALL FAILED. No PASS is claimed.
pause
exit /b 1
