#!/bin/bash
# setup_wsl_compiler.sh — WSL Ubuntu 24.04에서 arm-linux-gnueabihf GCC 5.4 설치
# VirtualBox (10.161.41.37, mxt/m@xtouch)에서 복사
# 실행: sudo bash setup_wsl_compiler.sh [vbox_ip]
#
# 사용법:
#   sudo bash setup_wsl_compiler.sh               # 기본 IP: 10.161.41.37
#   sudo bash setup_wsl_compiler.sh 192.168.0.13  # 다른 IP

set -e

VBOX_IP=${1:-10.161.41.37}
VBOX_USER=mxt
VBOX_PASS=m@xtouch
VBOX_HOSTKEY="SHA256:5/xqPV2d8B6A/EnZ7bHxPrTwf8IhtjwZ4JM/w30KK7E"
PKG_PATH=/tmp/arm-gcc54.tar.gz

echo "=== [1/3] Packaging GCC 5.4 from VirtualBox ($VBOX_IP) ==="

# plink로 VirtualBox에서 패키징
if ! command -v plink.exe &>/dev/null && ! command -v sshpass &>/dev/null; then
    echo "Installing sshpass..."
    apt-get install -y -qq sshpass
fi

# VirtualBox에서 tar 생성
sshpass -p "${VBOX_PASS}" ssh -o StrictHostKeyChecking=no ${VBOX_USER}@${VBOX_IP} \
    "echo ${VBOX_PASS} | sudo -S tar czf ${PKG_PATH} \
        /usr/bin/arm-linux-gnueabihf-* \
        /usr/lib/gcc-cross \
        /usr/lib/gcc/arm-linux-gnueabihf \
        /usr/arm-linux-gnueabihf \
        /usr/lib/x86_64-linux-gnu/libisl.so.15* \
        2>/dev/null; echo done"

echo "=== [2/3] Copying package to WSL ==="
sshpass -p "${VBOX_PASS}" scp -o StrictHostKeyChecking=no \
    ${VBOX_USER}@${VBOX_IP}:${PKG_PATH} /tmp/arm-gcc54.tar.gz

echo "Package size: $(ls -lh /tmp/arm-gcc54.tar.gz | awk '{print $5}')"

echo "=== [3/3] Installing GCC 5.4 in WSL ==="
cd /
tar xzf /tmp/arm-gcc54.tar.gz

# libisl.so.15 symlink 확인
if [ ! -f /usr/lib/x86_64-linux-gnu/libisl.so.15 ]; then
    ln -sf libisl.so.15.1.1 /usr/lib/x86_64-linux-gnu/libisl.so.15
fi

# 확인
echo ""
echo "=== Verify ==="
arm-linux-gnueabihf-gcc --version | head -1
echo "libisl: $(ls /usr/lib/x86_64-linux-gnu/libisl.so.15)"
echo ""
echo "=== Done ==="
