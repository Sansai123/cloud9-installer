cat << 'EOF' > install-cloud9.sh
#!/bin/bash
set -e

echo "================================================="
echo "🚀 Cloud9 SDK Native + PHP 8.3 Auto-Installer"
echo "   (Fix Ubuntu 24.04 Python 2.7 Compatibility)"
echo "================================================="

echo "[1/6] Installing Python 2.7 Compatibility Layer..."
sudo apt update -y
sudo apt install -y wget curl build-essential make g++ software-properties-common

# Download & Install Python 2.7 packages directly for Ubuntu 24.04
TMP_DIR=$(mktemp -d)
cd $TMP_DIR
wget -q http://archive.ubuntu.com/ubuntu/pool/universe/p/python2.7/libpython2.7-minimal_2.7.18-13ubuntu1.2_amd64.deb
wget -q http://archive.ubuntu.com/ubuntu/pool/universe/p/python2.7/python2.7-minimal_2.7.18-13ubuntu1.2_amd64.deb
wget -q http://archive.ubuntu.com/ubuntu/pool/universe/p/python2.7/libpython2.7-stdlib_2.7.18-13ubuntu1.2_amd64.deb
wget -q http://archive.ubuntu.com/ubuntu/pool/universe/p/python2.7/python2.7_2.7.18-13ubuntu1.2_amd64.deb

sudo dpkg -i *.deb || sudo apt-get install -f -y
cd ~
rm -rf $TMP_DIR

# Set symlink for python -> python2.7
sudo ln -sf /usr/bin/python2.7 /usr/bin/python

echo "[2/6] Installing PHP 8.3..."
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y
sudo apt install -y php8.3 php8.3-cli php8.3-curl php8.3-mbstring php8.3-xml php8.3-zip php8.3-gd php8.3-mysql

echo "[3/6] Installing Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

echo "[4/6] Setting up Cloud9 SDK..."
if [ ! -d "$HOME/cloud9" ]; then
  git clone https://github.com/c9/core.git $HOME/cloud9
fi

echo "[5/6] Running Cloud9 SDK Installer..."
cd $HOME/cloud9
PYTHON=/usr/bin/python2.7 ./scripts/install-sdk.sh

echo "[6/6] Restoring System Python Symlink..."
sudo ln -sf /usr/bin/python3 /usr/bin/python

echo "================================================="
echo "✅ Instalasi Cloud9 & PHP 8.3 Selesai!"
echo "================================================="
EOF

chmod +x install-cloud9.sh
sudo ./install-cloud9.sh
