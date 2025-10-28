chcp 65001 > $null
$ErrorActionPreference = "SilentlyContinue"

function Get-ExeArchitecture {
    param ($exePath)
    try {
        $stream = [System.IO.File]::OpenRead($exePath)
        $reader = New-Object System.IO.BinaryReader($stream)
        $stream.Seek(0x3C, 'Begin') | Out-Null
        $peOffset = $reader.ReadInt32()
        $stream.Seek($peOffset + 4, 'Begin') | Out-Null
        $machineType = $reader.ReadUInt16()
        $reader.Close()
        $stream.Close()

        switch ($machineType) {
            0x014C { return "x86" }
            0x8664 { return "x64" }
            0x01C0 { return "ARM" }
            0xAA64 { return "ARM64" }
            default { return "Unknown" }
        }
    } catch {
        return "Unreadable"
    }
}

function Start-Scan {
    param (
        [string]$TargetArch,
        [bool]$LogEnabled = $true
    )

    cls
    $paths = @("C:\Program Files", "C:\Program Files (x86)")
    $results = @()
    $logName = "Scan Architect - $TargetArch Log.txt"
    $logPath = Join-Path -Path $PSScriptRoot -ChildPath $logName

    Write-Host "`nScanning for $TargetArch executables..." -ForegroundColor Cyan
    foreach ($path in $paths) {
        Get-ChildItem -Path $path -Recurse -Filter *.exe -ErrorAction SilentlyContinue | ForEach-Object {
            $arch = Get-ExeArchitecture $_.FullName
            if ($arch -eq $TargetArch) {
                $line = $_.FullName + " -> " + $arch
                Write-Output $line
                $results += $line
            }
        }
    }

    if ($LogEnabled) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "`n[$timestamp] Scan ($TargetArch)`n" | Out-File -FilePath $logPath -Encoding UTF8 -Append
        $results | Out-File -FilePath $logPath -Encoding UTF8 -Append
        Write-Host "`nScan complete. Results saved to $logName." -ForegroundColor Yellow
    } else {
        Write-Host "`nScan complete. (No log created)" -ForegroundColor Yellow
    }

    pause
    Show-Menu
}

function Scan-IncompatibleExecutables {
    param ([bool]$LogEnabled = $true)

    cls
    $cpuArch = (Get-CimInstance Win32_Processor).Architecture
    $systemArch = switch ($cpuArch) {
        0  { "x86" }
        5  { "ARM" }
        9  { "x64" }
        12 { "ARM64" }
        default { "Unknown" }
    }

    $paths = @("C:\Program Files", "C:\Program Files (x86)")
    $results = @()
    $logPath = Join-Path -Path $PSScriptRoot -ChildPath "Scan Architect - Incompatible Log.txt"

    Write-Host "`nSystem architecture detected: $systemArch" -ForegroundColor Cyan
    Write-Host "Scanning for incompatible executables..." -ForegroundColor Cyan

    foreach ($path in $paths) {
        Get-ChildItem -Path $path -Recurse -Filter *.exe -ErrorAction SilentlyContinue | ForEach-Object {
            $arch = Get-ExeArchitecture $_.FullName
            $isIncompatible = switch ($systemArch) {
                "x86"   { $arch -in @("x64", "ARM", "ARM64") }
                "x64"   { $arch -in @("ARM", "ARM64") }
                "ARM"   { $arch -in @("x86", "x64", "ARM64") }
                "ARM64" { $arch -in @("x86", "x64", "ARM") }
                default { $false }
            }
            if ($isIncompatible) {
                $line = $_.FullName + " -> " + $arch
                Write-Output $line
                $results += $line
            }
        }
    }

    if ($LogEnabled) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "`n[$timestamp] Incompatible Scan ($systemArch)`n" | Out-File -FilePath $logPath -Encoding UTF8 -Append
        $results | Out-File -FilePath $logPath -Encoding UTF8 -Append
        Write-Host "`nScan complete. Results saved to Scan Architect - Incompatible Log.txt" -ForegroundColor Yellow
    } else {
        Write-Host "`nScan complete. (No log created)" -ForegroundColor Yellow
    }

    pause
    Show-Menu
}

function Show-IncompatibleSubMenu {
    $choice = @(
        "Scan incompatible executables with log",
        "Scan incompatible executables without log",
        "Back to main menu"
    ) | Out-GridView -Title "Scan incompatible executables" -OutputMode Single

    switch ($choice) {
        "Scan incompatible executables with log"    { Scan-IncompatibleExecutables -LogEnabled $true }
        "Scan incompatible executables without log" { Scan-IncompatibleExecutables -LogEnabled $false }
        "Back to main menu"                         { Show-Menu }
    }
}

function Show-Log {
    cls
    $logs = Get-ChildItem -Path $PSScriptRoot -Filter "Scan Architect - * Log.txt"
    if ($logs.Count -gt 0) {
        $logs.FullName | Out-GridView -Title "Select a log file to open" -OutputMode Single | ForEach-Object {
            notepad.exe $_
        }
    } else {
        Write-Host "`nNo log files found." -ForegroundColor Red
    }
    Show-Menu
}

function Run-Uninstall {
    cls
    $uninstaller = Join-Path -Path $PSScriptRoot -ChildPath "Uninstall Architect Scanner.bat"
    if (Test-Path $uninstaller) {
        Write-Host "`nLaunching uninstaller..." -ForegroundColor Red
        Start-Process -FilePath $uninstaller -Verb RunAs
		Stop-Process -Id $PID
    } else {
        Write-Host "`nUninstaller not found." -ForegroundColor DarkRed
    }
    Show-Menu
}

function Show-CPUArchitecture {
    cls
    $cpu = Get-CimInstance Win32_Processor
    $name = $cpu.Name
    $arch = $cpu.Architecture

    $archText = switch ($arch) {
        0  { "x86 (32-bit)" }
        5  { "ARM" }
        9  { "x64 (64-bit)" }
        12 { "ARM64" }
        default { "Unknown ($arch)" }
    }

    Write-Host "`nProcessor name: $name" -ForegroundColor Green
    Write-Host "System architecture: $archText" -ForegroundColor Cyan
    pause
    Show-CPUMenu
}

function Show-CPUMenu {
    $choice = @(
        "Show processor name and architecture",
        "Back to main menu"
    ) | Out-GridView -Title "System CPU Info" -OutputMode Single

    switch ($choice) {
        "Show processor name and architecture" { Show-CPUArchitecture }
        "Back to main menu"                    { Show-Menu }
    }
}

function Show-SubMenu {
    param ([string]$Arch)
    $choice = @(
        "Scan $Arch with log",
        "Scan $Arch without log",
        "Back to main menu"
    ) | Out-GridView -Title "Scan Architect - $Arch options" -OutputMode Single

    switch ($choice) {
        "Scan $Arch with log"     { Start-Scan -TargetArch $Arch -LogEnabled $true }
        "Scan $Arch without log"  { Start-Scan -TargetArch $Arch -LogEnabled $false }
        "Back to main menu"       { Show-Menu }
    }
}

function Show-Menu {
    $choice = @(
        "Scan Architect - x86",
        "Scan Architect - x64",
        "Scan Architect - ARM",
        "Scan Architect - ARM64",
        "Scan incompatible executables",
        "View log files",
        "System CPU Info",
        "Uninstall Architect Scanner",
        "Exit"
    ) | Out-GridView -Title "Architect Scanner - Main Menu" -OutputMode Single

    switch ($choice) {
        "Scan Architect - x86"                { Show-SubMenu -Arch "x86" }
        "Scan Architect - x64"                { Show-SubMenu -Arch "x64" }
        "Scan Architect - ARM"                { Show-SubMenu -Arch "ARM" }
        "Scan Architect - ARM64"              { Show-SubMenu -Arch "ARM64" }
        "Scan incompatible executables"       { Show-IncompatibleSubMenu }
        "View log files"                      { Show-Log }
        "System CPU Info"                     { Show-CPUMenu }
        "Uninstall Architect Scanner"         { Run-Uninstall }
        "Exit"                                { Stop-Process -Id $PID }
    }
}

Show-Menu