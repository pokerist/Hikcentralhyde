#!/bin/bash

# HydePark Sync System - Complete Deployment Script
# This script installs everything from scratch

set -e

echo "================================"
echo "HydePark Sync - Auto Deployment"
echo "================================"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
   echo "❌ Please run as regular user (not root)"
   echo "   The script will ask for sudo when needed"
   exit 1
fi

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}[1/6] Installing system dependencies...${NC}"
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv git cmake build-essential

echo ""
echo -e "${GREEN}[2/6] Creating application directory...${NC}"
sudo mkdir -p /opt/hydepark-sync
sudo chown $USER:$USER /opt/hydepark-sync

echo ""
echo -e "${GREEN}[3/6] Copying application files...${NC}"
# Copy all Python files and directories
cp -r api /opt/hydepark-sync/
cp -r processors /opt/hydepark-sync/
cp -r dashboard /opt/hydepark-sync/
cp -r utils /opt/hydepark-sync/
cp -r systemd /opt/hydepark-sync/
cp main.py /opt/hydepark-sync/
cp config.py /opt/hydepark-sync/
cp database.py /opt/hydepark-sync/
cp requirements.txt /opt/hydepark-sync/

echo ""
echo -e "${GREEN}[4/6] Setting up Python virtual environment...${NC}"
cd /opt/hydepark-sync
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

echo ""
echo -e "${GREEN}[5/6] Creating data directories...${NC}"
mkdir -p /opt/hydepark-sync/data/faces
mkdir -p /opt/hydepark-sync/data/id_cards
echo "[]" > /opt/hydepark-sync/data/workers.json
echo "[]" > /opt/hydepark-sync/data/request_logs.json

echo ""
echo -e "${GREEN}[6/6] Installing systemd service...${NC}"
# Replace %i with current user in service file
sed "s/%i/$USER/g" /opt/hydepark-sync/systemd/hydepark-sync.service | sudo tee /etc/systemd/system/hydepark-sync.service > /dev/null
sudo systemctl daemon-reload
sudo systemctl enable hydepark-sync
sudo systemctl start hydepark-sync

echo ""
echo "================================"
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo "================================"
echo ""
echo "Service Status:"
sudo systemctl status hydepark-sync --no-pager
echo ""
echo "Useful Commands:"
echo "  • View logs:    sudo journalctl -u hydepark-sync -f"
echo "  • Stop service: sudo systemctl stop hydepark-sync"
echo "  • Restart:      sudo systemctl restart hydepark-sync"
echo "  • Dashboard:    http://YOUR_IP:8080"
echo "                  Username: admin"
echo "                  Password: 123456"
echo ""
echo -e "${YELLOW}⚠️  Dashboard is running on port 8080${NC}"
echo ""