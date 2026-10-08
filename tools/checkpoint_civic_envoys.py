"""Record civic bindings without claiming completed cities or release approval."""
from pathlib import Path
from collections import Counter
import json,re
r=Path(__file__).resolve().parents[1]
header='> Civic envoy checkpoint — 2026-10-06: six city representatives bound in Central City with bilingual dialogue and six optional jobs;37 journal tasks. Native six no-jump approaches and talk ranges pass; actual city_gate/Elian claims reach revision9/25Gold, five other prerequisite dialogues observed. Roka rooftop placement and journal focus fixed/fresh-boot checked.666domain tests;305strict runtime sources;eight builds. Full cities, final art, imports, persistence, multiplayer/device and human acceptance remain. Quota68%used/32%remaining; continue to25%remaining, save/stop owned work, then normal shutdown.'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=r/'docs/uat01'/name;s=p.read_text(encoding='utf-8');s=re.sub(r'^> Civic envoy checkpoint[^\n]*\n\n','',s);p.write_text(header+'\n\n'+s,encoding='utf-8')
p=r/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
for a in d['assets']:
 if a['group']=='City cast':
  a['status']='CENTRAL_CITY_ENVOY_DIALOGUE_QUEST_BOUND_FINAL_ART_PENDING'
  a['productionBinding']='Rigged Central City envoy, EN/TH portrait/dialogue and one optional quest; native approach/talk checks. Full home city, final art/import and human approval pending.'
  if 'docs/uat01/CIVIC_ENVOYS.md' not in a['source']:a['source']+='; docs/uat01/CIVIC_ENVOYS.md'
d['summary'].update(assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8');print('CHECKPOINT',len(d['assets']))
