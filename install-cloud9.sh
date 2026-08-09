#!/bin/bash

# Exit jika terjadi error
set -e

echo "=================================================="
echo "      AUTOMATED CLOUD9 IDE INSTALLER              "
echo "=================================================="

# 1. Update sistem dan install Docker
echo "[1/4] Memeriksa dan menginstal Docker..."
sudo apt-get update -y
sudo apt-get install -y docker.io curl git

# Pastikan Docker berjalan
sudo systemctl enable --now docker

# 2. Buat direktori kerja proyek (/code)
echo "[2/4] Menyiapkan direktori workspace..."
WORKSPACE_DIR="$HOME/workspace"
mkdir -p "$WORKSPACE_DIR"

# 3. Hentikan container lama jika ada
if [ $(sudo docker ps -a -q -f name=cloud9) ]; then
    echo "Menghapus container Cloud9 lama..."
    sudo docker rm -f cloud9
fi

# 4. Jalankan Container Cloud9
echo "[3/4] Menjalankan Cloud9 IDE Container..."
sudo docker run -d \
  --name=cloud9 \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Jakarta \
  -e USERNAME=root \
  -e PASSWORD=sansai \
  -p 8080:8000 \
  -v "$WORKSPACE_DIR":/code \
  --restart unless-stopped \
  lscr.io/linuxserver/cloud9:latest

# 5. Pasang dependensi PHP & Python di dalam container
echo "[4/4] Menginstal PHP & Python runtime di dalam Cloud9..."
sleep 5 # Tunggu container siap
sudo docker exec -u root cloud9 apt-get update -y
sudo docker exec -u root cloud9 apt-get install -y php-cli php-curl php-json python3 python3-pip

# Ambil IP Public VPS
PUBLIC_IP=$(curl -s ifconfig.me || echo "IP-VPS-ANDA")

echo "=================================================="
echo "   INSTALASI CLOUD9 BERHASIL DIPASANG!            "
echo "=================================================="
echo " URL Akses : http://${PUBLIC_IP}:8080"
echo " Username  : root"
echo " Password  : sansai"
echo " Workspace : /code (terhubung ke $WORKSPACE_DIR)"
echo "=================================================="
