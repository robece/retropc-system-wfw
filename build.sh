#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
DIST_DIR="$SCRIPT_DIR/dist"
MSDOS_DIR="$SCRIPT_DIR/disk/msdos"
WFW_DIR="$SCRIPT_DIR/disk/wfw"
DRIVERS_DIR="$SCRIPT_DIR/drivers"
CD_DIR="$SCRIPT_DIR/cd"

echo "================================================"
echo "  retropc-system-wfw  --  build"
echo "  Output: dist/boot.img + dist/wfw311.iso"
echo "================================================"
echo

# ---- Prerequisites -------------------------------------------------------

echo "[1/5] Checking prerequisites..."

if ! command -v mtools &>/dev/null; then
    echo "ERROR: mtools not found. Run: brew install mtools"; exit 1
fi

if ! command -v mkisofs &>/dev/null; then
    echo "  mkisofs not found. Installing cdrtools..."
    brew install cdrtools || { echo "ERROR: could not install cdrtools"; exit 1; }
fi

if [ ! -f "$DRIVERS_DIR/OAKCDROM.SYS" ]; then
    echo "ERROR: drivers/OAKCDROM.SYS not found."
    echo "  Place OAKCDROM.SYS in the drivers/ folder and run again."
    exit 1
fi

for i in 1 2 3; do
    [ -f "$MSDOS_DIR/SetupDisk${i}MSDOS622.IMA" ] || \
        { echo "ERROR: MS-DOS Disk $i not found"; exit 1; }
done

for i in 01 02 03 04 05 06 07 08 09; do
    [ -f "$WFW_DIR/WIN311_${i}.IMA" ] || \
        { echo "ERROR: WFW Disk $i not found"; exit 1; }
done

echo "  OK"
echo

# ---- Clean ---------------------------------------------------------------

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/cd/WIN311"
mkdir -p "$DIST_DIR"

# ---- Extract WFW 3.11 ----------------------------------------------------

echo "[2/5] Extracting WFW 3.11 disk images..."
for i in 01 02 03 04 05 06 07 08 09; do
    IMG="$WFW_DIR/WIN311_${i}.IMA"
    printf "  Disk %s...\n" "$i"
    mcopy -i "$IMG" -o '::*' "$BUILD_DIR/cd/WIN311/" 2>/dev/null || true
done

COUNT=$(ls "$BUILD_DIR/cd/WIN311" | wc -l | tr -d ' ')
echo "  $COUNT files in cd/WIN311/"
echo

# Copy static CD root content
cp "$CD_DIR/START.BAT" "$BUILD_DIR/cd/START.BAT"

# Optional: include RTL8029 network installer if present next to this repo
NET_SRC="$SCRIPT_DIR/../retropc-network-rtl8029/disk-01"
if [ -d "$NET_SRC" ]; then
    echo "  RTL8029 installer found -- adding to cd/NET/"
    mkdir -p "$BUILD_DIR/cd/NET"
    cp -r "$NET_SRC/"* "$BUILD_DIR/cd/NET/"
fi

# ---- Build boot floppy ---------------------------------------------------

echo "[3/5] Building boot floppy..."

BOOT_IMG="$BUILD_DIR/boot.img"
MSDOS_DISK1="$MSDOS_DIR/SetupDisk1MSDOS622.IMA"

# Start from MS-DOS Disk 1 -- already bootable with IO.SYS, MSDOS.SYS,
# COMMAND.COM and MSCDEX.EXE in place
cp "$MSDOS_DISK1" "$BOOT_IMG"

# Remove files not needed on the boot floppy to free space
for f in ATTRIB.EXE CHKDSK.EXE COUNTRY.SYS COUNTRY.TX_ DEBUG.EXE \
         DEFRAG.EXE DEFRAG.HL_ DOSSETUP.INI DRVSPACE.BIN EDIT.COM \
         EGA.CP_ EGA2.CP_ EGA3.CP_ EMM386.EX_ EXPAND.EXE FDISK.EXE \
         FORMAT.COM ISO.CP_ KEYB.COM KEYBOARD.SYS KEYBRD2.SY_ MEM.EX_ \
         NETWORKS.TXT NLSFUNC.EXE PACKING.LST QBASIC.EXE README.TXT \
         REPLACE.EX_ RESTORE.EX_ SCANDISK.EXE SCANDISK.INI SETUP.EXE \
         SETUP.MSG SYS.COM XCOPY.EX_ AUTOEXEC.BAT CONFIG.SYS; do
    mdel -i "$BOOT_IMG" "::$f" 2>/dev/null || true
done

# Add OAKCDROM.SYS
mcopy -i "$BOOT_IMG" "$DRIVERS_DIR/OAKCDROM.SYS" '::OAKCDROM.SYS'

# CONFIG.SYS -- minimal: just enough to load the CD-ROM driver
cat > "$BUILD_DIR/CONFIG.SYS" << 'EOF'
FILES=30
BUFFERS=10
DEVICE=OAKCDROM.SYS /D:MSCD001
EOF
mcopy -i "$BOOT_IMG" "$BUILD_DIR/CONFIG.SYS" '::CONFIG.SYS'

# AUTOEXEC.BAT -- mount CD as D: then launch START.BAT from the CD
cat > "$BUILD_DIR/AUTOEXEC.BAT" << 'EOF'
@ECHO OFF
MSCDEX.EXE /D:MSCD001 /L:D
D:\START.BAT
EOF
mcopy -i "$BOOT_IMG" "$BUILD_DIR/AUTOEXEC.BAT" '::AUTOEXEC.BAT'

FREE=$(mdir -i "$BOOT_IMG" :: 2>/dev/null | grep "bytes free" | awk '{print $1}')
echo "  boot.img ready  (free space: $FREE bytes)"
echo

# ---- Embed boot.img in CD tree for El-Torito -----------------------------

cp "$BOOT_IMG" "$BUILD_DIR/cd/boot.img"

# ---- Build ISO -----------------------------------------------------------

echo "[4/5] Building ISO..."

ISO_OUT="$DIST_DIR/wfw311.iso"
mkisofs \
    -o "$ISO_OUT" \
    -V "WFW311" \
    -b boot.img \
    -c boot.cat \
    -J \
    -r \
    "$BUILD_DIR/cd/"

SIZE=$(du -sh "$ISO_OUT" | cut -f1)
echo "  wfw311.iso  ($SIZE)"
echo

# ---- Copy artifacts to dist ----------------------------------------------

cp "$BOOT_IMG" "$DIST_DIR/boot.img"

echo "[5/5] Done."
echo
echo "  dist/boot.img    -- write to a 1.44 MB floppy"
echo "  dist/wfw311.iso  -- burn to CD-ROM"
echo
echo "  On macOS:"
echo "    Write floppy : dd if=dist/boot.img of=/dev/rdiskN bs=512"
echo "    Burn ISO     : hdiutil burn dist/wfw311.iso"
echo
echo "  Boot sequence on 486:"
echo "    1. Insert boot floppy + WFW 3.11 CD"
echo "    2. Boot from floppy"
echo "    3. OAKCDROM.SYS loads the CD drive"
echo "    4. MSCDEX mounts CD as D:"
echo "    5. Installer launches automatically from D:\WIN311\INSTALAR.EXE"
