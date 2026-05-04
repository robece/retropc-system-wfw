@ECHO OFF
CLS
ECHO ================================================
ECHO   retropc-system-wfw  --  Installer
ECHO   MS-DOS 6.22 / Windows for Workgroups 3.11
ECHO ================================================
ECHO.
ECHO   1. Install MS-DOS 6.22
ECHO   2. Install Windows for Workgroups 3.11
ECHO   3. Exit
ECHO.
CHOICE /C:123 /N Option [1-3]:
IF ERRORLEVEL 3 GOTO END
IF ERRORLEVEL 2 GOTO WFW
IF ERRORLEVEL 1 GOTO MSDOS

:MSDOS
D:\MSDOS\SETUP.EXE
GOTO END

:WFW
D:\WIN311\INSTALAR /s:D:\WIN311
GOTO END

:END
