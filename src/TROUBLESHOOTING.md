# Troubleshooting - Dashboard Empty

## Problem: Dashboard stats are empty, no API requests logged

---

## Step 1: Check Service Status

```bash
sudo systemctl status hydepark-sync
```

**Expected:**
```
● hydepark-sync.service - HydePark Sync Service
     Active: active (running)
```

**If not running:**
```bash
sudo systemctl start hydepark-sync
sudo journalctl -u hydepark-sync -n 50
```

---

## Step 2: Check Logs for Errors

```bash
sudo journalctl -u hydepark-sync -n 50 --no-pager
```

**Look for:**
- ❌ `ModuleNotFoundError` - Missing dependencies
- ❌ `ImportError` - Code issue
- ❌ `Exception` - Runtime error
- ❌ `Fatal error` - Configuration issue

**Common errors:**

### Error: "No module named 'schedule'"
```bash
cd /opt/hydepark-sync
source venv/bin/activate
pip install schedule
deactivate
sudo systemctl restart hydepark-sync
```

### Error: "No module named 'face_recognition'"
```bash
cd /opt/hydepark-sync
bash install_requirements.sh
sudo systemctl restart hydepark-sync
```

### Error: Configuration validation failed
```bash
nano /opt/hydepark-sync/.env
# Check all required variables are set
sudo systemctl restart hydepark-sync
```

---

## Step 3: Check if Data Directory Exists

```bash
ls -la /opt/hydepark-sync/data/
```

**Expected:**
```
drwxr-xr-x faces/
drwxr-xr-x id_cards/
-rw-r--r-- workers.json
-rw-r--r-- request_logs.json
```

**If missing:**
```bash
cd /opt/hydepark-sync
mkdir -p data/faces data/id_cards
echo '[]' > data/workers.json
echo '[]' > data/request_logs.json
sudo systemctl restart hydepark-sync
```

---

## Step 4: Check API Request Logs

```bash
cat /opt/hydepark-sync/data/request_logs.json | python3 -m json.tool | tail -50
```

**If empty (`[]`):**
- Sync job is not running
- Exception before API call
- Logger not working

**Debug:**
```bash
# Run sync manually
cd /opt/hydepark-sync
source venv/bin/activate
python3 -c "
from processors.event_processor import EventProcessor
processor = EventProcessor()
processor.process_events()
"
deactivate

# Check logs again
cat data/request_logs.json
```

---

## Step 5: Test Configuration

```bash
cd /opt/hydepark-sync
source venv/bin/activate
python3 test_config.py
deactivate
```

**Expected:**
```
✓ Configuration is valid! You can start the service.
```

**If fails:**
- Fix .env file
- Restart service

---

## Step 6: Check Dashboard

```bash
curl -v http://localhost:8080/login
```

**Expected:**
```
< HTTP/1.1 200 OK
```

**If fails:**
- Dashboard thread crashed
- Port conflict
- Check logs

---

## Step 7: Manual Test Run

```bash
cd /opt/hydepark-sync
source venv/bin/activate

# Test imports
python3 -c "
from config import Config
from processors.event_processor import EventProcessor
from dashboard.app import run_dashboard
print('✓ All imports OK')
"

# Test event processing
python3 -c "
from processors.event_processor import EventProcessor
processor = EventProcessor()
print('✓ EventProcessor initialized')
processor.process_events()
print('✓ Process events completed')
"

deactivate
```

---

## Common Issues

### Issue 1: Service starts then stops immediately

```bash
sudo journalctl -u hydepark-sync -n 100 --no-pager | grep -i error
```

**Fix:** Check for Python errors, missing dependencies, or config issues

---

### Issue 2: Dashboard shows 0 requests but service is running

```bash
# Check if sync job is actually running
sudo journalctl -u hydepark-sync -f
# Wait 60 seconds to see "Starting sync job..."
```

**If no sync messages:**
- Scheduler not starting
- Main thread crashed

**Fix:**
```bash
sudo systemctl restart hydepark-sync
# Watch logs immediately
sudo journalctl -u hydepark-sync -f
```

---

### Issue 3: request_logs.json exists but empty

```bash
# Check file permissions
ls -l /opt/hydepark-sync/data/request_logs.json

# Should be writable
chmod 644 /opt/hydepark-sync/data/request_logs.json
```

---

### Issue 4: Old version deployed

**You need to update!**

```bash
cd ~/Hikcentralhyde/src
sudo systemctl stop hydepark-sync
bash update.sh
sudo systemctl start hydepark-sync
sudo journalctl -u hydepark-sync -f
```

---

## Quick Debug Script

Run this:

```bash
bash /path/to/debug_dashboard.sh
```

---

## Still Not Working?

1. **Collect full logs:**
```bash
sudo journalctl -u hydepark-sync -n 200 --no-pager > ~/hydepark-debug.log
cat /opt/hydepark-sync/data/request_logs.json >> ~/hydepark-debug.log
ls -laR /opt/hydepark-sync/data/ >> ~/hydepark-debug.log
```

2. **Send logs for analysis**

3. **Nuclear option - Reinstall:**
```bash
sudo systemctl stop hydepark-sync
sudo systemctl disable hydepark-sync
sudo rm /etc/systemd/system/hydepark-sync.service
sudo systemctl daemon-reload
sudo rm -rf /opt/hydepark-sync
cd ~/Hikcentralhyde/src
bash deploy.sh
```

---

Good luck! 🚀
