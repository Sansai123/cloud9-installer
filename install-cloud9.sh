#!/bin/bash

# Exit jika ada command yang gagal
set -e

echo "=================================================="
echo "    AUTOMATED CLOUD9 IDE INSTALLER (PHP 8.1)      "
echo "=================================================="

# Konfigurasi Default
C9_PORT=${C9_PORT:-8080}
C9_USER=${C9_USER:-root}
C9_PASS=${C9_PASS:-sansai}
WORKSPACE_DIR="$HOME/workspace"

# 1. Update Sistem & Install Docker
echo "[1/4] Memeriksa & Menginstal Docker..."
sudo apt-get update -y
sudo apt-get install -y docker.io curl git net-tools
sudo systemctl enable --now docker

# 2. Siapkan Folder Workspace
echo "[2/4] Menyiapkan direktori workspace..."
mkdir -p "$WORKSPACE_DIR"

# 3. Bersihkan Container Lama
echo "[3/4] Memeriksa container lama..."
if [ $(sudo docker ps -a -q -f name=cloud9) ]; then
    echo "  -> Menghapus container Cloud9 lama..."
    sudo docker rm -f cloud9
fi

# 4. Jalankan Cloud9 Container (Base Ubuntu 22.04 Native)
echo "[4/4] Menjalankan Cloud9 IDE Container..."
sudo docker run -d \
  --name=cloud9 \
  -e PUID=0 \
  -e PGID=0 \
  -e TZ=Asia/Jakarta \
  -e USERNAME="$C9_USER" \
  -e PASSWORD="$C9_PASS" \
  -p "$C9_PORT":8000 \
  -v "$WORKSPACE_DIR":/code \
  --restart unless-stopped \
  sapras/cloud9:latest

# Memasang PHP 8.1 (Tanpa MySQL) & Python di Dalam Container
sleep 5
sudo docker exec -u root cloud9 apt-get update -y
sudo docker exec -u root cloud9 apt-get install -y \
    php8.1 \
    php8.1-cli \
    php8.1-curl \
    php8.1-mbstring \
    php8.1-xml \
    php8.1-zip \
    python3 \
    python3-pip \
    wget \
    nano

# Ambil IP Public VPS
PUBLIC_IP=$(curl -s ifconfig.me || curl -s api.ipify.org || echo "IP-VPS-ANDA")

echo ""
echo "=================================================="
echo "   INSTALASI CLOUD9 BERHASIL & SIAP DIGUNAKAN!    "
echo "=================================================="
echo " URL Akses : http://${PUBLIC_IP}:${C9_PORT}"
echo " Username  : ${C9_USER}"
echo " Password  : ${C9_PASS}"
echo " Workspace : /code (terhubung ke $WORKSPACE_DIR)"
echo " Runtime   : PHP 8.1 (Tanpa MySQL) + Python 3"
echo "=================================================="
