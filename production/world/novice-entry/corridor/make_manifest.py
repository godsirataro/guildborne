"""Hash this corridor wave without rewriting historical entry evidence."""
import argparse,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
SOURCE=['review/NoviceRoadKit.luau','src/server/Services/NoviceRoadArt.luau','tests/studio_novice_road_probe.luau','tools/sync_novice_road_art.py','tools/blender_crown_road.py','production/world/novice-entry/render_geometry.py','production/world/novice-entry/capture_geometry.py','production/world/novice-entry/capture_prelude.luau']
parser=argparse.ArgumentParser();parser.add_argument('--verify-index',action='store_true');args=parser.parse_args()
if args.verify_index:
 data=json.loads((HERE/'manifest.json').read_text())
 for path,digest in data['sha256'].items():
  staged=subprocess.check_output(['git','show',':'+path],cwd=ROOT)
  assert hashlib.sha256(staged).hexdigest()==digest,path
 print('STAGED_MANIFEST_MATCH',len(data['sha256']))
else:
 paths=[ROOT/p for p in SOURCE]+[p for p in HERE.rglob('*') if p.is_file() and p.name!='manifest.json' and '__pycache__' not in p.parts]
 hashes={p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(paths)}
 data={'baseCommit':'ef4868b','scope':'novice-entry-art corridor wave','status':'LOCAL_REVIEW_CANDIDATE','studioTested':False,'humanApproved':False,'runtimeAssetIds':None,'sha256':hashes}
 (HERE/'manifest.json').write_bytes((json.dumps(data,indent=2)+'\n').encode());print('MANIFEST',len(hashes))
