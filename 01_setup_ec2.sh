#!/usr/bin/env bash
# Part 1 - step 2: install Git, Python, Node.js, pm2 on a fresh Amazon Linux 2023 EC2 instance.
# Run as ec2-user:  bash 01_setup_ec2.sh
set -euo pipefail

echo ">> Adding 2 GB swap (helps on small free-tier instances)"
if ! swapon --show | grep -q /swapfile; then
  sudo fallocate -l 2G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
fi

echo ">> Installing Git, Python 3, rsync, curl"
sudo dnf install -y git python3 python3-pip rsync curl

echo ">> Installing Node.js and npm"
sudo dnf install -y nodejs20 nodejs20-npm || sudo dnf install -y nodejs nodejs-npm
if ! command -v node >/dev/null 2>&1 && [ -x /usr/bin/node-20 ]; then
  sudo ln -sf /usr/bin/node-20 /usr/local/bin/node
fi
if ! command -v npm >/dev/null 2>&1 && [ -x /usr/bin/npm-20 ]; then
  sudo ln -sf /usr/bin/npm-20 /usr/local/bin/npm
fi

echo ">> Installing pm2 (process manager)"
sudo npm install -g pm2

echo ">> Versions"
git --version
python3 --version
node --version
npm --version
pm2 --version
