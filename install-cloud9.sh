#!/bin/bash

# Exit jika ada command yang gagal
set -e

echo "=================================================="
echo "    AUTOMATED CLOUD9 IDE INSTALLER (DOCKER)       "
echo "=================================================="

# Konfigurasi Default
C9_PORT=${C9_PORT:-8080}
C9_USER=${C9_USER:-root}
C9_PASS=${C9_PASS:-sansai}
WORKSPACE_DIR="$HOME/workspace"

# 1. Update Sistem & Install Dependency
echo "[1/5] Memeriksa & Menginstal Docker..."
sudo apt-get update -y
sudo apt-get install -y docker.io curl git net-tools

# Pastikan Service Docker Aktif
sudo systemctl enable --now docker

# 2. Siapkan Folder Workspace (/code)
echo "[2/5] Menyiapkan direktori workspace..."
mkdir -p "$WORKSPACE_DIR"

# 3. Penanganan Konflik Container & Port
echo "[3/5] Memeriksa container lama..."
if [ $(sudo docker ps -a -q -f name=cloud9) ]; then
    echo "  -> Menghapus container Cloud9 lama..."
    sudo docker rm -f cloud9
fi

# 4. Jalankan Container Cloud9 (Sama Persis dengan Environment C9 Asli)
echo "[4/5] Menjalankan Cloud9 Container..."
sudo docker run -d \
  --name=cloud9 \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Jakarta \
  -e USERNAME="$C9_USER" \
  -e PASSWORD="$C9_PASS" \
  -p "$C9_PORT":8000 \
  -v "$WORKSPACE_DIR":/code \
  --restart unless-stopped \
  lscr.io/linuxserver/cloud9:latest

# 5. Inject Tooling Tambahan (PHP 8.1 & Python 3) ke dalam Container
echo "[5/5] Memasang PHP 8.1 & Python runtime di dalam lingkungan C9..."
sleep 5 # Menunggu container selesai inisialisasi

# Update repo & install paket pendukung PPA
sudo docker exec -u root cloud9 apt-get update -y
sudo docker exec -u root cloud9 apt-get install -y software-properties-common wget nano python3 python3-pip python3-venv

# Tambahkan PPA Ondrej untuk PHP 8.1
sudo docker exec -u root cloud9 add-apt-repository ppa:ondrej/php -y
sudo docker exec -u root cloud9 apt-get update -y

# Install PHP 8.1 beserta ekstensi penting
sudo docker exec -u root cloud9 apt-get install -y \
    php8.1-cli \
    php8.1-curl \
    php8.1-mbstring \
    php8.1-xml \
    php8.1-zip \
    php8.1-mysql

# Set PHP 8.1 sebagai default
sudo docker exec -u root cloud9 update-alternatives --set php /usr/bin/php8.1

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
echo " Runtime   : PHP 8.1 + Node v6.3.1 + Python 3"
echo "=================================================="
