#!/bin/bash
cd "$(dirname "$0")"
export ARCH=arm
GCC13_DIR=/opt/arm-gnu-toolchain-13.2.Rel1-x86_64-arm-none-linux-gnueabihf/bin
export CROSS_COMPILE=${GCC13_DIR}/arm-none-linux-gnueabihf-
export PATH=${GCC13_DIR}:$PATH

BUILD_DIR=${HOME}/build_5v10
mkdir -p ${BUILD_DIR}

make sama5_defconfig
scripts/config --enable CONFIG_TOUCHSCREEN_ATMEL_MXT
scripts/config --enable CONFIG_TOUCHSCREEN_ATMEL_MXT_T37
scripts/config --set-val CONFIG_MT7601U y
scripts/config --set-str CONFIG_EXTRA_FIRMWARE "mt7601u.bin regulatory.db regulatory.db.p7s"
scripts/config --set-str CONFIG_EXTRA_FIRMWARE_DIR firmware
make olddefconfig

make -j$(nproc) LOCALVERSION=-mxt zImage dtbs

echo "=== Generating FIT image ==="
cp arch/arm/boot/zImage ${BUILD_DIR}/
cp arch/arm/boot/dts/at91-sama5d3_xplained.dtb ${BUILD_DIR}/
cd ${BUILD_DIR}
mkimage -f sama5d3.its sama5d3_xplained.itb
echo "=== ITB ready: ${BUILD_DIR}/sama5d3_xplained.itb ==="
