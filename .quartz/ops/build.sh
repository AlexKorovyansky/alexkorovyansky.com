#!/usr/bin/env bash
set -euo pipefail

# ── Paths (this script lives in .quartz/ops/) ───────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .quartz/ops
QUARTZ_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"                   # .quartz
REPO_ROOT="$(cd "$QUARTZ_DIR/.." && pwd)"                    # vault root = site content

# ── Settings ────────────────────────────────────────────────
QUARTZ_SHA="9cf87ff1c248a8ca551093214b0fec3b31415009"   # pinned quartz commit
QUARTZ_REPO="https://github.com/jackyzha0/quartz.git" # quartz github repo
if [ -n "${QUARTZ_BUILD_ROOT:-}" ]; then
  BUILD_DIR="$QUARTZ_BUILD_ROOT/$(basename "$REPO_ROOT")" # quartz cloned & built in target folder
else
  BUILD_DIR="$QUARTZ_DIR/build" # quartz cloned & built here (gitignored)
fi
OUTPUT_DIR="$BUILD_DIR/public"                 # built site output

# ── 1/3 Fetch Quartz (pinned) ───────────────────────────────
echo "▸ 1/3 Fetch Quartz (pinned ${QUARTZ_SHA:0:9})"
if [ ! -d "$BUILD_DIR/.git" ]; then
  git clone --filter=blob:none "$QUARTZ_REPO" "$BUILD_DIR"
fi
git -C "$BUILD_DIR" fetch --quiet origin
git -C "$BUILD_DIR" -c advice.detachedHead=false checkout -f --quiet "$QUARTZ_SHA"

# ── 2/3 Inject my files ─────────────────────────────────────
echo "▸ 2/3 Inject my files"
cp "$QUARTZ_DIR/quartz.config.yaml" "$BUILD_DIR/quartz.config.yaml"
cp "$QUARTZ_DIR/quartz.lock.json"   "$BUILD_DIR/quartz.lock.json"
cp "$QUARTZ_DIR/styles/custom.scss" "$BUILD_DIR/quartz/styles/custom.scss"
cp -r "$QUARTZ_DIR/static/." "$BUILD_DIR/quartz/static/"

# ── 3/3 Build ───────────────────────────────────────────────
echo "▸ 3/3 Build"
cd "$BUILD_DIR"
npm ci
node ./quartz/bootstrap-cli.mjs plugin install --from-config
node ./quartz/bootstrap-cli.mjs build --directory "$REPO_ROOT" --output "$OUTPUT_DIR"

echo "✓ Done. Site: $OUTPUT_DIR"
echo "  Quartz built at: $(git -C "$BUILD_DIR" rev-parse --short HEAD)"
