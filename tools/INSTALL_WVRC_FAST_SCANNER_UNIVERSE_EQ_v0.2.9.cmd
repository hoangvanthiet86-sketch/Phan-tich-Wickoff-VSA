@echo off
setlocal EnableExtensions

REM Wyckoff VSA Performance Runtime v0.2 - Fast Scanner Universe Equivalence installer
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
echo Installing Wyckoff VSA Fast Scanner Universe Equivalence Probe v0.2...
echo Include: %INCLUDE%
echo Formula: %FORMULA%
echo.

if not exist "%INCLUDE%" (
    echo ERROR: AmiBroker Include directory not found.
    goto :fail
)
if not exist "%FORMULA%" mkdir "%FORMULA%"

if not exist "%INCLUDE%\WyckoffVSA_RuntimeConfig_v0.2.afl" goto :missingstack
if not exist "%INCLUDE%\WyckoffVSA_DailySnapshotContract_v0.2.afl" goto :missingstack
if not exist "%INCLUDE%\WyckoffVSA_DailySnapshotConsumer_v0.2.afl" goto :missingstack
if not exist "%FORMULA%\WyckoffVSA_DailyPublisher_v0.2.afl" goto :missingpublisher

curl.exe -L --fail --silent --show-error "%RAW%/afl/WyckoffVSA_FastScanner_UniverseEquivalenceProbe_v0.2.afl" -o "%FORMULA%\WyckoffVSA_FastScanner_UniverseEquivalenceProbe_v0.2.afl"
if errorlevel 1 goto :fail

findstr /C:"FAST_SCANNER_UNIVERSE_EQ_V02_20260913_A" "%FORMULA%\WyckoffVSA_FastScanner_UniverseEquivalenceProbe_v0.2.afl" >nul || goto :fail

echo INSTALLED: WyckoffVSA_FastScanner_UniverseEquivalenceProbe_v0.2.afl
echo.
echo INSTALL COMPLETED SUCCESSFULLY.
echo.
echo NATIVE UNIVERSE CHECKPOINT:
echo   STEP 1 - Publish snapshots for the same universe used by the 1,558-row baseline.
echo     Formula: WyckoffVSA_DailyPublisher_v0.2.afl
echo     Apply to: All quotations / same universe as baseline
echo     Periodicity: Daily
echo     Range: 1 recent bar

echo   STEP 2 - Run snapshot-only equivalence probe.
echo     Formula: WyckoffVSA_FastScanner_UniverseEquivalenceProbe_v0.2.afl
echo     Apply to: the exact same universe
echo     Periodicity: Daily
echo     Range: 1 recent bar

echo   Expected if database/config remain equivalent:
echo     1558 eligible rows and exact decision-surface match.
echo.
echo   Please note the Analysis elapsed time for STEP 1 and STEP 2 if visible.
echo   Export STEP 2 result to TXT and send it back for automated comparison.
echo.
echo Opening the formula folder...
start "" explorer.exe "%FORMULA%"
echo.
pause
exit /b 0

:missingstack
echo ERROR: Required Runtime/Daily Snapshot consumer stack is missing.
echo Install/run Fast Scanner v0.2.8 and Daily Snapshot v0.2.7 first.
goto :fail

:missingpublisher
echo ERROR: WyckoffVSA_DailyPublisher_v0.2.afl is missing from %FORMULA%.
echo Install Daily Snapshot v0.2.7 first.
goto :fail

:fail
echo.
echo INSTALL FAILED. No PASS is claimed.
pause
exit /b 1
