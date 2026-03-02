# NextGenz iOS Keyboard (Starter)

This folder contains an iOS keyboard extension scaffold (Khmer-only) plus a host app.

## Generate Xcode Project

On macOS:

```bash
brew install xcodegen
cd NextGenz/mobile/ios
xcodegen generate
open NextGenziOS.xcodeproj
```

## Build Steps

1. Set your Apple Team in Xcode Signing settings.
2. Change bundle IDs if needed.
3. Build and run `NextGenzHostApp` on iPhone.
4. Enable keyboard in iOS Settings.

## Model Files

Files used by keyboard extension:

- `Shared/Model/prefix.tsv`
- `Shared/Model/next.tsv`

You can replace these with exported Khmer model files.

