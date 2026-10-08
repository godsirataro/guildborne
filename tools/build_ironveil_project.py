"""Explicit full Chapter00-02 memory-only preview; no production cutover."""
from pathlib import Path
import json,subprocess,hashlib,xml.etree.ElementTree as ET
root=Path(__file__).resolve().parents[1]
main=root/'src/server/Config/Runtime.luau';before=hashlib.sha256(main.read_bytes()).hexdigest()
runtime=(root/'offline/Runtime.luau').read_text(encoding='utf-8')
assert 'NoviceJourney=false' in runtime and 'IronveilJourney=false' in runtime
runtime=runtime.replace('NoviceJourney=false','NoviceJourney=true').replace('IronveilJourney=false','IronveilJourney=true')
(root/'offline/IronveilRuntime.luau').write_text(runtime,encoding='utf-8')
project=json.loads((root/'offline.project.json').read_text(encoding='utf-8'));project['name']='Guildborne_IronveilPreview'
project['tree']['ServerScriptService']['Server']['Config']['Runtime']['$path']='offline/IronveilRuntime.luau'
(root/'ironveil.project.json').write_text(json.dumps(project,indent=2)+'\n')
out=root/'build/Guildborne_IronveilPreview.rbxlx'
subprocess.run([str(root/'.tools/rojo/rojo.exe'),'build','ironveil.project.json','--output',str(out)],cwd=root,check=True)
found=[]
for props in ET.parse(out).iter('Properties'):
    name=props.find("*[@name='Name']");source=props.find("*[@name='Source']")
    if name is not None and name.text=='Runtime' and source is not None:found.append(source.text or '')
assert len(found)==1
assert all(text in found[0] for text in ['NoviceJourney=true','IronveilJourney=true','StudioPersistence="Memory"','AllowedDataStoreUniverses={}'])
assert hashlib.sha256(main.read_bytes()).hexdigest()==before
print('IRONVEIL PREVIEW BUILD PASS: explicit memory-only Chapter00-02; production and normal Novice preview unchanged')
