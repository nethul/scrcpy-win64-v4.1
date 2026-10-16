@echo off
setlocal
PowerShell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-camera.ps1"
set "SCRCPY_EXIT=%ERRORLEVEL%"
echo.
if not "%SCRCPY_EXIT%"=="0" echo scrcpy exited with error code %SCRCPY_EXIT%.
pause
exit /b %SCRCPY_EXIT%
