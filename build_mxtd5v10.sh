#!/bin/bash
# build_mxtd5v10.sh — SAMA5D3 maXTouch kernel 4.19 + driver v5.10.266 build script
# Compiler: arm-linux-gnueabihf- (Ubuntu 16.04 system gcc 5.4)
# Output: ~/at91/build/sama5d3_xplained.itb
# Kernel: 4.19.0-v4.19-mxtd5.10_YYMMDD.HHMM
#
# Usage:
#   cd ~/at91/kernel/maXTouch_linux
#   git checkout feat/mxt-driver-5v10
#   bash ~/at91/kernel/maXTouch_linux/build.sh
#
# Or copy this script to ~/at91/kernel/maXTouch_linux/build.sh when on feat branch.
#
# Driver source: https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
#                /plain/drivers/input/touchscreen/atmel_mxt_ts.c?h=v5.10.266

cd "$(dirname "$0")"

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

BUILD_DIR=${HOME}/at91/build
mkdir -p ${BUILD_DIR}

BUILD_NUM=$(date +%y%m%d.%H%M)

# Apply v5.10.266 driver
echo "=== Applying kernel.org v5.10.266 driver ==="
KERNEL_DIR=${HOME}/at91/kernel/maXTouch_linux
cp drivers/input/touchscreen/atmel_mxt_ts_5v10.c \
   ${KERNEL_DIR}/drivers/input/touchscreen/atmel_mxt_ts.c

cd ${KERNEL_DIR}

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

make -j$(nproc) LOCALVERSION=-v4.19-mxtd5.10_${BUILD_NUM} zImage dtbs

echo "=== Generating FIT image ==="
cp arch/arm/boot/zImage ${BUILD_DIR}/
cp arch/arm/boot/dts/at91-sama5d3_xplained.dtb ${BUILD_DIR}/
export PATH=$(pwd)/scripts/dtc:$PATH
cd ${BUILD_DIR}
/usr/bin/mkimage -f sama5d3.its sama5d3_xplained.itb
echo "=== ITB ready: ${BUILD_DIR}/sama5d3_xplained.itb ==="
echo "=== Kernel version: 4.19.0-v4.19-mxtd5.10_${BUILD_NUM} ==="
