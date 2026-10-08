"""Reconcile resumed work with measured UI evidence and original art."""
from pathlib import Path
import json
from collections import Counter
r=Path(__file__).resolve().parents[1]
p=r/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
identity='world.guild.island.arrival.concept'
if not any(a['designId']==identity for a in d['assets']):
 d['assets'].append(dict(designId=identity,group='Guild island',priority='P1',status='CONCEPT_REFERENCE',source='assets/uat01/generated/guildborne-island-arrival-v1.png',productionBinding='Original built-in imagegen island arrival art; visual direction only; import ID and loading-screen binding pending',robloxAssetId=None,uatApproved=False))
d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status']for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
p=r/'assets/uat01/manifest.json';m=json.loads(p.read_text(encoding='utf-8'))
for image in m['images']:
 if image['file'].endswith('guildborne-island-arrival-v1.png'):image['date']='2026-10-06';image['prompt']='assets/uat01/ISLAND_ARRIVAL_PROMPT.md'
p.write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header='> RESUMED — 2026-10-06: user changed stop to25%weeklyremaining and authorized shutdown after saving/stopping tests. Starting50%remaining. Fixed competing scroll restoration/focus callbacks; native synthetic EN/TH J-key Hall11 focus now fully visible (144..196 within128..252), captured clicks only. New original island-arrival image,29PNG;390asset records. Full fresh final-build campaign, imports, persistence, multiplayer/device and human approval remain pending. Historical stop headers below are superseded.\n\n'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=r/'docs/uat01'/name;s=p.read_text(encoding='utf-8')
 if not s.startswith('> RESUMED — 2026-10-06'):s=header+s
 if name=='WORK_CHECKLIST.md':
  lines=s.splitlines()
  for i,line in enumerate(lines):
   if line.startswith('| Tower |'):lines[i]='| Tower | Existing10 combat floors; Chapter04 six-quest world/receipts/checkpoints bound in explicit preview; actual Chapter00-04 run reachesHall11/Lv70,30story claims;6scenes/4cast/20objectives,three support lessons,physical echo,guardian and seals | Full untouched final-build journey; other combat Tower progression, multiplayer/device/persistence and human acceptance |'
  s='\n'.join(lines)+'\n'
 p.write_text(s,encoding='utf-8')
print('Resume checkpoint390assets/29PNGs')
