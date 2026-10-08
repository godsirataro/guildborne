"""Build a standalone local-only Roblox viewer from reviewed Blender data."""
from pathlib import Path
import json,subprocess
R=Path(__file__).resolve().parents[1];D=R/'build/civic-native-review';G=R/'build/civic-contact-preview-source';(G/'Data').mkdir(parents=True,exist_ok=True)
for identity in ['elian','vaela','borin','nyra','sela','roka']:
 source=(D/(identity+'.json')).read_text(encoding='utf-8');d=json.loads(source);assert len(d['bones'])==16 and len(d['frames'])==181
 (G/'Data'/(identity+'.luau')).write_text('return game:GetService("HttpService"):JSONDecode([==['+source+']==])\n',encoding='utf-8')
for source,target in [('native_civic_contact_review.luau','NativeReview.luau'),('native_civic_effect_review.luau','Effects.luau'),('civic_contact_viewer.client.luau','Viewer.client.luau')]:
 text=(R/'tools'/source).read_text(encoding='utf-8')
 if target=='NativeReview.luau':
  # The deliverable has no network loader; all six data modules are packaged locally.
  text=text.replace('local d=data or Http:JSONDecode(Http:GetAsync("http://127.0.0.1:8769/"..id..".json"))','local d=assert(data,"Packaged art data required")')
  assert 'GetAsync'not in text
 (G/target).write_text(text,encoding='utf-8')
(G/'Boot.server.luau').write_text('game:GetService("Players").CharacterAutoLoads=false\nlocal l=game:GetService("Lighting") l.ClockTime=14 l.Brightness=2 l.Ambient=Color3.fromRGB(145,145,145)\n',encoding='utf-8')
project={'name':'Guildborne_CivicContactArtReview','tree':{'$className':'DataModel','ReplicatedStorage':{'CivicReview':{'NativeReview':{'$path':'civic-contact-preview-source/NativeReview.luau'},'Effects':{'$path':'civic-contact-preview-source/Effects.luau'},'Data':{'$path':'civic-contact-preview-source/Data'}}},'ServerScriptService':{'ReviewBoot':{'$path':'civic-contact-preview-source/Boot.server.luau'}},'StarterPlayer':{'StarterPlayerScripts':{'Viewer':{'$path':'civic-contact-preview-source/Viewer.client.luau'}}}}}
project['tree']['ReplicatedStorage']['CivicReview']['$className']='Folder'
project['tree']['StarterPlayer']['StarterPlayerScripts']['$className']='StarterPlayerScripts'
p=R/'build/civic-contact-preview.project.json';p.write_text(json.dumps(project,indent=2)+'\n',encoding='utf-8')
result=subprocess.run([str(R/'.tools/rojo/rojo.exe'),'build',str(p),'--output',str(R/'build/Guildborne_CivicContactArtReview.rbxlx')],check=True,cwd=R)
print('CIVIC_CONTACT_PREVIEW_BUILT:6packaged datasets; noHTTP loader, persistence, rewards, purchases or live asset IDs.')
