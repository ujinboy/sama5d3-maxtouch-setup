@echo off
rem Kernel-only update (kernel 4.19) for SAMA5D3 Xplained
rem Source: WSL Ubuntu-24.04 /root/at91/build/sama5d3_xplained.itb

echo Copying ITB from WSL build...
copy /Y \\wsl.localhost\Ubuntu-24.04\home\a41839\at91\build\sama5d3_xplained.itb sama5d3_xplained-wsl.itb
copy /Y \\wsl.localhost\Ubuntu-24.04\home\a41839\at91\build\sama5d3_xplained.itb sama5d3_xplained-kernel_v4.19_wsl.itb
if errorlevel 1 (
    echo ERROR: Failed to copy ITB from WSL
    pause
    exit /b 1
)

echo Flashing kernel 4.19...
sam-ba.exe \usb\ARM0 at91sama5d3x-ek kernel_update.tcl > logfile_kernel.log 2>&1

notepad logfile_kernel.log
