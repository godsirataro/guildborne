"""Prove this artwork revision changes only the two allocated directories."""
from pathlib import Path
import subprocess,json,hashlib
ROOT=Path(__file__).resolve().parents[4]
BASE='ccd40f063b3111d38fde5a18ac70b732b4d102ce'
PREFIXES=('production/world/quality-slice/ironveil-ore-yard/','assets/production/world-slice/ironveil-ore-yard/')
ADMIN='f7924799eaaefae3199d336052842197e7d3b238'
ADMIN_PATH='production/studio/generated-manifest.json'
def git(*args):return subprocess.check_output(['git',*args],cwd=ROOT).decode().splitlines()
changed=git('diff','--name-only',BASE)+git('ls-files','--others','--exclude-standard')
unexpected=sorted({p for p in changed if not p.startswith(PREFIXES) and p!=ADMIN_PATH})
assert not unexpected,unexpected
assert (ROOT/ADMIN_PATH).read_bytes().replace(b'\r\n',b'\n')==subprocess.check_output(['git','show',ADMIN+':'+ADMIN_PATH],cwd=ROOT).replace(b'\r\n',b'\n')
fixed=['src/shared/Config/WorldQuality.luau','src/server/Services/WorldQualitySlice.luau','src/server/Services/WorldService.luau','src/server/Services/AdventureMapKit.luau','src/server/Services/RegionalWorld.luau','src/shared/Config/City.luau','production/world/quality-slice/greenwood-ironveil/ground.json','production/integration/quality-slice/SECOND_EDGE_NATIVE_01.json']
for p in fixed:
    blob=subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT)
    actual=(ROOT/p).read_bytes()
    assert actual.replace(b'\r\n',b'\n')==blob.replace(b'\r\n',b'\n'),p
print(json.dumps(dict(scope='AUTHORIZED_ART_DIRECTORIES_PLUS_EXACT_APPROVED_ADMIN_DEPENDENCY',baseCommit=BASE,adminDependency=ADMIN,unexpected=unexpected,protectedFilesUnchanged=fixed,changedFiles=len(set(changed)),nativeDockRetestExecuted=False),indent=2))
