#!/usr/bin/env bash
set -ex           
pwd
ls -la

git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter-sdk


export PATH="$PWD/flutter-sdk/bin:$PATH"

nd configure web
flutter --version
flutter config --enable-web


flutter pub get
flutter build web --release --web-renderer html

ls -la build/web
