@echo off
setlocal EnableExtensions

REM Wyckoff VSA Performance Runtime v0.2 - Daily Snapshot installer
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
echo Installing Wyckoff VSA Daily Snapshot v0.2...
echo Include: %INCLUDE%
echo Formula: %FORMULA%
echo.

if not exist "%INCLUDE%" (
    echo ERROR: AmiBroker Include directory not found.
    goto :fail
)
if not exist "%FORMULA%" mkdir "%FORMULA%"

REM The native-validated Runtime v0.2 stack must already exist.
if not exist "%INCLUDE%\WyckoffVSA_RuntimeConfig_v0.2.afl" goto :missingstack
if not exist "%INCLUDE%\WyckoffVSA_MarketScanner_Runtime_v0.2.afl" goto :missingstack
if not exist "%INCLUDE%\WyckoffVSA_CompositeIndicator_Runtime_v0.2.afl" goto :missingstack

curl.exe -L --fail --silent --show-error "%RAW%/afl/WyckoffVSA_DailySnapshotContract_v0.2.afl" -o "%INCLUDE%\WyckoffVSA_DailySnapshotContract_v0.2.afl"
if errorlevel 1 goto :fail

curl.exe -L --fail --silent --show-error "%RAW%/afl/WyckoffVSA_DailyPublisher_v0.2.afl" -o "%FORMULA%\WyckoffVSA_DailyPublisher_v0.2.afl"
if errorlevel 1 goto :fail

curl.exe -L --fail --silent --show-error "%RAW%/afl/WyckoffVSA_DailySnapshot_ConsumerProbe_v0.2.afl" -o "%FORMULA%\WyckoffVSA_DailySnapshot_ConsumerProbe_v0.2.afl"
if errorlevel 1 goto :fail

findstr /C:"WDS_SchemaMajor = 2" "%INCLUDE%\WyckoffVSA_DailySnapshotContract_v0.2.afl" >nul || goto :fail
findstr /C:"DAILY_PUBLISHER_V02_20260912_A" "%FORMULA%\WyckoffVSA_DailyPublisher_v0.2.afl" >nul || goto :fail
findstr /C:"DAILY_SNAPSHOT_CONSUMER_PROBE_V02_20260912_A" "%FORMULA%\WyckoffVSA_DailySnapshot_ConsumerProbe_v0.2.afl" >nul || goto :fail

echo INSTALLED: WyckoffVSA_DailySnapshotContract_v0.2.afl
echo INSTALLED: WyckoffVSA_DailyPublisher_v0.2.afl
echo INSTALLED: WyckoffVSA_DailySnapshot_ConsumerProbe_v0.2.afl
echo.
echo INSTALL COMPLETED SUCCESSFULLY.
echo.
echo Native checkpoint:
echo   1. Run WyckoffVSA_DailyPublisher_v0.2.afl on DTP, Daily, Current, 1 recent bar.
echo   2. Then run WyckoffVSA_DailySnapshot_ConsumerProbe_v0.2.afl on DTP with the same settings.
echo.
pause
exit /b 0

:missingstack
echo ERROR: Runtime v0.2 Include stack is incomplete.
echo Run the previously validated Runtime stack builder first.
goto :fail

:fail
echo.
echo INSTALL FAILED. No PASS is claimed.
pause
exit /b 1
