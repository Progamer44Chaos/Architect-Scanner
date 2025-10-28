@echo off
chcp 65001 >nul

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

setlocal

:: Define paths
set "target=C:\Program Files\Architect Scanner"
set "self=%~f0"
set "shortcut=%USERPROFILE%\Desktop\Architect Scanner.lnk"

echo [x] Starting uninstallation of "%target%" ...

:: Remove desktop shortcut
if exist "%shortcut%" (
    echo [x] Removing desktop shortcut ...
    del /f /q "%shortcut%"
)

:: Remove folder (force attributes reset first)
if exist "%target%" (
    echo [x] Removing folder and contents ...
    attrib -r -s -h "%target%" /S /D
    rd /s /q "%target%"
    if exist "%target%" (
        echo [!] Folder could not be removed. Check permissions or open files.
    ) else (
        echo [✓] Folder successfully removed.
    )
) else (
    echo [!] Target folder not found: "%target%"
)

:: Self-delete
echo [x] Removing uninstaller ...
start "" cmd /c "ping 127.0.0.1 -n 2 >nul & del /f /q \"%self%\""

exit