@echo off
color f
cls
echo Loading...
title Minecraft Launcher ^| By Kotsasmin
set "launcher=%cd%\bin\launcher.py"
set "launcher_url=https://raw.githubusercontent.com/Kotsasmin/Minecraft_Batchpy_Launcher/main/pylauncher.py"
set "mcVersion=1.16.5"
set "ram=1024"
set "accountMode="
set "guest=false"
set "version=al-10"
set "args=-Xmx%ram%M -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M"
call:internet
if not exist data mkdir data
if not exist bin mkdir bin
if exist "latestGuest.bat" call:deleteGuest
if not exist "admin.bat" call:createAdmin
python -V | find /v "Python" >NUL 2>NUL && (call :PYTHON_DOES_NOT_EXIST)
python -V | find "Python"    >NUL 2>NUL && (call :PYTHON_DOES_EXIST)
:pythonRetry


:argument
IF "%1"=="" ( goto main 
) else (
echo Logging In
)

set "name=%1"
if exist "%name%.bat" (
call "%name%.bat"
) else (
echo Invalid Username
pause>nul
goto main
)
rem makes username case sensitive
if not "%name%" EQU "%username%" (
echo Invalid Username
pause>nul
goto main
)

set pass=%2
if not %pass% EQU %password% (
echo That Is Not A valid Password.
pause>nul
goto main
)
goto loginsettings


:main
call:internet
cls
echo What would you like to do?
echo.
echo 1) Login
echo 2) Create Account
echo 3) Login as guest
echo.
echo.
set /p login=
if %login% EQU 1 goto login
if %login% EQU 2 goto createuser
if %login% EQU 3 goto guest
if %login% EQU admin goto admincheck
goto main

:login
call:internet
cls
set /p "name=Username: "
if exist "%name%.bat" (
call "%name%.bat"
) else (
echo Invalid username
pause>nul
goto main
)
if not "%name%" EQU "%username%" (
echo Invalid Username
pause>nul
goto main
)
set /p pass=Password: 
if not %pass% EQU %password% (
echo That Is Not A valid Password.
pause>nul
goto main
)
goto loginsettings


:loginsettings
call:internet
cls
echo What would you like to do %username%?
echo.
echo 1) Play Minecraft %mcVersion%
echo 2) Game settings
echo 3) Account settings
echo 4) Open Minecraft folder
echo 5) Open Minecraft saves folder
echo 6) Open Minecraft textures folder
echo 7) Log out
echo.
echo.
set /p "settingchoise=Select: "
if %settingchoise% EQU 1 goto play
if %settingchoise% EQU 2 goto gameSettings
if %settingchoise% EQU 3 goto accountSettings
if %settingchoise% EQU 4 Explorer "%cd%\data\%name%"
if %settingchoise% EQU 5 Explorer "%cd%\data\%name%\saves"
if %settingchoise% EQU 6 Explorer "%cd%\data\%name%\texturepacks"
if %settingchoise% EQU 7 goto main
goto loginsettings


:gameSettings
cls
echo Game Settings
echo.
echo 1) Game version
echo 2) Game RAM
echo 3) Change Player name
echo 4) Change Mode
echo 5) Back
echo.
echo.
set /p "settingchoise=Select: "
if %settingchoise% EQU 1 goto changeMcVersion
if %settingchoise% EQU 2 goto changeRAM
if %settingchoise% EQU 3 goto changeUsername
if %settingchoise% EQU 4 goto changeMode
if %settingchoise% EQU 5 goto loginsettings
goto gameSettings

:changeRAM
cls
set /p "ram=Set how much ram do you need in Megabytes (do not add the M): "
call:save
goto gameSettings


:accountSettings
cls
echo Account Settings
echo.
echo 1) Change username
echo 2) Change password
echo 3) Delete account
echo 4) Account Mode
echo 5) Back
echo.
echo.
set /p "settingchoise=Select: "
if %settingchoise% EQU 1 goto changeUsername
if %settingchoise% EQU 2 goto changepassword
if %settingchoise% EQU 3 goto accountdelete
if %settingchoise% EQU 4 goto changemode
if %settingchoise% EQU 5 goto loginsettings
goto accountSettings

:changeMode
cls
echo Change Mode
echo.
echo 1) Premium
echo 2) Demo
echo.
echo.
set /p "settingchoise=Select: "
if %settingchoise% EQU 1 goto modePremium
if %settingchoise% EQU 2 goto modeDemo
goto changeMode

:modePremium
set "accountMode="
call:save
goto accountSettings

:modeDemo
set "accountMode=--demo"
call:save
goto accountSettings


:changeMcVersion
call:internet
cls
echo Loading Minecraft versions...
curl.exe -L -s -o "%launcher%" "%launcher_url%"
echo ====================================================
"%launcher%" search
echo ====================================================
echo.
set /p "mcVersion=Select a Minecraft Version: "
call:save
attrib +H +S "%username%.bat"
goto gameSettings

:play
call:internet
cls
echo Initialization run...
timeout 1 /nobreak >nul
echo Downloading binary data...
curl.exe -L -# -o "%launcher%" "%launcher_url%"
echo Loading libraries...
"%launcher%" start "%mcVersion%" --dry
echo Launching Minecraft...
"%launcher%" --main-dir "%cd%\bin" --work-dir "%cd%\data\%name%" start --jvm-args "%args%" %mcVersion% -u %name% -i 0 %accountMode% >nul
echo Minecraft exited...
timeout 0 /nobreak >nul
echo Saving files...
timeout 1 /nobreak >nul
pause
goto loginsettings


:changepassword
cls
set /p pass=Please enter your current password:
call "%name%.bat"
if not %password% EQU %pass% (
echo Invalid password.
pause>nul
goto loginsettings
)
echo What would you like to be your password to?
set /p password=
echo.
call:save
echo Password Changed.
pause>nul
goto main


:changeUsername
cls
call "%name%.bat"
echo What would you like to be your username to?
set /p "usernameNew="
echo.
call:save
ren "%cd%\data\%username%" "%cd%\data\%usernameNew%"
echo Username changed.
pause>nul
goto main


:accountdelete
del /AS "%name%.bat"
del /F/Q/S "%cd%\data\%username%\*.*" > nul
rmdir /Q/S "%cd%\data\%username%" >nul
if not exist "%cd%\data" mkdir "%cd%\data"
echo Account Deleted
pause>nul
goto main


:createuser
call:internet
cls
set /p "username=Please enter your username (without spaces): "
if exist "%username%.bat" (
echo The Account %username% Already Exist.
pause>nul
goto main
)
set /p "password=Please enter your password: "
(
echo set "username=%username%"
echo set password=%password%
echo set mcVersion=%mcVersion%
echo set accountMode=%accountMode%
echo set ram=%ram%
)>"%username%.bat"
mkdir "%cd%\data\%username%"
attrib +H +S "%username%.bat"
goto main


:admincheck
call "admin.bat"
cls
set /p "pass=Please enter the admin password: "
if not %password% EQU %pass% (
echo Invalid password.
pause>nul
goto main
)
goto admin



:admin
call:internet
cls
echo What Would You Like To Do?
echo.
echo 1) Main Menu
echo 2) Delete User
echo 3) List Users
echo 4) Change Admin Password
echo.
echo.
set /p admin=
if %admin% EQU 1 goto main
if %admin% EQU 2 goto delete
if %admin% EQU 3 goto list
if %admin% EQU 4 goto adminpassword
goto admin


:delete
cls
echo If You Delete The Admin Account You Can Make a New Account Called Admin
set /p "name=Username: "
if not exist "%name%.bat" (
echo That Is Not a Valid Username.
pause>nul
goto admin
)
del /AS "%name%.bat"
del /F/Q/S "%cd%\data\%username%\*.*" > nul
rmdir /Q/S "%cd%\data\%username%" >nul
if not exist "%cd%\data" mkdir "%cd%\data"
goto admin


:list
cls
echo Showing all users:
echo.
for /F "delims= eol=" %%A IN ('dir /AS /B') do echo %%~nA
echo.
echo Press Any Key To Continue
pause >nul
goto admin

:changeuserpassword
goto admin


:adminpassword
cls
echo Please enter the admin password:
set /p pass= 
if not %password% EQU %pass% (
echo Invalid Password.
pause>nul
goto main
)

echo Enter new admin password
set /p password=
del /AS admin.bat
echo set password=%password%>admin.bat
attrib +H +S admin.bat
echo Password Changed
pause>nul
goto main


:internet
Ping www.google.nl -n 1 -w 1000 >nul
if errorlevel 1 (set internet=0) else (set internet=1)
if %internet%==1 goto:EOF
:errorInternet
cls
echo I am so sorry but for the moment this launcher is not in offline mode,
echo which means that it needs internet connection in order to run it.
echo.
echo PlEASE CHECK YOUR INTERNET CONNECTION^!
ECHO.
echo.
timeout 0 /nobreak >nul
Ping www.google.nl -n 1 -w 1000 >nul
if errorlevel 1 (set internet=0) else (set internet=1)
if %internet%==1 goto:EOF
goto errorInternet



:save
call:internet
del /AS "%name%.bat"
(
echo set "username=%username%"
echo set "password=%password%"
echo set "mcVersion=%mcVersion%"
echo set "accountMode=%accountMode%"
echo set "ram=%ram%"
)>"%username%.bat"
attrib +H +S "%username%.bat"
goto:EOF


:guest
cls
set /p "username=Please enter your username (without spaces): "
mkdir "%cd%\data\%username%"
set "name=%username%"
set "guest=true"
(
echo set "latestGuest=%username%"
)>"latestGuest.bat"
attrib +H +S "latestGuest.bat"
goto guestMenu



:guestMenu
call:internet
cls
echo What would you like to do %username%?
echo.
echo 1) Play Minecraft Demo %mcVersion%
echo 2) Change Minecraft version
echo 3) Change Game RAM
echo 4) Logout
echo.
echo.
echo.
set /p "settingchoise=Select: "
if %settingchoise% EQU 1 goto guestPlay
if %settingchoise% EQU 2 goto guestChangeMcVersion
if %settingchoise% EQU 3 goto guestChangeRAM
if %settingchoise% EQU 4 goto guestLogout
goto guestMenu


:guestLogout
cls
echo Logging out...
call:deleteGuest
timeout 1 /nobreak >nul
goto main

:guestChangeRAM
cls
set /p "ram=Set how much ram do you need in Megabytes (do not add the M): "
goto guestMenu

:guestChangeMcVersion
call:internet
cls
echo Loading Minecraft versions...
curl.exe -L -s -o "%launcher%" "%launcher_url%"
echo ====================================================
"%launcher%" search
echo ====================================================
echo.
set /p "mcVersion=Select a Minecraft Version: "
goto guestMenu

:guestPlay
call:internet
cls
echo Initialization run...
timeout 1 /nobreak >nul
echo Downloading binary data...
curl.exe -L -# -o "%launcher%" "%launcher_url%"
echo Loading libraries...
"%launcher%" start "%mcVersion%" --dry
echo Launching Minecraft...
"%launcher%" --main-dir "%cd%\bin" --work-dir "%cd%\data\%name%" start --jvm-args "%args%" %mcVersion% -u %name% -i 0 >nul
echo Minecraft exited...
timeout 0 /nobreak >nul
echo Saving files...
timeout 1 /nobreak >nul
pause
goto guestMenu

:deleteGuest
call "latestGuest.bat"
timeout 0 /nobreak >nul
del /AS "latestGuest.bat"
del /F/Q/S "%cd%\data\%latestGuest%\*.*" > nul
rmdir /Q/S "%cd%\data\%latestGuest%" >nul
if not exist "%cd%\data" mkdir "%cd%\data"
goto:EOF


:createAdmin
(
echo :: Admin password details:
echo set password=password
)>"admin.bat"
attrib +H +S "admin.bat"
goto:EOF

:checkDlls
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT
if not exist "%cd%\bin\jvm\dll\32 bit" mkdir "%cd%\bin\jvm\dll\32 bit"
if not exist "%cd%\bin\jvm\dll\64 bit" mkdir "%cd%\bin\jvm\dll\64 bit"
if %OS%==32BIT if not exist "%cd%\bin\jvm\dll\32 bit\opengl32.dll" curl.exe -s -L -o "%cd%\bin\jvm\dll\32 bit\opengl32.dll" https://github.com/Kotsasmin/Kotsasmin_Download_Files/blob/main/32%20bit/opengl32.dll?raw=true
if %OS%==64BIT if not exist "%cd%\bin\jvm\dll\64 bit\opengl32.dll" curl.exe -s -L -o "%cd%\bin\jvm\dll\64 bit\opengl32.dll" https://github.com/Kotsasmin/Kotsasmin_Download_Files/blob/main/64%20bit/opengl32.dll?raw=true
goto:EOF



:PYTHON_DOES_NOT_EXIST
echo Python is not installed on your system.
echo You need to download python manually in order to continue.
echo Now opening the download URL.
start "" "https://www.python.org/downloads/windows/"
echo.
echo Press any key after finishing the Python installation
python -V | find /v "Python" >NUL 2>NUL && (call :PYTHON_DOES_NOT_EXIST)
python -V | find "Python"    >NUL 2>NUL && (call :PYTHON_DOES_EXIST)
goto :EOF



:PYTHON_DOES_EXIST
for /f "delims=" %%V in ('python -V') do @set pythonVer=%%V
goto pythonRetry
