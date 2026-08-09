cat << 'EOF' > install-cloud9.sh
#!/bin/bash
set -e

# =================================================
# KELOLA AKSES LOGIN DI SINI
# =================================================
C9_USER="root"
C9_PASS="Sansai26"  # Ubah password ini sesuai kebutuhan
C9_PORT="8080"
WORKSPACE_DIR="$HOME/workspace"

echo "================================================="
echo "🚀 Cloud9 SDK Auto-Installer (Python 3 + Password)"
echo "================================================="

echo "[1/5] Menginstal dependensi & Python 3..."
sudo apt update -y
sudo apt install -y build-essential g++ make python3 python3-pip git curl php8.3 php8.3-cli php8.3-curl php8.3-mbstring php8.3-xml php8.3-zip php8.3-gd php8.3-mysql

echo "[2/5] Menginstal Node.js & node-gyp (Dukungan Kompilasi Python 3)..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g node-gyp@latest

echo "[3/5] Mengunduh Cloud9 SDK..."
if [ ! -d "$HOME/cloud9" ]; then
  git clone https://github.com/c9/core.git $HOME/cloud9
fi

echo "[4/5] Memasang Cloud9 SDK dengan Python 3..."
cd $HOME/cloud9
export PYTHON=/usr/bin/python3
npm config set python /usr/bin/python3
./scripts/install-sdk.sh

mkdir -p "$WORKSPACE_DIR"

echo "[5/5] Memasang Cloud9 sebagai System Service (Autostart + Password)..."
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
echo "✅ Instalasi Selesai & Service Berhasil Dijalankan!"
echo "-------------------------------------------------"
echo "Akses URL : http://<IP-Server-Anda>:$C9_PORT"
echo "Username  : $C9_USER"
echo "Password  : $C9_PASS"
echo "================================================="
EOF

chmod +x install-cloud9.sh
./install-cloud9.sh
