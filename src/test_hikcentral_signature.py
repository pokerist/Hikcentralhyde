#!/usr/bin/env python3
"""
Test HikCentral signature generation against known good example
"""
import hmac
import hashlib
import base64
import sys
import os
from urllib.parse import urlparse

# Add src directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))


def build_string_to_sign(method, accept, content_type, app_key, nonce, timestamp, uri, content_md5=""):
    """Build string to sign according to HikCentral spec"""
    parts = [method, accept]
    
    # Add Content-MD5 only if provided
    if content_md5:
        parts.append(content_md5)
    
    parts.append(content_type)
    
    # x-ca headers MUST be in alphabetical order
    parts.append(f"x-ca-key:{app_key}")
    parts.append(f"x-ca-nonce:{nonce}")
    parts.append(f"x-ca-timestamp:{timestamp}")
    
    parts.append(uri)
    
    return '\n'.join(parts)


def generate_signature(string_to_sign, app_secret):
    """Generate HMAC-SHA256 signature"""
    signature = hmac.new(
        app_secret.encode('utf-8'),
        string_to_sign.encode('utf-8'),
        hashlib.sha256
    ).digest()
    return base64.b64encode(signature).decode('utf-8')


# Test data from your example
method = 'POST'
accept = 'application/json'
content_type = 'application/json;charset=UTF-8'
app_key = '22452825'
app_secret = 'Q9bWogAziordVdIngfoa'
nonce = '0049395a-85a5-4991-8240-148dcf3e3612'
timestamp = '1592894521052'
base_url = 'https://10.19.133.55:443/artemis'
endpoint = '/artemis/api/common/v1/version'
body = ''  # No body in example

print("=" * 60)
print("HikCentral Signature Test")
print("=" * 60)
print()
print(f"Base URL: {base_url}")
print(f"Endpoint: {endpoint}")
print()

# The CORRECT URI should be just the endpoint (which already includes /artemis)
correct_uri = endpoint
string_correct = build_string_to_sign(method, accept, content_type, app_key, nonce, timestamp, correct_uri)
sig_correct = generate_signature(string_correct, app_secret)

print('--- CORRECT IMPLEMENTATION ---')
print(f'URI for signature: {correct_uri}')
print('STRING_TO_SIGN:')
print(string_correct)
print()
print('SIGNATURE:')
print(sig_correct)
print()

print("=" * 60)
print("Now test with our actual implementation:")
print("=" * 60)
print()

# Test our implementation
try:
    # Mock the Config to avoid dotenv dependency
    class MockConfig:
        HIKCENTRAL_BASE_URL = base_url
        HIKCENTRAL_APP_KEY = app_key
        HIKCENTRAL_APP_SECRET = app_secret
        HIKCENTRAL_USER_ID = "1"
        HIKCENTRAL_ORG_INDEX_CODE = "test"
        HIKCENTRAL_PRIVILEGE_GROUP_ID = "1"
        HIKCENTRAL_VERIFY_SSL = False
        LOG_API_REQUESTS = False
    
    # Mock the config module
    sys.modules['config'] = type(sys)('config')
    sys.modules['config'].Config = MockConfig
    
    # Mock utils.logger
    class MockLogger:
        """Mock logger for testing"""
        def info(self, msg):
            pass
        def error(self, msg):
            pass
        def warning(self, msg):
            pass
        def debug(self, msg):
            pass
    
    class MockRequestLogger:
        def log_request(self, **kwargs): pass
    
    sys.modules['utils'] = type(sys)('utils')
    sys.modules['utils.logger'] = type(sys)('utils.logger')
    sys.modules['utils.logger'].logger = MockLogger()
    sys.modules['utils.logger'].request_logger = MockRequestLogger()
    
    # Now import our API
    from api.hikcentral_api import HikCentralAPI
    
    api = HikCentralAPI()
    
    # Mock headers
    headers = {
        'X-Ca-Key': app_key,
        'X-Ca-Nonce': nonce,
        'X-Ca-Timestamp': timestamp,
        'Content-Type': content_type,
        'Accept': accept
    }
    
    # Test signature generation
    # In our implementation, we pass the full endpoint path
    test_uri = endpoint  # '/artemis/api/common/v1/version'
    test_sig = api._generate_signature(method, test_uri, headers, body)
    
    print(f'Our implementation signature: {test_sig}')
    print(f'Expected signature: {sig_correct}')
    print()
    
    if test_sig == sig_correct:
        print('✅ SIGNATURE MATCHES!')
        print()
        print('The implementation is correct!')
    else:
        print('❌ SIGNATURE MISMATCH!')
        print()
        print('Debugging info:')
        print(f'Test URI: {test_uri}')
        print()
        print('Our string_to_sign would be:')
        parts = [method, accept]
        if body:
            md5_hash = hashlib.md5(body.encode('utf-8')).digest()
            content_md5 = base64.b64encode(md5_hash).decode('utf-8')
            parts.append(content_md5)
        parts.append(content_type)
        parts.append(f"x-ca-key:{app_key}")
        parts.append(f"x-ca-nonce:{nonce}")
        parts.append(f"x-ca-timestamp:{timestamp}")
        parts.append(test_uri)
        our_string = '\n'.join(parts)
        print(our_string)

except Exception as e:
    print(f'❌ Error testing implementation: {e}')
    import traceback
    traceback.print_exc()

print()
print("=" * 60)
print()
print("IMPORTANT NOTE:")
print("When calling HikCentral API, make sure:")
print("1. base_url = 'https://IP:PORT/artemis'")
print("2. endpoint = '/artemis/api/...' (full path)")
print("3. URL = base_url + endpoint would be wrong!")
print("4. URL should be: 'https://IP:PORT' + endpoint")
print()
print("OR better:")
print("1. base_url = 'https://IP:PORT' (no /artemis)")
print("2. endpoint = '/artemis/api/...' (full path)")
print("3. URL = base_url + endpoint = 'https://IP:PORT/artemis/api/...'")
print("=" * 60)