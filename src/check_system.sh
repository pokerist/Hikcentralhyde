#!/bin/bash

echo "============================================"
echo "System Check"
echo "============================================"

echo ""
echo "1. Service Status:"
sudo systemctl status hydepark-sync --no-pager | head -20

echo ""
echo "2. Last 30 log lines:"
sudo journalctl -u hydepark-sync -n 30 --no-pager

echo ""
echo "3. Data directory:"
ls -lh /opt/hydepark-sync/data/

echo ""
echo "4. Request logs file:"
if [ -f /opt/hydepark-sync/data/request_logs.json ]; then
    echo "File exists:"
    ls -lh /opt/hydepark-sync/data/request_logs.json
    echo ""
    echo "Content (last 5 entries):"
    python3 -c "
import json
try:
    with open('/opt/hydepark-sync/data/request_logs.json', 'r') as f:
        logs = json.load(f)
        print(f'Total logs: {len(logs)}')
        for log in logs[-5:]:
            print(f'{log.get(\"timestamp\", \"?\")} - {log.get(\"api_target\", \"?\")} - {log.get(\"status_code\", \"?\")}')
except Exception as e:
    print(f'Error reading logs: {e}')
"
else
    echo "File not found!"
fi

echo ""
echo "5. Dashboard accessible?"
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/login

echo ""
echo "============================================"
