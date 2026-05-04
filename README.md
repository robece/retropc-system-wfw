# retropc-system-wfw

### MS-DOS 6.22 + Windows for Workgroups 3.11 (ES) — CD installer for 486 PC

Boot floppy + CD-ROM that installs MS-DOS 6.22 and/or Windows for Workgroups 3.11
(Spanish) on a 486 PC from scratch.

---

## How it works

```
floppy/          <- copy to a formatted MS-DOS boot floppy
  AUTOEXEC.BAT   <- prompts to insert CD, mounts it as D:, launches D:\INSTALL.BAT
  CONFIG.SYS     <- loads OAKCDROM.SYS
  MSCDEX.EXE     <- CD-ROM extensions
  OAKCDROM.SYS   <- ATAPI CD-ROM driver (user-supplied)

cd/              <- burn to CD-ROM
  INSTALL.BAT    <- installer menu
  MSDOS/         <- MS-DOS 6.22 files (all 3 disks, extracted)
  WIN311/        <- WFW 3.11 files (all 9 disks, extracted)
  DOS/           <- useful DOS utilities, ready to use
```

### Boot sequence on 486

```
1. Insert boot floppy, power on
2. Prompt: "Insert the CD-ROM and press any key..."
3. Insert CD, press any key
4. CD mounts as D:, PATH set to D:\DOS
5. Installer menu:
      1. Install MS-DOS 6.22
      2. Install Windows for Workgroups 3.11
      3. Exit
```

---

## Preparing the floppy

On any MS-DOS machine, format a 1.44 MB floppy with system files:

```
FORMAT A: /S
```

Then copy all files from `floppy/` to the floppy.
`OAKCDROM.SYS` must be added manually (see requirements below).

---

## Burning the CD

### macOS — build ISO with build.sh

```bash
chmod +x build.sh
./build.sh
hdiutil burn dist/wfw311.iso
```

### Windows — burn cd/ folder directly

Use any CD burning software (ImgBurn, Nero, Windows Explorer) and burn the
contents of the `cd/` folder to a blank CD-R.

---

## Requirements

`OAKCDROM.SYS` is the universal Oak Technology ATAPI CD-ROM driver. It is
freely available at [archive.org](https://archive.org/details/oakcdrom).

Copy it to the `floppy/` folder before preparing the floppy disk.

---

## DOS utilities included (cd/DOS/)

| File | Description |
|---|---|
| `FDISK.EXE` | Disk partitioning |
| `FORMAT.COM` | Disk formatting |
| `SYS.COM` | Transfer system files to a drive |
| `SCANDISK.EXE` | Disk surface scan and repair |
| `CHKDSK.EXE` | Check disk structure |
| `EDIT.COM` | Full-screen text editor (requires QBASIC.EXE) |
| `QBASIC.EXE` | Required by EDIT |
| `DEBUG.EXE` | Low-level debugger |
| `EXPAND.EXE` | Expand compressed DOS files |
| `ATTRIB.EXE` | File attribute manager |
| `MSD.EXE` | Hardware diagnostic tool |
| `CHOICE.COM` | Menu/prompt utility |
| `MORE.COM` | Output pager |
| `UNFORMAT.COM` | Recover a formatted drive |
| `UNDELETE.EXE` | Recover deleted files |
