@echo off
setlocal

echo 🚀 Starting FusionExport service...

REM Start the service in the background
start "FusionExportService" fusionexport-service.exe --port 1337

REM Wait a few seconds to ensure the service is ready
timeout /t 5 /nobreak >nul

echo 📄 Preparing export request...

REM Define paths
set "CHART_CONFIG=%~dp0chartConfig.json"
set "OUTPUT_DIR=%~dp0output"
set "TIMESTAMP=%DATE:~-4%%DATE:~4,2%%DATE:~7,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "OUTPUT_FILE=%OUTPUT_DIR%\export_%TIMESTAMP%.pdf"

REM Ensure output directory exists
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM Check if chart config exists
if not exist "%CHART_CONFIG%" (
    echo ❌ Chart config not found at %CHART_CONFIG%
    goto stop
)

echo 📤 Sending export request to FusionExport service...

REM Use PowerShell to send POST request and save raw PDF output
powershell -Command ^
  "$json = Get-Content '%CHART_CONFIG%' -Raw; " ^
  "Invoke-WebRequest -Uri 'http://localhost:1337/api/v2.0/export' -Method Post -Body $json -ContentType 'application/json' -OutFile '%OUTPUT_FILE%'"

if %errorlevel% neq 0 (
    echo ❌ Export failed.
    goto stop
)

echo ✅ Export complete! PDF saved as %OUTPUT_FILE%

:stop
echo 🛑 Stopping FusionExport service...
taskkill /im fusionexport-service.exe /f >nul 2>&1

echo ✅ Done.
pause
endlocal
