"""Record verified shared civic services without claiming full city completion."""
from pathlib import Path
import json,re
r=Path(__file__).resolve().parents[1]
p=r/'docs/uat01/intake/registry-reconciled.json'
d=json.loads(p.read_text(encoding='utf-8'))
for a in d['assets']:
 if a['designId']=='ui.civic.local_map':
  a['productionBinding']='Six-city six-target map includes shared Market/Tavern positions; 36 EN/TH views/216 text bounds verified. Actual Crownford market and tavern Scout using earned Gold; other city/device journeys pending.'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header='> Civic services checkpoint — 2026-10-06: six cities bind Market/Tavern; guild-only tavern upgrade hint. Native48paths/12landings/36prompts,36map views/216bounds,120tavern views/4confirmation cases. Fresh ordinary-input Crownford: earned25Gold, Scout20Gold ->5Gold/Archer/revision11; insufficient-funds controls disabled.672domain tests/311strict runtime sources/eight builds. Registry452assets/35PNG/29WAV. Quota3%used/97%remaining; stop at25%remaining then save/stop owned work and normal shutdown. Final city content/art, other actual city/device journeys, imports/persistence/multiplayer remain.'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=r/'docs/uat01'/name;s=p.read_text(encoding='utf-8');s=re.sub(r'^> Civic services checkpoint[^\n]*\n\n','',s);p.write_text(header+'\n\n'+s,encoding='utf-8')
p=r/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8');s=re.sub(r'Latest observed quota: \d+% used / \d+% remaining\.','Latest observed quota: 3% used / 97% remaining.',s,count=1);p.write_text(s,encoding='utf-8')
print('CHECKPOINT',len(d['assets']))
