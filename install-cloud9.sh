#!/bin/bash
set -e

# =================================================
# KELOLA AKSES LOGIN DI SINI
# =================================================
C9_USER="root"
C9_PASS="sansai"
C9_PORT="8080"
WORKSPACE_DIR="$HOME/workspace"

echo "================================================="
echo "🚀 Cloud9 SDK + PHP 8.3 Auto-Installer (Ubuntu 24.04)"
echo "================================================="

# 1. Update & Install Tools Dasar
sudo apt update -y
sudo apt install -y build-essential g++ make git curl wget software-properties-common

# 2. Pasang Kompatibilitas Python 2.7 Khusus Ubuntu 24.04
if ! command -v python2.7 &> /dev/null; then
  echo "[1/5] Mengunduh dependensi Python 2.7..."
  TMP_DIR=$(mktemp -d)
  cd $TMP_DIR
  wget -q http://archive.ubuntu.com/ubuntu/pool/universe/p/python2.7/libpython2.7-minimal_2.7.18-13ubuntu1.2_amd64.deb || true
  wget -q http://archive.ubuntu.com/ubuntu/pool/universe/p/python2.7/python2.7-minimal_2.7.18-13ubuntu1.2_amd64.deb || true
  wget -q http://archive.ubuntu.com/ubuntu/pool/universe/p/python2.7/libpython2.7-stdlib_2.7.18-13ubuntu1.2_amd64.deb || true
  wget -q http://archive.ubuntu.com/ubuntu/pool/universe/p/python2.7/python2.7_2.7.18-13ubuntu1.2_amd64.deb || true
  sudo dpkg -i *.deb || sudo apt-get install -f -y
  cd ~
  rm -rf $TMP_DIR
fi

# Link sementara perintah 'python' ke python2.7
sudo ln -sf /usr/bin/python2.7 /usr/bin/python

# 3. Install PHP 8.3
echo "[2/5] Menginstal PHP 8.3..."
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y
sudo apt install -y php8.3 php8.3-cli php8.3-curl php8.3-mbstring php8.3-xml php8.3-zip php8.3-gd php8.3-mysql

# 4. Install Node.js 18
echo "[3/5] Menginstal Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# 5. Clone & Install Cloud9 SDK
echo "[4/5] Memasang Cloud9 SDK..."
if [ ! -d "$HOME/cloud9" ]; then
  git clone https://github.com/c9/core.git $HOME/cloud9
fi

cd $HOME/cloud9
PYTHON=/usr/bin/python2.7 ./scripts/install-sdk.sh

mkdir -p "$WORKSPACE_DIR"

# Kembalikan symlink python utama ke Python 3 demi kestabilan sistem
if [ -f /usr/bin/python3 ]; then
  sudo ln -sf /usr/bin/python3 /usr/bin/python
fi

# 6. Pasang Service Autostart (Systemd)
echo "[5/5] Membuat Service Cloud9..."
sudo bash -c "cat <<SERVICE > /etc/systemd/system/cloud9.service
[Unit]
Description=Cloud9 IDE Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/cloud9
ExecStart=/usr/bin/node $HOME/cloud9/server.js -p $C9_PORT -a $C9_USER:$C9_PASS -w $WORKSPACE_DIR
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE"

sudo systemctl daemon-reload
sudo systemctl enable cloud9
sudo systemctl restart cloud9

echo "================================================="
echo "✅ Instalasi Selesai!"
echo "Akses URL : http://<IP-VPS-Anda>:$C9_PORT"
echo "Username  : $C9_USER"
echo "Password  : $C9_PASS"
echo "================================================="
