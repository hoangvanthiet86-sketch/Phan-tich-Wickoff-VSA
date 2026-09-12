@echo off
setlocal
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo Running Wyckoff VSA Runtime v0.2.1 Phase/Composite stack builder...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0BUILD_WVRC_PHASE_COMPOSITE_RUNTIME_STACK_v0.2.1.ps1"
set "RC=%errorlevel%"

echo.
if not "%RC%"=="0" (
    echo BUILD COMMAND FAILED with exit code %RC%.
) else (
    echo BUILD COMMAND COMPLETED SUCCESSFULLY.
)
echo.
pause
exit /b %RC%
