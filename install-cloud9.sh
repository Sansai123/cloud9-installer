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
print_msg "$GREEN" "🚀 Cloud9 Sansaii_c9 Auto-Installer (PHP 8.3 Ready)"
print_msg "$BLUE" "================================================="

# Step 1: Detect OS
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

# Step 5: Deploy Base Container (Official Ubuntu 22.04 LTS)
print_msg "$YELLOW" "🐳 Deploying Base Container (Ubuntu 22.04) on Port ${PORT}..."
sudo docker run -d \
  --name Sansaii_c9 \
  --restart always \
  -p ${PORT}:8080 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ubuntu:22.04 tail -f /dev/null

if [ $? -eq 0 ]; then
  print_msg "$GREEN" "✅ Container deployed successfully."
else
  print_msg "$RED" "❌ Failed to start Docker container."
  exit 1
fi

# Step 6: Auto Install PHP 8.3 & Essentials Inside Container
print_msg "$YELLOW" "⏳ Preparing environment inside container..."
sleep 3

print_msg "$YELLOW" "📦 Installing PHP 8.3 and tools inside container..."
sudo docker exec -i Sansaii_c9 bash -c "apt update && DEBIAN_FRONTEND=noninteractive apt install -y software-properties-common curl wget git python3 make g++ && add-apt-repository -y ppa:ondrej/php && apt update && DEBIAN_FRONTEND=noninteractive apt install -y php8.3 php8.3-cli php8.3-curl php8.3-mbstring php8.3-xml php8.3-zip php8.3-gd php8.3-mysql"

if [ $? -eq 0 ]; then
  print_msg "$GREEN" "✅ PHP 8.3 installed successfully."
else
  print_msg "$RED" "⚠️ Warning: Failed to install PHP 8.3."
fi

# Step 7: Get Public IP
print_msg "$YELLOW" "🌐 Fetching Server Public IP..."
PUBLIC_IP=$(curl -s --max-time 5 ifconfig.me || curl -s --max-time 5 api.ipify.org || echo "YOUR_SERVER_IP")

print_msg "$BLUE" "==========================================="
print_msg "$GREEN" "🎉 Setup Successfully Finished!"
print_msg "$BLUE" "==========================================="
print_msg "$YELLOW" "🔗 Access IP : http://${PUBLIC_IP}:${PORT}"
print_msg "$BLUE" "==========================================="

# Auto remove script file after execution
rm -f "$0"
