## U-Boot env update only - SAM-BA 2.18 TCL script
## Fixes bootcmd_boot read size for larger ITB

set boardFamily "sama5d3_xplained"
set ubootEnvAddr 0x00140000
set pmeccConfig 0xc0902405
set build_uboot_env "yes"

## u-boot variables (read size = 0x600000 for larger kernel)
lappend u_boot_variables \
    "bootdelay=1" \
    "baudrate=115200" \
    "stdin=serial" \
    "stdout=serial" \
    "stderr=serial" \
    "video_mode_pda4=Unknown-1:480x272-16" \
    "video_mode_pda5=Unknown-1:800x480-16" \
    "video_mode_pda7=Unknown-1:800x480-16" \
    "video_mode_pda7b=Unknown-1:800x480-16" \
    "at91_set_display=test -n \$pda && setenv display \$pda" \
    "pda4300test=test -n \$display && test \$display = 4300 && setenv display_var 'pda4' && setenv video_mode \${video_mode_pda4}" \
    "pda4301test=test -n \$display && test \$display = 4301 && setenv display_var 'pda4' && setenv video_mode \${video_mode_pda4}" \
    "pda4301btest=test -n \$display && test \$display = 4301B && setenv display_var 'pda4' && setenv video_mode \${video_mode_pda4}" \
    "pda5000test=test -n \$display && test \$display = 5000 && setenv display_var 'pda5' && setenv video_mode \${video_mode_pda5}" \
    "pda7000test=test -n \$display && test \$display = 7000 && setenv display_var 'pda7' && setenv video_mode \${video_mode_pda7}" \
    "pda7000btest=test -n \$display && test \$display = 7000B && setenv display_var 'pda7b' && setenv video_mode \${video_mode_pda7b}" \
    "at91_pda_detect=run pda4300test; run pda7000test; run pda7000btest; run pda5000test; run pda4301test; run pda4301btest;" \
    "at91_prepare_video_bootargs=test -n \$display_var && setenv at91_video_bootargs video=\${video_mode}" \
    "at91_prepare_bootargs=test -n \$display_var && setenv bootargs \${bootargs} \${at91_video_bootargs}" \
    "at91_prepare_overlays_config=test -n \$display_var && setenv at91_overlays_config '#'\${display_var}" \
    "bootargs=console=ttyS0,115200 mtdparts=atmel_nand:256k(bootstrap)ro,768k(uboot)ro,256k(env_redundant),256k(env),6656k(itb)ro,-(rootfs) rootfstype=ubifs ubi.mtd=5 root=ubi0:rootfs rw" \
    "bootcmd_boot=nand read 0x24000000 0x00180000 0x600000; bootm 0x24000000#kernel_dtb\${at91_overlays_config}" \
    "bootcmd=run at91_set_display; run at91_pda_detect; run at91_prepare_video_bootargs; run at91_prepare_bootargs; run at91_prepare_overlays_config; run bootcmd_boot;"

set ubootEnvFile "ubootEnvtFileNandFlash.bin"

################################################################################
proc set_uboot_env {nameOfLstOfVar} {
    upvar $nameOfLstOfVar lstOfVar
    set sectorSize [expr 0x20000 - 5]
    set strEnv [join $lstOfVar "\0"]
    while {[string length $strEnv] < $sectorSize} {
        append strEnv "\0"
    }
    set strCrc [binary format i [::vfs::crc $strEnv]]
    return "$strCrc\0$strEnv"
}

################################################################################
puts "-I- === Initialize the NAND access ==="
NANDFLASH::Init

puts "-I- === Enable PMECC OS Parameters ==="
NANDFLASH::NandHeaderValue HEADER $pmeccConfig

if {$build_uboot_env == "yes"} {
    puts "-I- === Load the u-boot environment variables ==="
    set fh [open "$ubootEnvFile" w]
    fconfigure $fh -translation binary
    puts -nonewline $fh [set_uboot_env u_boot_variables]
    close $fh
    send_file {NandFlash} "$ubootEnvFile" $ubootEnvAddr 0
}

puts "-I- === DONE. ==="
