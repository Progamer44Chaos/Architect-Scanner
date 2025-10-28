@echo off
setlocal

:: Set paths
set "TargetScript=%~dp0Architect Scanner.bat"
set "ShortcutName=Architect Scanner"
set "ShortcutPath=%USERPROFILE%\Desktop\%ShortcutName%.lnk"
set "IconPath=%~dp0Architect_Scanner_Icon.ico"

:: Create shortcut using PowerShell (single-line command)
powershell -Command "$s = (New-Object -ComObject WScript.Shell).CreateShortcut('%ShortcutPath%'); $s.TargetPath = '%TargetScript%'; $s.WorkingDirectory = '%~dp0'; $s.IconLocation = '%IconPath%'; $s.Save()"

echo Shortcut created on Desktop.
pause