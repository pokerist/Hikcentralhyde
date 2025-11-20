#!/usr/bin/env python3
"""
Test HikCentral signature generation against known good example
"""
import hmac
import hashlib
import base64
from urllib.parse import urlparse


def build_string_to_sign(method, accept, content_type, app_key, nonce, timestamp, uri, content_md5=""):
    """Build string to sign according to HikCentral spec"""
    parts = [method, accept]
    
    # Add Content-MD5 only if provided
    if content_md5:
        parts.append(content_md5)
    
    parts.append(content_type)
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

# Parse base URL
parsed = urlparse(base_url)
base_path = parsed.path.rstrip('/') if parsed.path else ''
port = parsed.port

print("=" * 60)
print("HikCentral Signature Test")
print("=" * 60)
print()

# Variant A: path-only
uri_a = f"{base_path}{endpoint}"
string_a = build_string_to_sign(method, accept, content_type, app_key, nonce, timestamp, uri_a)
sig_a = generate_signature(string_a, app_secret)

print('--- Variant A: PATH-ONLY ---')
print(f'URI used for sign: {uri_a}')
print('STRING_TO_SIGN:')
print(string_a)
print()
print('SIGNATURE:')
print(sig_a)
print()

# Variant B: include port (if available)
if port:
    uri_b = f"{base_path}:{port}{endpoint}"
    string_b = build_string_to_sign(method, accept, content_type, app_key, nonce, timestamp, uri_b)
    sig_b = generate_signature(string_b, app_secret)
    
    print('--- Variant B: INCLUDE-PORT ---')
    print(f'URI used for sign: {uri_b}')
    print('STRING_TO_SIGN:')
    print(string_b)
    print()
    print('SIGNATURE:')
    print(sig_b)
    print()

print("=" * 60)
print("Now test with our actual implementation:")
print("=" * 60)
print()

# Test our implementation
try:
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
    test_sig = api._generate_signature(method, uri_a, headers, body)
    
    print(f'Our implementation signature: {test_sig}')
    print(f'Expected signature (Variant A): {sig_a}')
    print()
    
    if test_sig == sig_a:
        print('✅ SIGNATURE MATCHES! (Variant A)')
    elif port and test_sig == sig_b:
        print('✅ SIGNATURE MATCHES! (Variant B)')
    else:
        print('❌ SIGNATURE MISMATCH!')
        print()
        print('Our string_to_sign would be:')
        # Debug: show what our implementation builds
        parts = [method, accept]
        if body:
            md5_hash = hashlib.md5(body.encode('utf-8')).digest()
            content_md5 = base64.b64encode(md5_hash).decode('utf-8')
            parts.append(content_md5)
        parts.append(content_type)
        parts.append(f"x-ca-key:{app_key}")
        parts.append(f"x-ca-nonce:{nonce}")
        parts.append(f"x-ca-timestamp:{timestamp}")
        parts.append(uri_a)
        our_string = '\n'.join(parts)
        print(our_string)

except Exception as e:
    print(f'❌ Error testing implementation: {e}')
    import traceback
    traceback.print_exc()

print()
print("=" * 60)
