from pathlib import Path
import hashlib,json
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
paths=[p for base in [HERE,ROOT/'assets/production/world-slice/corridor-landforms'] for p in base.rglob('*') if p.is_file() and '__pycache__' not in p.parts and p.name!='manifest.json' and p.suffix!='.blend1']
sha={p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(paths)}
(HERE/'manifest.json').write_bytes((json.dumps(dict(baseCommit='3040b67b2cad164c1db9b200a870d8291465caea',status='LOCAL_ART_REVIEW_CANDIDATE',studioImported=False,humanApproved=False,sha256=sha),indent=2)+'\n').encode());print('MANIFEST',len(sha))
