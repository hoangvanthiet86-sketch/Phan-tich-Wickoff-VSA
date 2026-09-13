@echo off
setlocal EnableExtensions

REM Wyckoff VSA Performance Runtime v0.2 - VN STOCKS ONLY U4 installer
REM Right-click -> Run as administrator.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator rights...
    powershell -NoProfile -Command "Start-Process -Verb RunAs -FilePath '%~f0'"
    exit /b
)

set "FORMULA=C:\Program Files (x86)\AmiBroker\Formulas\afl"
set "RAW=https://raw.githubusercontent.com/hoangvanthiet86-sketch/Phan-tich-Wickoff-VSA/feature/performance-runtime-v0.2"
set "PUBLISHER=%FORMULA%\WyckoffVSA_DailyPublisher_v0.2.afl"
set "FAST=%FORMULA%\WyckoffVSA_FastScanner_v0.2.afl"
set "AUDIT=%FORMULA%\WyckoffVSA_VNStocksOnly_OperationalSnapshotAudit_v0.2.afl"

echo.
echo Installing VN STOCKS ONLY U4 operational formulas...
echo.

if not exist "%FORMULA%" mkdir "%FORMULA%"

curl.exe -L --fail --silent --show-error "%RAW%/afl/WyckoffVSA_DailyPublisher_v0.2.afl" -o "%PUBLISHER%"
if errorlevel 1 goto :fail

curl.exe -L --fail --silent --show-error "%RAW%/afl/WyckoffVSA_FastScanner_v0.2.afl" -o "%FAST%"
if errorlevel 1 goto :fail

curl.exe -L --fail --silent --show-error "%RAW%/afl/WyckoffVSA_VNStocksOnly_OperationalSnapshotAudit_v0.2.afl" -o "%AUDIT%"
if errorlevel 1 goto :fail

findstr /C:"DAILY_PUBLISHER_V02_20260912_A" "%PUBLISHER%" >nul || goto :fail
findstr /C:"FAST_SCANNER_V02_20260913_A" "%FAST%" >nul || goto :fail
findstr /C:"VN_STOCKS_ONLY_U4_SNAPSHOT_AUDIT_V02_20260913_A" "%AUDIT%" >nul || goto :fail
findstr /C:"InWatchListName" "%AUDIT%" >nul || goto :fail
findstr /C:"U4_SnapshotValid" "%AUDIT%" >nul || goto :fail

echo INSTALLED: WyckoffVSA_DailyPublisher_v0.2.afl
echo INSTALLED: WyckoffVSA_FastScanner_v0.2.afl
echo INSTALLED: WyckoffVSA_VNStocksOnly_OperationalSnapshotAudit_v0.2.afl
echo.
echo INSTALL COMPLETED SUCCESSFULLY.
echo.
echo ============================================================
echo U4-A - DAILY PUBLISHER
 echo ============================================================
echo Formula: WyckoffVSA_DailyPublisher_v0.2.afl
echo Apply to: VN STOCKS ONLY
echo Periodicity: Daily
echo Range: 1 recent bar
echo Parameter 1.3 Treat Last Bar As Provisional: No
echo Explore and export TXT.
echo Record AmiBroker Analysis wall-clock elapsed time.
echo Expected rows: 1668
echo Expected Publisher Status: 1 / COMMITTED on every row.
echo.
echo ============================================================
echo U4-B - SNAPSHOT COVERAGE AUDIT
 echo ============================================================
echo Formula: WyckoffVSA_VNStocksOnly_OperationalSnapshotAudit_v0.2.afl
echo Apply to: VN STOCKS ONLY
echo Periodicity: Daily
echo Range: 1 recent bar
echo Explore and export TXT.
echo Expected rows: 1668
echo Expected U4_SnapshotStatus: 1 on every row.
echo Expected U4_SnapshotValid: 1 on every row.
echo.
echo ============================================================
echo U4-C - FAST SCANNER OPERATIONAL RUN
 echo ============================================================
echo Formula: WyckoffVSA_FastScanner_v0.2.afl
echo Apply to: VN STOCKS ONLY
echo Periodicity: Daily
echo Range: 1 recent bar
echo Parameter 1.2 Production Filter: 4 All Eligible
echo Explore and export TXT.
echo Record AmiBroker Analysis wall-clock elapsed time.
echo Row count must equal U4_DataEligible=1 count from U4-B.
echo Every emitted row must have Snapshot Status = 1.
echo.
echo SEND BACK:
echo   1. Publisher TXT
 echo   2. U4 Snapshot Audit TXT
 echo   3. Fast Scanner TXT
 echo   4. Publisher wall-clock elapsed time
 echo   5. Fast Scanner wall-clock elapsed time
 echo.
echo No U4 PASS claim is made before native evidence is checked.
echo.
start "" explorer.exe "%FORMULA%"
pause
exit /b 0

:fail
echo.
echo INSTALL FAILED. No U4 PASS claim is made.
pause
exit /b 1
