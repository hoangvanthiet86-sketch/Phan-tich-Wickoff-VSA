@echo off
setlocal EnableExtensions

REM Wyckoff VSA Performance Runtime v0.2 - grouped Daily Snapshot fail-closed probe installer
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
echo Installing Wyckoff VSA Daily Snapshot grouped fail-closed probe v0.2...
echo.

if not exist "%INCLUDE%" (
    echo ERROR: AmiBroker Include directory not found.
    goto :fail
)
if not exist "%FORMULA%" mkdir "%FORMULA%"

if not exist "%INCLUDE%\WyckoffVSA_RuntimeConfig_v0.2.afl" goto :missingstack
if not exist "%INCLUDE%\WyckoffVSA_DailySnapshotContract_v0.2.afl" goto :missingstack
if not exist "%INCLUDE%\WyckoffVSA_DailySnapshotConsumer_v0.2.afl" goto :missingstack
if not exist "%INCLUDE%\WyckoffVSA_OperationalClock_v0.1.afl" goto :missingstack

curl.exe -L --fail --silent --show-error "%RAW%/afl/WyckoffVSA_DailySnapshot_FailClosedGroupedProbe_v0.2.afl" -o "%FORMULA%\WyckoffVSA_DailySnapshot_FailClosedGroupedProbe_v0.2.afl"
if errorlevel 1 goto :fail

findstr /C:"DAILY_SNAPSHOT_FAILCLOSED_GROUPED_V02_20260913_A" "%FORMULA%\WyckoffVSA_DailySnapshot_FailClosedGroupedProbe_v0.2.afl" >nul || goto :fail

echo INSTALLED: WyckoffVSA_DailySnapshot_FailClosedGroupedProbe_v0.2.afl
echo.
echo INSTALL COMPLETED SUCCESSFULLY.
echo.
echo ONE-RUN NATIVE CHECKPOINT:
echo   Formula: WyckoffVSA_DailySnapshot_FailClosedGroupedProbe_v0.2.afl
echo   Apply to: All quotations
echo   Periodicity: Daily
echo   Range: 1 recent bar
echo   Explore
echo.
echo Expected output: exactly 9 selected test symbols.
echo Every row must show CASE PASS = 1.
echo Invalid cases must show Fail-Closed Zero Surface = 1.
echo DTP VALID must show Actual Status = 1 and Valid Surface Preserved = 1.
echo.
echo This probe uses and removes only WVSA_DAILY_FC_TEST_v02_* StaticVars.
echo Production WVSA_DAILY_v02_* snapshots are not modified.
echo.
start "" explorer.exe "%FORMULA%"
pause
exit /b 0

:missingstack
echo ERROR: Required Runtime/Daily Snapshot consumer stack is missing.
echo Install the validated Daily Snapshot and Fast Scanner packages first.
goto :fail

:fail
echo.
echo INSTALL FAILED. No PASS is claimed.
pause
exit /b 1
