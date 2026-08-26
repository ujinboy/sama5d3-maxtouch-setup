#!/bin/bash
# build_vbox.sh — SAMA5D3 maXTouch kernel 4.19 build script (VirtualBox Ubuntu 16.04)
# Compiler: arm-linux-gnueabihf- (GCC 5.4, /usr/bin/)
# Output: ~/at91/build/sama5d3_xplained.itb

cd "$(dirname "$0")"

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

BUILD_DIR=${HOME}/at91/build
mkdir -p ${BUILD_DIR}

BUILD_NUM=$(date +%y%m%d.%H%M)

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
/usr/bin/mkimage -f sama5d3.its sama5d3_xplained.itb
echo "=== ITB ready: ${BUILD_DIR}/sama5d3_xplained.itb ==="
echo "=== Kernel version: 4.19.0-v4.19_${BUILD_NUM} ==="
