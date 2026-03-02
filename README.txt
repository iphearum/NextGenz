NextGenz - Professional Native Package

Install target:
- Primary: C:\Program Files\NextGenz
- Fallback: %LOCALAPPDATA%\NextGenz

Structure after install:
- bin\KhmerTrayApp.exe
- bin\khmer_engine.dll
- bin\model_dll\*.tsv
- bin\NotoSansKhmer-Regular.ttf
- bin\typing_icon.png
- config\
- logs\
- uninstall.exe

Install:
- Run setup.exe (or install.cmd)

Uninstall:
- Run uninstall.cmd or uninstall.exe in install folder

Notes:
- Adds auto-start shortcut in Startup folder.
- Registers uninstall metadata in HKCU uninstall registry.

Linux:
- See NextGenz\linux for daemon + .deb packaging (manual systemd start, no auto-start on install).
