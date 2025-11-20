# HydePark Sync System

Local synchronization bridge between Supabase (online) and HikCentral (offline LAN).

**Clean Installation** - This version automatically cleans old installations before deploying.

---

## Quick Install

```bash
cd ~/Hikcentralhyde/src
bash deploy.sh
```

The deploy script will:
- Stop and backup any existing installation
- Clean old files (preserving data/ and .env)
- Install fresh version
- Restore your data and configuration

Follow prompts. Edit `.env` after installation if needed.

---

## Requirements

- Ubuntu 18.04+
- Python 3.8+
- 2GB RAM, 10GB disk
- LAN access to HikCentral
- Internet access to Supabase

---

## Configuration

Edit `/opt/hydepark-sync/.env`:

```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co/functions/v1/your-function
SUPABASE_BEARER_TOKEN=eyJ...
SUPABASE_API_KEY=your-api-key

# HikCentral (use IP:PORT format, /artemis will be added automatically)
HIKCENTRAL_BASE_URL=https://10.127.0.2
HIKCENTRAL_APP_KEY=your-app-key
HIKCENTRAL_APP_SECRET=your-secret

# Dashboard
DASHBOARD_PASSWORD=change-this-password
```

---

## Commands

```bash
# Status
sudo systemctl status hydepark-sync

# Logs
sudo journalctl -u hydepark-sync -f

# Restart
sudo systemctl restart hydepark-sync

# Update
cd ~/Hikcentralhyde/src && bash update.sh
```

---

## Dashboard

Access: `http://server-ip:8080`
- Username: `admin`
- Password: (from .env)

---

## How It Works

1. **Polling**: Every 60s, fetch pending events from Supabase
2. **Processing**: 
   - `worker.created` → Add to HikCentral + grant access
   - `worker.blocked` → Revoke access
   - `worker.deleted` → Delete from HikCentral
   - `worker.unblocked` → Restore access
3. **Sync**: Update worker status back to Supabase
4. **Face Recognition**: Detect duplicate faces (fraud prevention)

---

## Directory Structure

```
/opt/hydepark-sync/
├── main.py                 # Entry point
├── config.py               # Configuration
├── database.py             # Local JSON database
├── .env                    # Configuration (DO NOT COMMIT)
├── api/
│   ├── supabase_api.py     # Supabase client
│   └── hikcentral_api.py   # HikCentral client
├── processors/
│   ├── event_processor.py  # Event handling logic
│   └── image_processor.py  # Face recognition
├── dashboard/              # Web dashboard
├── data/
│   ├── faces/              # Downloaded face images
│   ├── id_cards/           # Downloaded ID cards
│   ├── workers.json        # Worker database
│   └── request_logs.json   # API logs
└── venv/                   # Python virtual environment
```

---

## Troubleshooting

```bash
# Test configuration
cd /opt/hydepark-sync
source venv/bin/activate
python3 test_config.py
deactivate

# Verify setup
bash /opt/hydepark-sync/verify_setup.sh

# Check specific error
sudo journalctl -u hydepark-sync -n 100 --no-pager | grep -i error
```

---

## API Documentation

See `API_DOCS.md` for Supabase and HikCentral API details.

---

## License

Proprietary - HydePark Project