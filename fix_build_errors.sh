#!/bin/bash
# fix_build_errors.sh — maXTouch_linux 4.19 커널 빌드 에러 수정
# 사용법: 커널 소스 디렉토리에서 실행
#   cd /root/maxtouch_linux
#   bash /path/to/fix_build_errors.sh

echo "=== Fixing build errors for maXTouch_linux (kernel 4.19) ==="

# 1. dtc-lexer.l: yylloc 중복 정의 에러
#    에러: multiple definition of 'yylloc'
#    원인: gcc 10+ 에서 -fno-common 기본 적용
if grep -q '^YYLTYPE yylloc;' scripts/dtc/dtc-lexer.l; then
    sed -i 's/^YYLTYPE yylloc;/extern YYLTYPE yylloc;/' scripts/dtc/dtc-lexer.l
    echo "[FIXED] scripts/dtc/dtc-lexer.l: YYLTYPE yylloc → extern"
else
    echo "[OK] scripts/dtc/dtc-lexer.l: already fixed"
fi

# 2. firmware 파일 배치
#    MT7601U + regulatory.db builtin 필요
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p firmware

if [ ! -f firmware/mt7601u.bin ]; then
    if [ -f "$SCRIPT_DIR/mt7601u.bin" ]; then
        cp "$SCRIPT_DIR/mt7601u.bin" firmware/
        echo "[FIXED] firmware/mt7601u.bin: copied from Settings"
    else
        curl -sL https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/mediatek/mt7601u.bin -o firmware/mt7601u.bin
        echo "[FIXED] firmware/mt7601u.bin: downloaded"
    fi
else
    echo "[OK] firmware/mt7601u.bin: exists"
fi

if [ ! -f firmware/regulatory.db ]; then
    if [ -f "$SCRIPT_DIR/regulatory.db" ]; then
        cp "$SCRIPT_DIR/regulatory.db" "$SCRIPT_DIR/regulatory.db.p7s" firmware/
        echo "[FIXED] firmware/regulatory.db: copied from Settings"
    else
        curl -sL https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/plain/regulatory.db -o firmware/regulatory.db
        curl -sL https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/plain/regulatory.db.p7s -o firmware/regulatory.db.p7s
        echo "[FIXED] firmware/regulatory.db: downloaded"
    fi
else
    echo "[OK] firmware/regulatory.db: exists"
fi

echo "=== Done ==="
