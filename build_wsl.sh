#!/bin/bash
# build_wsl.sh — SAMA5D3 maXTouch kernel 4.19 build script (WSL Ubuntu 24.04)
# Compiler: arm-linux-gnueabihf- (GCC 5.4, copied from VirtualBox)
# Output: /root/at91/build/sama5d3_xplained.itb
# Note: HOME may point to Windows path in WSL, so BUILD_DIR is hardcoded

cd "$(dirname "$0")"

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

BUILD_DIR=/root/at91/build
mkdir -p ${BUILD_DIR}

BUILD_NUM=$(date +%y%m%d.%H%M)

# Fix init/Kconfig: $(shell,...) and $(success,...) syntax not supported by
# Ubuntu 24.04 kconfig. Replace with compatible defaults.
if grep -q '$(shell,' init/Kconfig 2>/dev/null; then
    echo "=== Patching init/Kconfig for Ubuntu 24.04 kconfig compatibility ==="
    python3 - << 'PYEOF'
import re
with open('init/Kconfig', 'r') as f:
    content = f.read()
content = re.sub(r'\tdefault \$\(shell,.*?\) if CC_IS_GCC', '\tdefault 0 if CC_IS_GCC', content)
content = re.sub(r'\tdef_bool \$\(success,.*?\)', '\tdef_bool n', content)
content = re.sub(r'\tdefault \$\(shell,.*?\)', '\tdefault 0', content)
with open('init/Kconfig', 'w') as f:
    f.write(content)
print("init/Kconfig patched")
PYEOF
fi

make sama5_defconfig
scripts/config --enable CONFIG_TOUCHSCREEN_ATMEL_MXT
scripts/config --enable CONFIG_TOUCHSCREEN_ATMEL_MXT_T37
scripts/config --set-val CONFIG_CFG80211 y
scripts/config --set-val CONFIG_MAC80211 y
scripts/config --disable CONFIG_CFG80211_REQUIRE_SIGNED_REGDB
scripts/config --disable CONFIG_CFG80211_CRDA_SUPPORT
scripts/config --set-val CONFIG_MT7601U y
scripts/config --set-str CONFIG_EXTRA_FIRMWARE "mt7601u.bin regulatory.db regulatory.db.p7s"
scripts/config --set-str CONFIG_EXTRA_FIRMWARE_DIR firmware
make olddefconfig

make -j$(nproc) LOCALVERSION=-v4.19_${BUILD_NUM} zImage dtbs

echo "=== Generating FIT image ==="
cp arch/arm/boot/zImage ${BUILD_DIR}/
cp arch/arm/boot/dts/at91-sama5d3_xplained.dtb ${BUILD_DIR}/
export PATH=$(pwd)/scripts/dtc:$PATH
cd ${BUILD_DIR}
mkimage -f sama5d3.its sama5d3_xplained.itb
echo "=== ITB ready: ${BUILD_DIR}/sama5d3_xplained.itb ==="
echo "=== Kernel version: 4.19.0-v4.19_${BUILD_NUM} ==="
