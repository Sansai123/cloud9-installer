# 1. Unduh dan update script lokal secara otomatis
cat << 'EOF' > install-cloud9.sh
#!/bin/bash
set -e

echo "=================================================="
echo "    AUTOMATED CLOUD9 IDE INSTALLER (PHP 8.1)      "
echo "=================================================="

C9_PORT=${C9_PORT:-8080}
C9_USER=${C9_USER:-root}
C9_PASS=${C9_PASS:-sansai}
WORKSPACE_DIR="$HOME/workspace"

echo "[1/4] Memeriksa & Menginstal Docker..."
sudo apt-get update -y
sudo apt-get install -y docker.io curl git net-tools
sudo systemctl enable --now docker

echo "[2/4] Menyiapkan direktori workspace..."
mkdir -p "$WORKSPACE_DIR"

echo "[3/4] Memeriksa container lama..."
if [ $(sudo docker ps -a -q -f name=cloud9) ]; then
    echo "  -> Menghapus container Cloud9 lama..."
    sudo docker rm -f cloud9
fi

echo "[4/4] Menjalankan Cloud9 IDE Container..."
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

echo "[5/5] Injecting PHP 8.1 ke dalam Container..."
sleep 5
sudo docker exec -u root cloud9 apt-get update -y
sudo docker exec -u root cloud9 apt-get install -y software-properties-common wget nano python3 python3-pip

# Gunakan mirror PPA Ondrej untuk Ubuntu Bionic di dalam container
sudo docker exec -u root cloud9 bash -c "echo 'deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main' > /etc/apt/sources.list.d/ondrej-php.list"
sudo docker exec -u root cloud9 bash -c "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C 14AA902398F442F1" || true
sudo docker exec -u root cloud9 apt-get update -y

# Install PHP 8.1 tanpa MySQL
sudo docker exec -u root cloud9 apt-get install -y --allow-unauthenticated \
    php8.1-cli \
    php8.1-curl \
    php8.1-mbstring \
    php8.1-xml \
    php8.1-zip

# Set default CLI ke PHP 8.1
sudo docker exec -u root cloud9 update-alternatives --set php /usr/bin/php8.1

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
EOF

# 2. Jalankan skrip perbaikan
bash install-cloud9.sh
