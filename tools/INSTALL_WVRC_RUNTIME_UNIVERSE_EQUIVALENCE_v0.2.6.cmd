@echo off
setlocal EnableExtensions

:: Self-elevate when not already Administrator.
net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo Requesting Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "FORMULADIR=C:\Program Files (x86)\AmiBroker\Formulas\afl"
set "INCLUDEDIR=C:\Program Files (x86)\AmiBroker\Formulas\Include"
set "TARGET=%FORMULADIR%\WyckoffVSA_RuntimeUniverse_EquivalenceProbe_v0.2.afl"
set "RAWURL=https://raw.githubusercontent.com/hoangvanthiet86-sketch/Phan-tich-Wickoff-VSA/feature/performance-runtime-v0.2/afl/WyckoffVSA_RuntimeUniverse_EquivalenceProbe_v0.2.afl"

echo Installing Wyckoff VSA Runtime v0.2 whole-universe equivalence probe...
echo.

if not exist "%INCLUDEDIR%\WyckoffVSA_MarketScanner_Runtime_v0.2.afl" (
    echo ERROR: Missing Runtime Scanner include:
    echo %INCLUDEDIR%\WyckoffVSA_MarketScanner_Runtime_v0.2.afl
    echo Run the v0.2.4 scanner runtime builder first.
    echo.
    pause
    exit /b 1
)

if not exist "%INCLUDEDIR%\WyckoffVSA_RuntimeConfig_v0.2.afl" (
    echo ERROR: Missing RuntimeConfig include.
    echo.
    pause
    exit /b 1
)

if not exist "%FORMULADIR%" mkdir "%FORMULADIR%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop'; Invoke-WebRequest -UseBasicParsing -Uri '%RAWURL%' -OutFile '%TARGET%'; $t=[IO.File]::ReadAllText('%TARGET%'); if($t -notmatch 'RUNTIME_UNIVERSE_EQ_V02_20260912_A'){ throw 'Probe verification failed'; }; Write-Host 'VERIFIED: whole-universe equivalence probe installed.'"

if not "%errorlevel%"=="0" (
    echo.
    echo INSTALL FAILED.
    pause
    exit /b 1
)

echo.
echo INSTALLED:
echo %TARGET%
echo.
echo Next: AmiBroker - Analysis - Formula - WyckoffVSA_RuntimeUniverse_EquivalenceProbe_v0.2.afl
echo Apply to: All quotations
echo Range: 1 recent bar
echo Periodicity: Daily
echo Explore, then export the result and send it back for 1558-row comparison.
echo.
echo INSTALL COMPLETED SUCCESSFULLY.
pause
exit /b 0
