## Kernel-only update for SAMA5D3 Xplained (6.1 base)
## Replaces ITB (FIT image) in NAND with new build from WSL

set itbFile "sama5d3_xplained-wsl.itb"

## NandFlash addresses
set itbAddr 0x00180000

## ECC config
set pmeccConfig 0xc0902405

## Start
puts "-I- === Initialize the NAND access ==="
NANDFLASH::Init

puts "-I- === Enable PMECC OS Parameters ==="
NANDFLASH::NandHeaderValue HEADER $pmeccConfig

puts "-I- === Erase and load FIT image (kernel + dtb) ==="
send_file {NandFlash} "$itbFile" $itbAddr 0

puts "-I- === DONE. ==="
