@echo off
setlocal EnableExtensions

REM Wyckoff VSA Performance Runtime v0.2 - Native performance benchmark installer
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
echo Installing Wyckoff VSA Runtime v0.2 native performance benchmark probes...
echo.

if not exist "%INCLUDE%" (
    echo ERROR: AmiBroker Include directory not found.
    goto :fail
)
if not exist "%FORMULA%" mkdir "%FORMULA%"

if not exist "%INCLUDE%\WyckoffVSA_RuntimeConfig_v0.2.afl" goto :missingstack
if not exist "%INCLUDE%\WyckoffVSA_MarketScanner_Runtime_v0.2.afl" goto :missingstack
if not exist "%INCLUDE%\WyckoffVSA_DailySnapshotConsumer_v0.2.afl" goto :missingstack

curl.exe -L --fail --silent --show-error "%RAW%/afl/WyckoffVSA_PerformanceBenchmark_FullRuntime_v0.2.afl" -o "%FORMULA%\WyckoffVSA_PerformanceBenchmark_FullRuntime_v0.2.afl"
if errorlevel 1 goto :fail

curl.exe -L --fail --silent --show-error "%RAW%/afl/WyckoffVSA_PerformanceBenchmark_FastSnapshot_v0.2.afl" -o "%FORMULA%\WyckoffVSA_PerformanceBenchmark_FastSnapshot_v0.2.afl"
if errorlevel 1 goto :fail

findstr /C:"PERF_BENCH_FULL_RUNTIME_V02_20260913_A" "%FORMULA%\WyckoffVSA_PerformanceBenchmark_FullRuntime_v0.2.afl" >nul || goto :fail
findstr /C:"PERF_BENCH_FAST_SNAPSHOT_V02_20260913_A" "%FORMULA%\WyckoffVSA_PerformanceBenchmark_FastSnapshot_v0.2.afl" >nul || goto :fail
findstr /C:"GetPerformanceCounter(1)" "%FORMULA%\WyckoffVSA_PerformanceBenchmark_FullRuntime_v0.2.afl" >nul || goto :fail
findstr /C:"GetPerformanceCounter(1)" "%FORMULA%\WyckoffVSA_PerformanceBenchmark_FastSnapshot_v0.2.afl" >nul || goto :fail

echo INSTALLED: WyckoffVSA_PerformanceBenchmark_FullRuntime_v0.2.afl
echo INSTALLED: WyckoffVSA_PerformanceBenchmark_FastSnapshot_v0.2.afl
echo.
echo INSTALL COMPLETED SUCCESSFULLY.
echo.
echo BENCHMARK PROTOCOL - use the EXACT SAME universe for both runs:
echo.
echo RUN A - FULL RUNTIME
necho   Formula: WyckoffVSA_PerformanceBenchmark_FullRuntime_v0.2.afl
necho   Apply to: same universe used for the 1558-row equivalence baseline
necho   Periodicity: Daily
necho   Range: 1 recent bar
necho   Explore, then export result to TXT
necho.
echo RUN B - FAST SNAPSHOT
necho   Formula: WyckoffVSA_PerformanceBenchmark_FastSnapshot_v0.2.afl
necho   Apply to: EXACTLY the same universe
necho   Periodicity: Daily
necho   Range: 1 recent bar
necho   Explore, then export result to TXT
necho.
echo Send both TXT files back. Comparison will use matched symbols and report
necho median / mean / P95 elapsed milliseconds and matched-symbol speed ratio.
echo.
echo NOTE: these are formula-local per-symbol execution timings, not total
necho Analysis-window wall-clock time. If AmiBroker also shows total Analysis
necho elapsed time, note it separately as supplementary evidence.
echo.
start "" explorer.exe "%FORMULA%"
pause
exit /b 0

:missingstack
echo ERROR: Required Runtime/Fast Snapshot Include stack is missing.
echo Install the validated Runtime, Daily Snapshot and Fast Scanner packages first.
goto :fail

:fail
echo.
echo INSTALL FAILED. No performance claim is made.
pause
exit /b 1
