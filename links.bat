@echo off

@REM THESE HAVE TO BE IN THE SAME DIRECTORY AS THIS SCRIPT
@REM YOU CAN MOVE THEM AFTERWARDS, AS EVERYTHING IS HARD LINKED
@REM Paths to the original and modded game directories
@REM Modded directory will be created from the original
set "ORIGINAL_DIR=original"
set "MODDED_DIR=modded"


@REM // ============================================ \\
@REM ||     /           \/                     /     ||
@REM ||    /           MAIN  PROGRAM           \     ||
@REM ||          \                              \    ||
@REM \\ ============================================ //


call :main

echo Done!
pause

@REM DONT FORGET TO EXIT, OTHERWISE IT WILL KEEP GOING, EXECUTING THE REST OF THE FUNCTIONS
exit /b %ERRORLEVEL%


@REM // ============================================ \\
@REM ||     /           \/                     /     ||
@REM ||    /           MAIN  FUNCTION          \     ||
@REM ||          \_                 --          \    ||
@REM \\ ============================================ //

@REM DONT FORGET TO EXIT FROM ALL FUNCTIONS, OTHERWISE THEY WILL KEEP GOING, EXECUTING THE REST OF THE FUNCTIONS


:main
setlocal EnableDelayedExpansion

for /r "%ORIGINAL_DIR%" %%i IN ( . ) do (
    set "file=%%~i"

    @REM remove current script path from file path (we only want the path relative to the game folder)
    set "file=!file:%~dp0%=!"

    @REM echo !file!
    call :populate_dir_no_recurse "%MODDED_DIR%" "!file!"
)


@REM DONT FORGET TO EXIT, OTHERWISE IT WILL KEEP GOING, EXECUTING THE REST OF THE FUNCTIONS
exit /b 0


@REM // -------------------------------------------- \\
@REM ||     /           \/                     /     ||
@REM ||    /        AUXILIARY  FUNCTIONS       \     ||
@REM ||          \                              \    ||
@REM \\ -------------------------------------------- //


:populate_dir_no_recurse
@REM Populate a directory with all files from the original directory
@REM %1: directory to populate
@REM %2: directory to copy from

echo ==================== Populating '%~1' from '%~2' ====================

if not exist "%~1" mkdir "%~1"

@REM Populate files
for %%i in ("%~2\*") do (
    @REM Get only the path relative to the game folder, not the one where we are running this script
    for /f "tokens=1,* delims=\" %%a in ("%%~i") do (
        @REM echo '%~1' -- '%%~b'
        @mklink /h "%~1\%%~b" "%%~fi" >nul
    )
)

@REM Do the same but for directories
for /d %%i in ("%~2\*") do (
    @REM Get only the path relative to the game folder, not the one where we are running this script
    for /f "tokens=1,* delims=\" %%a in ("%%~i") do (
        @REM echo '%~1' -- '%%~b'
        mkdir "%~1\%%~b"
    )
)

@REM DONT FORGET TO EXIT, OTHERWISE IT WILL KEEP GOING, EXECUTING THE REST OF THE FUNCTIONS
exit /b 0