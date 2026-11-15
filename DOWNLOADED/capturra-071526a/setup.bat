@echo off
setlocal EnableDelayedExpansion
title Capturra Setup - release 071526a
cd /d "%~dp0"

REM Carriage-return character for the same-line spinner animation
for /f %%a in ('copy /Z "%~f0" nul') do set "CR=%%a"

echo.
echo  ============================================
echo    CAPTURRA - SETUP  (release 071526a)
echo  ============================================
echo.
echo  This will build the Capturra Windows app.
echo  Steps: check requirements -^> install -^> build .exe -^> shortcut
echo.

REM ---------- 1. Check that Node.js / npm are installed ----------
where node >nul 2>nul
if errorlevel 1 goto :no_node
where npm >nul 2>nul
if errorlevel 1 goto :no_node

for /f "delims=" %%v in ('node -v') do set NODEVER=%%v
echo  [OK] Node.js !NODEVER! found.
echo.

REM ---------- 2. Install dependencies (animated) ----------
set "FLAG=%TEMP%\capturra_step_flag.txt"
set "LOG=%~dp0setup-install.log"
if exist "%FLAG%" del /q "%FLAG%"
echo  [1/2] Installing dependencies (first run downloads ~100 MB, one time)
start /b "" cmd /c "npm install >"%LOG%" 2>&1 && (echo 0)>"%FLAG%" || (echo 1)>"%FLAG%""
call :spinner "INSTALLING"
set /p RC=<"%FLAG%"
del /q "%FLAG%" 2>nul
if not "!RC!"=="0" (
    echo.
    echo  [ERROR] npm install failed. Last log lines:
    echo  --------------------------------------------
    powershell -NoProfile -Command "Get-Content -Tail 15 '%LOG%'"
    echo  --------------------------------------------
    echo  Common fixes:
    echo    - Check your internet connection and try again.
    echo    - If you are behind a proxy/VPN, disable it or configure npm for it.
    echo    - Delete the "node_modules" folder here and re-run setup.
    echo    - Run this setup as Administrator if you saw "EPERM" / "access denied".
    echo  Full log: %LOG%
    echo.
    pause
    exit /b 1
)
echo  [OK] Dependencies installed.
echo.

REM ---------- 3. Build the portable .exe (animated) ----------
set "LOG=%~dp0setup-build.log"
if exist "%FLAG%" del /q "%FLAG%"
echo  [2/2] Building the standalone .exe (takes a minute or two)
start /b "" cmd /c "npm run dist >"%LOG%" 2>&1 && (echo 0)>"%FLAG%" || (echo 1)>"%FLAG%""
call :spinner "BUILDING "
set /p RC=<"%FLAG%"
del /q "%FLAG%" 2>nul
if not "!RC!"=="0" (
    echo.
    echo  [ERROR] Build failed. Last log lines:
    echo  --------------------------------------------
    powershell -NoProfile -Command "Get-Content -Tail 15 '%LOG%'"
    echo  --------------------------------------------
    echo  Common fixes:
    echo    - Re-run this setup once more (first builds sometimes need a retry
    echo      while electron-builder downloads its tools).
    echo    - Make sure your antivirus is not blocking "electron-builder".
    echo    - Free up disk space (the build needs ~500 MB temporarily).
    echo  Full log: %LOG%
    echo.
    pause
    exit /b 1
)

set "EXE=%~dp0dist\Capturra-Standalone-071526a.exe"
if not exist "!EXE!" (
    for %%f in ("%~dp0dist\*.exe") do set "EXE=%%~ff"
)
if not exist "!EXE!" (
    echo  [ERROR] Build finished but no .exe was found in the "dist" folder.
    pause
    exit /b 1
)

echo  [OK] Built: !EXE!
echo.

REM ---------- 4. Optional desktop shortcut ----------
choice /c YN /m "  Create a shortcut on your Desktop"
if errorlevel 2 goto :launch

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ws = New-Object -ComObject WScript.Shell; ^
   $lnk = $ws.CreateShortcut([IO.Path]::Combine([Environment]::GetFolderPath('Desktop'),'Capturra.lnk')); ^
   $lnk.TargetPath = '!EXE!'; ^
   $lnk.WorkingDirectory = '%~dp0dist'; ^
   $lnk.Description = 'Capturra - multi-source capture, mixer, scenes, recorder'; ^
   $lnk.Save()"
if errorlevel 1 (
    echo  [WARN] Could not create the shortcut automatically.
    echo         You can right-click the .exe and choose Send to ^> Desktop instead.
) else (
    echo  [OK] Desktop shortcut created: "Capturra"
)
echo.

:launch
REM ---------- 5. Optional launch ----------
choice /c YN /m "  Launch Capturra now"
if errorlevel 2 goto :done
start "" "!EXE!"

:done
echo.
echo  Setup complete. Run Capturra any time from:
echo    - the Desktop shortcut (if created), or
echo    - !EXE!
echo.
pause
exit /b 0

REM ================================================================
REM :spinner "LABEL" - animate on one line until %FLAG% file appears.
REM Keeps something moving so nobody assumes the window is safe to
REM close. Updates roughly once per second with an elapsed counter.
REM ================================================================
:spinner
set "LABEL=%~1"
set /a SECS=0
set /a PH=0
:spin_loop
if exist "%FLAG%" (
    <nul set /p "=  [DONE] %LABEL% finished after !SECS!s.                                        "
    echo.
    goto :eof
)
set /a PH=(PH+1) %% 4
if !PH!==0 set "BAR=[=   ]"
if !PH!==1 set "BAR=[ =  ]"
if !PH!==2 set "BAR=[  = ]"
if !PH!==3 set "BAR=[   =]"
<nul set /p "=  !BAR! %LABEL% ... !SECS!s elapsed - DO NOT CLOSE THIS WINDOW !CR!"
ping -n 2 127.0.0.1 >nul
set /a SECS+=1
goto :spin_loop
