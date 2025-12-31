@echo off
setlocal enabledelayedexpansion

set "PARENT_FOLDER=C:\path\to\your\containing\folder"
set "CONSTANT=900684525"

echo Starting file renaming process...
echo.

for /d %%D in ("%PARENT_FOLDER%\*") do (
    echo Processing folder: %%~nxD
    
    for %%F in ("%%D\*.*") do (
        set "filename=%%~nF"
        set "extension=%%~xF"
        set "foldername=%%~nxD"
        
        REM Check if file already has the pattern to avoid duplicate renaming
        echo "!filename!" | findstr /C:"_%CONSTANT%_" >nul
        if !errorlevel! neq 0 (
            ren "%%F" "!filename!_%CONSTANT%_!foldername!!extension!"
            echo   Renamed: %%~nxF -^> !filename!_%CONSTANT%_!foldername!!extension!
        ) else (
            echo   Skipped: %%~nxF ^(already renamed^)
        )
    )
    echo.
)

echo.
echo Done! All files renamed.
pause