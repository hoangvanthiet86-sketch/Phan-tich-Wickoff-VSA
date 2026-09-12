@echo off
setlocal

set "SCRIPT=%~dp0BUILD_WVRC_PHASE_COMPOSITE_RUNTIME_STACK_v0.2.ps1"

if not exist "%SCRIPT%" (
    echo ERROR: Required PowerShell script was not found next to this launcher:
    echo   %SCRIPT%
    echo.
    echo Put both files in the same folder, then run this CMD again.
    pause
    exit /b 1
)

net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo Requesting Administrator privileges...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo Running Wyckoff VSA Runtime v0.2 Phase/Composite stack builder...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
set "RC=%errorlevel%"

echo.
if "%RC%"=="0" (
    echo BUILD COMMAND COMPLETED.
) else (
    echo BUILD COMMAND FAILED with exit code %RC%.
)
echo.
pause
exit /b %RC%
