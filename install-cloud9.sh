#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "================================================="
echo "🚀 Cloud9 SDK Native + PHP 8.3 Auto-Installer"
echo "================================================="

# 1. Update system & Install PHP 8.3 & Python3
echo "[1/5] Updating system & Installing PHP 8.3..."
sudo apt update -y
sudo apt install -y software-properties-common curl wget git build-essential python3 python-is-python3 g++ make

sudo add-apt-repository -y ppa:ondrej/php
sudo apt update -y
sudo apt install -y php8.3 php8.3-cli php8.3-curl php8.3-mbstring php8.3-xml php8.3-zip php8.3-gd php8.3-mysql
sudo update-alternatives --set php /usr/bin/php8.3

# 2. Install Node.js v18 (LTS yang stabil untuk Ubuntu 24.04)
echo "[2/5] Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# 3. Clone & Build Cloud9 SDK
echo "[3/5] Setting up Cloud9 SDK..."
rm -rf $HOME/cloud9
git clone https://github.com/c9/core.git $HOME/cloud9
cd $HOME/cloud9

echo "[4/5] Running Cloud9 SDK Installer Script..."
PYTHON=python3 scripts/install-sdk.sh

# 4. Create Systemd Service
echo "[5/5] Configuring Systemd Service..."

C9_PORT=8080
C9_USER="admin"
C9_PASS="Sansaii83#Secure"

sudo tee /etc/systemd/system/cloud9.service > /dev/null <<EOF
[Unit]
Description=Cloud9 IDE Native Service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/cloud9
ExecStart=/usr/bin/node $HOME/cloud9/server.js -p $C9_PORT -a $C9_USER:$C9_PASS -w $HOME
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and Start Service
sudo systemctl daemon-reload
sudo systemctl enable cloud9
sudo systemctl restart cloud9

# Final Information
PUBLIC_IP=$(curl -s --max-time 5 ifconfig.me || curl -s --max-time 5 api.ipify.org || echo "YOUR_VPS_IP")

echo "================================================="
echo "🎉 Cloud9 Setup Successfully Completed!"
echo "================================================="
echo "🔗 Access URL : http://${PUBLIC_IP}:${C9_PORT}"
echo "🔑 Username   : ${C9_USER}"
echo "🔑 Password   : ${C9_PASS}"
echo "================================================="
