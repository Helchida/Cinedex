#!/bin/bash
set -e

echo "========================================"
echo "Installing Flutter..."
echo "========================================"

git clone https://github.com/flutter/flutter.git \
  --depth 1 \
  -b stable \
  "$HOME/flutter"

export PATH="$HOME/flutter/bin:$PATH"

flutter --version

echo "========================================"
echo "Enable Flutter Web"
echo "========================================"

flutter config --enable-web

echo "========================================"
echo "Installing dependencies"
echo "========================================"

flutter pub get

echo "========================================"
echo "Building Flutter Web"
echo "========================================"

flutter build web --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=TMDB_ACCESS_TOKEN="$TMDB_ACCESS_TOKEN"