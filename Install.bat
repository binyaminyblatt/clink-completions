@echo off
:clinkcheck
IF EXIST "%ProgramFiles(x86)%\clink\0.4.9\clink.bat" (
	goto gitcheck
) ELSE (
    echo Failure: Clink Not Installed!!!
    GOTO End
)
:gitcheck
git version>nul 2>&1
if %errorLevel% == 0 (
    GOTO admincheck
) else (
    echo Failure: Git required!!!
    GOTO End
)
:admincheck
net session >nul 2>&1
if %errorLevel% == 0 (
    GOTO adminInstall
) else (
    GOTO nonadminInstall
)

:adminInstall
CLS
ECHO 1.Install to ProgramFiles
ECHO 2.Install to UserFiles
ECHO 3.Exit
ECHO.

CHOICE /C 123 /M "Enter your choice:"

IF ERRORLEVEL 3 GOTO Exit
IF ERRORLEVEL 2 GOTO UserFiles
IF ERRORLEVEL 1 GOTO ProgramFiles

:nonadminInstall
CLS
ECHO Administrative permissions required to Install to ProgramFiles
ECHO 1.Install to UserFiles
ECHO 2.Exit
ECHO.

CHOICE /C 12 /M "Enter your choice:"

IF ERRORLEVEL 2 GOTO Exit
IF ERRORLEVEL 1 GOTO UserFiles

:ProgramFiles
SET TargetFolder="%ProgramFiles(x86)%\clink\0.4.9\Profile"
goto install
:UserFiles
SET TargetFolder="%LOCALAPPDATA%\clink\Profile"
goto install
:install
dir /b /a "%TargetFolder%" | >nul findstr "^" && (goto updateinstall) || (goto newinstall)
:newinstall
git clone https://github.com/binyaminyblatt/clink-completions.git "%TargetFolder%" >nul 2>&1
ECHO Clink Completions Installed Successfully
:updateinstall
git -C "%TargetFolder%" pull >nul 2>&1
ECHO Clink Completions Updated Successfully
:End
PAUSE >nul
:Exit