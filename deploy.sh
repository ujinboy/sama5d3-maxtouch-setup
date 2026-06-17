#!/bin/bash
# deploy.sh — maXTouch 드라이버 빌드 + 보드 배포 + insmod
# 사용법: ./deploy.sh [IP]
# 예: ./deploy.sh 192.168.50.55

BOARD_IP=${1:-192.168.50.25}
BOARD_USER=root
MODULE=drivers/input/touchscreen/atmel_mxt_ts.ko
SRC_DIR=/root/maxtouch_linux

export ARCH=arm
export CROSS_COMPILE=/opt/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-

cd $SRC_DIR

# 드라이버만 빌드
echo "=== Building atmel_mxt_ts.ko ==="
make M=drivers/input/touchscreen modules
if [ $? -ne 0 ]; then
    echo "ERROR: Build failed"
    exit 1
fi

if [ ! -f "$MODULE" ]; then
    echo "ERROR: $MODULE not found"
    exit 1
fi

echo "=== Deploying to $BOARD_IP ==="
scp -o StrictHostKeyChecking=no "$MODULE" ${BOARD_USER}@${BOARD_IP}:/tmp/atmel_mxt_ts.ko
if [ $? -ne 0 ]; then
    echo "ERROR: SCP failed. Check board Wi-Fi connection."
    exit 1
fi

echo "=== Installing module on board ==="
ssh -o StrictHostKeyChecking=no ${BOARD_USER}@${BOARD_IP} "rmmod atmel_mxt_ts 2>/dev/null; insmod /tmp/atmel_mxt_ts.ko && echo 'OK: module loaded' || echo 'FAIL: insmod error'"

echo "=== Done ==="
