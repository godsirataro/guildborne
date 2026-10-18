from pathlib import Path
import hashlib,json,subprocess
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
paths=[ROOT/p for p in ['src/server/Services/WorldQualitySlice.luau','src/shared/Config/WorldQuality.luau','tests/world_quality.luau']]
paths += [p for base in [HERE,ROOT/'assets/production/world-slice/continuous-corridor'] for p in base.rglob('*') if p.is_file() and '__pycache__' not in p.parts and p.name!='manifest.json']
sha={p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(paths)}
(HERE/'manifest.json').write_bytes((json.dumps(dict(baseCommit='fa9ea00',status='LOCAL_REVIEW_CANDIDATE',studioTested=False,humanApproved=False,sha256=sha),indent=2)+'\n').encode())
print('MANIFEST',len(sha))
