# SAMA5D3 maXTouch Setup

SAMA5D3 Xplained + maXTouch Linux driver 개발환경 자동 셋업.

## Quick Start (WSL Ubuntu)

```bash
git clone https://github.com/ujinboy/sama5d3-maxtouch-setup.git
cd sama5d3-maxtouch-setup
sudo bash setup.sh
```

## 이후 사용

```bash
# 커널 전체 빌드
cd /root/maxtouch_linux
./build.sh

# 드라이버만 빌드 + 보드 배포
./deploy.sh 192.168.50.25
```

## 파일 구성

| 파일 | 용도 |
|------|------|
| setup.sh | 전체 환경 셋업 (toolchain + 소스 + fix + firmware) |
| build.sh | 커널 빌드 → ITB 생성 |
| deploy.sh | 드라이버 빌드 → SCP → insmod |
| fix_build_errors.sh | 빌드 에러 수정 (yylloc + firmware) |
| sama5d3.its | FIT image descriptor |
| mt7601u.bin | MT7601U Wi-Fi firmware |
| regulatory.db / .p7s | Wi-Fi regulatory database |

## HW 요구사항

- SAMA5D3 Xplained (NAND 256MB)
- maXTouch 디바이스 (I2C0, CHG=PE13, RST=PE14)
- MT7601U USB Wi-Fi 동글
- SAM-BA 2.18 (Windows, NAND 플래시용)

## NAND 플래시

SAM-BA 모드: JP5 열고 → 리셋 → JP5 닫기

- 전체 플래시: `demo_linux_nandflash_tcl.bat`
- 커널만: `kernel_update.bat`
- env만: `env_update.bat`

## rootfs 초기 설정 (전체 플래시 후 1회)

```bash
rm -f /etc/rc5.d/*hostapd*
cat > /etc/wpa_supplicant.conf << 'EOF'
ctrl_interface=/run/wpa_supplicant
update_config=1
country=KR

network={
    ssid="YOUR_SSID"
    psk="YOUR_PSK"
}
EOF
cat > /etc/init.d/S99wifi << 'EOF'
#!/bin/sh
ip link set wlan0 up
wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant.conf
sleep 3
udhcpc -b -i wlan0
EOF
chmod +x /etc/init.d/S99wifi
ln -sf /etc/init.d/S99wifi /etc/rc5.d/S99wifi
sync && reboot
```
