#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  export FLUTTER_HOME="${VERCEL_PROJECT_DIR:-$PWD}/.flutter"
  git clone https://github.com/flutter/flutter.git --branch stable --depth 1 "$FLUTTER_HOME"
  export PATH="$FLUTTER_HOME/bin:$PATH"
fi

flutter config --enable-web
flutter pub get

flutter build web --release --no-wasm-dry-run \
  --dart-define=SUPABASE_URL="${SUPABASE_URL:-}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}" \
  --dart-define=CLOUDINARY_CLOUD_NAME="${CLOUDINARY_CLOUD_NAME:-}" \
  --dart-define=CLOUDINARY_UPLOAD_PRESET="${CLOUDINARY_UPLOAD_PRESET:-}"
