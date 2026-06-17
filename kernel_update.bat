copy \\wsl.localhost\Ubuntu-24.04\root\build\sama5d3_xplained.itb sama5d3_xplained-wsl.itb
sam-ba.exe \usb\ARM0 at91sama5d3x-ek kernel_update.tcl > logfile_kernel.log 2>&1
notepad logfile_kernel.log
