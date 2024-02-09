@echo off


@REM // ============================================ \\
@REM ||     /           \/                     /     ||
@REM ||    /           MAIN  PROGRAM           \     ||
@REM ||          \                              \    ||
@REM \\ ============================================ //


call :main

echo.
echo Done!
pause

@REM DONT FORGET TO EXIT, OTHERWISE IT WILL KEEP GOING, EXECUTING THE REST OF THE FUNCTIONS
exit /b %ERRORLEVEL%


@REM // ============================================ \\
@REM ||     /           \/                     /     ||
@REM ||    /           MAIN  FUNCTION          \     ||
@REM ||          \_                 --          \    ||
@REM \\ ============================================ //

@REM !!!!!!!!!! VERY IMPORTANT INFORMATION IF YOU'RE ADDING FUNCTIONS !!!!!!!!!!
@REM vvvvvvvvvv                                                       vvvvvvvvvv
@REM DONT FORGET TO EXIT FROM ALL FUNCTIONS, OTHERWISE THEY WILL KEEP GOING, EXECUTING THE REST OF THE FUNCTIONS
@REM ^^^^^^^^^^                                                       ^^^^^^^^^^
@REM !!!!!!!!!! VERY IMPORTANT INFORMATION IF YOU'RE ADDING FUNCTIONS !!!!!!!!!!


:main

call :get_dirs
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

@REM Function already has the paths from before, just call from beggining and let it roll!!
call :populate_dir_recursive "."


@REM DONT FORGET TO EXIT, OTHERWISE IT WILL KEEP GOING, EXECUTING THE REST OF THE FUNCTIONS
exit /b 0


@REM // -------------------------------------------- \\
@REM ||     /           \/                     /     ||
@REM ||    /        AUXILIARY  FUNCTIONS       \     ||
@REM ||          \                              \    ||
@REM \\ -------------------------------------------- //


:populate_dir_recursive
@REM Populate a directory with all files from the original directory, recursively
@REM %1: directory (relative to original_dir) to duplicate
@REM (CONSTANT) ORIGINAL_DIR: path to the directory to copy from
@REM (CONSTANT)      NEW_DIR: path to the directory to copy to


set "dir_relative=%~1"
set "dir_from=%ORIGINAL_DIR%\%dir_relative%"
set "dir_to=%NEW_DIR%\%dir_relative%"

echo =============== Populating '%dir_to%' ===============

if not exist "%dir_to%" mkdir "%dir_to%"

@REM Populate files
for %%i in ("%dir_from%\*") do (
    @mklink /h "%dir_to%\%%~nxi" "%%~fi" >nul
)

@REM Call this function for all directories (it's recursive, duh)
for /d %%i in ("%dir_from%\*") do (
    call :populate_dir_recursive "%dir_relative%\%%~nxi"
)

@REM DONT FORGET TO EXIT, OTHERWISE IT WILL KEEP GOING, EXECUTING THE REST OF THE FUNCTIONS
exit /b 0



:get_dirs
@REM Get the paths to the original and new game directories

@REM This is used to make powershell not mess up the command prompt
for /f "usebackq tokens=2 delims=:" %%i in (`chcp`) do set "chcp_old=%%i"
chcp 437>nul


@REM Open folder browser to select the original directory
call :set_psCommand "from (original)"

echo Select the directory to copy from (original)
for /f "usebackq delims=" %%i in (`powershell -noprofile -command %psCommand%`) do set "ORIGINAL_DIR=%%i"
if not defined ORIGINAL_DIR (
    echo ERROR: You didn't choose a directory! :^(
    @REM Parenthesis isn't escaped in vscode for some reason, adding closing parenthesis to fix
    echo ^)>nul

    exit /b 1
)
if not exist "%ORIGINAL_DIR%" (
    echo ERROR: Invalid directory
    exit /b 1
)

echo Copying from '%ORIGINAL_DIR%'

@REM Open folder browser to select the new directory
call :set_psCommand "to (new)"

echo Select the directory to copy to (new)
for /f "usebackq delims=" %%i in (`powershell -noprofile -command %psCommand%`) do set "NEW_DIR=%%i"
if not defined NEW_DIR (
    echo ERROR: You didn't choose a directory! :^(
    @REM Parenthesis isn't escaped in vscode for some reason, adding closing parenthesis to fix
    echo ^)>nul

    exit /b 1
)
if not exist "%NEW_DIR%" (
    echo ERROR: Invalid directory
    exit /b 1
)

echo Copying to '%NEW_DIR%'


@REM Restore the original code page
chcp %chcp_old%>nul

@REM DONT FORGET TO EXIT, OTHERWISE IT WILL KEEP GOING, EXECUTING THE REST OF THE FUNCTIONS
exit /b 0

:set_psCommand
@REM Set the powershell command to open a folder browser
@REM %1: string (out | to) to display in the description

set psCommand="&{"^
    "[System.Reflection.Assembly]::LoadWithPartialName('System.windows.forms') | Out-Null ;"^
    "$f = New-Object Windows.Forms.FolderBrowserDialog ;"^
    "$f.Description = 'Select the directory to copy %~1' ;"^
    "$f.RootFolder = 0 ;"^
    "$f.SelectedPath = '%~dp0' ;"^
    "$f.ShowNewFolderButton = $true ;"^
    "if ($f.ShowDialog() -eq 'OK') {"^
        "$folder = $f.SelectedPath ;"^
    "} else {"^
        "$folder = '' ;"^
    "}"^
    "Write-Host $folder ;}"

exit /b 0
