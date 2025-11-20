#!/usr/bin/env python3
"""
Test configuration script
Run this to verify your .env file is correctly configured
"""

import os
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def print_status(check_name, value, is_ok):
    """Print colored status"""
    status = "✓" if is_ok else "✗"
    color = "\033[92m" if is_ok else "\033[91m"
    reset = "\033[0m"
    masked_value = "***" if value and len(str(value)) > 10 else str(value)
    print(f"{color}{status}{reset} {check_name}: {masked_value if is_ok else 'MISSING'}")

def main():
    print("\n" + "="*60)
    print("HydePark Sync - Configuration Test")
    print("="*60 + "\n")
    
    all_ok = True
    
    # Supabase Configuration
    print("📡 Supabase Configuration:")
    print("-" * 40)
    
    supabase_url = os.getenv('SUPABASE_URL') or os.getenv('SUPABASE_BASE_URL')
    print_status("SUPABASE_URL", supabase_url, bool(supabase_url))
    if not supabase_url:
        all_ok = False
    
    supabase_key = os.getenv('SUPABASE_API_KEY')
    print_status("SUPABASE_API_KEY", supabase_key, bool(supabase_key))
    
    supabase_bearer = os.getenv('SUPABASE_BEARER_TOKEN') or os.getenv('SUPABASE_AUTH_BEARER')
    print_status("SUPABASE_BEARER_TOKEN", supabase_bearer, bool(supabase_bearer))
    
    if not supabase_key and not supabase_bearer:
        print("  ⚠️  Warning: Need either SUPABASE_API_KEY or SUPABASE_BEARER_TOKEN")
        all_ok = False
    
    print()
    
    # HikCentral Configuration
    print("🏢 HikCentral Configuration:")
    print("-" * 40)
    
    hikcentral_url = os.getenv('HIKCENTRAL_BASE_URL')
    print_status("HIKCENTRAL_BASE_URL", hikcentral_url, bool(hikcentral_url))
    if not hikcentral_url:
        all_ok = False
    
    hikcentral_key = os.getenv('HIKCENTRAL_APP_KEY')
    print_status("HIKCENTRAL_APP_KEY", hikcentral_key, bool(hikcentral_key))
    if not hikcentral_key:
        all_ok = False
    
    hikcentral_secret = os.getenv('HIKCENTRAL_APP_SECRET')
    print_status("HIKCENTRAL_APP_SECRET", hikcentral_secret, bool(hikcentral_secret))
    if not hikcentral_secret:
        all_ok = False
    
    hikcentral_user = os.getenv('HIKCENTRAL_USER_ID', 'admin')
    print_status("HIKCENTRAL_USER_ID", hikcentral_user, True)
    
    hikcentral_org = os.getenv('HIKCENTRAL_ORG_INDEX_CODE', '1')
    print_status("HIKCENTRAL_ORG_INDEX_CODE", hikcentral_org, True)
    
    hikcentral_privilege = os.getenv('HIKCENTRAL_PRIVILEGE_GROUP_ID', '3')
    print_status("HIKCENTRAL_PRIVILEGE_GROUP_ID", hikcentral_privilege, True)
    
    verify_ssl = os.getenv('VERIFY_SSL', 'false')
    print_status("VERIFY_SSL", verify_ssl, True)
    
    print()
    
    # Dashboard Configuration
    print("🖥️  Dashboard Configuration:")
    print("-" * 40)
    
    dashboard_host = os.getenv('DASHBOARD_HOST', '0.0.0.0')
    print_status("DASHBOARD_HOST", dashboard_host, True)
    
    dashboard_port = os.getenv('DASHBOARD_PORT', '8080')
    print_status("DASHBOARD_PORT", dashboard_port, True)
    
    dashboard_user = os.getenv('DASHBOARD_USERNAME', 'admin')
    print_status("DASHBOARD_USERNAME", dashboard_user, True)
    
    dashboard_pass = os.getenv('DASHBOARD_PASSWORD', 'admin')
    is_default_password = dashboard_pass == 'admin' or dashboard_pass == 'change_this_password_immediately'
    print_status("DASHBOARD_PASSWORD", dashboard_pass, not is_default_password)
    if is_default_password:
        print("  ⚠️  Warning: Using default password! Please change it.")
        all_ok = False
    
    print()
    
    # System Configuration
    print("⚙️  System Configuration:")
    print("-" * 40)
    
    sync_interval = os.getenv('SYNC_INTERVAL_SECONDS', '60')
    print_status("SYNC_INTERVAL_SECONDS", sync_interval, True)
    
    face_threshold = os.getenv('FACE_MATCH_THRESHOLD', '0.8')
    print_status("FACE_MATCH_THRESHOLD", face_threshold, True)
    
    data_dir = os.getenv('DATA_DIR', './data')
    print_status("DATA_DIR", data_dir, True)
    
    print()
    
    # Summary
    print("="*60)
    if all_ok:
        print("✓ Configuration is valid! You can start the service.")
        print("\nNext steps:")
        print("  1. sudo systemctl restart hydepark-sync")
        print("  2. sudo systemctl status hydepark-sync")
        print(f"  3. Open http://your-server-ip:{dashboard_port}")
        return 0
    else:
        print("✗ Configuration has errors! Please fix them in .env file.")
        print("\nTo edit:")
        print("  nano /opt/hydepark-sync/.env")
        print("  (or nano .env if running from source directory)")
        return 1

if __name__ == '__main__':
    exit(main())
