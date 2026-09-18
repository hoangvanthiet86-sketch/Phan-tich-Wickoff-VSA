@echo off
setlocal
powershell -ExecutionPolicy Bypass -File "%~dp0BUILD_WVOC_REENTRANT_CONTEXT_STACK_v0.1.ps1" %*
set RC=%ERRORLEVEL%
echo.
if not "%RC%"=="0" (
  echo BUILD FAILED. ExitCode=%RC%
  exit /b %RC%
)
echo BUILD PASSED.
endlocal
