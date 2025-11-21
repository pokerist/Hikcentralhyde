#!/bin/bash

# HydePark Sync System - Professional Deployment Script
# Zero-config, zero-hassle deployment

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
APP_DIR="/opt/hydepark-sync"
SERVICE_NAME="hydepark-sync"
DASHBOARD_PORT=8080

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   HydePark Sync - Auto Deployment     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
   echo -e "${RED}❌ Don't run as root!${NC}"
   echo "   Run as regular user, script will ask for sudo when needed"
   exit 1
fi

# Function to print step
print_step() {
    echo ""
    echo -e "${GREEN}▶ $1${NC}"
}

# Function to print error and exit
print_error() {
    echo ""
    echo -e "${RED}❌ ERROR: $1${NC}"
    exit 1
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# ============================================
# PRE-FLIGHT CHECKS
# ============================================

print_step "Running pre-flight checks..."

# Check Ubuntu/Debian
if ! command -v apt-get &> /dev/null; then
    print_error "This script requires Ubuntu/Debian (apt-get not found)"
fi

# Check internet connection (for package installation)
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    print_warning "No internet connection detected. Make sure you have local APT mirrors configured."
fi

print_success "Pre-flight checks passed"

# ============================================
# CLEANUP OLD INSTALLATIONS
# ============================================

print_step "Cleaning up any old installations..."

# Stop and disable old service
if systemctl is-active --quiet $SERVICE_NAME 2>/dev/null; then
    sudo systemctl stop $SERVICE_NAME
    print_success "Stopped old service"
fi

if systemctl is-enabled --quiet $SERVICE_NAME 2>/dev/null; then
    sudo systemctl disable $SERVICE_NAME
    print_success "Disabled old service"
fi

# Kill any process on port 8080
if sudo lsof -ti:$DASHBOARD_PORT &> /dev/null; then
    print_warning "Port $DASHBOARD_PORT is in use, killing process..."
    sudo kill -9 $(sudo lsof -ti:$DASHBOARD_PORT) 2>/dev/null || true
    sleep 2
    print_success "Port $DASHBOARD_PORT freed"
fi

# Remove old installation
if [ -d "$APP_DIR" ]; then
    print_warning "Removing old installation..."
    sudo rm -rf $APP_DIR
fi

# Remove old service file
if [ -f "/etc/systemd/system/$SERVICE_NAME.service" ]; then
    sudo rm -f /etc/systemd/system/$SERVICE_NAME.service
    sudo systemctl daemon-reload
fi

print_success "Cleanup complete"

# ============================================
# SYSTEM DEPENDENCIES
# ============================================

print_step "Installing system dependencies..."

sudo apt-get update -qq
sudo apt-get install -y -qq \
    python3 \
    python3-pip \
    python3-venv \
    git \
    cmake \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    lsof \
    net-tools \
    curl \
    > /dev/null 2>&1

print_success "System dependencies installed"

# ============================================
# FIREWALL CONFIGURATION
# ============================================

print_step "Configuring firewall..."

# Check if UFW is installed and active
if command -v ufw &> /dev/null; then
    if sudo ufw status | grep -q "Status: active"; then
        print_warning "UFW is active, opening port $DASHBOARD_PORT..."
        sudo ufw allow $DASHBOARD_PORT/tcp > /dev/null 2>&1
        print_success "Port $DASHBOARD_PORT allowed in UFW"
    else
        print_success "UFW is installed but not active"
    fi
fi

# Check if firewalld is installed and active
if command -v firewall-cmd &> /dev/null; then
    if sudo firewall-cmd --state 2>/dev/null | grep -q "running"; then
        print_warning "firewalld is active, opening port $DASHBOARD_PORT..."
        sudo firewall-cmd --add-port=$DASHBOARD_PORT/tcp --permanent > /dev/null 2>&1
        sudo firewall-cmd --reload > /dev/null 2>&1
        print_success "Port $DASHBOARD_PORT allowed in firewalld"
    else
        print_success "firewalld is installed but not running"
    fi
fi

print_success "Firewall configured"

# ============================================
# APPLICATION INSTALLATION
# ============================================

print_step "Creating application directory..."

sudo mkdir -p $APP_DIR
sudo chown $USER:$USER $APP_DIR
print_success "Application directory created: $APP_DIR"

print_step "Copying application files..."

# Copy all necessary files
cp -r api $APP_DIR/
cp -r processors $APP_DIR/
cp -r dashboard $APP_DIR/
cp -r utils $APP_DIR/
cp -r systemd $APP_DIR/
cp main.py $APP_DIR/
cp config.py $APP_DIR/
cp database.py $APP_DIR/
cp requirements.txt $APP_DIR/
cp post_deploy_check.sh $APP_DIR/ 2>/dev/null || true

print_success "Application files copied"

# ============================================
# PYTHON VIRTUAL ENVIRONMENT
# ============================================

print_step "Setting up Python virtual environment..."

cd $APP_DIR
python3 -m venv venv
source venv/bin/activate

print_step "Installing Python packages (this may take a few minutes)..."

pip install --upgrade pip -q
pip install -r requirements.txt -q

# Install face recognition models separately (they sometimes fail silently)
pip install face_recognition_models -q 2>/dev/null || \
    pip install git+https://github.com/ageitgey/face_recognition_models -q

print_success "Python environment ready"

# ============================================
# DATA DIRECTORIES
# ============================================

print_step "Creating data directories..."

mkdir -p $APP_DIR/data/faces
mkdir -p $APP_DIR/data/id_cards

# Create empty JSON files
echo "[]" > $APP_DIR/data/workers.json
echo "[]" > $APP_DIR/data/request_logs.json

# Set proper permissions
chmod 755 $APP_DIR/data
chmod 755 $APP_DIR/data/faces
chmod 755 $APP_DIR/data/id_cards
chmod 644 $APP_DIR/data/workers.json
chmod 644 $APP_DIR/data/request_logs.json

print_success "Data directories created"

# ============================================
# SYSTEMD SERVICE
# ============================================

print_step "Installing systemd service..."

# Replace user placeholder and install service
sed "s/%i/$USER/g" $APP_DIR/systemd/$SERVICE_NAME.service | \
    sudo tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null

sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME > /dev/null 2>&1

print_success "Service installed and enabled"

# ============================================
# START SERVICE
# ============================================

print_step "Starting service..."

sudo systemctl start $SERVICE_NAME

# Wait for service to start
sleep 3

# Check if service is running
if ! systemctl is-active --quiet $SERVICE_NAME; then
    print_error "Service failed to start! Check logs: sudo journalctl -u $SERVICE_NAME -n 50"
fi

print_success "Service started"

# ============================================
# HEALTH CHECK
# ============================================

print_step "Running health checks..."

# Run the comprehensive health check
if [ -f "$APP_DIR/post_deploy_check.sh" ]; then
    chmod +x "$APP_DIR/post_deploy_check.sh"
    
    # Give service more time to fully initialize
    print_warning "Waiting for service to fully initialize..."
    sleep 5
    
    # Run health check
    bash "$APP_DIR/post_deploy_check.sh"
else
    # Fallback to basic checks
    # Check if port is listening
    MAX_RETRIES=15
    RETRY_COUNT=0
    PORT_READY=false

    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if sudo lsof -i:$DASHBOARD_PORT | grep LISTEN &> /dev/null; then
            PORT_READY=true
            break
        fi
        RETRY_COUNT=$((RETRY_COUNT + 1))
        sleep 1
    done

    if [ "$PORT_READY" = false ]; then
        print_error "Dashboard port $DASHBOARD_PORT is not responding! Check logs: sudo journalctl -u $SERVICE_NAME -n 50"
    fi

    print_success "Port $DASHBOARD_PORT is listening"

    # Try to connect to dashboard
    if command -v curl &> /dev/null; then
        sleep 2
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:$DASHBOARD_PORT | grep -q "200\|302"; then
            print_success "Dashboard is responding"
        else
            print_warning "Dashboard port is open but not responding to HTTP requests yet (may still be initializing)"
        fi
    fi
fi

# ============================================
# FINAL REPORT
# ============================================

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     🎉 Deployment Successful! 🎉       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

# Get IP addresses
echo -e "${BLUE}📡 Access Dashboard:${NC}"
if command -v hostname &> /dev/null; then
    HOSTNAME=$(hostname -I | awk '{print $1}')
    if [ -n "$HOSTNAME" ]; then
        echo "   🌐 http://$HOSTNAME:$DASHBOARD_PORT"
    fi
fi
echo "   🌐 http://localhost:$DASHBOARD_PORT"
echo ""

echo -e "${BLUE}🔐 Login Credentials:${NC}"
echo "   Username: admin"
echo "   Password: 123456"
echo ""

echo -e "${BLUE}📊 Service Status:${NC}"
sudo systemctl status $SERVICE_NAME --no-pager | head -n 5
echo ""

echo -e "${BLUE}📝 Useful Commands:${NC}"
echo "   View logs:      sudo journalctl -u $SERVICE_NAME -f"
echo "   Stop service:   sudo systemctl stop $SERVICE_NAME"
echo "   Start service:  sudo systemctl start $SERVICE_NAME"
echo "   Restart:        sudo systemctl restart $SERVICE_NAME"
echo "   Status:         sudo systemctl status $SERVICE_NAME"
echo ""

echo -e "${BLUE}📂 Application Files:${NC}"
echo "   Directory:      $APP_DIR"
echo "   Config:         $APP_DIR/config.py"
echo "   Data:           $APP_DIR/data/"
echo ""

echo -e "${YELLOW}⚠️  Important Notes:${NC}"
echo "   • Edit config.py to update Supabase/HikCentral settings"
echo "   • Restart service after config changes"
echo "   • Dashboard runs on port $DASHBOARD_PORT"
echo "   • All data stored in $APP_DIR/data/"
echo ""

print_success "System is ready to use!"
echo ""