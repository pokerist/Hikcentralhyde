# HydePark Sync - Project Files

## 📦 Core Application Files

### Configuration
- `config.py` - Application configuration (hardcoded, no .env)
- `database.py` - Local JSON database management

### Main Application
- `main.py` - Entry point for the application

### API Clients
- `api/supabase_api.py` - Supabase API client
- `api/hikcentral_api.py` - HikCentral API client

### Processors
- `processors/event_processor.py` - Event processing logic
- `processors/image_processor.py` - Image processing and face recognition

### Dashboard
- `dashboard/app.py` - Flask web application
- `dashboard/auth.py` - Authentication middleware
- `dashboard/templates/` - HTML templates
  - `base.html` - Base template
  - `login.html` - Login page
  - `dashboard.html` - Main dashboard
  - `workers.html` - Workers management
  - `logs.html` - Request logs

### Utilities
- `utils/logger.py` - Logging configuration
- `utils/sanitizer.py` - Input sanitization

### System
- `systemd/hydepark-sync.service` - systemd service file

### Deployment
- `deploy.sh` - Automated deployment script
- `post_deploy_check.sh` - Health check script
- `requirements.txt` - Python dependencies

### Documentation
- `README.md` - Main documentation
- `DEPLOYMENT_NOTES.md` - Deployment details and troubleshooting
- `USAGE.md` - Usage guide
- `DEPLOY_TO_SERVER.md` - Server deployment guide

## 🗂️ Directory Structure (Production)

```
/opt/hydepark-sync/
├── api/
│   ├── supabase_api.py
│   └── hikcentral_api.py
├── processors/
│   ├── event_processor.py
│   └── image_processor.py
├── dashboard/
│   ├── app.py
│   ├── auth.py
│   └── templates/
│       ├── base.html
│       ├── login.html
│       ├── dashboard.html
│       ├── workers.html
│       └── logs.html
├── utils/
│   ├── logger.py
│   └── sanitizer.py
├── systemd/
│   └── hydepark-sync.service
├── data/
│   ├── faces/
│   ├── id_cards/
│   ├── workers.json
│   └── request_logs.json
├── venv/
│   └── (Python virtual environment)
├── main.py
├── config.py
├── database.py
├── requirements.txt
└── post_deploy_check.sh
```

## 🚫 Files NOT Needed in Production

These files are part of the Figma Make environment and NOT part of the HydePark Sync system:

- `App.tsx` - React app (not used)
- `components/` - React components (not used)
- `styles/` - CSS styles (not used)
- `guidelines/` - Figma Make guidelines (not used)
- `Attributions.md` - Figma Make attributions (not used)

**Note:** These files exist in the development environment but are NOT copied during deployment.

## 📋 Files Copied During Deployment

The `deploy.sh` script copies only these files:

```bash
cp -r api $APP_DIR/
cp -r processors $APP_DIR/
cp -r dashboard $APP_DIR/
cp -r utils $APP_DIR/
cp -r systemd $APP_DIR/
cp main.py $APP_DIR/
cp config.py $APP_DIR/
cp database.py $APP_DIR/
cp requirements.txt $APP_DIR/
cp post_deploy_check.sh $APP_DIR/
```

## ✅ File Checklist

Before deployment, ensure these files exist:

- [x] config.py
- [x] main.py
- [x] database.py
- [x] requirements.txt
- [x] deploy.sh
- [x] post_deploy_check.sh
- [x] api/supabase_api.py
- [x] api/hikcentral_api.py
- [x] processors/event_processor.py
- [x] processors/image_processor.py
- [x] dashboard/app.py
- [x] dashboard/auth.py
- [x] dashboard/templates/*.html
- [x] utils/logger.py
- [x] utils/sanitizer.py
- [x] systemd/hydepark-sync.service

---

**Total Python Files:** 15  
**Total HTML Templates:** 5  
**Total Scripts:** 2 (deploy.sh, post_deploy_check.sh)
