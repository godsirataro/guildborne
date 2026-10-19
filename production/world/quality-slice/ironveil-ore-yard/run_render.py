"""Exclusive background Blender only. Never touches existing interactive scenes."""
from pathlib import Path
import subprocess,json,hashlib,time,sys
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
variant=sys.argv[1];assert variant in ('before','after')
OUT=ROOT/'assets/production/world-slice/ironveil-ore-yard'/variant;OUT.mkdir(parents=True,exist_ok=True)
assert not (OUT/'blender-exit.json').exists(),'Preserve historical receipts'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
files=[HERE/'render.py',HERE/'run_render.py',HERE/'cameras.json',HERE/'source-survey.json',ROOT/'assets/production/world-slice/ironveil-ore-yard/scenery.mesh.json',ROOT/'assets/production/world-slice/greenwood-ironveil/scenery.mesh.json',ROOT/'production/world/quality-slice/greenwood-ironveil/ground.json']
before={p.relative_to(ROOT).as_posix():sha(p) for p in files};cmd=['C:/Program Files/Blender Foundation/Blender 5.2/blender.exe','--background','--disable-autoexec','--python-exit-code','2','--python',str(HERE/'render.py'),'--',variant];started=time.monotonic()
with (OUT/'blender-stdout.txt').open('wb') as o,(OUT/'blender-stderr.txt').open('wb') as e:result=subprocess.run(cmd,stdout=o,stderr=e,cwd=ROOT)
receipt=dict(command=cmd,exitCode=result.returncode,seconds=time.monotonic()-started,inputHashes=before,inputsUnchanged=all(sha(ROOT/p)==h for p,h in before.items()),stdoutSha256=sha(OUT/'blender-stdout.txt'),stderrSha256=sha(OUT/'blender-stderr.txt'))
(OUT/'blender-exit.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8');print(json.dumps(receipt,indent=2));assert result.returncode==0 and receipt['inputsUnchanged']
