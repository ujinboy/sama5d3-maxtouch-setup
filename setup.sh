#!/bin/bash
# setup.sh — SAMA5D3 maXTouch 개발환경 전체 자동 셋업
# WSL Ubuntu에서 실행: bash setup.sh
# 전제: WSL Ubuntu 설치됨, 인터넷 연결됨

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KERNEL_DIR=/root/maxtouch_linux
BUILD_DIR=/root/build
TOOLCHAIN_DIR=/opt/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf

echo "=== [1/6] Installing packages ==="
apt update -qq
apt install -y -qq build-essential bc flex bison libssl-dev u-boot-tools curl git

echo "=== [2/6] Installing Linaro 7.5 toolchain ==="
if [ ! -d "$TOOLCHAIN_DIR" ]; then
    cd /opt
    curl -sL https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz -o toolchain.tar.xz
    tar xf toolchain.tar.xz
    rm toolchain.tar.xz
    echo "Toolchain installed: $TOOLCHAIN_DIR"
else
    echo "Toolchain already exists"
fi

echo "=== [3/6] Cloning maXTouch_linux ==="
if [ ! -d "$KERNEL_DIR" ]; then
    git clone https://github.com/atmel-maxtouch/maXTouch_linux.git "$KERNEL_DIR"
else
    echo "Kernel source already exists: $KERNEL_DIR"
fi

echo "=== [4/6] Applying build fixes ==="
cd "$KERNEL_DIR"

# dtc-lexer.l yylloc fix
if grep -q '^YYLTYPE yylloc;' scripts/dtc/dtc-lexer.l; then
    sed -i 's/^YYLTYPE yylloc;/extern YYLTYPE yylloc;/' scripts/dtc/dtc-lexer.l
    echo "Fixed: dtc-lexer.l yylloc"
else
    echo "OK: dtc-lexer.l already fixed"
fi

# Firmware files
mkdir -p firmware
for f in mt7601u.bin regulatory.db regulatory.db.p7s; do
    if [ -f "$SCRIPT_DIR/$f" ]; then
        cp "$SCRIPT_DIR/$f" firmware/
    fi
done

if [ ! -f firmware/mt7601u.bin ]; then
    curl -sL https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/mediatek/mt7601u.bin -o firmware/mt7601u.bin
fi
if [ ! -f firmware/regulatory.db ]; then
    curl -sL https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/plain/regulatory.db -o firmware/regulatory.db
    curl -sL https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/plain/regulatory.db.p7s -o firmware/regulatory.db.p7s
fi
echo "Firmware files ready"

echo "=== [5/6] Installing scripts ==="
# build.sh
cp "$SCRIPT_DIR/build.sh" "$KERNEL_DIR/build.sh"
chmod +x "$KERNEL_DIR/build.sh"

# deploy.sh
cp "$SCRIPT_DIR/deploy.sh" "$KERNEL_DIR/deploy.sh"
chmod +x "$KERNEL_DIR/deploy.sh"

# ITS file
mkdir -p "$BUILD_DIR"
cp "$SCRIPT_DIR/sama5d3.its" "$BUILD_DIR/sama5d3.its"

echo "=== [6/6] Verify ==="
echo "Kernel source: $KERNEL_DIR"
echo "Build output:  $BUILD_DIR"
echo "Toolchain:     $TOOLCHAIN_DIR"
echo ""
echo "Next steps:"
echo "  1. Build kernel:    cd $KERNEL_DIR && ./build.sh"
echo "  2. Flash ITB:       kernel_update.bat (Windows, SAM-BA mode)"
echo "  3. Deploy driver:   cd $KERNEL_DIR && ./deploy.sh 192.168.50.25"
echo ""
echo "=== Setup complete ==="
