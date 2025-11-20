"""
Configuration management for HydePark sync system
"""
import os
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

class Config:
    """Application configuration"""
    
    # Supabase Configuration
    SUPABASE_BASE_URL = os.getenv('SUPABASE_URL') or os.getenv('SUPABASE_BASE_URL')
    SUPABASE_API_KEY = os.getenv('SUPABASE_API_KEY')
    SUPABASE_AUTH_BEARER = os.getenv('SUPABASE_BEARER_TOKEN') or os.getenv('SUPABASE_AUTH_BEARER')
    
    # HikCentral Configuration
    HIKCENTRAL_BASE_URL = os.getenv('HIKCENTRAL_BASE_URL')
    HIKCENTRAL_APP_KEY = os.getenv('HIKCENTRAL_APP_KEY')
    HIKCENTRAL_APP_SECRET = os.getenv('HIKCENTRAL_APP_SECRET')
    HIKCENTRAL_USER_ID = os.getenv('HIKCENTRAL_USER_ID', 'admin')
    HIKCENTRAL_ORG_INDEX_CODE = os.getenv('HIKCENTRAL_ORG_INDEX_CODE', '1')
    HIKCENTRAL_PRIVILEGE_GROUP_ID = os.getenv('HIKCENTRAL_PRIVILEGE_GROUP_ID', '3')
    HIKCENTRAL_VERIFY_SSL = os.getenv('VERIFY_SSL', 'false').lower() == 'true'
    
    # Dashboard Configuration
    DASHBOARD_HOST = os.getenv('DASHBOARD_HOST', '0.0.0.0')
    DASHBOARD_PORT = int(os.getenv('DASHBOARD_PORT', 8080))
    DASHBOARD_USERNAME = os.getenv('DASHBOARD_USERNAME', 'admin')
    DASHBOARD_PASSWORD = os.getenv('DASHBOARD_PASSWORD', 'admin')
    DASHBOARD_SESSION_TIMEOUT = int(os.getenv('DASHBOARD_SESSION_TIMEOUT', 1800))
    DASHBOARD_LOG_RETENTION_DAYS = int(os.getenv('DASHBOARD_LOG_RETENTION_DAYS', 30))
    
    # Logging Configuration
    LOG_API_REQUESTS = os.getenv('LOG_API_REQUESTS', 'true').lower() == 'true'
    MAX_REQUEST_LOGS = int(os.getenv('MAX_REQUEST_LOGS', 10000))
    
    # System Configuration
    SYNC_INTERVAL_SECONDS = int(os.getenv('SYNC_INTERVAL_SECONDS', 60))
    DATA_DIR = Path(os.getenv('DATA_DIR', './data'))
    FACE_SIMILARITY_THRESHOLD = float(os.getenv('FACE_MATCH_THRESHOLD') or os.getenv('FACE_SIMILARITY_THRESHOLD', '0.8'))
    
    # Data directories
    FACES_DIR = DATA_DIR / 'faces'
    ID_CARDS_DIR = DATA_DIR / 'id_cards'
    WORKERS_DB = DATA_DIR / 'workers.json'
    REQUEST_LOGS_DB = DATA_DIR / 'request_logs.json'
    
    # Secret key for Flask sessions
    SECRET_KEY = os.getenv('SECRET_KEY', 'change-this-secret-key-in-production')
    
    @classmethod
    def ensure_directories(cls):
        """Ensure all required directories exist"""
        cls.DATA_DIR.mkdir(exist_ok=True)
        cls.FACES_DIR.mkdir(exist_ok=True)
        cls.ID_CARDS_DIR.mkdir(exist_ok=True)
    
    @classmethod
    def validate(cls):
        """Validate required configuration"""
        errors = []
        
        if not cls.SUPABASE_BASE_URL:
            errors.append("SUPABASE_URL (or SUPABASE_BASE_URL) is required")
        
        if not cls.SUPABASE_API_KEY and not cls.SUPABASE_AUTH_BEARER:
            errors.append("Either SUPABASE_API_KEY or SUPABASE_BEARER_TOKEN is required")
        
        if not cls.HIKCENTRAL_BASE_URL:
            errors.append("HIKCENTRAL_BASE_URL is required")
        
        if not cls.HIKCENTRAL_APP_KEY:
            errors.append("HIKCENTRAL_APP_KEY is required")
        
        if not cls.HIKCENTRAL_APP_SECRET:
            errors.append("HIKCENTRAL_APP_SECRET is required")
        
        if errors:
            raise ValueError("Configuration errors:\n" + "\n".join(f"  - {e}" for e in errors))
        
        return True