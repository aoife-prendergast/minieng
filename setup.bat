@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "ROOT=%USERPROFILE%\RobotSetup"
set "LOG=%ROOT%\setup.log"
for /f "usebackq delims=" %%D in (`powershell.exe -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"`) do set "DESKTOP=%%D"
if not defined DESKTOP set "DESKTOP=%USERPROFILE%\Desktop"
set "FILES=%DESKTOP%\Robot Files"
if not exist "%ROOT%\Downloads" mkdir "%ROOT%\Downloads"
if not exist "%FILES%" mkdir "%FILES%"
echo Robot PC setup started %DATE% %TIME% > "%LOG%"
where winget >nul 2>&1
if errorlevel 1 (
 echo [WARNING] winget missing. App installs skipped.
 echo winget missing >> "%LOG%"
) else (
 call :install "Arduino IDE" "ArduinoSA.IDE.stable"
 call :install "Thonny Python IDE" "AivarAnnamaa.Thonny"
)
call :getzip "hardware-code.zip" "1V3kKZKvjOVkMcPH8ai2EqKz2OzHz982z" "hardware-code"
call :getzip "system-code.zip" "1ZMTczYrsVh44JjRNYu4YlIesGZnBwtIm" "system-code"
call :getzip "robotics-arduino.zip" "1V7YL-Bb_Yc_CUEK0p_6WNKcvKF_HlOfr" "robotics-arduino"
>"%DESKTOP%\Gmail.url" echo [InternetShortcut]
>>"%DESKTOP%\Gmail.url" echo URL=https://mail.google.com/
>"%DESKTOP%\Tinkercad.url" echo [InternetShortcut]
>>"%DESKTOP%\Tinkercad.url" echo URL=https://www.tinkercad.com/
echo Creating application shortcuts...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$desktop=$env:DESKTOP; $menus=@([Environment]::GetFolderPath('CommonStartMenu'),[Environment]::GetFolderPath('StartMenu')); $apps=@(@{Name='Arduino IDE';Pattern='Arduino IDE*.lnk'},@{Name='Thonny Python IDE';Pattern='Thonny*.lnk'}); foreach($app in $apps) { $link=$null; foreach($menu in $menus) { $link=Get-ChildItem -LiteralPath $menu -Filter $app.Pattern -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1; if($link){break} }; if($link) { Copy-Item -LiteralPath $link.FullName -Destination (Join-Path $desktop ($app.Name+'.lnk')) -Force; Write-Output ('Created shortcut: '+$app.Name) } else { Write-Output ('WARNING: Shortcut not found for '+$app.Name) } }" >> "%LOG%" 2>&1
echo.
echo Setup finished. Robot files: "%FILES%"
echo Log: "%LOG%"
pause
exit /b 0
:install
echo Installing/checking %~1...
winget install --id "%~2" --exact --silent --accept-package-agreements --accept-source-agreements >> "%LOG%" 2>&1
if errorlevel 1 (echo [WARNING] %~1: see log.) else (echo [OK] %~1)
exit /b
:getzip
set "ZIP=%ROOT%\Downloads\%~1"
set "URL=https://drive.usercontent.google.com/download?id=%~2"
set "DEST=%FILES%\%~3"
echo Downloading %~1...
powershell.exe -NoProfile -Command "try { Invoke-WebRequest -Uri $env:URL -OutFile $env:ZIP -UseBasicParsing -ErrorAction Stop; exit 0 } catch { Write-Output $_; exit 1 }" >> "%LOG%" 2>&1
if errorlevel 1 (
 echo [FAILED] Download %~1. Check network and log.
 echo Download failed: %~1 >> "%LOG%"
 exit /b
)
powershell.exe -NoProfile -Command "try { $f=[IO.File]::OpenRead($env:ZIP); try { $b=New-Object byte[] 4; if($f.Read($b,0,4) -ne 4 -or $b[0] -ne 80 -or $b[1] -ne 75) { throw 'Not a ZIP file' } } finally { $f.Dispose() }; Expand-Archive -LiteralPath $env:ZIP -DestinationPath $env:DEST -Force -ErrorAction Stop; exit 0 } catch { Write-Output $_; exit 1 }" >> "%LOG%" 2>&1
if errorlevel 1 (echo [FAILED] Extract %~1. See log.) else (echo [OK] %~1 extracted.)
exit /b
