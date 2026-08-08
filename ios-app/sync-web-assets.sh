#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RESOURCE_DIR="$SCRIPT_DIR/AutumnRecruitmentApp/Resources"

mkdir -p "$RESOURCE_DIR"

cp "$REPO_DIR/index.html" "$RESOURCE_DIR/index.html"
cp "$REPO_DIR/styles.css" "$RESOURCE_DIR/styles.css"
cp "$REPO_DIR/app.js" "$RESOURCE_DIR/app.js"
cp "$REPO_DIR/manifest.webmanifest" "$RESOURCE_DIR/manifest.webmanifest"
cp "$REPO_DIR/app-icon.svg" "$RESOURCE_DIR/app-icon.svg"

echo "iOS web assets synced."
