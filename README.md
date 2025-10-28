# Architect-Scanner
Architect Scanner is a modular Windows toolkit for scanning .exe files by architecture type (x86, x64, ARM, ARM64). It includes an interactive PowerShell menu, per-architecture logging, incompatible executable detection, CPU info, uninstall automation, and shortcut creation — ideal for diagnostics, maintenance, and portable use.

---

## 🧩 Features

- 🔍 **Architecture scanning**:
  - x86 (classic)
  - x64 (64-bit)
  - ARM
  - ARM64

- 🚫 **Incompatible executable detection**:
  - Automatically detects system architecture
  - Lists `.exe` files that cannot run on the current system
  - Optional logging

- 📁 **Separate log files per scan type**:
  - `Scan Architect - x86 Log.txt`
  - `Scan Architect - x64 Log.txt`
  - `Scan Architect - ARM Log.txt`
  - `Scan Architect - ARM64 Log.txt`
  - `Scan Architect - Incompatible Log.txt`

- 🖥 **Interactive menu with GridView selection**

- 🧠 **CPU info viewer**:
  - Shows processor name and architecture

- 📄 **Log viewer with Notepad integration**

- 🗑 **Uninstall function with admin elevation**

- 🔗 **Desktop shortcut to launcher**

- 🧼 **Automatic console clearing (`cls`) before each process**

- ❌ **Console closes automatically when menu is exited or closed**

---

## 🚀 Installation

1. Extract the ZIP archive to: `C:\Program Files\Architect Scanner`
2. Optionally run `Create Architect Shortcut.bat` to create a desktop shortcut
3. Launch `Architect Scanner.bat`

---

## 🧹 Uninstallation

Run `Uninstall Architect Scanner.bat`  
→ Removes the entire folder `C:\Program Files\Architect Scanner` and all related files

> 🔐 Administrator rights are recommended for full functionality

---

## 🛠 Requirements

- Windows 10 or later  
- PowerShell 5.0+  
- Admin rights for folder access and shortcut creation

---

## 📌 Notes

This toolkit is designed for technical analysis and system maintenance. It is portable, visually clear, and modular for future expansion. All components are open-source and customizable for professional use.

---

© 2025 Progamer44Chaos — Architect Scanner (Toolkit)
