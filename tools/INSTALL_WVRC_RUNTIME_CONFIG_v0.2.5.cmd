@echo off
setlocal EnableExtensions

:: Self-elevate when not already Administrator.
net session >nul 2>&1
if not "%errorlevel%"=="0" (
  echo Requesting Administrator permission...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

set "TARGET=C:\Program Files (x86)\AmiBroker\Formulas\Include\WyckoffVSA_RuntimeConfig_v0.2.afl"
set "TEMPFILE=%TEMP%\WyckoffVSA_RuntimeConfig_v0.2.download.afl"
set "RAWURL=https://raw.githubusercontent.com/hoangvanthiet86-sketch/Phan-tich-Wickoff-VSA/feature/performance-runtime-v0.2/afl/WyckoffVSA_RuntimeConfig_v0.2.afl"

echo Installing approved Wyckoff VSA RuntimeConfig v0.2...
echo Target: %TARGET%

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "Invoke-WebRequest -UseBasicParsing -Uri '%RAWURL%' -OutFile '%TEMPFILE%';" ^
  "$t=[IO.File]::ReadAllText('%TEMPFILE%');" ^
  "if($t -notmatch 'WVRC_RuntimeConfigSchemaMajor\s*=\s*2' -or $t -notmatch 'ADJUSTED PRICE'){throw 'Downloaded RuntimeConfig failed content verification'};" ^
  "if(Test-Path -LiteralPath '%TARGET%'){Copy-Item -LiteralPath '%TARGET%' -Destination ('%TARGET%.pre-v0.2.5.bak') -Force};" ^
  "Copy-Item -LiteralPath '%TEMPFILE%' -Destination '%TARGET%' -Force;" ^
  "$u=[IO.File]::ReadAllText('%TARGET%');" ^
  "if($u -notmatch 'ADJUSTED PRICE'){throw 'Installed RuntimeConfig verification failed'};" ^
  "Write-Host 'VERIFIED: 6.3 Adjustment Basis Declaration = ADJUSTED PRICE';" ^
  "Write-Host 'RuntimeConfig install completed.'"

if not "%errorlevel%"=="0" (
  echo.
  echo INSTALL FAILED with exit code %errorlevel%.
  pause
  exit /b 1
)

del /q "%TEMPFILE%" >nul 2>&1

echo.
echo INSTALL COMPLETED SUCCESSFULLY.
echo Existing config backup, if present, is: WyckoffVSA_RuntimeConfig_v0.2.afl.pre-v0.2.5.bak
echo.
pause
exit /b 0
