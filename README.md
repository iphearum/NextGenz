# NextGenz Khmer Typing Assistant

NextGenz provides Khmer typing suggestions and next-word prediction.

- Windows: tray application (`setup.exe` / `uninstall.exe`)
- Linux: daemon + Debian package (`.deb`)

## Features

- Khmer word suggestion from typed prefix
- Next-word prediction
- Offline model files (`prefix.tsv`, `next.tsv`)
- Local install/uninstall package flow

## Quick Start (Windows)

Release folder:

`NextGenz/`

Install:

1. Open `NextGenz/setup.exe` (or `NextGenz/install.cmd`)
2. App starts in system tray (hidden icons area)

Uninstall:

1. Run `NextGenz/uninstall.cmd`
2. Or run installed `uninstall.exe`
3. Installer removes installed `NextGenz` folder

Default install paths:

- Primary: `C:\Program Files\NextGenz`
- Fallback: `%LOCALAPPDATA%\NextGenz`

## Quick Start (Linux - Debian/Ubuntu)

Build package:

```bash
cd NextGenz/linux
chmod +x build.sh package_deb.sh
./build.sh
./package_deb.sh 1.0.0
```

Install package:

```bash
sudo dpkg -i dist/nextgenz_1.0.0_amd64.deb
```

Start daemon manually:

```bash
sudo systemctl start nextgenz
```

Uninstall:

```bash
sudo apt remove nextgenz
```

Uninstall removes:

- `/opt/NextGenz`

## Linux Daemon Socket Protocol

Socket path:

- `/run/nextgenz/daemon.sock`

Commands:

- `PING`
- `PREFIX<TAB>top_n<TAB>prefix`
- `NEXT<TAB>top_n<TAB>w1<TAB>w2`
- `SMART<TAB>top_n<TAB>text`

Response format:

- `OK<TAB>...`
- `ERR<TAB>...`

## Repository Layout

- `NextGenz/` Windows release package
- `NextGenz/linux/` Linux daemon + deb packaging
- `nextgen/native/` shared native engine source

## Notes

- Linux package does not auto-start service after install.
- For Windows, ensure all files under `NextGenz/payload` are kept together.

