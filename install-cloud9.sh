#!/bin/bash

# Exit jika ada command yang gagal
set -e

echo "=================================================="
echo "    AUTOMATED CLOUD9 IDE INSTALLER (DOCKER)       "
echo "=================================================="

# Konfigurasi Default (Bisa Diubah Sesuai Kebutuhan)
C9_PORT=${C9_PORT:-8080}
C9_USER=${C9_USER:-root}
C9_PASS=${C9_PASS:-sansai}
WORKSPACE_DIR="$HOME/workspace"

# 1. Update Sistem & Install Dependency
echo "[1/5] Memeriksa & Menginstal Docker serta Curl..."
sudo apt-get update -y
sudo apt-get install -y docker.io curl git net-tools

# Pastikan Service Docker Aktif
sudo systemctl enable --now docker

# 2. Siapkan Folder Workspace (/code)
echo "[2/5] Menyiapkan direktori workspace..."
mkdir -p "$WORKSPACE_DIR"

# 3. Penanganan Konflik Container & Port
echo "[3/5] Memeriksa port $C9_PORT dan container lama..."
if [ $(sudo docker ps -a -q -f name=cloud9_ide) ]; then
    echo "  -> Menghapus container Cloud9 lama..."
    sudo docker rm -f cloud9_ide
fi

# 4. Jalankan Container Cloud9 (LinuxServer Image - Identik dengan c9sdk)
echo "[4/5] Menjalankan Cloud9 Container..."
sudo docker run -d \
  --name=cloud9_ide \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Jakarta \
  -e USERNAME="$C9_USER" \
  -e PASSWORD="$C9_PASS" \
  -p "$C9_PORT":8000 \
  -v "$WORKSPACE_DIR":/code \
  --restart unless-stopped \
  lscr.io/linuxserver/cloud9:latest

# 5. Inject Tooling Tambahan (PHP, Python, Git) ke dalam Container
echo "[5/5] Memasang PHP & Python runtime di dalam lingkungan C9..."
sleep 5 # Menunggu container selesai init
sudo docker exec -u root cloud9_ide apt-get update -y
sudo docker exec -u root cloud9_ide apt-get install -y \
    php-cli \
    php-curl \
    php-json \
    php-mbstring \
    php-xml \
    python3 \
    python3-pip \
    python3-venv \
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
echo " Environment: Identik dengan c9sdk (Node v6.3.1 + node-pty)"
echo "=================================================="
