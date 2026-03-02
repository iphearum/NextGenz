# NextGenz Android Keyboard (IME) - Starter

This is a starter Android keyboard app that loads local model assets and shows suggestions while typing.
Current configuration is Khmer-only.

## Included

- Custom keyboard service (`KhmerImeService`)
- Suggestion strip UI
- Prefix suggestions + next-word prediction from local TSV files
- Launcher activity with setup instructions

## Project Path

- `NextGenz/mobile/android`

## Requirements

- Android Studio (latest stable)
- Android SDK 24+

## Build

1. Open `NextGenz/mobile/android` in Android Studio.
2. Let Gradle sync.
3. Run on device/emulator.

## Enable Keyboard

1. Open app.
2. Tap "Open Keyboard Settings".
3. Enable `NextGenz Keyboard`.
4. Tap "Switch Keyboard" and choose `NextGenz Keyboard`.

## Model Assets

Current sample files:

- `app/src/main/assets/model/prefix.tsv`
- `app/src/main/assets/model/next.tsv`

Format:

- `prefix.tsv`: `prefix<TAB>word1|word2|word3`
- `next.tsv`: `w1<TAB>w2<TAB>next1|next2|next3`

Replace these files with your full model export for production.

## Export Small Model From `model.msgpack`

Use this command from repo root to generate a compact model for Android:

```powershell
.\.venv\Scripts\python.exe .\nextgen\tools\export_model_for_dll.py `
  --model .\khmerLM\khmer_keyboard\model.msgpack `
  --out-dir .\NextGenz\mobile\android\app\src\main\assets\model `
  --prefix-max-len 5 `
  --prefix-top-n 6 `
  --next-top-n 5 `
  --max-unigram-words 25000 `
  --max-trigram-keys 80000 `
  --max-bigram-keys 30000 `
  --khmer-only
```

Tune for smaller size:

- Reduce `--max-unigram-words`
- Reduce `--max-trigram-keys`
- Reduce `--max-bigram-keys`
- Reduce `--prefix-top-n` and `--next-top-n`
