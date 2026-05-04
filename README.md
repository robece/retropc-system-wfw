# retropc-system-wfw

### Windows for Workgroups 3.11 (ES) — CD installer for 486 PC

Generates a **bootable 1.44 MB floppy** (`boot.img`) and a **data CD** (`wfw311.iso`) that together install Windows for Workgroups 3.11 (Spanish) on a 486 PC running MS-DOS 6.22.

If the sister project `retropc-network-rtl8029` is present next to this folder, its Disk 1 content is automatically added to `NET\` on the CD.

---

## How it works

```
boot floppy (boot.img)
  IO.SYS / MSDOS.SYS / COMMAND.COM   <- MS-DOS 6.22
  OAKCDROM.SYS                        <- ATAPI CD-ROM driver
  MSCDEX.EXE                          <- CD-ROM extensions (from MS-DOS 6.22 Disk 1)
  CONFIG.SYS   -> loads OAKCDROM.SYS
  AUTOEXEC.BAT -> mounts CD as D:, then calls D:\START.BAT

CD-ROM (wfw311.iso)
  START.BAT         <- launches D:\WIN311\INSTALAR /s:D:\WIN311
  WIN311\           <- all 9 WFW 3.11 disk images flattened into one directory
  NET\  (optional)  <- RTL8029 network installer (retropc-network-rtl8029 disk-01)
```

Boot sequence on 486:
1. Insert floppy + CD, boot from floppy
2. `OAKCDROM.SYS` loads the CD drive
3. `MSCDEX.EXE` mounts CD as `D:`
4. Installer runs: `D:\WIN311\INSTALAR /s:D:\WIN311`
5. WFW 3.11 installs from CD without any disk swapping

> Most 486 BIOSes do not support booting from CD (El-Torito). The floppy handles
> the boot; the CD is a plain data disc. The ISO is also El-Torito bootable for
> machines that do support it.

---

## Project structure

```
retropc-system-wfw/
├── build.sh          Main build script
├── cd/               Static content placed at the CD root
│   └── START.BAT     Launches the WFW installer
├── disk/
│   ├── msdos/        MS-DOS 6.22 floppy images (3 x 1.44 MB)
│   └── wfw/          WFW 3.11 floppy images (9 x 1.44 MB, Spanish)
├── drivers/          OAKCDROM.SYS (user-supplied)
└── source/           Additional scripts or tools
```

Build output (generated, not tracked):
```
dist/boot.img    <- 1.44 MB bootable floppy image
dist/wfw311.iso  <- CD-ROM image (~12 MB)
```

---

## Requirements

| Item | Details |
|---|---|
| `OAKCDROM.SYS` | Universal ATAPI CD-ROM driver — place in `drivers/` |
| mtools | `brew install mtools` |
| cdrtools | `brew install cdrtools` (provides `mkisofs`) — installed automatically by build.sh |

### OAKCDROM.SYS

`OAKCDROM.SYS` is the universal Oak Technology ATAPI driver. It is freely
available at [archive.org](https://archive.org/details/oakcdrom).

Place the file at `drivers/OAKCDROM.SYS` before running the build.

---

## Build

```bash
chmod +x build.sh
./build.sh
```

---

## Write to physical media (macOS)

### Floppy

```bash
diskutil list                          # find your floppy drive, e.g. /dev/disk4
diskutil unmountDisk /dev/disk4
sudo dd if=dist/boot.img of=/dev/rdisk4 bs=512
```

### CD-ROM

```bash
hdiutil burn dist/wfw311.iso
```
