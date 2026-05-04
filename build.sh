#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIST_DIR="$SCRIPT_DIR/dist"
CD_DIR="$SCRIPT_DIR/cd"

echo "================================================"
echo "  retropc-system-wfw  --  build ISO"
echo "  Output: dist/wfw311.iso"
echo "================================================"
echo

if ! command -v mkisofs &>/dev/null; then
    echo "mkisofs not found. Installing cdrtools..."
    brew install cdrtools || { echo "ERROR: could not install cdrtools"; exit 1; }
fi

mkdir -p "$DIST_DIR"

echo "Building ISO..."
mkisofs \
    -o "$DIST_DIR/wfw311.iso" \
    -V "WFW311" \
    -J \
    -r \
    "$CD_DIR/"

SIZE=$(du -sh "$DIST_DIR/wfw311.iso" | cut -f1)
echo "  dist/wfw311.iso  ($SIZE)"
echo
echo "  Burn to CD-ROM:  hdiutil burn dist/wfw311.iso"
