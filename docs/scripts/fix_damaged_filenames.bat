@echo off
setlocal enabledelayedexpansion

set "PARENT_FOLDER=C:\path\to\your\containing\folder"

echo Starting file name correction process...
echo.

for /d %%D in ("%PARENT_FOLDER%\*") do (
    echo Processing folder: %%~nxD
    
    for %%F in ("%%D\*.*") do (
        set "fullname=%%~nxF"
        set "filename=%%~nF"
        set "extension=%%~xF"
        
        REM Check if filename contains underscore (indicating it needs fixing)
        echo "!filename!" | findstr "_" >nul
        if !errorlevel! equ 0 (
            REM Extract everything before the first underscore
            for /f "tokens=1 delims=_" %%A in ("!filename!") do (
                set "originalname=%%A"
            )
            
            REM Rename the file to original name + extension
            ren "%%F" "!originalname!!extension!"
            echo   Fixed: !fullname! -^> !originalname!!extension!
        ) else (
            echo   Skipped: !fullname! ^(no underscore found^)
        )
    )
    echo.
)

echo.
echo Done! All damaged filenames corrected.
pause