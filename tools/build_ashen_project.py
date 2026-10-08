"""Explicit Chapter00-03 memory-only preview. Keeps other runtime flags unchanged."""
from pathlib import Path
import json,subprocess,hashlib,xml.etree.ElementTree as ET
root=Path(__file__).resolve().parents[1]
main=root/'src/server/Config/Runtime.luau';before=hashlib.sha256(main.read_bytes()).hexdigest()
runtime=(root/'offline/Runtime.luau').read_text(encoding='utf-8')
for flag in ['NoviceJourney','IronveilJourney','AshenJourney']:
 assert flag+'=false' in runtime
 runtime=runtime.replace(flag+'=false',flag+'=true')
(root/'offline/AshenRuntime.luau').write_text(runtime,encoding='utf-8')
project=json.loads((root/'offline.project.json').read_text(encoding='utf-8'));project['name']='Guildborne_AshenPreview'
project['tree']['ServerScriptService']['Server']['Config']['Runtime']['$path']='offline/AshenRuntime.luau'
(root/'ashen.project.json').write_text(json.dumps(project,indent=2)+'\n')
out=root/'build/Guildborne_AshenPreview.rbxlx'
subprocess.run([str(root/'.tools/rojo/rojo.exe'),'build','ashen.project.json','--output',str(out)],cwd=root,check=True)
sources=[]
for props in ET.parse(out).iter('Properties'):
 name=props.find("*[@name='Name']");source=props.find("*[@name='Source']")
 if name is not None and name.text=='Runtime' and source is not None:sources.append(source.text or '')
assert len(sources)==1
assert all(value in sources[0]for value in ['NoviceJourney=true','IronveilJourney=true','AshenJourney=true','StudioPersistence="Memory"','AllowedDataStoreUniverses={}'])
assert hashlib.sha256(main.read_bytes()).hexdigest()==before
print('ASHEN PREVIEW BUILD PASS: explicit memory-only Chapter00-03; other build runtimes unchanged')
