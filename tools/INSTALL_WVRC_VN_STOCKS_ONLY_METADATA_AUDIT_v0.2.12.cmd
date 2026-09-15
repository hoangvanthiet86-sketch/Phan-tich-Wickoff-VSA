@echo off
setlocal EnableExtensions

REM Wyckoff VSA Performance Runtime v0.2 - VN STOCKS ONLY metadata audit installer
REM Right-click -> Run as administrator.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator rights...
    powershell -NoProfile -Command "Start-Process -Verb RunAs -FilePath '%~f0'"
    exit /b
)

set "FORMULA=C:\Program Files (x86)\AmiBroker\Formulas\afl"
set "RAW=https://raw.githubusercontent.com/hoangvanthiet86-sketch/Phan-tich-Wickoff-VSA/feature/performance-runtime-v0.2"
set "TARGET=%FORMULA%\WyckoffVSA_VNStocksOnly_MetadataAudit_v0.2.afl"

echo.
echo Installing VN STOCKS ONLY metadata audit probe...
echo.

if not exist "%FORMULA%" mkdir "%FORMULA%"

curl.exe -L --fail --silent --show-error "%RAW%/afl/WyckoffVSA_VNStocksOnly_MetadataAudit_v0.2.afl" -o "%TARGET%"
if errorlevel 1 goto :fail

findstr /C:"VN_STOCKS_ONLY_METADATA_AUDIT_V02_20260913_A" "%TARGET%" >nul || goto :fail
findstr /C:"MarketID" "%TARGET%" >nul || goto :fail
findstr /C:"GroupID" "%TARGET%" >nul || goto :fail
findstr /C:"FullName" "%TARGET%" >nul || goto :fail

echo INSTALLED: WyckoffVSA_VNStocksOnly_MetadataAudit_v0.2.afl
echo.
echo INSTALL COMPLETED SUCCESSFULLY.
echo.
echo AMIBROKER RUN PROTOCOL:
echo   Formula: WyckoffVSA_VNStocksOnly_MetadataAudit_v0.2.afl
echo   Apply to: same full database/universe used for the 1558-row benchmark
echo   Periodicity: Daily
echo   Range: 1 recent bar
echo   Explore, then export result to TXT
echo.
echo This probe is READ-ONLY. It does NOT create or modify watchlists.
echo Do not filter symbols manually before this audit.
echo.
start "" explorer.exe "%FORMULA%"
pause
exit /b 0

:fail
echo.
echo INSTALL FAILED. No universe classification claim is made.
pause
exit /b 1
