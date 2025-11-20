#!/bin/bash

# HydePark Sync - Setup Verification Script
# This script verifies that everything is configured correctly

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

INSTALL_DIR="/opt/hydepark-sync"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}HydePark Sync - Setup Verification${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Check if installed
echo -e "${BLUE}1. Checking installation...${NC}"
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${GREEN}✓ Installation directory exists${NC}"
else
    echo -e "${RED}✗ Installation directory not found${NC}"
    echo -e "${YELLOW}  Run: bash deploy.sh${NC}"
    exit 1
fi

# Check .env file
echo -e "\n${BLUE}2. Checking .env file...${NC}"
if [ -f "$INSTALL_DIR/.env" ]; then
    echo -e "${GREEN}✓ .env file exists${NC}"
    
    # Run Python configuration test
    cd "$INSTALL_DIR"
    if [ -f "test_config.py" ]; then
        source venv/bin/activate
        python3 test_config.py
        CONFIG_RESULT=$?
        deactivate
        
        if [ $CONFIG_RESULT -ne 0 ]; then
            echo -e "\n${YELLOW}⚠️  Please fix configuration errors above${NC}"
            exit 1
        fi
    fi
else
    echo -e "${RED}✗ .env file not found${NC}"
    echo -e "${YELLOW}  Copy from: cp $INSTALL_DIR/.env.example $INSTALL_DIR/.env${NC}"
    exit 1
fi

# Check service
echo -e "\n${BLUE}3. Checking systemd service...${NC}"
if systemctl list-unit-files | grep -q "hydepark-sync.service"; then
    echo -e "${GREEN}✓ Service is registered${NC}"
    
    if systemctl is-enabled --quiet hydepark-sync; then
        echo -e "${GREEN}✓ Service is enabled (auto-start)${NC}"
    else
        echo -e "${YELLOW}⚠️  Service is not enabled${NC}"
        echo -e "${YELLOW}  Run: sudo systemctl enable hydepark-sync${NC}"
    fi
    
    if systemctl is-active --quiet hydepark-sync; then
        echo -e "${GREEN}✓ Service is running${NC}"
    else
        echo -e "${RED}✗ Service is not running${NC}"
        echo -e "${YELLOW}  Run: sudo systemctl start hydepark-sync${NC}"
        echo -e "${YELLOW}  Logs: sudo journalctl -u hydepark-sync -n 30${NC}"
    fi
else
    echo -e "${RED}✗ Service not registered${NC}"
    exit 1
fi

# Check network connectivity
echo -e "\n${BLUE}4. Checking network connectivity...${NC}"

# Check Supabase
SUPABASE_URL=$(grep "^SUPABASE_URL=" "$INSTALL_DIR/.env" | cut -d'=' -f2-)
if [ -n "$SUPABASE_URL" ]; then
    SUPABASE_HOST=$(echo "$SUPABASE_URL" | sed -E 's|https?://([^/]+).*|\1|')
    if ping -c 1 -W 2 $SUPABASE_HOST &> /dev/null || curl -s --head --max-time 5 "$SUPABASE_URL" &> /dev/null; then
        echo -e "${GREEN}✓ Can reach Supabase${NC}"
    else
        echo -e "${YELLOW}⚠️  Cannot reach Supabase (might be OK if no internet)${NC}"
    fi
fi

# Check HikCentral
HIKCENTRAL_URL=$(grep "^HIKCENTRAL_BASE_URL=" "$INSTALL_DIR/.env" | cut -d'=' -f2-)
if [ -n "$HIKCENTRAL_URL" ]; then
    HIKCENTRAL_HOST=$(echo "$HIKCENTRAL_URL" | sed -E 's|https?://([^/]+).*|\1|')
    if ping -c 1 -W 2 $HIKCENTRAL_HOST &> /dev/null; then
        echo -e "${GREEN}✓ Can reach HikCentral server${NC}"
    else
        echo -e "${YELLOW}⚠️  Cannot reach HikCentral server${NC}"
        echo -e "${YELLOW}  Make sure server is on LAN: $HIKCENTRAL_HOST${NC}"
    fi
fi

# Check Dashboard port
echo -e "\n${BLUE}5. Checking Dashboard...${NC}"
DASHBOARD_PORT=$(grep "^DASHBOARD_PORT=" "$INSTALL_DIR/.env" | cut -d'=' -f2- | tr -d ' ')
DASHBOARD_PORT=${DASHBOARD_PORT:-8080}

if netstat -tlnp 2>/dev/null | grep ":$DASHBOARD_PORT " &> /dev/null || ss -tlnp 2>/dev/null | grep ":$DASHBOARD_PORT " &> /dev/null; then
    echo -e "${GREEN}✓ Dashboard is listening on port $DASHBOARD_PORT${NC}"
    
    LOCAL_IP=$(hostname -I | awk '{print $1}')
    echo -e "${GREEN}  Access at: http://$LOCAL_IP:$DASHBOARD_PORT${NC}"
else
    echo -e "${YELLOW}⚠️  Dashboard not listening on port $DASHBOARD_PORT${NC}"
    if systemctl is-active --quiet hydepark-sync; then
        echo -e "${YELLOW}  Service is running but dashboard not ready yet${NC}"
        echo -e "${YELLOW}  Wait a few seconds or check logs${NC}"
    fi
fi

# Check firewall
echo -e "\n${BLUE}6. Checking firewall...${NC}"
if command -v ufw &> /dev/null; then
    if ufw status | grep -q "Status: active"; then
        if ufw status | grep -q "$DASHBOARD_PORT"; then
            echo -e "${GREEN}✓ Port $DASHBOARD_PORT is open in firewall${NC}"
        else
            echo -e "${YELLOW}⚠️  Port $DASHBOARD_PORT not open in firewall${NC}"
            echo -e "${YELLOW}  Run: sudo ufw allow $DASHBOARD_PORT/tcp${NC}"
        fi
    else
        echo -e "${BLUE}ℹ Firewall is disabled${NC}"
    fi
else
    echo -e "${BLUE}ℹ UFW not installed${NC}"
fi

# Check disk space
echo -e "\n${BLUE}7. Checking disk space...${NC}"
DISK_USAGE=$(df -h "$INSTALL_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    echo -e "${GREEN}✓ Disk space OK ($DISK_USAGE% used)${NC}"
else
    echo -e "${YELLOW}⚠️  Disk space low ($DISK_USAGE% used)${NC}"
fi

# Check data directories
echo -e "\n${BLUE}8. Checking data directories...${NC}"
if [ -d "$INSTALL_DIR/data" ]; then
    echo -e "${GREEN}✓ Data directory exists${NC}"
    
    WORKERS_COUNT=$(cat "$INSTALL_DIR/data/workers.json" 2>/dev/null | python3 -c "import sys, json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
    echo -e "${BLUE}  Workers in database: $WORKERS_COUNT${NC}"
    
    FACES_COUNT=$(ls -1 "$INSTALL_DIR/data/faces" 2>/dev/null | wc -l)
    echo -e "${BLUE}  Face images stored: $FACES_COUNT${NC}"
else
    echo -e "${YELLOW}⚠️  Data directory missing${NC}"
fi

# Final summary
echo -e "\n${BLUE}========================================${NC}"
if systemctl is-active --quiet hydepark-sync; then
    echo -e "${GREEN}✓ System is ready!${NC}\n"
    
    LOCAL_IP=$(hostname -I | awk '{print $1}')
    echo -e "${BLUE}Dashboard Access:${NC}"
    echo -e "  ${YELLOW}http://$LOCAL_IP:$DASHBOARD_PORT${NC}"
    echo -e "  ${YELLOW}http://localhost:$DASHBOARD_PORT${NC}"
    
    DASHBOARD_USER=$(grep "^DASHBOARD_USERNAME=" "$INSTALL_DIR/.env" | cut -d'=' -f2-)
    echo -e "\n${BLUE}Login Credentials:${NC}"
    echo -e "  Username: ${YELLOW}${DASHBOARD_USER:-admin}${NC}"
    echo -e "  Password: ${YELLOW}(check .env file)${NC}"
    
    echo -e "\n${BLUE}Useful Commands:${NC}"
    echo -e "  View logs: ${YELLOW}sudo journalctl -u hydepark-sync -f${NC}"
    echo -e "  Check status: ${YELLOW}sudo systemctl status hydepark-sync${NC}"
    echo -e "  Restart: ${YELLOW}sudo systemctl restart hydepark-sync${NC}"
else
    echo -e "${YELLOW}⚠️  System needs attention${NC}\n"
    echo -e "${BLUE}Next steps:${NC}"
    echo -e "  1. Fix any errors shown above"
    echo -e "  2. Start service: ${YELLOW}sudo systemctl start hydepark-sync${NC}"
    echo -e "  3. Check logs: ${YELLOW}sudo journalctl -u hydepark-sync -f${NC}"
fi

echo -e "${BLUE}========================================${NC}\n"
