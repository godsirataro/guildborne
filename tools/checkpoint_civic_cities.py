"""Record six earned exploration routes, keeping full-city release gaps explicit."""
from pathlib import Path
from collections import Counter
import json,re
r=Path(__file__).resolve().parents[1]
p=r/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
for a in d['assets']:
 if a['designId'].startswith('world.city_layout.'):
  a['status']='EARNED_EXPLORATION_ROUTE_BOUND_CITY_SERVICES_PENDING'
  a['productionBinding']='200x250stud district; envoy charter gate, fixed landings, city/guild portals. Six native access checks; Crownford actual entry/walk/guild return. Full services, terrain and other city journeys pending.'
  a['productionBinding']+=' See docs/uat01/CIVIC_CITY_TRAVEL.md.'
d['summary'].update(assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header='> Civic city routes checkpoint — 2026-10-06: six quest-gated exploration districts with city/guild portals;42native routes/12landings/18prompts. Actual Crownford locked rejection, earned entry revision10/25Gold,5destinations and guild return; fresh rebuilt ordinary-input city round trip reaches revision11/25Gold with safe-zone banner and clean console.671domain tests;310strict runtime sources;eight builds. Registry445assets/35PNG/29WAV. Tool reconnect reported quota externally changed to0%used/100%remaining; agent did not reset or issue shutdown. Continue to25%remaining. Full city services/terrain, other actual journeys, imports/persistence/multiplayer/devices and human acceptance remain.'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=r/'docs/uat01'/name;s=p.read_text(encoding='utf-8');s=re.sub(r'^> Civic city routes checkpoint[^\n]*\n\n','',s);p.write_text(header+'\n\n'+s,encoding='utf-8')
p=r/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8');s=re.sub(r'Latest observed quota: \d+% used / \d+% remaining\.','Latest observed quota: 0% used / 100% remaining. External change after tool disconnection; no agent reset or shutdown.',s,count=1);p.write_text(s,encoding='utf-8')
print('CHECKPOINT',len(d['assets']))
