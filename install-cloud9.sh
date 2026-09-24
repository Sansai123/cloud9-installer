#!/bin/bash
# ==============================================================================
# Cloud9 IDE + PHP Automated Installer (Stable Native Repo)
# ==============================================================================

set -eo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}    AUTOMATED CLOUD9 IDE INSTALLER (PHP)          ${NC}"
echo -e "${BLUE}==================================================${NC}"

C9_PORT="${C9_PORT:-8080}"
C9_USER="${C9_USER:-root}"
C9_PASS="${C9_PASS:-sansai}"
WORKSPACE_DIR="${WORKSPACE_DIR:-$HOME/workspace}"

if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

echo -e "\n${GREEN}[1/5] Memeriksa & Menginstal Dependency Host...${NC}"
$SUDO apt-get update -y
$SUDO apt-get install -y docker.io curl git net-tools
$SUDO systemctl enable --now docker

echo -e "\n${GREEN}[2/5] Menyiapkan Direktori Workspace...${NC}"
mkdir -p "$WORKSPACE_DIR"

echo -e "\n${GREEN}[3/5] Menghapus Container Cloud9 Lama...${NC}"
if [ "$($SUDO docker ps -a -q -f name=cloud9)" ]; then
    echo -e "${YELLOW}  -> Menghapus container lama...${NC}"
    $SUDO docker rm -f cloud9
fi

echo -e "\n${GREEN}[4/5] Menjalankan Container Cloud9...${NC}"
$SUDO docker run -d \
  --name=cloud9 \
  -e PUID=$(id -u) \
  -e PGID=$(id -g) \
  -e TZ=Asia/Jakarta \
  -e USERNAME="$C9_USER" \
  -e PASSWORD="$C9_PASS" \
  -p "$C9_PORT":8000 \
  -v "$WORKSPACE_DIR":/code \
  --restart unless-stopped \
  lscr.io/linuxserver/cloud9:latest

echo -e "\n${GREEN}[5/5] Menginstal PHP & Composer ke Dalam Container...${NC}"
echo "Menunggu container inisialisasi (8 detik)..."
sleep 8

# Menggunakan PHP bawaan dari repository resmi Ubuntu (stabil & tanpa error PPA)
$SUDO docker exec -u root cloud9 bash -c "
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y && \
    apt-get install -y wget nano curl git unzip php php-cli php-curl php-mbstring php-xml php-zip php-mysql php-gd php-sqlite3 php-bcmath && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
"

PUBLIC_IP=$(curl -s --max-time 5 ifconfig.me || curl -s --max-time 5 api.ipify.org || echo "IP-VPS-ANDA")

echo ""
echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}   INSTALASI CLOUD9 BERHASIL & SIAP DIGUNAKAN!    ${NC}"
echo -e "${GREEN}==================================================${NC}"
echo -e " URL Akses : ${BLUE}http://${PUBLIC_IP}:${C9_PORT}${NC}"
echo -e " Username  : ${YELLOW}${C9_USER}${NC}"
echo -e " Password  : ${YELLOW}${C9_PASS}${NC}"
echo -e " Workspace : /code (terhubung ke $WORKSPACE_DIR)"
echo -e "${GREEN}==================================================${NC}"
