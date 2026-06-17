#!/bin/bash
export ARCH=arm
export CROSS_COMPILE=/opt/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
export PATH=/opt/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin:$PATH

make clean
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
make -j$(nproc) LOCALVERSION=-wj-mxt-4.19 zImage dtbs

# Generate FIT image
echo "=== Generating FIT image ==="
mkdir -p /root/build
cp arch/arm/boot/zImage /root/build/
cp arch/arm/boot/dts/at91-sama5d3_xplained.dtb /root/build/
cd /root/build
mkimage -f sama5d3.its sama5d3_xplained.itb
echo "=== ITB ready: /root/build/sama5d3_xplained.itb ==="
