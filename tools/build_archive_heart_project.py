"""Explicit Chapter00-06 memory-only preview; never enables staging or cloud data."""
from pathlib import Path
import json,subprocess,hashlib,xml.etree.ElementTree as ET
root=Path(__file__).resolve().parents[1]
main=root/'src/server/Config/Runtime.luau';before=hashlib.sha256(main.read_bytes()).hexdigest()
runtime=(root/'offline/Runtime.luau').read_text(encoding='utf-8')
flags=['NoviceJourney','IronveilJourney','AshenJourney','TowerJourney','CrosshavenJourney','ArchiveHeartJourney']
for flag in flags:
 assert flag+'=false' in runtime
 runtime=runtime.replace(flag+'=false',flag+'=true')
(root/'offline/ArchiveHeartRuntime.luau').write_text(runtime,encoding='utf-8')
project=json.loads((root/'offline.project.json').read_text(encoding='utf-8'));project['name']='Guildborne_ArchiveHeartPreview'
project['tree']['ServerScriptService']['Server']['Config']['Runtime']['$path']='offline/ArchiveHeartRuntime.luau'
(root/'archive-heart.project.json').write_text(json.dumps(project,indent=2)+'\n',encoding='utf-8')
out=root/'build/Guildborne_ArchiveHeartPreview.rbxlx'
subprocess.run([str(root/'.tools/rojo/rojo.exe'),'build','archive-heart.project.json','--output',str(out)],cwd=root,check=True)
sources=[]
for props in ET.parse(out).iter('Properties'):
 name=props.find("*[@name='Name']");source=props.find("*[@name='Source']")
 if name is not None and name.text=='Runtime' and source is not None:sources.append(source.text or '')
assert len(sources)==1 and all(flag+'=true' in sources[0]for flag in flags)
assert all(value in sources[0]for value in ['StudioPersistence="Memory"','AllowedDataStoreUniverses={}'])
assert hashlib.sha256(main.read_bytes()).hexdigest()==before
for other in ['Runtime','NoviceRuntime','IronveilRuntime','AshenRuntime','TowerRuntime','CrosshavenRuntime']:
 assert 'ArchiveHeartJourney=false' in (root/'offline'/f'{other}.luau').read_text(encoding='utf-8'),other
print('ARCHIVE HEART PREVIEW BUILD PASS: explicit memory-only Chapter00-06; all other previews disabled for ArchiveHeart')
