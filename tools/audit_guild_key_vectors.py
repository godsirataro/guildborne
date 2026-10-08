"""Compare native Roblox SHA-256/base64url keys against Python's independent implementation."""
from pathlib import Path
import json, hashlib, base64
root=Path(__file__).resolve().parents[1]
data=json.loads((root/'docs/uat01/validation-guild-provider-native.json').read_text(encoding='utf-8'))
for item in data['hashVectors'].values():
    digest=hashlib.sha256((item['kind']+':'+item['logicalKey']).encode('utf-8')).digest()
    expected='g1:'+base64.urlsafe_b64encode(digest).decode('ascii').rstrip('=')
    assert item['physicalKey']==expected and len(expected)==46
assert data['cacheBypassed'] and data['metadataPreserved'] and data['cancelDidNotWrite']
print('PASS: 4 native key vectors match SHA-256/base64url; 46-character keys.')
