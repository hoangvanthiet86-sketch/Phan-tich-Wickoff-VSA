@echo off
set SCRIPT=%~dp0BUILD_LOC_AIO_CANONICAL_HEADLESS_RC2.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%SCRIPT%""'"
