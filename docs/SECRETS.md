# API keys & secrets (PakFasal)

Secrets must **not** live in the asset bundle or in git. Inject them at build
time with Flutter `--dart-define` / `--dart-define-from-file`.

## One-time local setup

```bash
cp config/app_config.example.json config/dev.json
```

Edit `config/dev.json` and fill:

| Key | Used for |
|-----|----------|
| `YOUTUBE_API_KEY` | Learning → YouTube videos |
| `OPENWEATHER_API_KEY` | Weather (OpenWeatherMap) |
| `CLOUDINARY_CLOUD_NAME` | Profile photo upload |
| `CLOUDINARY_UPLOAD_PRESET` | Unsigned Cloudinary preset |

`config/dev.json` is git-ignored. Only `config/app_config.example.json` is committed.

## Run / build

```bash
# Dev
flutter run --dart-define-from-file=config/dev.json

# Release
flutter build apk --dart-define-from-file=config/dev.json
# or inject CI secrets:
flutter build apk \
  --dart-define=OPENWEATHER_API_KEY=$OPENWEATHER_API_KEY \
  --dart-define=YOUTUBE_API_KEY=$YOUTUBE_API_KEY \
  --dart-define=CLOUDINARY_CLOUD_NAME=$CLOUDINARY_CLOUD_NAME \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=$CLOUDINARY_UPLOAD_PRESET \
  --dart-define=APP_ENV=prod
```

In Cursor / VS Code, use the **PakFasal (dev.json)** launch configuration
(`.vscode/launch.json`) so Run/Debug already passes the file.

## Without keys

The app still starts:

- Learning → demo videos
- Weather → Open-Meteo fallback where possible
- Profile photo upload → shows “not configured”

## Hardening (recommended)

1. Restrict API keys in each provider console (Android package + SHA-1, iOS bundle ID, HTTP referrers).
2. Prefer a backend proxy for high-value keys long term.
3. If a key was ever shared or shipped in an old APK, **rotate it** in the provider console.
