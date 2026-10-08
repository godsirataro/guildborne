"""Explicit Chapter00-05 memory-only preview; keep other runtime flags unchanged."""
from pathlib import Path
import json,subprocess,hashlib,xml.etree.ElementTree as ET
root=Path(__file__).resolve().parents[1]
main=root/'src/server/Config/Runtime.luau';before=hashlib.sha256(main.read_bytes()).hexdigest()
runtime=(root/'offline/Runtime.luau').read_text(encoding='utf-8')
flags=['NoviceJourney','IronveilJourney','AshenJourney','TowerJourney','CrosshavenJourney']
for flag in flags:
 assert flag+'=false' in runtime
 runtime=runtime.replace(flag+'=false',flag+'=true')
(root/'offline/CrosshavenRuntime.luau').write_text(runtime,encoding='utf-8')
project=json.loads((root/'offline.project.json').read_text(encoding='utf-8'));project['name']='Guildborne_CrosshavenPreview'
project['tree']['ServerScriptService']['Server']['Config']['Runtime']['$path']='offline/CrosshavenRuntime.luau'
(root/'crosshaven.project.json').write_text(json.dumps(project,indent=2)+'\n')
out=root/'build/Guildborne_CrosshavenPreview.rbxlx'
subprocess.run([str(root/'.tools/rojo/rojo.exe'),'build','crosshaven.project.json','--output',str(out)],cwd=root,check=True)
sources=[]
for props in ET.parse(out).iter('Properties'):
 name=props.find("*[@name='Name']");source=props.find("*[@name='Source']")
 if name is not None and name.text=='Runtime' and source is not None:sources.append(source.text or '')
assert len(sources)==1
assert all(flag+'=true' in sources[0]for flag in flags)
assert all(value in sources[0]for value in ['StudioPersistence="Memory"','AllowedDataStoreUniverses={}'])
assert hashlib.sha256(main.read_bytes()).hexdigest()==before
for other in ['Runtime','NoviceRuntime','IronveilRuntime','AshenRuntime','TowerRuntime']:
 assert 'CrosshavenJourney=false' in (root/'offline'/f'{other}.luau').read_text(encoding='utf-8'),other
print('CROSSHAVEN PREVIEW BUILD PASS: explicit memory-only Chapter00-05; all other preview Crosshaven flags disabled')
