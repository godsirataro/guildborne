"""Run one owned Blender render with immutable-input checks and raw logs."""
from pathlib import Path
import argparse,subprocess,json,hashlib,time
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
parser=argparse.ArgumentParser();parser.add_argument('--variant',choices=['before','after'],required=True);args=parser.parse_args()
OUT=ROOT/'assets/production/world-slice/coast-prop-composition'/args.variant
assert not (OUT/'blender-exit.json').exists(), 'Never overwrite a receipt'
OUT.mkdir(parents=True,exist_ok=True)
packet=ROOT/('assets/production/world-slice/bespoke-spire/scenery.mesh.json' if args.variant=='before' else 'assets/production/world-slice/coast-prop-composition/scenery.mesh.json')
inputs=[packet,HERE/'render_compare.py',HERE/'cameras.json',ROOT/'production/world/quality-slice/continuous-corridor/ground.json']
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
before={p.relative_to(ROOT).as_posix():digest(p) for p in inputs}
command=['C:/Program Files/Blender Foundation/Blender 5.2/blender.exe','--background','--disable-autoexec','--python-exit-code','2','--python',str(HERE/'render_compare.py'),'--','--variant',args.variant]
started=time.monotonic()
with (OUT/'blender-stdout.txt').open('wb') as out,(OUT/'blender-stderr.txt').open('wb') as err:
 result=subprocess.run(command,cwd=ROOT,stdout=out,stderr=err)
unchanged=all(digest(ROOT/p)==h for p,h in before.items())
receipt=dict(command=command,exitCode=result.returncode,seconds=time.monotonic()-started,inputHashes=before,inputsUnchanged=unchanged,stdoutSha256=digest(OUT/'blender-stdout.txt'),stderrSha256=digest(OUT/'blender-stderr.txt'))
(OUT/'blender-exit.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
print(json.dumps(receipt,indent=2));assert result.returncode==0 and unchanged
