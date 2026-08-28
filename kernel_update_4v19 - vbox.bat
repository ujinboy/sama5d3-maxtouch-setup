@echo off
rem Kernel-only update (kernel 4.19) for SAMA5D3 Xplained
rem Source: VirtualBox Ubuntu 16.04 ~/at91/build/sama5d3_xplained.itb
rem Flash:  SAM-BA 2.18, TCL, NAND 0x00180000

echo Copying ITB from VirtualBox build...
copy /Y \\10.161.41.37\at91\build\sama5d3_xplained.itb sama5d3_xplained-wsl.itb
if errorlevel 1 (
    echo ERROR: Failed to copy ITB from VirtualBox
    pause
    exit /b 1
)

echo Flashing kernel 4.19...
sam-ba.exe \usb\ARM0 at91sama5d3x-ek kernel_update.tcl > logfile_kernel.log 2>&1

notepad logfile_kernel.log
