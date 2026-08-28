#!/bin/bash
# build.sh — SAMA5D3 maXTouch kernel build & ITB generation script

cd "$(dirname "$0")"

# 1. 툴체인 및 환경변수 설정
export PATH=$PATH:/opt/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

BUILD_DIR=${HOME}/at91/build
mkdir -p ${BUILD_DIR}

BUILD_NUM=$(date +%y%m%d.%H%M)

echo "=== Starting Kernel & DTB Compilation ==="
make -j$(nproc) LOCALVERSION=-v4.19-mxtd5.10_${BUILD_NUM} zImage dtbs

echo "=== Generating FIT image ==="
cp arch/arm/boot/zImage ${BUILD_DIR}/
cp arch/arm/boot/dts/at91-sama5d3_xplained.dtb ${BUILD_DIR}/

export PATH=$(pwd)/scripts/dtc:$PATH

cd ${BUILD_DIR}
/usr/bin/mkimage -f sama5d3.its sama5d3_xplained.itb

echo "=== ITB ready: ${BUILD_DIR}/sama5d3_xplained.itb ==="
echo "=== Kernel version: v4.19-mxtd5.10_${BUILD_NUM} ==="
