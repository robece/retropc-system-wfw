@ECHO OFF
CLS
ECHO ================================================
ECHO   retropc-system-wfw
ECHO ================================================
ECHO.
ECHO Insert the CD-ROM and press any key...
PAUSE > NUL
MSCDEX.EXE /D:MSCD001 /L:D
PATH D:\DOS
D:\INSTALL.BAT
