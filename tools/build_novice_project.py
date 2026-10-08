"""Dedicated incomplete Chapter 00 preview; memory-only, no cloud IDs or allowlist."""
from pathlib import Path
import json,subprocess,hashlib,xml.etree.ElementTree as ET
root=Path(__file__).resolve().parents[1]
main=root/'src/server/Config/Runtime.luau';before=hashlib.sha256(main.read_bytes()).hexdigest()
runtime=(root/'offline/Runtime.luau').read_text(encoding='utf-8')
assert 'NoviceJourney=false' in runtime
(root/'offline/NoviceRuntime.luau').write_text(runtime.replace('NoviceJourney=false','NoviceJourney=true'),encoding='utf-8')
project=json.loads((root/'offline.project.json').read_text(encoding='utf-8'));project['name']='Guildborne_NoviceCoursePreview'
project['tree']['ServerScriptService']['Server']['Config']['Runtime']['$path']='offline/NoviceRuntime.luau'
(root/'novice.project.json').write_text(json.dumps(project,indent=2)+'\n')
out=root/'build/Guildborne_NoviceCoursePreview.rbxlx'
subprocess.run([str(root/'.tools/rojo/rojo.exe'),'build','novice.project.json','--output',str(out)],cwd=root,check=True)
found=[]
for props in ET.parse(out).iter('Properties'):
 name=props.find("*[@name='Name']");source=props.find("*[@name='Source']")
 if name is not None and name.text=='Runtime' and source is not None:found.append(source.text or '')
assert len(found)==1 and 'NoviceJourney=true' in found[0] and 'StudioPersistence="Memory"' in found[0] and 'AllowedDataStoreUniverses={}' in found[0]
assert hashlib.sha256(main.read_bytes()).hexdigest()==before
print('NOVICE PREVIEW BUILD PASS: opt-in memory-only course, staging Runtime unchanged; full journey acceptance tracked separately')
