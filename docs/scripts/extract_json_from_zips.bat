@echo off
setlocal enabledelayedexpansion

set "PARENT_FOLDER=C:\path\to\your\containing\folder"
set "JSON_FOLDER=%PARENT_FOLDER%\JSON"

echo Starting JSON extraction from zip files...
echo.

REM Create JSON folder if it doesn't exist
if not exist "%JSON_FOLDER%" (
    mkdir "%JSON_FOLDER%"
    echo Created JSON folder: %JSON_FOLDER%
    echo.
)

REM Process all zip files in the parent folder
for %%Z in ("%PARENT_FOLDER%\*.zip") do (
    set "zipname=%%~nZ"
    echo Processing zip: !zipname!.zip
    
    REM Extract the part after the last underscore (e.g., rips_PAOL4027 -> PAOL4027)
    set "identifier="
    set "tempname=!zipname!"
    
    REM Replace underscores with spaces and get the last token
    set "tempname=!tempname:_= !"
    for %%B in (!tempname!) do (
        set "identifier=%%B"
    )
    
    if defined identifier (
        set "jsonfile=!identifier!.json"
        echo   Looking for JSON file: !jsonfile!
        
        REM Extract only the specific JSON file using PowerShell
        powershell -Command "& { Add-Type -AssemblyName System.IO.Compression.FileSystem; $zip = [System.IO.Compression.ZipFile]::OpenRead('%%Z'); $entry = $zip.Entries | Where-Object { $_.Name -eq '!jsonfile!' }; if ($entry) { [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, '%JSON_FOLDER%\!jsonfile!', $true); Write-Host '   Extracted: !jsonfile!' } else { Write-Host '   Warning: !jsonfile! not found in zip' }; $zip.Dispose() }"
    ) else (
        echo   Warning: Could not extract identifier from !zipname!
    )
    echo.
)

echo.
echo Done! JSON files extracted to: %JSON_FOLDER%
pause