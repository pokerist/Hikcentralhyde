# Installation Guide

## Prerequisites

```bash
# Ubuntu 18.04+ with sudo access
# Verify Python 3.8+
python3 --version
```

---

## Install

```bash
# 1. Navigate to source
cd ~/Hikcentralhyde/src

# 2. Run deploy script
bash deploy.sh
```

**During installation:**
- Press `y` to continue
- Press `y` to delete old installation (if exists)
- Press `n` when asked to edit .env (we'll do it next)
- Press `y` to open firewall port
- Press `n` to start service (configure first)

**Installation takes 10-15 minutes** (downloading packages, compiling dlib)

---

## Configure

```bash
# Edit configuration
nano /opt/hydepark-sync/.env
```

**Change these:**
```env
DASHBOARD_PASSWORD=YourSecurePassword123

# If needed:
SUPABASE_URL=https://your-project.supabase.co/...
SUPABASE_BEARER_TOKEN=eyJ...
SUPABASE_API_KEY=your-key
HIKCENTRAL_BASE_URL=https://10.x.x.x/artemis
HIKCENTRAL_APP_KEY=your-key
HIKCENTRAL_APP_SECRET=your-secret
```

Save: `Ctrl+O`, `Enter`, `Ctrl+X`

---

## Start

```bash
# Start service
sudo systemctl start hydepark-sync

# Check status
sudo systemctl status hydepark-sync

# Watch logs
sudo journalctl -u hydepark-sync -f
```

**Expected logs:**
```
HydePark Sync System Starting
Supabase URL: https://...
HikCentral URL: https://10.x.x.x/artemis
Sync Interval: 60 seconds
Dashboard: http://0.0.0.0:8080
Dashboard started successfully
Starting sync job...
SUPABASE GET /admin/events/pending - 200 - XXXms
Fetched 0 pending events
```

---

## Access Dashboard

Open browser: `http://server-ip:8080`

Login:
- Username: `admin`
- Password: (from .env)

---

## Update

```bash
cd ~/Hikcentralhyde/src
bash update.sh
```

---

## Uninstall

```bash
sudo systemctl stop hydepark-sync
sudo systemctl disable hydepark-sync
sudo rm /etc/systemd/system/hydepark-sync.service
sudo systemctl daemon-reload
sudo rm -rf /opt/hydepark-sync
```

---

## Troubleshooting

### Check configuration
```bash
cd /opt/hydepark-sync
source venv/bin/activate
python3 test_config.py
deactivate
```

### Verify setup
```bash
bash /opt/hydepark-sync/verify_setup.sh
```

### View errors
```bash
sudo journalctl -u hydepark-sync -n 50 | grep -i error
```

### Restart service
```bash
sudo systemctl restart hydepark-sync
```

---

Done! 🚀
