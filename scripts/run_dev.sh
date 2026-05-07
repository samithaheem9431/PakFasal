#!/usr/bin/env bash
# Run the app in dev mode with secrets loaded from config/dev.json.
# Usage:  ./scripts/run_dev.sh                  (debug)
#         ./scripts/run_dev.sh --profile        (profile)
#         ./scripts/run_dev.sh --release        (release)
#         ./scripts/run_dev.sh --build          (just build apk, no run)

set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f config/dev.json ]; then
    echo "config/dev.json not found."
    echo "Copy config/app_config.example.json to config/dev.json and fill in your keys."
    exit 1
fi

mode="debug"
build_only=0
for arg in "$@"; do
    case "$arg" in
        --profile) mode="profile" ;;
        --release) mode="release" ;;
        --build)   build_only=1 ;;
        *) echo "Unknown arg: $arg"; exit 2 ;;
    esac
done

if [ "$build_only" -eq 1 ]; then
    set -x
    flutter build apk --dart-define-from-file=config/dev.json
else
    set -x
    flutter run --"$mode" --dart-define-from-file=config/dev.json
fi
