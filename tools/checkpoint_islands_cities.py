from pathlib import Path
import json
r=Path(__file__).resolve().parents[1]
header='> Latest work — 2026-10-06:550domain tests;259runtime sources; Hall-focus EN/TH native input fixed; island directory filters and earned crest/motto projection pass36UIviews/834bounds/18filter transitions and8server projection checks. Six city review layouts now712parts/48no-jump paths; actualSylvaris+Ironroot12destinations,658visible Blender parts/7896triangles/12roundtrip exports. Registry390assets/73screens/33workareas,29generatedPNG. Last quota51%used/49%remaining; continue until25%remaining, then save/stop tests/shutdown per user. Full final-build campaign, imports, persistent/multiplayer/device/human acceptance pending.\n\n'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=r/'docs/uat01'/name;s=p.read_text(encoding='utf-8')
 if not s.startswith('> Latest work — 2026-10-06'):s=header+s
 s=s.replace('Runtime validation is 546 tests','Runtime validation is 550 tests')
 p.write_text(s,encoding='utf-8')
p=r/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
for a in d['assets']:
 if a['status']=='CITY_LAYOUT_REVIEW_ONLY_GAMEPLAY_UNBOUND':
  a['productionBinding']='Six distinct review plans;48native paths;Sylvaris/Ironroot12actual destinations;658visible parts/12FBX-GLB roundtrips; game services and finished terrain unbound'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Island/city progress checkpoint saved')
