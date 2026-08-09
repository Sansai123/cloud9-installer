cat << 'EOF' > install-cloud9.sh
#!/bin/bash
set -e

echo "=================================================="
echo "    AUTOMATED CLOUD9 IDE INSTALLER (PHP 8.3)      "
echo "  Base OS Container: Ubuntu 24.04 LTS (Noble)     "
echo "=================================================="

C9_PORT=${C9_PORT:-8080}
C9_USER=${C9_USER:-root}
C9_PASS=${C9_PASS:-sansai}
WORKSPACE_DIR="$HOME/workspace"

echo "[1/5] Memeriksa & Menginstal Docker..."
sudo apt-get update -y
sudo apt-get install -y docker.io curl git net-tools
sudo systemctl enable --now docker

echo "[2/5] Menyiapkan direktori workspace..."
mkdir -p "$WORKSPACE_DIR"

echo "[3/5] Memeriksa container lama..."
if [ $(sudo docker ps -a -q -f name=cloud9) ]; then
    echo "  -> Menghapus container Cloud9 lama..."
    sudo docker rm -f cloud9
fi

echo "[4/5] Menjalankan Cloud9 IDE Container (Ubuntu Noble)..."
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
  lscr.io/linuxserver/cloud9:ubuntu-noble

echo "[5/5] Injecting PHP 8.3 ke dalam Container..."
echo "Menunggu container siap..."
sleep 5

# Tambahkan PPA Ondrej PHP
sudo docker exec -u root cloud9 apt-get update -y
sudo docker exec -u root cloud9 apt-get install -y software-properties-common wget nano curl git
sudo docker exec -u root cloud9 add-apt-repository ppa:ondrej/php -y
sudo docker exec -u root cloud9 apt-get update -y

# Install PHP 8.3 dan ekstensi pendukung
sudo docker exec -u root cloud9 apt-get install -y \
    php8.3-cli \
    php8.3-curl \
    php8.3-mbstring \
    php8.3-xml \
    php8.3-zip \
    php8.3-mysql \
    php8.3-gd \
    php8.3-sqlite3

# Atur default CLI ke PHP 8.3
sudo docker exec -u root cloud9 update-alternatives --set php /usr/bin/php8.3

PUBLIC_IP=$(curl -s ifconfig.me || curl -s api.ipify.org || echo "IP-VPS-ANDA")

echo ""
echo "=================================================="
echo "   INSTALASI CLOUD9 BERHASIL & SIAP DIGUNAKAN!    "
echo "=================================================="
echo " URL Akses : http://${PUBLIC_IP}:${C9_PORT}"
echo " Username  : ${C9_USER}"
echo " Password  : ${C9_PASS}"
echo " Workspace : /code (terhubung ke $WORKSPACE_DIR)"
echo " Base OS   : Ubuntu 24.04 LTS (Noble)"
echo " Runtime   : PHP 8.3"
echo "=================================================="
EOF

# Eksekusi script yang baru dibuat
bash install-cloud9.sh
