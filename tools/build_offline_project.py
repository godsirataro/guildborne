"""Separate full-game local playtest; never edits the staging Runtime module."""
from pathlib import Path
import json,subprocess,hashlib,xml.etree.ElementTree as ET
root=Path(__file__).resolve().parents[1]
runtime=root/'src/server/Config/Runtime.luau'
before=hashlib.sha256(runtime.read_bytes()).hexdigest()
project=json.loads((root/'default.project.json').read_text(encoding='utf-8'))
project['name']='Guildborne_OfflinePlaytest'
project.pop('servePlaceIds',None)
server=project['tree']['ServerScriptService']['Server']
server.clear();server['$className']='Folder'
for path in sorted((root/'src/server').iterdir()):
 if path.name=='Config':
  server['Config']={'$className':'Folder',**{p.stem:{'$path':p.relative_to(root).as_posix()} for p in sorted(path.glob('*.luau'))}}
  server['Config']['Runtime']={'$path':'offline/Runtime.luau'}
 elif path.is_dir():server[path.name]={'$path':path.relative_to(root).as_posix()}
 elif path.suffix=='.luau':server[path.name.removesuffix('.luau').removesuffix('.server').removesuffix('.client')]={'$path':path.relative_to(root).as_posix()}
(root/'offline.project.json').write_text(json.dumps(project,indent=2)+'\n',encoding='utf-8')
subprocess.run([str(root/'.tools/rojo/rojo.exe'),'build','offline.project.json','--output','build/Guildborne_OfflinePlaytest.rbxlx'],cwd=root,check=True)
assert hashlib.sha256(runtime.read_bytes()).hexdigest()==before,'Staging configuration changed'
xml=ET.parse(root/'build/Guildborne_OfflinePlaytest.rbxlx')
found=[]
for item in xml.iter('Item'):
 props=item.find('Properties')
 if props is None:continue
 name=props.find("*[@name='Name']")
 if name is not None and name.text=='Runtime':
  source=props.find("*[@name='Source']")
  if source is not None:found.append(source.text or '')
assert len(found)==1 and 'StudioPersistence="Memory"' in found[0]
assert 'AllowedDataStoreUniverses={}' in found[0] and '10768425213' not in found[0]
def scripts(file):
 result={}
 def walk(node,path=()):
  for item in node.findall('Item'):
   props=item.find('Properties');name=props.find("*[@name='Name']") if props is not None else None
   current=path+(name.text if name is not None else item.get('class'),)
   source=props.find("*[@name='Source']") if props is not None else None
   if source is not None:result[current]=source.text
   walk(item,current)
 walk(ET.parse(file).getroot());return result
main=scripts(root/'build/Guildborne.rbxlx');offline=scripts(root/'build/Guildborne_OfflinePlaytest.rbxlx')
assert main.keys()==offline.keys(),'Runtime module inventory differs'
changed=[key for key in main if main[key]!=offline[key]]
assert changed==[('ServerScriptService','Server','Config','Runtime')],changed
report={
 'place':'build/Guildborne_OfflinePlaytest.rbxlx',
 'runtimeScriptCount':len(offline),
 'changedSourcePaths':['/'.join(key) for key in changed],
 'runtimeModuleCount':len(found),
 'studioPersistence':'Memory',
 'cloudAllowlistEmpty':True,
 'stagingRuntimeSha256':before,
 'stagingRuntimeUnchanged':True,
 'placeSha256':hashlib.sha256((root/'build/Guildborne_OfflinePlaytest.rbxlx').read_bytes()).hexdigest(),
 'runtimeAcceptance':'Separate evidence required; build comparison does not prove gameplay',
}
(root/'docs/uat01/validation-offline-build.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print('OFFLINE BUILD PASS: full runtime, memory-only Studio configuration, no cloud allowlist, staging source unchanged')
