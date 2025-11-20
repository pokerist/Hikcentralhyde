#!/bin/bash

echo "============================================"
echo "Dashboard Debug Script"
echo "============================================"

echo ""
echo "1. Check if service is running:"
if systemctl is-active --quiet hydepark-sync; then
    echo "✓ Service is running"
else
    echo "✗ Service is NOT running"
    exit 1
fi

echo ""
echo "2. Check logs for errors:"
echo "Last 20 lines:"
sudo journalctl -u hydepark-sync -n 20 --no-pager

echo ""
echo "3. Check if API requests are being logged:"
if [ -f /opt/hydepark-sync/data/request_logs.json ]; then
    COUNT=$(python3 -c "import json; f=open('/opt/hydepark-sync/data/request_logs.json'); logs=json.load(f); print(len(logs))")
    echo "Total logged requests: $COUNT"
    
    if [ "$COUNT" = "0" ]; then
        echo "⚠️  WARNING: No API requests logged!"
        echo ""
        echo "Possible issues:"
        echo "  1. Sync job not running"
        echo "  2. Exception before API call"
        echo "  3. Logger not initialized"
    else
        echo "✓ API requests are being logged"
        echo ""
        echo "Last 3 requests:"
        python3 -c "
import json
with open('/opt/hydepark-sync/data/request_logs.json') as f:
    logs = json.load(f)
    for log in logs[-3:]:
        print(f'  {log[\"timestamp\"][:19]} - {log[\"api_target\"]} - {log[\"method\"]} - {log[\"status_code\"]}')
"
    fi
else
    echo "✗ request_logs.json not found!"
fi

echo ""
echo "4. Test dashboard connection:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/login)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ Dashboard is accessible (HTTP $HTTP_CODE)"
else
    echo "✗ Dashboard returned HTTP $HTTP_CODE"
fi

echo ""
echo "5. Check Python process:"
ps aux | grep "python.*main.py" | grep -v grep

echo ""
echo "============================================"
echo "Quick Fix Commands:"
echo "============================================"
echo "# Restart service:"
echo "sudo systemctl restart hydepark-sync"
echo ""
echo "# Watch live logs:"
echo "sudo journalctl -u hydepark-sync -f"
echo ""
echo "# Test configuration:"
echo "cd /opt/hydepark-sync && source venv/bin/activate && python3 test_config.py"
echo "============================================"
