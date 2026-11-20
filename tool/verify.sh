#!/usr/bin/env bash
set -euo pipefail

# Gerbang verifikasi terpadu untuk proyek Flutter.
dart format --output=none --set-exit-if-changed .
flutter analyze
dart run tool/check_test_files.dart
flutter test
