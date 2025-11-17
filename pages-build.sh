#!/usr/bin/env bash
set -ex

git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter-sdk


export PATH="$PWD/flutter-sdk/bin:$PATH"

flutter config --enable-web

# Get dependencies and build web
flutter pub get
flutter build web --release
