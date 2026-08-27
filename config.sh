#!/bin/bash
# 1_config.sh — SAMA5D3 maXTouch kernel config script

cd "$(dirname "$0")"

# 1. 툴체인 및 환경변수 설정
export PATH=$PATH:/opt/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

echo "=== Applying sama5_defconfig ==="
make sama5_defconfig

echo "=== Updating Kconfig Options ==="
# Touchscreen
scripts/config --enable CONFIG_TOUCHSCREEN_ATMEL_MXT
scripts/config --enable CONFIG_TOUCHSCREEN_ATMEL_MXT_T37

# Wireless & Firmware
scripts/config --set-val CONFIG_CFG80211 y
scripts/config --set-val CONFIG_MAC80211 y
scripts/config --disable CONFIG_CFG80211_REQUIRE_SIGNED_REGDB
scripts/config --disable CONFIG_CFG80211_CRDA_SUPPORT
scripts/config --set-val CONFIG_MT7601U y
scripts/config --set-str CONFIG_EXTRA_FIRMWARE "mt7601u.bin regulatory.db regulatory.db.p7s"
scripts/config --set-str CONFIG_EXTRA_FIRMWARE_DIR firmware

echo "=== Resolving dependencies (olddefconfig) ==="
make olddefconfig

echo "=== Configuration complete! You can check .config file. ==="
