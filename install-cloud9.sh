#!/bin/bash

# Exit on severe errors
set -e

# Color definitions
GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

print_msg() {
  echo -e "${1}${2}${RESET}"
}

print_msg "$BLUE" "================================================="
print_msg "$GREEN" "🚀 Cloud9 Sansaii_c9 Auto-Installer (PHP 8.x Ready)"
print_msg "$BLUE" "================================================="

# Step 1: Detect OS & Package Manager
print_msg "$YELLOW" "🔍 Detecting System OS..."
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
else
  print_msg "$RED" "❌ Unknown OS. Exiting..."
  exit 1
fi

print_msg "$BLUE" "🖥️ OS Detected: $OS"

# Step 2: Install Prerequisites & Docker Engine
print_msg "$YELLOW" "⚙️ Installing Docker and Required Tools..."

if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
  sudo apt update -y && sudo apt install -y curl wget git docker.io
  sudo systemctl enable --now docker
elif [[ "$OS" == "centos" || "$OS" == "rhel" || "$OS" == "almalinux" || "$OS" == "rocky" || "$OS" == "fedora" ]]; then
  sudo dnf install -y curl wget git docker
  sudo systemctl enable --now docker
else
  print_msg "$RED" "❌ Unsupported Distribution."
  exit 1
fi

if ! command -v docker &> /dev/null; then
  print_msg "$RED" "❌ Docker installation failed."
  exit 1
fi

print_msg "$GREEN" "✅ Docker is running successfully."

# Step 3: Interactive Credentials Prompt
read -p "Enter Cloud9 Username [default: root]: " USERNAME
USERNAME=${USERNAME:-root}

read -p "Enter Cloud9 Password [default: sansai]: " PASSWORD
PASSWORD=${PASSWORD:-sansai}

read -p "Enter Port [default: 8080]: " PORT
PORT=${PORT:-8080}

# Step 4: Cleanup Old Containers
print_msg "$YELLOW" "🧹 Cleaning old Cloud9 containers if present..."
sudo docker stop Sansaii_c9 &>/dev/null || true
sudo docker rm Sansaii_c9 &>/dev/null || true

# Step 5: Deploy Cloud9 Container (Menggunakan Base Image Ubuntu Jammy untuk PHP 8.x)
print_msg "$YELLOW" "🐳 Deploying Cloud9 Container on Port ${PORT}..."
sudo docker run -d \
  --name Sansaii_c9 \
  --restart always \
  -p ${PORT}:8000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e PUID=1000 \
  -e PGID=1000 \
  -e USERNAME=$USERNAME \
  -e PASSWORD=$PASSWORD \
  lscr.io/linuxserver/cloud9:latest

if [ $? -eq 0 ]; then
  print_msg "$GREEN" "✅ Container deployed successfully."
else
  print_msg "$RED" "❌ Failed to start Docker container."
  exit 1
fi

# Step 6: Auto Install PHP 8.x & Python 3 Inside Container
print_msg "$YELLOW" "⏳ Waiting for container to initialize..."
sleep 10

print_msg "$YELLOW" "📦 Installing PHP 8.x, Python 3, and essentials inside Cloud9..."
sudo docker exec -i Sansaii_c9 bash -c "apt update && DEBIAN_FRONTEND=noninteractive apt install -y php php-cli php-curl php-mbstring php-xml php-zip php-gd php-mysql python3 python3-pip git curl wget"

if [ $? -eq 0 ]; then
  print_msg "$GREEN" "✅ PHP 8.x and Python 3 installed successfully."
else
  print_msg "$RED" "⚠️ Warning: Failed to auto-install PHP/Python inside C9."
fi

# Step 7: Get Public IP
print_msg "$YELLOW" "🌐 Fetching Server Public IP..."
PUBLIC_IP=$(curl -s --max-time 5 ifconfig.me || curl -s --max-time 5 api.ipify.org || echo "YOUR_SERVER_IP")

print_msg "$BLUE" "==========================================="
print_msg "$GREEN" "🎉 Cloud9 Setup Successfully Finished!"
print_msg "$BLUE" "==========================================="
print_msg "$YELLOW" "🔗 Access URL : http://${PUBLIC_IP}:${PORT}"
print_msg "$YELLOW" "🔑 Username   : ${USERNAME}"
print_msg "$YELLOW" "🔑 Password   : ${PASSWORD}"
print_msg "$BLUE" "==========================================="

# Auto remove this script file after execution
rm -f "$0"
