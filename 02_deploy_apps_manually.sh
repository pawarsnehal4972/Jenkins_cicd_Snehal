#!/usr/bin/env bash
# Part 1 - steps 3-6: clone both repositories, install dependencies and start them with pm2.
# Usage:
#   FLASK_REPO=https://github.com/<you>/flask-backend.git \
#   EXPRESS_REPO=https://github.com/<you>/express-frontend.git \
#   bash 02_deploy_apps_manually.sh
set -euo pipefail

: "${FLASK_REPO:?Set FLASK_REPO to the Flask GitHub URL}"
: "${EXPRESS_REPO:?Set EXPRESS_REPO to the Express GitHub URL}"

APPS_DIR="$HOME/apps"
mkdir -p "$APPS_DIR"
cd "$APPS_DIR"

echo ">> Flask backend (port 5000)"
[ -d flask-backend ] || git clone "$FLASK_REPO" flask-backend
cd flask-backend
python3 -m venv venv
venv/bin/pip install --upgrade pip
venv/bin/pip install -r requirements.txt
pm2 start ecosystem.config.js
cd "$APPS_DIR"

echo ">> Express frontend (port 3000)"
[ -d express-frontend ] || git clone "$EXPRESS_REPO" express-frontend
cd express-frontend
npm install --omit=dev
pm2 start ecosystem.config.js
cd "$APPS_DIR"

echo ">> Keep apps alive after reboot (pm2 -> systemd)"
pm2 save
sudo env PATH="$PATH:/usr/bin:/usr/local/bin" pm2 startup systemd -u "$USER" --hp "$HOME"
pm2 save

pm2 list
echo ">> Test:  curl http://localhost:5000/api/health   and   curl http://localhost:3000/health"
