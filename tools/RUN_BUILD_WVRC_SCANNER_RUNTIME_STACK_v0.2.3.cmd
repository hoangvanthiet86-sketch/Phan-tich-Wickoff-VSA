@echo off
setlocal

:: Self-elevate if not already Administrator.
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "SCRIPT=%~dp0BUILD_WVRC_SCANNER_RUNTIME_STACK_v0.2.3.ps1"
if not exist "%SCRIPT%" (
    echo ERROR: Missing builder next to this CMD:
    echo %SCRIPT%
    echo.
    echo Put both v0.2.3 files in the same folder, then run this CMD again.
    pause
    exit /b 1
)

echo Running Wyckoff VSA Runtime v0.2.3 Scanner stack builder...
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
set "RC=%errorlevel%"
echo.
if not "%RC%"=="0" (
    echo BUILD COMMAND FAILED with exit code %RC%.
    pause
    exit /b %RC%
)

echo BUILD COMMAND COMPLETED SUCCESSFULLY.
echo Runtime Scanner probe was installed automatically into AmiBroker Formulas\afl.
pause
exit /b 0
