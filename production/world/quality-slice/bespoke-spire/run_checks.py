"""Record bounded offline checks, preserving raw streams and exact inputs."""
from pathlib import Path
import subprocess,json,hashlib,time,sys
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
OUT=ROOT/'assets/production/world-slice/bespoke-spire'
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
inputs=[OUT/'scenery.mesh.json',HERE/'recipe.py',HERE/'validate_geometry.py',HERE/'verify_architecture.py',ROOT/'production/world/quality-slice/continuous-corridor/ground.json']
before={p.relative_to(ROOT).as_posix():digest(p) for p in inputs}
results=[]
for name in ['validate_geometry','verify_architecture']:
 command=[sys.executable,str(HERE/(name+'.py'))];start=time.monotonic()
 with (HERE/(name+'-stdout.txt')).open('wb') as out,(HERE/(name+'-stderr.txt')).open('wb') as err:
  result=subprocess.run(command,cwd=ROOT,stdout=out,stderr=err)
 results.append(dict(command=command,exitCode=result.returncode,seconds=time.monotonic()-start,stdoutSha256=digest(HERE/(name+'-stdout.txt')),stderrSha256=digest(HERE/(name+'-stderr.txt'))))
unchanged=all(digest(ROOT/p)==h for p,h in before.items())
report=dict(status='OFFLINE_CHECKS_ONLY',inputs=before,inputsUnchanged=unchanged,results=results,studioTested=False,humanApproved=False)
(HERE/'checks-receipt.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,indent=2));assert unchanged and all(r['exitCode']==0 for r in results)
