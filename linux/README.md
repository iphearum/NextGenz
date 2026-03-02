# NextGenz Linux Package

This folder contains a Linux daemon build and Debian package pipeline.

## What it builds

- `nextgenz-daemon`: Unix socket daemon for suggestions/predictions.
- Debian package (`.deb`) that installs into `/opt/NextGenz`.

## No autostart behavior

This package does **not** auto-enable/start service after install.
You can start it manually:

```bash
sudo systemctl start nextgenz
```

## Build on Linux

```bash
cd NextGenz/linux
./build.sh
./package_deb.sh 1.0.0
```

Output:

- `NextGenz/linux/dist/nextgenz_<version>_amd64.deb`

## Uninstall

```bash
sudo apt remove nextgenz
```

Package `postrm` script removes `/opt/NextGenz` recursively.

