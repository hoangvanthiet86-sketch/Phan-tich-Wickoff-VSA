@echo off
setlocal EnableExtensions

REM Wyckoff VSA Performance Runtime v0.2 - VN STOCKS ONLY watchlist builder/audit installer
REM Right-click -> Run as administrator.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator rights...
    powershell -NoProfile -Command "Start-Process -Verb RunAs -FilePath '%~f0'"
    exit /b
)

set "FORMULA=C:\Program Files (x86)\AmiBroker\Formulas\afl"
set "RAW=https://raw.githubusercontent.com/hoangvanthiet86-sketch/Phan-tich-Wickoff-VSA/feature/performance-runtime-v0.2"
set "BUILDER=%FORMULA%\WyckoffVSA_VNStocksOnly_WatchlistBuilder_v0.2.afl"
set "AUDIT=%FORMULA%\WyckoffVSA_VNStocksOnly_WatchlistAudit_v0.2.afl"

echo.
echo Installing VN STOCKS ONLY watchlist builder and audit...
echo.

if not exist "%FORMULA%" mkdir "%FORMULA%"

curl.exe -L --fail --silent --show-error "%RAW%/afl/WyckoffVSA_VNStocksOnly_WatchlistBuilder_v0.2.afl" -o "%BUILDER%"
if errorlevel 1 goto :fail

curl.exe -L --fail --silent --show-error "%RAW%/afl/WyckoffVSA_VNStocksOnly_WatchlistAudit_v0.2.afl" -o "%AUDIT%"
if errorlevel 1 goto :fail

findstr /C:"VN_STOCKS_ONLY_WATCHLIST_BUILDER_V02_20260913_B" "%BUILDER%" >nul || goto :fail
findstr /C:"CategoryCreate" "%BUILDER%" >nul || goto :fail
findstr /C:"CategoryAddSymbol" "%BUILDER%" >nul || goto :fail
findstr /C:"CategoryRemoveSymbol" "%BUILDER%" >nul || goto :fail
findstr /C:"VN_STOCKS_ONLY_WATCHLIST_AUDIT_V02_20260913_B" "%AUDIT%" >nul || goto :fail
findstr /C:"InWatchListName" "%AUDIT%" >nul || goto :fail

echo INSTALLED: WyckoffVSA_VNStocksOnly_WatchlistBuilder_v0.2.afl
echo INSTALLED: WyckoffVSA_VNStocksOnly_WatchlistAudit_v0.2.afl
echo.
echo INSTALL COMPLETED SUCCESSFULLY.
echo.
echo STEP 1 - BUILD / SYNCHRONIZE WATCHLIST:
echo   Formula: WyckoffVSA_VNStocksOnly_WatchlistBuilder_v0.2.afl
echo   Apply to: All quotations
echo   Periodicity: Daily
echo   Range: 1 recent bar
echo   Explore
echo   Expected Exploration rows from current audited database: 1668
echo   Expected watchlist name: VN STOCKS ONLY
echo.
echo STEP 2 - VERIFY EXACT MEMBERSHIP:
echo   Formula: WyckoffVSA_VNStocksOnly_WatchlistAudit_v0.2.afl
echo   Apply to: All quotations
echo   Periodicity: Daily
echo   Range: 1 recent bar
echo   Explore
echo   Expected result: ZERO ROWS
echo.
echo IMPORTANT:
echo   The builder modifies ONLY the watchlist VN STOCKS ONLY.
echo   It does NOT modify Market/Group/Sector/Industry metadata.
echo   The audit is read-only.
echo.
start "" explorer.exe "%FORMULA%"
pause
exit /b 0

:fail
echo.
echo INSTALL FAILED. No VN STOCKS ONLY PASS claim is made.
pause
exit /b 1
