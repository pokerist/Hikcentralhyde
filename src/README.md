# HydePark Sync System

A local synchronization system that bridges an online application (hosted on Supabase) with a HikCentral security system, featuring a comprehensive web-based dashboard for monitoring and troubleshooting.

## Features

### Core Synchronization
- ✅ Bi-directional data sync between Supabase and HikCentral
- ✅ Worker management (create, block, unblock, delete)
- ✅ Facial recognition for duplicate detection
- ✅ Image storage and processing
- ✅ Automatic retry and error handling
- ✅ Complete audit trail

### Web Dashboard
- 🖥️ Real-time monitoring of API requests
- 📊 System statistics and success rates
- 🔍 Advanced filtering and search
- 📥 Export logs as CSV/JSON
- 🔐 Secure authentication
- 📱 Responsive design

### Security
- 🔒 Sensitive data sanitization
- 🛡️ Face recognition for fraud detection
- 🔑 Secure credential management
- 📝 Comprehensive logging with redaction

## System Requirements

- Ubuntu 18.04 or later
- Python 3.8 or later
- LAN access to HikCentral server
- 2GB RAM minimum
- 10GB disk space for images and logs

## Installation

### 1. Clone or Download the Project

```bash
cd /opt
sudo mkdir hydepark-sync
sudo chown $USER:$USER hydepark-sync
cd hydepark-sync
```

### 2. Install System Dependencies

```bash
sudo apt update
sudo apt install -y python3 python3-pip python3-venv
sudo apt install -y build-essential cmake
sudo apt install -y libopenblas-dev liblapack-dev
sudo apt install -y libx11-dev libgtk-3-dev
```

### 3. Create Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate
```

### 4. Install Python Dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

**Note:** Installing `face-recognition` and `dlib` may take several minutes as they compile from source.

### 5. Configure Environment Variables

```bash
cp .env.example .env
nano .env
```

Fill in your actual credentials:

```env
# Supabase Configuration
SUPABASE_BASE_URL=https://xrkxxqhoglrimiljfnml.supabase.co/functions/v1/make-server-2c3121a9
SUPABASE_API_KEY=your_actual_api_key_here
SUPABASE_AUTH_BEARER=your_actual_bearer_token_here

# HikCentral Configuration
HIKCENTRAL_BASE_URL=https://10.127.0.2/artemis
HIKCENTRAL_APP_KEY=your_actual_app_key_here
HIKCENTRAL_APP_SECRET=your_actual_app_secret_here
HIKCENTRAL_USER_ID=admin
HIKCENTRAL_ORG_INDEX_CODE=1
HIKCENTRAL_PRIVILEGE_GROUP_ID=3
HIKCENTRAL_VERIFY_SSL=false

# Dashboard Configuration
DASHBOARD_HOST=0.0.0.0
DASHBOARD_PORT=8080
DASHBOARD_USERNAME=admin
DASHBOARD_PASSWORD=your_secure_password_here
DASHBOARD_SESSION_TIMEOUT=1800
DASHBOARD_LOG_RETENTION_DAYS=30

# System Configuration
SYNC_INTERVAL_SECONDS=60
FACE_SIMILARITY_THRESHOLD=0.6
```

### 6. Test the Application

```bash
python main.py
```

You should see output like:

```
============================================================
HydePark Sync System Starting
============================================================
Supabase URL: https://...
HikCentral URL: https://10.127.0.2/artemis
Sync Interval: 60 seconds
Dashboard: http://0.0.0.0:8080
============================================================
```

Access the dashboard at `http://localhost:8080` (default credentials: admin/admin)

### 7. Install as System Service

Edit the service file to match your setup:

```bash
sudo nano /etc/systemd/system/hydepark-sync.service
```

Update the paths and username:

```ini
[Unit]
Description=HydePark Sync Service
After=network.target

[Service]
Type=simple
User=your_username
WorkingDirectory=/opt/hydepark-sync
Environment="PATH=/opt/hydepark-sync/venv/bin"
ExecStart=/opt/hydepark-sync/venv/bin/python main.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable hydepark-sync
sudo systemctl start hydepark-sync
```

Check status:

```bash
sudo systemctl status hydepark-sync
```

View logs:

```bash
sudo journalctl -u hydepark-sync -f
```

## Dashboard Usage

### Accessing the Dashboard

1. Open your browser and navigate to `http://server-ip:8080`
2. Login with your credentials (default: admin/admin)
3. You'll see the main dashboard with system statistics

### Dashboard Pages

#### 1. Dashboard (Home)
- System overview with key statistics
- Worker counts (total, approved, blocked)
- API request metrics (total, success rate, failed requests)
- Average response times
- Recent API requests

#### 2. Request Logs
- Comprehensive list of all API requests
- Filter by:
  - API target (Supabase/HikCentral)
  - Success/failure status
  - Endpoint
  - Result limit
- View detailed information for each request
- Export logs as CSV or JSON

#### 3. Workers
- View all synced workers
- Filter by status (approved/blocked/deleted)
- See HikCentral person IDs
- Check privilege access status

### Filtering Logs

Use the filter panel to narrow down results:

```
API Target: [All APIs ▼]  Status: [All Status ▼]  
Endpoint: [Filter by endpoint...]  
Limit: [100 results ▼]  
[Filter] [Clear] [Export CSV] [Export JSON]
```

### Viewing Request Details

Click the **Details** button on any log entry to see:

- Complete request information
- Request headers (sensitive data redacted)
- Request body (formatted JSON)
- Response details
- Response body (formatted JSON)
- Error messages (if applicable)

### Exporting Data

- **CSV Export**: Click "Export CSV" to download logs in spreadsheet format
- **JSON Export**: Click "Export JSON" to download logs in JSON format

## Architecture

### Directory Structure

```
hydepark-sync/
├── main.py                     # Entry point
├── config.py                   # Configuration
├── database.py                 # Local JSON database
├── requirements.txt            # Python dependencies
├── .env                        # Environment variables
├── api/
│   ├── supabase_api.py        # Supabase client
│   └── hikcentral_api.py      # HikCentral client
├── processors/
│   ├── event_processor.py     # Event handling
│   └── image_processor.py     # Image processing
├── dashboard/
│   ├── app.py                 # Flask application
│   ├── auth.py                # Authentication
│   └── templates/             # HTML templates
├── utils/
│   ├── logger.py              # Logging system
│   └── sanitizer.py           # Data sanitization
├── data/
│   ├── workers.json           # Workers database
│   ├── request_logs.json      # API logs
│   ├── faces/                 # Face images
│   └── id_cards/              # ID card images
└── systemd/
    └── hydepark-sync.service  # Systemd service
```

### Data Flow

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│  Supabase API   │◄───────►│  HydePark Sync   │◄───────►│  HikCentral API │
│  (Online App)   │         │  (This System)   │         │  (Local LAN)    │
└─────────────────┘         └──────────────────┘         └─────────────────┘
                                     │
                                     ▼
                            ┌─────────────────┐
                            │  Web Dashboard  │
                            │  (Port 8080)    │
                            └─────────────────┘
```

### Event Processing

1. **Poll Events**: System polls Supabase every 60 seconds for pending events
2. **Download Images**: For new workers, download face photo and ID card
3. **Face Recognition**: Check for duplicate faces in local database
4. **Sync to HikCentral**: Add/update/delete person in HikCentral
5. **Update Status**: Report success/failure back to Supabase
6. **Log Everything**: All API requests logged with sanitization

### Supported Event Types

- `worker.created` - New worker added
- `workers.bulk_created` - Multiple workers added
- `worker.blocked` - Worker access blocked
- `unit.workers_blocked` - Multiple workers blocked
- `worker.deleted` - Worker removed
- `user.expired_workers_deleted` - Expired workers cleaned up
- `user.deleted_workers_deleted` - Deleted workers cleaned up
- `worker.unblocked` - Worker access restored
- `unit.workers_unblocked` - Multiple workers unblocked

## Security Considerations

### Data Sanitization

All API requests are logged with sensitive data automatically redacted:

- API keys and tokens
- Passwords and secrets
- National ID numbers (replaced with `***IDNUM***`)
- Phone numbers (replaced with `***PHONE***`)
- Base64-encoded images (replaced with `[BASE64_IMAGE_X_BYTES]`)

### Dashboard Security

- Password-protected access
- Session timeout after 30 minutes of inactivity
- CSRF protection on all forms
- No sensitive data exposed in URLs

### Network Security

- Dashboard binds to all interfaces by default (change `DASHBOARD_HOST` to `127.0.0.1` for local-only access)
- Consider using a reverse proxy (nginx) with HTTPS
- Restrict dashboard access with firewall rules:

```bash
sudo ufw allow from 192.168.1.0/24 to any port 8080
```

## Troubleshooting

### Service Won't Start

Check logs:
```bash
sudo journalctl -u hydepark-sync -n 50
```

Common issues:
- Missing environment variables
- Incorrect file permissions
- Port 8080 already in use

### Face Recognition Not Working

Ensure dlib is installed correctly:
```bash
source venv/bin/activate
python -c "import dlib; print(dlib.__version__)"
```

If fails, reinstall:
```bash
pip uninstall dlib face-recognition
pip install dlib face-recognition
```

### HikCentral Connection Failed

Check network connectivity:
```bash
ping 10.127.0.2
curl -k https://10.127.0.2/artemis/api/system/v1/health
```

Verify SSL settings in `.env`:
```env
HIKCENTRAL_VERIFY_SSL=false
```

### Dashboard Shows No Data

Check if database files exist:
```bash
ls -la data/
```

Should show:
- `workers.json`
- `request_logs.json`

If missing, they will be created automatically on first run.

### High Memory Usage

Reduce log retention:
```env
MAX_REQUEST_LOGS=5000
DASHBOARD_LOG_RETENTION_DAYS=7
```

### Logs Growing Too Large

Run manual cleanup:
```bash
source venv/bin/activate
python -c "from utils.logger import request_logger; request_logger.cleanup_old_logs()"
```

## Maintenance

### Regular Tasks

**Daily:**
- Check dashboard for failed requests
- Review blocked workers

**Weekly:**
- Verify disk space: `df -h`
- Check log file size: `ls -lh hydepark-sync.log`

**Monthly:**
- Update Python packages: `pip install --upgrade -r requirements.txt`
- Review and archive old worker images

### Backup

Backup important data:

```bash
#!/bin/bash
BACKUP_DIR="/backup/hydepark-sync/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# Backup databases
cp data/workers.json $BACKUP_DIR/
cp data/request_logs.json $BACKUP_DIR/

# Backup configuration
cp .env $BACKUP_DIR/

# Backup images (optional, can be large)
# tar -czf $BACKUP_DIR/images.tar.gz data/faces/ data/id_cards/

echo "Backup completed: $BACKUP_DIR"
```

### Monitoring

Set up monitoring alerts:

```bash
# Check if service is running
systemctl is-active hydepark-sync

# Check last successful sync (from logs)
grep "Sync job completed" hydepark-sync.log | tail -1

# Check for errors in last hour
grep ERROR hydepark-sync.log | tail -20
```

## API Reference

### Supabase API Endpoints

**GET /admin/events/pending**
- Fetch pending events
- Parameters: `limit` (default: 100), `type` (optional)

**GET /admin/events/stats**
- Get event statistics

**POST /admin/workers/update-status**
- Update worker status
- Body: `{workerId, status, externalId, blockedReason}`

### HikCentral API Endpoints

**POST /api/resource/v1/person/single/add**
- Add new person

**POST /api/resource/v1/person/single/update**
- Update person information

**POST /api/resource/v1/person/single/delete**
- Delete person

**POST /api/acs/v1/privilege/group/single/addPersons**
- Grant access privileges

**POST /api/acs/v1/privilege/group/single/deletePersons**
- Revoke access privileges

## Support

For issues or questions:

1. Check logs: `sudo journalctl -u hydepark-sync -f`
2. Review dashboard error messages
3. Verify configuration in `.env`
4. Check network connectivity to HikCentral

## License

Proprietary - Internal Use Only

## Changelog

### Version 1.0.0 (2025-01-20)
- Initial release
- Core synchronization functionality
- Web-based dashboard
- Face recognition for duplicate detection
- Comprehensive logging and monitoring
