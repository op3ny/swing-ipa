#!/bin/bash
# Fast local syntax validation - no Xcode/SDK needed.
# Catches parse errors (unbalanced delimiters, dangling ternaries, broken modifiers)
# in seconds, before spending ~2 min on the macOS CI runner.
set -uo pipefail
SWIFTC="${SWIFTC:-swiftc}"
if ! command -v "$SWIFTC" >/dev/null 2>&1 && [ -x /tmp/opencode/swift/usr/bin/swiftc ]; then SWIFTC=/tmp/opencode/swift/usr/bin/swiftc; fi
ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1
files=()
while IFS= read -r -d '' f; do files+=("$f"); done < <(find SwingMusic SwingMusicWidgetExtension SwingMusicTests -name '*.swift' -print0 2>/dev/null)
if [ ${#files[@]} -eq 0 ]; then
  echo "No Swift files found"; exit 1
fi
echo "Parsing ${#files[@]} Swift files..."
# -frontend -parse checks syntax only; SDK-dependent type checking is impossible on Linux.
"$SWIFTC" -frontend -parse "${files[@]}" 2>&1
rc=$?
if [ $rc -eq 0 ]; then
  echo "SYNTAX OK (${#files[@]} files)"
else
  echo "SYNTAX ERRORS (exit $rc)"
fi
exit $rc
