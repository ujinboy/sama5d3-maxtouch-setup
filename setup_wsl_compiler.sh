#!/bin/bash
# setup_wsl_compiler.sh — WSL Ubuntu 24.04에서 arm-linux-gnueabihf GCC 5.4 설치
# GitHub에서 직접 다운로드 (VirtualBox 불필요)
#
# 실행: sudo bash setup_wsl_compiler.sh

set -e

REPO_URL="https://raw.githubusercontent.com/ujinboy/sama5d3-maxtouch-setup/master"
PKG_URL="${REPO_URL}/arm-gcc54.tar.gz"
PKG_LOCAL=/tmp/arm-gcc54.tar.gz

echo "=== [1/3] Downloading GCC 5.4 toolchain from GitHub ==="
curl -L "${PKG_URL}" -o "${PKG_LOCAL}" --progress-bar
echo "Package size: $(ls -lh ${PKG_LOCAL} | awk '{print $5}')"

echo "=== [2/3] Installing GCC 5.4 in WSL ==="
cd /
tar xzf ${PKG_LOCAL}

# libisl.so.15 symlink 확인
if [ -f /usr/lib/x86_64-linux-gnu/libisl.so.15.1.1 ] && \
   [ ! -L /usr/lib/x86_64-linux-gnu/libisl.so.15 ]; then
    ln -sf libisl.so.15.1.1 /usr/lib/x86_64-linux-gnu/libisl.so.15
fi

echo "=== [3/3] Verify ==="
arm-linux-gnueabihf-gcc --version | head -1
echo "libisl.so.15: $(ls -la /usr/lib/x86_64-linux-gnu/libisl.so.15)"
echo ""
echo "=== Done ==="
