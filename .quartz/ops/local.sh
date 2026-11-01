#!/usr/bin/env bash
set -euo pipefail

# this script lives in .quartz/ops/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .quartz/ops
QUARTZ_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"                   # .quartz

# serve the already-built static output with clean-URL support
if [ -n "${QUARTZ_BUILD_ROOT:-}" ]; then
  cd "$QUARTZ_BUILD_ROOT/$(basename "$(dirname "$QUARTZ_DIR")")/public"
else
  cd "$QUARTZ_DIR/build/public"
fi
exec npx --yes serve -l 8080 .
