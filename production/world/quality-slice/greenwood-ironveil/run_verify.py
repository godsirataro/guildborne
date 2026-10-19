"""Capture immutable raw verifier streams and exit receipt."""
from pathlib import Path
import subprocess,sys,json,hashlib,time
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
out=HERE/'verify.stdout.txt';err=HERE/'verify.stderr.txt';receipt=HERE/'verify-receipt.json'
assert not receipt.exists(),'Do not overwrite retained receipts'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
files=[HERE/'verify_geometry.py',HERE/'build_ground.py',HERE/'ground.json',HERE/'runtime-descriptor.json',ROOT/'assets/production/world-slice/greenwood-ironveil/scenery.mesh.json']
before={p.relative_to(ROOT).as_posix():sha(p) for p in files};start=time.monotonic()
with out.open('wb') as o,err.open('wb') as e:r=subprocess.run([sys.executable,str(HERE/'verify_geometry.py')],stdout=o,stderr=e,cwd=ROOT)
data=dict(exitCode=r.returncode,elapsedSeconds=time.monotonic()-start,inputHashes=before,inputsUnchanged=all(sha(ROOT/k)==v for k,v in before.items()),stdoutSha256=sha(out),stderrSha256=sha(err))
receipt.write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8');print(json.dumps(data,indent=2));assert r.returncode==0 and data['inputsUnchanged']
