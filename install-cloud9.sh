#!/bin/bash
# ==============================================================================
# Cloud9 IDE + PHP 8.3 Auto Installer
# Base Image  : lscr.io/linuxserver/cloud9:latest (Ubuntu 24.04 LTS Noble)
# ==============================================================================

set -e

# Warna untuk output terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}    AUTOMATED CLOUD9 IDE INSTALLER (PHP 8.3)      ${NC}"
echo -e "${BLUE}==================================================${NC}"

C9_PORT=${C9_PORT:-8080}
C9_USER=${C9_USER:-root}
C9_PASS=${C9_PASS:-sansai}
WORKSPACE_DIR="$HOME/workspace"

echo -e "\n${GREEN}[1/5] Memeriksa & Menginstal Dependency Host...${NC}"
sudo apt-get update -y
sudo apt-get install -y docker.io curl git net-tools
sudo systemctl enable --now docker

echo -e "\n${GREEN}[2/5] Menyiapkan Direktori Workspace...${NC}"
mkdir -p "$WORKSPACE_DIR"

echo -e "\n${GREEN}[3/5] Memeriksa & Menghapus Container Cloud9 Lama...${NC}"
if [ "$(sudo docker ps -a -q -f name=cloud9)" ]; then
    echo "  -> Menghapus container Cloud9 lama..."
    sudo docker rm -f cloud9
fi

echo -e "\n${GREEN}[4/5] Menjalankan Container Cloud9 (Latest Ubuntu)...${NC}"
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

echo -e "\n${GREEN}[5/5] Menginstal PHP 8.3 & Composer ke Dalam Container...${NC}"
echo "Menunggu container siap (5 detik)..."
sleep 5

# Update & Tambah PPA Ondrej PHP
sudo docker exec -u root cloud9 apt-get update -y
sudo docker exec -u root cloud9 apt-get install -y software-properties-common wget nano curl git unzip
sudo docker exec -u root cloud9 add-apt-repository ppa:ondrej/php -y
sudo docker exec -u root cloud9 apt-get update -y

# Instalasi PHP 8.3 dan ekstensi umum
sudo docker exec -u root cloud9 apt-get install -y \
    php8.3-cli \
    php8.3-curl \
    php8.3-mbstring \
    php8.3-xml \
    php8.3-zip \
    php8.3-mysql \
    php8.3-gd \
    php8.3-sqlite3 \
    php8.3-bcmath

# Set PHP 8.3 sebagai CLI bawaan
sudo docker exec -u root cloud9 update-alternatives --set php /usr/bin/php8.3

# Install Composer
sudo docker exec -u root cloud9 bash -c "curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer"

# Mendapatkan Public IP
PUBLIC_IP=$(curl -s ifconfig.me || curl -s api.ipify.org || echo "IP-VPS-ANDA")

echo ""
echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}   INSTALASI CLOUD9 BERHASIL & SIAP DIGUNAKAN!    ${NC}"
echo -e "${GREEN}==================================================${NC}"
echo " URL Akses : http://${PUBLIC_IP}:${C9_PORT}"
echo " Username  : ${C9_USER}"
echo " Password  : ${C9_PASS}"
echo " Workspace : /code (terhubung ke $WORKSPACE_DIR)"
echo " Runtime   : PHP 8.3 & Composer"
echo -e "${GREEN}==================================================${NC}"
